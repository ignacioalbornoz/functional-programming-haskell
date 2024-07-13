#lang play
(print-only-errors #t)

(require "env.rkt")
(require "core-base.rkt")


#| SL: Surface Language

<SL> ::= <num>
         | {+ <SL> <SL>}
         | {if0 <SL> <SL> <SL>}
         | {with {<sym> <SL>} <SL>}
         | <id>
         | {<SL> <SL>}
         | {fun {<sym> : <mtype>} → <mtype> : <SL>}  ;; note el uso de mtype (tipos con modificadores)
         | {printn <SL>}


|#
(deftype SL         
  ; los constructores empiezan con 's' para diferenciar con el AST de CL
  ; tp es el tipo de cada nodo
  (snum tp n)
  (sadd tp l r)
  (sif0 tp c t f)
  (swith tp x e b)
  (sfun tp p b)
  (sprintn tp e)
  (sid tp s)
  (sapp tp f e))


#|
<mtype> ::= {<mod> <type>} ; tipo con modificador
         | <type>          ; azúcar para evaluación temprana
|#
(deftype mType
  (Modtype m t)
  (Eagertype t))

#|
<mod> ::= lazy   ; call-by-need / lazy
        | name   ; call-by-name

|#
(deftype Mod
  (eager)
  (lazy)
  (name))


#|<type> ::= Num
         | {<mtype> -> <mtype>}
|#
(deftype Type
  (TNum)
  (MNum m n)
  (TFun dom cod))

; sl-type : SL -> Type
; accesor polimórfico a la info de tipo de una expr
(define (sl-type sl)
  (match sl
    [(snum tp _) tp]
    [(sadd tp _ _) tp]
    [(sif0 tp _ _ _) tp]
    [(swith tp _ _ _) tp]
    [(sfun tp _ _) tp]
    [(sprintn tp _) tp]
    [(sid tp _) tp]
    [(sapp tp _ _) tp]))

; parse-sl : s-expr -> SL
; parsea expresiones SL
(define (parse-sl s-expr)
  (begin (print "test1") (print s-expr) (print "test2")
  (match s-expr
    [(? number?) (snum #f s-expr)]
    [(? symbol?) (sid #f s-expr)]
    [(list '+ l r) (sadd #f (parse-sl l) (parse-sl r))]
    [(list 'if0 c t f) (sif0 #f (parse-sl c) (parse-sl t) (parse-sl f))]
    [(list 'with (list x e) b) (swith #f x (parse-sl e) (parse-sl b))]
    [(list 'printn e) (sprintn #f (parse-sl e))]
    ;;[(list 'fun t (list x) b) (begin (print t) (print "end-t") (print x) (print "end-x") (print b) (print "end-b") (sfun (parse-type t) x (parse-sl b)))]
    [(list 'fun (list x ': t) '-> c ': b) (print "test3")(print b)(print "test4") (sfun (parse-mtype (list t '-> c)) x (parse-sl b))]
    [(list 'fun a) (parse-mtype2 a)]
    [(list f a) (sapp #f (parse-sl f) (parse-sl a))])))


(define (parse-mtype2 s-expr)
  (match s-expr
    ['Num (TNum) (MNum (eager) (TNum))]
    [(list 'lazy 'Num) (MNum (lazy) (TNum))]
    [(list 'name 'Num) (MNum (name) (TNum))]
    [(list t1 '-> t2) (TFun (parse-mtype t1) (parse-mtype t2))]))


(define (parse-mtype s-expr)
  (match s-expr
    ['Num (TNum) (MNum (eager) (TNum))]
    [(list 'lazy 'Num) (MNum (lazy) (TNum))]
    [(list 'name 'Num) (MNum (name) (TNum))]
    [(list t1 '-> t2) (TFun (parse-mtype t1) (parse-mtype t2))]))


(define (parse-type s-expr)
  (match s-expr
    ['Num (TNum)]
    [(list t1 '-> t2) (TFun (parse-type t1) (parse-type t2))]))

; type->str : Type -> String
; representación en string de un tipo
(define (type->str t)
  (match t
    [(TNum) "Num"]
    [(TFun t1 t2) (string-append "{" (type->str t1)
                                 " -> " (type->str t2) "}")]))

; check-type : Type Type -> Void
; falla si los dos tipos no son iguales
(define (check-type expected actual)
  (when (not (equal? expected actual))  ; when es como un if con una sola rama (si la condicion es falsa no evalua nada)
    (error (format "type error: expected ~a, got ~a"
                   (type->str expected) (type->str actual)))))

; check-function-type : Type -> Void
; falla si el tipo no es un tipo función
(define (check-function-type t)
  (when (not (TFun? t))
    (error (format "type error: expected a function type, got ~a"
                   (type->str t)))))

; tipo num por defecto (usado por type-ast)
(define tnum (TNum))

; type-ast : SL Env -> SL
; retorna el ast decorado con tipos (o falla si la expr no es válida)
; se usa Env como un ambiente de tipos (mapea identificadores a tipos)
(define (type-ast expr tenv)
  (match expr 
    [(snum _ n) (snum tnum n)]
    
    [(sadd _ l r) (def tl (type-ast l tenv))
                  (def tr (type-ast r tenv))
                  (check-type tnum (sl-type tl))
                  (check-type tnum (sl-type tr))
                  (sadd tnum tl tr)]

    [(sfun t x b)  (check-function-type t)
                   (def tb (type-ast b (extend-env x (TFun-dom t) tenv)))
                   (check-type (TFun-cod t) (sl-type tb))
                   (sfun t x tb)]
    
    [(sid _ x) (sid (env-lookup x tenv) x)]

    [(sapp _ f a) (def tf (type-ast f tenv))
                  (def t (sl-type tf))
                  (check-function-type t)
                  (def ta (type-ast a tenv))
                  (check-type (TFun-dom t) (sl-type ta))
                  (sapp (TFun-cod t) tf ta)]

    [(swith _ x e b) (def te (type-ast e tenv))
                     (def tb (type-ast b (extend-env x (sl-type te) tenv)))
                     (swith (sl-type tb) x te tb)]

    [(sif0 _ c t f) (def tc (type-ast c tenv))
                    (check-type tnum (sl-type tc))
                    (def tt (type-ast t tenv))
                    (def tf (type-ast f tenv))
                    (check-type (sl-type tt) (sl-type tf))
                    (sif0 (sl-type tt) tc tt tf)]

    [(sprintn _ e) (def te (type-ast e tenv))
                   (check-type tnum (sl-type te))
                   (sprintn tnum te)]))
    

; transform : SL -> CL
; transforma un programa SL a un programa CL equivalente
; ignora la información de tipo, y traduce un `with` a un aplicación de lambda
(define (transform expr)
  (match expr
    [(snum _ n)      (num n)]
    [(sid _ x)       (id x)]
    [(swith _ x e b) (app (fun x (transform b)) (transform e))]
    [(sadd _ l r)    (add (transform l) (transform r))]
    [(sif0 _ c t f)  (if0 (transform c) (transform t) (transform f))]
    [(sfun _ x b)    (fun x (transform b))]
    [(sapp _ f a)    (app (transform f) (transform a))]
    [(sprintn _ e)   (printn (transform e))])) 


(define (run-sl prog)
  (interp-top (transform (type-ast (parse-sl prog) empty-env))))




(parse-sl '{with {f {fun {x : {lazy Num}} -> Num : 1}}   
                     {f {printn 10}}})





#|
(parse-sl '{with {f {fun {x : Num} -> Num : {+ x x}}}   
                     {f {printn 10}}}) 


(parse-sl '{with {f {fun {x : {lazy Num}} -> Num : {+ x x}}}   
                     {f {printn 10}}})

(parse-sl '{with {f {fun {x : {name Num}} -> Num : {+ x x}}} 
                     {f {printn 10}}})


(parse-sl '{with {f {fun {x : {lazy Num} -> Num : 1}}}   
                     {f {printn 10}}})


|#













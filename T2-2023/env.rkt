#lang play

(deftype Env
  (mtEnv)
  (aEnv id val env))
 
(def empty-env  (mtEnv))
 
(def extend-env aEnv)
 
(define (env-lookup x env)
  (match env
    [(mtEnv) (error 'env-lookup "free identifier: ~a" x)]
    [(aEnv id val rest)
     (if (symbol=? id x)
         val
         (env-lookup x rest))]))
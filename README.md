
# Functional Programming

## Introducción
Este proyecto contiene materiales y ejercicios de programación funcional en el lenguaje Racket, organizados por trimestres. El objetivo es ayudar a los estudiantes a aprender y practicar conceptos clave de la programación funcional.

## Estructura del Proyecto
El repositorio está organizado en varias carpetas:

- **T1/**: Materiales y ejercicios del primer trimestre.
- **T2-2023/**: Materiales y ejercicios del segundo trimestre de 2023.
- **T3/**: Materiales y ejercicios del tercer trimestre.

### Archivos Principales
- **.gitignore**: Lista de archivos y directorios que Git debe ignorar.
- **LICENSE**: Licencia del proyecto bajo AGPL-3.0.
- **README.md**: Este archivo.

## Instalación
Para ejecutar los ejemplos y ejercicios de este repositorio, sigue estos pasos:

1. Clona el repositorio:
   ```bash
   git clone https://github.com/ignacioalbornoz/functional-programming.git
   cd functional-programming
   ```

2. Instala Racket siguiendo las instrucciones de la [página oficial](https://racket-lang.org/).

## Uso
Cada carpeta contiene archivos `.rkt` que puedes ejecutar con Racket. A continuación se detallan los contenidos de cada carpeta:

### T1/
Contiene ejercicios y ejemplos básicos de programación funcional en Racket.

- **archivo1.rkt**: Describe cómo definir funciones simples y aplicar recursión.
  ```racket
  (define (suma x y)
    (+ x y))
  ```
- **archivo2.rkt**: Introduce el uso de listas y patrones de diseño funcional.
  ```racket
  (define (longitud lst)
    (if (null? lst)
        0
        (+ 1 (longitud (cdr lst)))))
  ```

### T2-2023/
Contiene ejercicios y ejemplos avanzados de programación funcional, incluyendo conceptos de orden superior y composición.

- **archivo3.rkt**: Ejemplo de uso de funciones de orden superior.
  ```racket
  (define (aplicar-dos-veces f x)
    (f (f x)))
  ```
- **archivo4.rkt**: Uso de cierres y funciones anónimas.
  ```racket
  (define (generar-suma n)
    (lambda (x) (+ x n)))
  ```

### T3/
Contiene proyectos y ejercicios finales integradores de programación funcional.

- **archivo5.rkt**: Implementación de una pequeña librería funcional.
  ```racket
  (define (mapear f lst)
    (if (null? lst)
        '()
        (cons (f (car lst)) (mapear f (cdr lst)))))
  ```
- **archivo6.rkt**: Ejercicio de procesamiento de listas con funciones puras.
  ```racket
  (define (filtrar pred lst)
    (cond
      [(null? lst) '()]
      [(pred (car lst)) (cons (car lst) (filtrar pred (cdr lst)))]
      [else (filtrar pred (cdr lst))]))
  ```

## Contribución
Si deseas contribuir a este proyecto, sigue estos pasos:

1. Haz un fork del repositorio.
2. Crea una rama para tu contribución:
   ```bash
   git checkout -b mi-nueva-rama
   ```
3. Realiza tus cambios y commitea:
   ```bash
   git commit -am 'Agrega nueva funcionalidad'
   ```
4. Envía tus cambios al repositorio original:
   ```bash
   git push origin mi-nueva-rama
   ```
5. Crea un Pull Request.

## Licencia
Este proyecto está licenciado bajo la AGPL-3.0. Para más detalles, consulta el archivo [LICENSE](LICENSE).

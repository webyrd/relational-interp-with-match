(load "interp-with-variadic-lambda-and-map-and-match.scm")
(load "mk/test-check.scm")
(load "mk/matche.scm")

;; Use a Scheme interpreter, written in Scheme using higher-order
;; representation of procedures and environments, running in a
;; relational Scheme interpreter, to generate quines and (I love you)
;; expressions.


;; Helper Scheme predicate for testing
(define member? (lambda (x ls) (not (not (member x ls)))))


;; map tests

(test "match-0"
  (run* (q) (eval-expo '(map (lambda (x) x) (list 3 4 5)) '() q))
  '((3 4 5)))

(test "match-1"
  (run* (q) (eval-expo '(map (lambda (x) 6) (list 3 4 5)) '() q))
  '((6 6 6)))

(test "match-2"
  (run* (q) (eval-expo '(map (lambda (x) (cons x x)) (list 3 4 5)) '() q))
  '(((3 . 3) (4 . 4) (5 . 5))))



(test "Scheme-interpreter-list-map-1"
  (run 1 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(list . ,e*)
                     (map (lambda (e) (eval-expr e env)) e*)]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr '(list '3 '4 '5)
                   (lambda (y) ((lambda (z) z)))))
     '()
     q))
  '((3 4 5)))

;; 25 collections
;; 3819 ms elapsed cpu time, including 18 ms collecting
;; 3819 ms elapsed real time, including 19 ms collecting
;; 211716736 bytes allocated
(test "Scheme-interpreter-list-cons-love-1"
  (run 10 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(cons ,e1 ,e2)
                     (cons (eval-expr e1 env) (eval-expr e2 env))]
                    [`(list . ,e*)
                     (map (lambda (e) (eval-expr e env)) e*)]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     '(I love you)))
  '('(I love you)
    (cons 'I '(love you))
    (list 'I 'love 'you)
    (cons 'I (cons 'love '(you)))
    (cons 'I (list 'love 'you))
    (cons 'I (cons 'love (cons 'you '())))
    (((lambda (_.0) '(I love you)) '_.1) (=/= ((_.0 closure)))
     (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) '_.1) '(love you))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (cons 'I (cons 'love (list 'you)))
    (((lambda (_.0) _.0) '(I love you)) (=/= ((_.0 closure)))
     (sym _.0))))

;; 30 collections
;; 6202 ms elapsed cpu time, including 33 ms collecting
;; 6206 ms elapsed real time, including 33 ms collecting
;; 252558864 bytes allocated
(test "Scheme-interpreter-list-cons-love-no-map-1b"
  ;; list implemented with letrec rather than with map
  (run 10 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(cons ,e1 ,e2)
                     (cons (eval-expr e1 env) (eval-expr e2 env))]
                    [`(list . ,e*)
                     (letrec ((loop (lambda (e*)
                                      (if (null? e*)
                                          '()
                                          (cons (eval-expr (car e*) env) (loop (cdr e*)))))))
                       (loop e*))]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     '(I love you)))
  '('(I love you)
    (cons 'I '(love you))
    (cons 'I (cons 'love '(you)))
    (list 'I 'love 'you)
    (cons 'I (cons 'love (cons 'you '())))
    (((lambda (_.0) '(I love you)) '_.1) (=/= ((_.0 closure)))
     (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) '_.1) '(love you))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) _.0) '(I love you)) (=/= ((_.0 closure)))
     (sym _.0))
    (cons 'I (list 'love 'you))
    ((cons ((lambda (_.0) 'I) '_.1) (cons 'love '(you)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))))

;; 441 collections
;; 244419 ms elapsed cpu time, including 1782 ms collecting
;; 244804 ms elapsed real time, including 1787 ms collecting
;; 3693675840 bytes allocated
(test "Scheme-interpreter-list-cons-love-2"
  (run 99 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(cons ,e1 ,e2)
                     (cons (eval-expr e1 env) (eval-expr e2 env))]
                    [`(list . ,e*)
                     (map (lambda (e) (eval-expr e env)) e*)]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     '(I love you)))
  '('(I love you)
    (cons 'I '(love you))
    (list 'I 'love 'you)
    (cons 'I (cons 'love '(you)))
    (cons 'I (list 'love 'you))
    (cons 'I (cons 'love (cons 'you '())))
    (((lambda (_.0) '(I love you)) '_.1) (=/= ((_.0 closure)))
     (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) '_.1) '(love you))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (cons 'I (cons 'love (list 'you)))
    (((lambda (_.0) _.0) '(I love you)) (=/= ((_.0 closure)))
     (sym _.0))
    ((cons ((lambda (_.0) 'I) '_.1) (cons 'love '(you)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) _.0) 'I) '(love you))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (cons 'I '(love you))) '_.1)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) '_.1) (list 'love 'you))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) '(I love you)) (list))
     (=/= ((_.0 closure))) (sym _.0))
    (cons 'I (cons 'love (cons 'you (list))))
    ((cons ((lambda (_.0) _.0) 'I) (cons 'love '(you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) '_.1) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (cons 'I _.0)) '(love you))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) '(I love you)) (lambda (_.1) _.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) (cons _.0 '(love you))) 'I)
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) 'I) '_.1)
           (cons 'love (cons 'you '())))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) '(I love you)) (cons '_.1 '_.2))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2)))
    ((cons ((lambda (_.0) 'I) '_.1) (cons 'love (list 'you)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (cons 'I '(love you))) (list))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) _.0) 'I) (list 'love 'you))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) _.0) 'I) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I ((lambda (_.0) '(love you)) '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (list 'I 'love 'you)) '_.1)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I 'love ((lambda (_.0) 'you) '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I ((lambda (_.0) 'love) '_.1) 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons 'I (cons ((lambda (_.0) 'love) '_.1) '(you)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (cons 'I (cons 'love '(you)))) '_.1)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) _.0) (cons 'I '(love you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) _.0) 'I)
           (cons 'love (cons 'you '())))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I ((lambda (_.0) _.0) '(love you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) 'I) (list)) '(love you))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (cons 'I '(love you))) (lambda (_.1) _.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((cons ((lambda (_.0) 'I) '_.1)
           (cons 'love (cons 'you (list))))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I 'love ((lambda (_.0) _.0) 'you))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I
           (cons ((lambda (_.0) 'love) '_.1) (cons 'you '())))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) _.0) 'I) (cons 'love (list 'you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) 'I) (list)) (cons 'love '(you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I (cons ((lambda (_.0) 'love) '_.1) (list 'you)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (list _.0 'love 'you)) 'I)
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (list 'I 'love _.0)) 'you)
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I ((lambda (_.0) _.0) 'love) 'you)
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I (cons ((lambda (_.0) _.0) 'love) '(you)))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (cons 'I (cons 'love _.0))) '(you))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I ((lambda (_.0) (cons 'love '(you))) '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (list 'I _.0 'you)) 'love)
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (cons 'I (cons _.0 '(you)))) 'love)
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (cons _.0 (cons 'love '(you)))) 'I)
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (list 'I 'love 'you)) (list))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I ((lambda (_.0) '(love you)) (list)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I
           (cons ((lambda (_.0) 'love) '_.1) (cons 'you (list))))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) '(love you)) '_.3))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((cons ((lambda (_.0) 'I) (list)) (list 'love 'you))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (cons 'I '(love you))) (cons '_.1 '_.2))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2)))
    ((list 'I 'love ((lambda (_.0) 'you) (list)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I (list 'love ((lambda (_.0) 'you) '_.1)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (cons 'I (cons 'love '(you)))) (list))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I (list ((lambda (_.0) 'love) '_.1) 'you))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (cons 'I (list 'love 'you))) '_.1)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons 'I
           (cons ((lambda (_.0) _.0) 'love) (cons 'you '())))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) 'I) (lambda (_.1) _.2)) '(love you))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((cons 'I ((lambda (_.0) (cons 'love _.0)) '(you)))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) '(I love you)) (list '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) '_.1)
           (cons ((lambda (_.2) 'love) '_.3) '(you)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((cons ((lambda (_.0) _.0) 'I)
           (cons 'love (cons 'you (list))))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I ((lambda (_.0) '(love you)) (lambda (_.1) _.2)))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((cons 'I ((lambda (_.0) (cons _.0 '(you))) 'love))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) (list)) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I (cons ((lambda (_.0) _.0) 'love) (list 'you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) 'you) '_.3))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) 'love) '_.3) 'you)
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((cons ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) _.2) '(love you)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    ((list 'I 'love ((lambda (_.0) 'you) (lambda (_.1) _.2)))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((cons ((lambda (_.0) 'I) (list))
           (cons 'love (cons 'you '())))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I (list 'love ((lambda (_.0) _.0) 'you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I ((lambda (_.0) (list 'love 'you)) '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) (lambda (_.1) _.2))
           (cons 'love '(you)))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((cons ((lambda (_.0) 'I) '_.1)
           (cons ((lambda (_.2) 'love) '_.3) (cons 'you '())))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) 'you) '_.3))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) _.2) 'you))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    ((cons 'I ((lambda (_.0) '(love you)) (cons '_.1 '_.2)))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2)))
    ((cons 'I ((lambda (_.0) (cons 'love '(you))) (list)))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (cons 'I _.0)) (cons 'love '(you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) 'I) '_.1)
           (cons ((lambda (_.2) 'love) '_.3) (list 'you)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((cons 'I (list ((lambda (_.0) _.0) 'love) 'you))
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I 'love ((lambda (_.0) 'you) (cons '_.1 '_.2)))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2)))
    ((cons ((lambda (_.0) 'I) (list)) (cons 'love (list 'you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons ((lambda (_.0) 'I) '_.1)
           (cons ((lambda (_.2) _.2) 'love) '(you)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    ((cons 'I
           (cons ((lambda (_.0) _.0) 'love) (cons 'you (list))))
     (=/= ((_.0 closure))) (sym _.0))
    ((cons 'I (cons 'love ((lambda (_.0) '(you)) '_.1)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((cons ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) (cons 'love '(you))) '_.3))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) _.2) 'you))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    (((lambda (_.0) (cons 'I (cons 'love (cons 'you '()))))
      '_.1)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list ((lambda (_.0) 'I) '_.1) ((lambda (_.2) _.2) 'love)
           'you)
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))))

;; 29 collections
;; 6299 ms elapsed cpu time, including 23 ms collecting
;; 6301 ms elapsed real time, including 23 ms collecting
;; 241978816 bytes allocated
(test "Scheme-interpreter-list-love-1"
  (run 10 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(list . ,e*)
                     (map (lambda (e) (eval-expr e env)) e*)]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     '(I love you)))
  '('(I love you)
    (list 'I 'love 'you)
    (((lambda (_.0) '(I love you)) '_.1) (=/= ((_.0 closure)))
     (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) _.0) '(I love you)) (=/= ((_.0 closure)))
     (sym _.0))
    (((lambda (_.0) '(I love you)) (list))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) '_.1) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) '(I love you)) (lambda (_.1) _.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) (list 'I 'love 'you)) '_.1)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I 'love ((lambda (_.0) 'you) '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I ((lambda (_.0) 'love) '_.1) 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))))

;; 51 collections
;; 19822 ms elapsed cpu time, including 56 ms collecting
;; 19906 ms elapsed real time, including 57 ms collecting
;; 429917424 bytes allocated
(test "Scheme-interpreter-list-love-no-map-1"
  (run 10 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(list . ,e*)
                     (letrec ((loop (lambda (e*)
                                      (if (null? e*)
                                          '()
                                          (cons (eval-expr (car e*) env) (loop (cdr e*)))))))
                       (loop e*))]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     '(I love you)))
  '('(I love you)
    (list 'I 'love 'you)
    (((lambda (_.0) '(I love you)) '_.1) (=/= ((_.0 closure)))
     (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) _.0) '(I love you)) (=/= ((_.0 closure)))
     (sym _.0))
    (((lambda (_.0) '(I love you)) (lambda (_.1) _.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) '(I love you)) (list))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) '_.1) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I 'love ((lambda (_.0) 'you) '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I ((lambda (_.0) 'love) '_.1) 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list ((lambda (_.0) _.0) 'I) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0))))

;; 542 collections
;; 376792 ms elapsed cpu time, including 2521 ms collecting
;; 377667 ms elapsed real time, including 2530 ms collecting
;; 4541768432 bytes allocated
(test "Scheme-interpreter-list-love-2"
  (run 99 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(list . ,e*)
                     (map (lambda (e) (eval-expr e env)) e*)]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     '(I love you)))
  '('(I love you)
    (list 'I 'love 'you)
    (((lambda (_.0) '(I love you)) '_.1) (=/= ((_.0 closure)))
     (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) _.0) '(I love you)) (=/= ((_.0 closure)))
     (sym _.0))
    (((lambda (_.0) '(I love you)) (list))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) '_.1) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) '(I love you)) (lambda (_.1) _.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) (list 'I 'love 'you)) '_.1)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I 'love ((lambda (_.0) 'you) '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I ((lambda (_.0) 'love) '_.1) 'you)
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list ((lambda (_.0) _.0) 'I) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (list 'I 'love _.0)) 'you)
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (list _.0 'love 'you)) 'I)
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) '(I love you)) (list '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) (list 'I 'love 'you)) (list))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (list 'I _.0 'you)) 'love)
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I 'love ((lambda (_.0) _.0) 'you))
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I ((lambda (_.0) _.0) 'love) 'you)
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I 'love ((lambda (_.0) 'you) (list)))
     (=/= ((_.0 closure))) (sym _.0))
    (((lambda (_.0) (list 'I 'love 'you)) (lambda (_.1) _.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) ((lambda (_.1) '(I love you)) '_.2)) '_.3)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2) (closure _.3)))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) 'you) '_.3))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) 'love) '_.3) 'you)
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list ((lambda (_.0) 'I) (list)) 'love 'you)
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I 'love ((lambda (_.0) 'you) (lambda (_.1) _.2)))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) '(I love you)) (list '_.1 '_.2))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2)))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) 'you) '_.3))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    (((lambda (_.0) ((lambda (_.1) _.1) '(I love you))) '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) _.2) 'you))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) _.2) 'you))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    (((lambda (_.0) ((lambda (_.1) _.0) '_.2)) '(I love you))
     (=/= ((_.0 _.1)) ((_.0 closure)) ((_.1 closure)))
     (sym _.0 _.1) (absento (closure _.2)))
    ((list ((lambda (_.0) 'I) '_.1) ((lambda (_.2) _.2) 'love)
           'you)
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    (((lambda (_.0) ((lambda (_.1) '(I love you)) '_.2))
      (list))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) (list 'I 'love 'you)) (list '_.1))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    (((lambda (_.0) ((lambda (_.1) '(I love you)) _.0)) '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) 'you) (list)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    ((list 'I ((lambda (_.0) 'love) (list)) 'you)
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) (lambda (_.1) _.2)) 'love 'you)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list ((lambda (_.0) _.0) 'I) 'love
           ((lambda (_.1) 'you) '_.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list ((lambda (_.0) _.0) 'I) ((lambda (_.1) 'love) '_.2)
           'you)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list 'I 'love ((lambda (_.0) 'you) (list '_.1)))
     (=/= ((_.0 closure))) (sym _.0) (absento (closure _.1)))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) 'you) (list)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) 'you) (lambda (_.3) _.4)))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.3 closure)))
     (sym _.0 _.2 _.3) (absento (closure _.1) (closure _.4)))
    ((list 'I ((lambda (_.0) _.0) 'love)
           ((lambda (_.1) 'you) '_.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list 'I 'love
           ((lambda (_.0) ((lambda (_.1) 'you) '_.2)) '_.3))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2) (closure _.3)))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) 'you) (lambda (_.3) _.4)))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.3 closure)))
     (sym _.0 _.2 _.3) (absento (closure _.1) (closure _.4)))
    ((list ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) 'love) '_.3) ((lambda (_.4) 'you) '_.5))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.4 closure)))
     (sym _.0 _.2 _.4)
     (absento (closure _.1) (closure _.3) (closure _.5)))
    (((lambda (_.0) ((lambda (_.1) _.1) '(I love you))) (list))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    (((lambda (_.0) ((lambda (_.1) _.1) _.0)) '(I love you))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    ((list ((lambda (_.0) _.0) 'I) 'love
           ((lambda (_.1) _.1) 'you))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    (((lambda (_.0) (_.0 '_.1)) (lambda (_.2) '(I love you)))
     (=/= ((_.0 closure)) ((_.0 lambda)) ((_.0 list))
          ((_.0 quote)) ((_.2 closure)))
     (sym _.0 _.2) (absento (closure _.1)))
    (((lambda (_.0) ((lambda (_.1) '(I love you)) (list)))
      '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) ((lambda (_.1) _.0) _.0)) '(I love you))
     (=/= ((_.0 _.1)) ((_.0 closure)) ((_.1 closure)))
     (sym _.0 _.1))
    ((list 'I ((lambda (_.0) _.0) 'love)
           ((lambda (_.1) _.1) 'you))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    ((list 'I 'love
           ((lambda (_.0) ((lambda (_.1) _.1) 'you)) '_.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) ((lambda (_.1) (list 'I 'love 'you)) '_.2))
      '_.3)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2) (closure _.3)))
    ((list ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) 'love) '_.3) ((lambda (_.4) _.4) 'you))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.4 closure)))
     (sym _.0 _.2 _.4) (absento (closure _.1) (closure _.3)))
    (((lambda (_.0) '(I love you)) (list '_.1 '_.2 '_.3))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2) (closure _.3)))
    ((list ((lambda (_.0) _.0) 'I) ((lambda (_.1) _.1) 'love)
           'you)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    ((list 'I ((lambda (_.0) 'love) (lambda (_.1) _.2)) 'you)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) ((lambda (_.1) '(I love you)) _.0)) (list))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    ((list ((lambda (_.0) _.0) 'I) 'love
           ((lambda (_.1) 'you) (list)))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    (((lambda (_.0)
        ((lambda (_.1) '(I love you)) (lambda (_.2) _.3)))
      '_.4)
     (=/= ((_.0 closure)) ((_.1 closure)) ((_.2 closure)))
     (sym _.0 _.1 _.2) (absento (closure _.3) (closure _.4)))
    (((lambda (_.0) (list 'I 'love ((lambda (_.1) 'you) '_.2)))
      '_.3)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2) (closure _.3)))
    (((lambda (_.0) (list 'I 'love 'you)) (list '_.1 '_.2))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2)))
    ((list 'I 'love
           ((lambda (_.0) ((lambda (_.1) _.0) '_.2)) 'you))
     (=/= ((_.0 _.1)) ((_.0 closure)) ((_.1 closure)))
     (sym _.0 _.1) (absento (closure _.2)))
    ((list ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) 'love) (list)) 'you)
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1)))
    (((lambda (_.0) (list ((lambda (_.1) 'I) '_.2) 'love 'you))
      '_.3)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2) (closure _.3)))
    ((list ((lambda (_.0) 'I) (list)) 'love
           ((lambda (_.1) 'you) '_.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) _.0) (list 'I 'love 'you))
     (=/= ((_.0 closure))) (sym _.0))
    ((list ((lambda (_.0) 'I) (list))
           ((lambda (_.1) 'love) '_.2) 'you)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list 'I ((lambda (_.0) _.0) 'love)
           ((lambda (_.1) 'you) (list)))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))
    ((list 'I 'love
           ((lambda (_.0) ((lambda (_.1) 'you) _.0)) '_.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) (list ((lambda (_.1) 'I) '_.2) 'love 'you))
      (list))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) (_.0 '(I love you))) (lambda (_.1) _.1))
     (=/= ((_.0 closure)) ((_.0 lambda)) ((_.0 list))
          ((_.0 quote)) ((_.1 closure)))
     (sym _.0 _.1))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) 'you) (list '_.3)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) 'love) '_.3)
           ((lambda (_.4) 'you) (list)))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.4 closure)))
     (sym _.0 _.2 _.4) (absento (closure _.1) (closure _.3)))
    ((list 'I 'love
           ((lambda (_.0) ((lambda (_.1) 'you) '_.2)) (list)))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (lambda) (lambda lambda))
      (lambda (_.0) '(I love you)))
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I 'love ((lambda (_.0) 'you) (list '_.1 '_.2)))
     (=/= ((_.0 closure))) (sym _.0)
     (absento (closure _.1) (closure _.2)))
    (((lambda (_.0) ((lambda (_.1) _.0) (list))) '(I love you))
     (=/= ((_.0 _.1)) ((_.0 closure)) ((_.1 closure)))
     (sym _.0 _.1))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) 'you) (list '_.3)))
     (=/= ((_.0 closure)) ((_.2 closure))) (sym _.0 _.2)
     (absento (closure _.1) (closure _.3)))
    ((list ((lambda (_.0) _.0) 'I) 'love
           ((lambda (_.1) 'you) (lambda (_.2) _.3)))
     (=/= ((_.0 closure)) ((_.1 closure)) ((_.2 closure)))
     (sym _.0 _.1 _.2) (absento (closure _.3)))
    (((lambda (_.0) (list ((lambda (_.1) 'I) '_.2) 'love _.0))
      'you)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) ((lambda (_.1) (list 'I 'love _.1)) 'you))
      '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) ((lambda (_.1) (list _.1 'love 'you)) 'I))
      '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list ((lambda (_.0) 'I) '_.1) ((lambda (_.2) _.2) 'love)
           ((lambda (_.3) 'you) '_.4))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.3 closure)))
     (sym _.0 _.2 _.3) (absento (closure _.1) (closure _.4)))
    ((list ((lambda (_.0) 'I) '_.1) 'love
           ((lambda (_.2) ((lambda (_.3) 'you) '_.4)) '_.5))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.3 closure)))
     (sym _.0 _.2 _.3)
     (absento (closure _.1) (closure _.4) (closure _.5)))
    (((lambda (_.0) '(I love you)) (list (list)))
     (=/= ((_.0 closure))) (sym _.0))
    ((list 'I ((lambda (_.0) 'love) (list))
           ((lambda (_.1) 'you) '_.2))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list 'I ((lambda (_.0) _.0) 'love)
           ((lambda (_.1) 'you) (lambda (_.2) _.3)))
     (=/= ((_.0 closure)) ((_.1 closure)) ((_.2 closure)))
     (sym _.0 _.1 _.2) (absento (closure _.3)))
    ((list ((lambda (_.0) _.0) 'I) ((lambda (_.1) 'love) '_.2)
           ((lambda (_.3) 'you) '_.4))
     (=/= ((_.0 closure)) ((_.1 closure)) ((_.3 closure)))
     (sym _.0 _.1 _.3) (absento (closure _.2) (closure _.4)))
    (((lambda (_.0) (list ((lambda (_.1) 'I) '_.2) _.0 'you))
      'love)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list 'I ((lambda (_.0) 'love) '_.1)
           ((lambda (_.2) ((lambda (_.3) 'you) '_.4)) '_.5))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.3 closure)))
     (sym _.0 _.2 _.3)
     (absento (closure _.1) (closure _.4) (closure _.5)))
    (((lambda (_.0) ((lambda (_.1) (list 'I 'love 'you)) _.0)) '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list ((lambda (_.0) 'I) '_.1)
           ((lambda (_.2) 'love) '_.3)
           ((lambda (_.4) 'you) (lambda (_.5) _.6)))
     (=/= ((_.0 closure)) ((_.2 closure)) ((_.4 closure))
          ((_.5 closure)))
     (sym _.0 _.2 _.4 _.5)
     (absento (closure _.1) (closure _.3) (closure _.6)))
    (((lambda (_.0) ((lambda (_.1) (list 'I _.1 'you)) 'love)) '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    (((lambda (_.0) (list 'I 'love ((lambda (_.1) _.1) 'you))) '_.2)
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1)
     (absento (closure _.2)))
    ((list ((lambda (_.0) 'I) (list)) 'love
           ((lambda (_.1) _.1) 'you))
     (=/= ((_.0 closure)) ((_.1 closure))) (sym _.0 _.1))))


;; 1 collection
;; 788 ms elapsed cpu time, including 0 ms collecting
;; 792 ms elapsed real time, including 0 ms collecting
;; 10150592 bytes allocated
(test "Scheme-interpreter-list-quine-0"
  (run 1 (q)
    (== '((lambda (_.0) (list _.0 (list 'quote _.0)))
          '(lambda (_.0) (list _.0 (list 'quote _.0))))
        q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(list . ,e*)
                     (map (lambda (e) (eval-expr e env)) e*)]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     q))
  '(((lambda (_.0) (list _.0 (list 'quote _.0)))
     '(lambda (_.0) (list _.0 (list 'quote _.0))))))

;; 84 collections
;; 33214 ms elapsed cpu time, including 181 ms collecting
;; 33253 ms elapsed real time, including 182 ms collecting
;; 701188960 bytes allocated
(test "Scheme-interpreter-list-quine-1"
  (run 1 (q)
    (eval-expo
     `(letrec ((eval-expr
                (lambda (expr env)
                  (match expr
                    [`(quote ,datum) datum]
                    [(? symbol? x) (env x)]
                    [`(list . ,e*)
                     (map (lambda (e) (eval-expr e env)) e*)]
                    [`(lambda (,(? symbol? x)) ,body)
                     (lambda (a)
                       (eval-expr body (lambda (y)
                                         (if (equal? x y)
                                             a
                                             (env y)))))]
                    [`(,rator ,rand)
                     ((eval-expr rator env) (eval-expr rand env))]))))
        (eval-expr ',q
                   (lambda (y) ((lambda (z) z)))))
     '()
     q))
  '((((lambda (_.0) (list _.0 (list 'quote _.0)))
      '(lambda (_.0) (list _.0 (list 'quote _.0))))
     (=/= ((_.0 closure))) (sym _.0))))

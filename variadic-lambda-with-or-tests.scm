(load "interp-with-variadic-lambda-and-or-and-match.scm")
(load "mk/test-check.scm")
(load "mk/matche.scm")


;; Helper Scheme predicate for testing
(define member? (lambda (x ls) (not (not (member x ls)))))


;; and tests
(test "and-0"
  (run* (q) (eval-expo '(and) '() q))
  '(#t))

(test "and-1"
  (run* (q) (eval-expo '(and 5) '() q))
  '(5))

(test "and-2"
  (run* (q) (eval-expo '(and #f) '() q))
  '(#f))

(test "and-3"
  (run* (q) (eval-expo '(and 5 6) '() q))
  '(6))

(test "and-4"
  (run* (q) (eval-expo '(and #f 6) '() q))
  '(#f))

(test "and-5"
  (run* (q) (eval-expo '(and (null? '()) 6) '() q))
  '(6))

(test "and-6"
  (run* (q) (eval-expo '(and (null? '(a b c)) 6) '() q))
  '(#f))


;; or tests
(test "or-0"
  (run* (q) (eval-expo '(or) '() q))
  '(#f))

(test "or-1"
  (run* (q) (eval-expo '(or 5) '() q))
  '(5))

(test "or-2"
  (run* (q) (eval-expo '(or #f) '() q))
  '(#f))

(test "or-3"
  (run* (q) (eval-expo '(or 5 6) '() q))
  '(5))

(test "or-4"
  (run* (q) (eval-expo '(or #f 6) '() q))
  '(6))

(test "or-5"
  (run* (q) (eval-expo '(or (null? '()) 6) '() q))
  '(#t))

(test "or-6"
  (run* (q) (eval-expo '(or (null? '(a b c)) 6) '() q))
  '(6))


;; port of Matt Might's very simple theorem prover

;; 4 collections
;; 3824 ms elapsed cpu time, including 0 ms collecting
;; 3826 ms elapsed real time, including 0 ms collecting
;; 33697312 bytes allocated
(test "proof-1"
  (run 1 (q)
    (eval-expo
     `(letrec ((member? (lambda (x ls)
                          (if (null? ls)
                              #f
                              (if (equal? (car ls) x)
                                  #t
                                  (member? x (cdr ls)))))))
        (letrec ((proof? (lambda (proof)
                           (match proof
                             [`(assumption ,assms () ,A)
                              (member? A assms)]
                             [`(modus-ponens
                                ,assms
                                ((,r1 ,assms ,ants1 (if ,A ,B))
                                 (,r2 ,assms ,ants2 ,A))
                                ,B)
                              (and (proof? (list r1 assms ants1 (list 'if A B)))
                                   (proof? (list r2 assms ants2 A)))]))))
          (proof? '(modus-ponens
                    (A (if A B) (if B C))
                    ((assumption (A (if A B) (if B C)) () (if B C))
                     (modus-ponens
                      (A (if A B) (if B C))
                      ((assumption (A (if A B) (if B C)) () (if A B))
                       (assumption (A (if A B) (if B C)) () A)) B))
                    C))))
     '()
     q))
  '(#t))

;; 3 collections
;; 3332 ms elapsed cpu time, including 0 ms collecting
;; 3336 ms elapsed real time, including 0 ms collecting
;; 23832224 bytes allocated
(test "proof-2a"
  (run 1 (prf)
    (fresh (rule assms ants)
      (== '(modus-ponens
             (A (if A B) (if B C))
             ((assumption (A (if A B) (if B C)) () (if B C))
              (modus-ponens
                (A (if A B) (if B C))
                ((assumption (A (if A B) (if B C)) () (if A B))
                 (assumption (A (if A B) (if B C)) () A)) B))
             C)
          prf)
      (eval-expo
       `(letrec ((member? (lambda (x ls)
                            (if (null? ls)
                                #f
                                (if (equal? (car ls) x)
                                    #t
                                    (member? x (cdr ls)))))))
          (letrec ((proof? (lambda (proof)
                             (match proof
                               [`(assumption ,assms () ,A)
                                (member? A assms)]
                               [`(modus-ponens
                                  ,assms
                                  ((,r1 ,assms ,ants1 (if ,A ,B))
                                   (,r2 ,assms ,ants2 ,A))
                                  ,B)
                                (and (proof? (list r1 assms ants1 (list 'if A B)))
                                     (proof? (list r2 assms ants2 A)))]))))
            (proof? ',prf)))
       '()
       #t)))
  '((modus-ponens (A (if A B) (if B C))
      ((assumption (A (if A B) (if B C)) () (if B C))
       (modus-ponens (A (if A B) (if B C))
         ((assumption (A (if A B) (if B C)) () (if A B))
          (assumption (A (if A B) (if B C)) () A))
         B))
      C)))

;; 2 collections
;; 3479 ms elapsed cpu time, including 0 ms collecting
;; 3481 ms elapsed real time, including 0 ms collecting
;; 23832976 bytes allocated
(test "proof-2b"
  (run 1 (prf)
    (fresh (rule assms ants)
      (== `(,rule ,assms ,ants C) prf)
      (== `(A (if A B) (if B C)) assms)
      (== '(modus-ponens
             (A (if A B) (if B C))
             ((assumption (A (if A B) (if B C)) () (if B C))
              (modus-ponens
                (A (if A B) (if B C))
                ((assumption (A (if A B) (if B C)) () (if A B))
                 (assumption (A (if A B) (if B C)) () A)) B))
             C)
          prf)
      (eval-expo
       `(letrec ((member? (lambda (x ls)
                            (if (null? ls)
                                #f
                                (if (equal? (car ls) x)
                                    #t
                                    (member? x (cdr ls)))))))
          (letrec ((proof? (lambda (proof)
                             (match proof
                               [`(assumption ,assms () ,A)
                                (member? A assms)]
                               [`(modus-ponens
                                  ,assms
                                  ((,r1 ,assms ,ants1 (if ,A ,B))
                                   (,r2 ,assms ,ants2 ,A))
                                  ,B)
                                (and (proof? (list r1 assms ants1 (list 'if A B)))
                                     (proof? (list r2 assms ants2 A)))]))))
            (proof? ',prf)))
       '()
       #t)))
  '((modus-ponens (A (if A B) (if B C))
      ((assumption (A (if A B) (if B C)) () (if B C))
       (modus-ponens (A (if A B) (if B C))
         ((assumption (A (if A B) (if B C)) () (if A B))
          (assumption (A (if A B) (if B C)) () A))
         B))
      C)))

;; 10 collections
;; 12273 ms elapsed cpu time, including 1 ms collecting
;; 12283 ms elapsed real time, including 2 ms collecting
;; 82533568 bytes allocated
(test "proof-2c"
  (run 1 (prf)
    (fresh (rule assms ants)
      (== `(,rule ,assms ,ants C) prf)
      (== `(A (if A B) (if B C)) assms)
      (eval-expo
       `(letrec ((member? (lambda (x ls)
                            (if (null? ls)
                                #f
                                (if (equal? (car ls) x)
                                    #t
                                    (member? x (cdr ls)))))))
          (letrec ((proof? (lambda (proof)
                             (match proof
                               [`(assumption ,assms () ,A)
                                (member? A assms)]
                               [`(modus-ponens
                                  ,assms
                                  ((,r1 ,assms ,ants1 (if ,A ,B))
                                   (,r2 ,assms ,ants2 ,A))
                                  ,B)
                                (and (proof? (list r1 assms ants1 (list 'if A B)))
                                     (proof? (list r2 assms ants2 A)))]))))
            (proof? ',prf)))
       '()
       #t)))
  '((modus-ponens (A (if A B) (if B C))
      ((assumption (A (if A B) (if B C)) () (if B C))
       (modus-ponens (A (if A B) (if B C))
         ((assumption (A (if A B) (if B C)) () (if A B))
          (assumption (A (if A B) (if B C)) () A))
         B))
      C)))
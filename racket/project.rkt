#lang racket

; 1. process-4: Hands 4 to the given function and returns its result.
(define process-4
    (lambda (action)
        (action 4))
)

; 2. mymap: Duplicates map. Must use recursion.
(define mymap
    (lambda (transform stack-of-items)
        (cond
            [(empty? stack-of-items) '()]
            [else (cons (transform (first stack-of-items))
                (mymap transform (rest stack-of-items)))]))
)

; 3. second-min: drop repeats, sort smallest to largest and return the second.
;       If fewer than two uniques then raise an error.
(define second-min
    (lambda (numbers)
        (define unique-numbers (remove-duplicates numbers))
        (define ranked-numbers (sort unique-numbers <))
            (cond
                [(< (length ranked-numbers) 2) (error "Need at least two unique values!")]
                [else (second ranked-numbers)]))
)

; 4. zipper: pair up items from two lists by position as 2-item lists.
;       If either list is empty then stop as extras are ignored. Must use recursion.
(define zipper
  (lambda (first-stack second-stack)
    (cond
      [(or (empty? first-stack) (empty? second-stack)) '()]
      [else (cons (list (first first-stack) (first second-stack))
                  (zipper (rest first-stack) (rest second-stack)))]))
)

; UNIT TESTS: the code here is for testing the above functions.
;   Run these tests with 
;       raco test <file name>.rkt
(module+ test
  (require rackunit)
    ; process-4
    (check-equal? (process-4 sqr) 16)
    (check-equal? (process-4 sqrt) 2)
    (check-equal? (process-4 add1) 5)
    (check-equal? (process-4 (lambda (n) (* 2 n))) 8)
    (check-equal? (process-4 (lambda (n) n)) 4)

    ; mymap
    (check-equal? (mymap sqrt '(9 25 81 49)) '(3 5 9 7))
    (check-equal? (mymap add1 '(6 4 8 3)) '(7 5 9 4))
    (check-equal? (mymap sqr '(5 7)) '(25 49))
    (check-equal? (mymap add1 '()) '())
    (check-equal? (mymap (lambda (n) (> n 5)) '(3 8 5 9)) '(#f #t #f #t))

    ; second-min
    (check-equal? (second-min '(1 2 3 4)) 2)
    (check-equal? (second-min '(3 8 5 6 3 7)) 5)
    (check-equal? (second-min '(1 1 2)) 2)
    (check-equal? (second-min '(9 2)) 9)
    (check-equal? (second-min '(2.5 1.5 3.5)) 2.5)
    (check-exn exn:fail? (lambda () (second-min '(4 4))))
    (check-exn exn:fail? (lambda () (second-min '(7))))
    (check-exn exn:fail? (lambda () (second-min '())))

    ; zipper
    (check-equal? (zipper '(1 2 3 4) '(a b c d)) '((1 a) (2 b) (3 c) (4 d)))
    (check-equal? (zipper '(1 2 3) '(4 9 5 7)) '((1 4) (2 9) (3 5)))
    (check-equal? (zipper '(3 5 6) '("one" 6.18 #t "two")) '((3 "one") (5 6.18) (6 #t)))
    (check-equal? (zipper '(5) '()) '())
    (check-equal? (zipper '() '(1 2)) '())
    (check-equal? (zipper '() '()) '())
)
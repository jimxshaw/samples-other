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

; 3. second-min: Drop repeats, sort smallest to largest and return the second.
;     If fewer than two uniques then raise an error.
(define second-min
  (lambda (numbers)
    (define unique-numbers (remove-duplicates numbers))
    (define ranked-numbers (sort unique-numbers <))
      (cond
        [(< (length ranked-numbers) 2) (error "Need at least two unique values!")]
        [else (second ranked-numbers)]))
)

; 4. zipper: Pair up items from two lists by position as 2-item lists.
;     If either list is empty then stop as extras are ignored. Must use recursion.
(define zipper
  (lambda (first-stack second-stack)
    (cond
      [(or (empty? first-stack) (empty? second-stack)) '()]
      [else (cons (list (first first-stack) (first second-stack))
        (zipper (rest first-stack) (rest second-stack)))]))
)

; 5. classify: Split a list into either passing or failing using a yes/no test.
;       A recursive helper sorts each item into one of the two stacks, keeping order
;       and returns them as a 2-item list. Must use recursion.
(define classify
  (lambda (test stack-of-items)
    (define sort-into-two-stacks
      (lambda (stack)
        (cond
          [(empty? stack) (list '() '())]
          [else
            (define rest-result (sort-into-two-stacks (rest stack)))
            (define passing-rest (first rest-result))
            (define failing-rest (second rest-result))
            (cond
              [(test (first stack))
                (list (cons (first stack) passing-rest) failing-rest)]
              [else
                (list passing-rest (cons (first stack) failing-rest))])])))
      (sort-into-two-stacks stack-of-items))
)

; 6. member-n-times?: Is our target in the list exactly how many times given
;     in the input? Recursive helper counts the matches then the count is 
;     compared to the how many input. Must use recursion.
(define member-n-times?
  (lambda (target how-many stack-of-items)
    (define count-matches
      (lambda (stack)
        (cond
          [(empty? stack) 0]
          [(equal? (first stack) target) (+ 1 (count-matches (rest stack)))]
          [else (count-matches (rest stack))])))
    (= (count-matches stack-of-items) how-many))
)

; 7. luhn: Is the number a valid luhn checksum number?
;     Walk the digits right to left, doubling every 2nd digit where a doubled 
;     2-digit result has its digits added. Valid if the total ends in 0.
(define luhn
  (lambda (number)
    (define digit-value
      (lambda (digit should-double?)
        (if should-double?
            (+ (quotient (* 2 digit) 10) (remainder (* 2 digit) 10))
            digit)))
    (define sum-digits
      (lambda (remaining should-double?)
        (if (= remaining 0)
            0
            (+ (digit-value (remainder remaining 10) should-double?)
               (sum-digits (quotient remaining 10) (not should-double?))))))
    (= (remainder (sum-digits number #f) 10) 0))
)

; 8. my-sorted?: Is the list in order according to the in order input?
;     Check each neighboring pair. One failing pair makes the answer false.
;     Fewer than two items has no pairs so it counts as sorted. 
;     Must use recursion.
(define my-sorted?
  (lambda (in-order? stack-of-items)
    (cond
      [(or (empty? stack-of-items) (empty? (rest stack-of-items))) #t]
      [else (and (in-order? (first stack-of-items) (second stack-of-items))
                 (my-sorted? in-order? (rest stack-of-items)))]))
)

; 9. my-flatten: Turn arbitrarily nested lists into one flat list.
;     First item is a list, flatten it, flatten the rest then append
;     the two results. Otherwise keep the item and cons it on.
;     Must use recursion.
(define my-flatten
  (lambda (stack-of-things)
    (cond
      [(empty? stack-of-things) '()]
      [(list? (first stack-of-things))
       (append (my-flatten (first stack-of-things))
               (my-flatten (rest stack-of-things)))]
      [else (cons (first stack-of-things)
                  (my-flatten (rest stack-of-things)))]))
)

; 10. my-list-ref: Return the item at the input position. Empty list produces
;       error. Position 0 returns the first item. Otherwise ask for position -1
;       in the rest of the list. Must use recursion.
(define my-list-ref
  (lambda (stack-of-items position)
    (cond
      [(empty? stack-of-items) (error "ERROR: Index out of bounds")]
      [(= position 0) (first stack-of-items)]
      [else (my-list-ref (rest stack-of-items) (- position 1))]))
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

    ; classify
    (check-equal? (classify even? '(7 2 3 5 8)) '((2 8) (7 3 5)))
    (check-equal? (classify number? '()) '(() ()))
    (check-equal? (classify (lambda (n) (> n 10)) '(3 8 -5 16 99)) '((16 99) (3 8 -5)))
    (check-equal? (classify integer? '(4 8 2)) '((4 8 2) ()))
    (check-equal? (classify string? '(4 8 2)) '(() (4 8 2)))
    (check-equal? (classify string? '("a" 1 "b" #t)) '(("a" "b") (1 #t)))

    ; member-n-times?
    (check-equal? (member-n-times? 6 2 '(4 8 6 2 1 6)) #t)
    (check-equal? (member-n-times? 7 0 '(4 8 6 2 1)) #t)
    (check-equal? (member-n-times? 3.5 2 '(9 3.5 6 3.52)) #f)
    (check-equal? (member-n-times? "hello" 2 '("hello" 4 5 #f "hello" a)) #t)
    (check-equal? (member-n-times? 5 1 '()) #f)
    (check-equal? (member-n-times? 5 0 '()) #t)
    (check-equal? (member-n-times? 4 3 '(4 4 4 4)) #f)

    ; luhn
    (check-equal? (luhn 799273987104) #t)
    (check-equal? (luhn 49927398717) #f)
    (check-equal? (luhn 49927398716) #t)
    (check-equal? (luhn 59) #t)
    (check-equal? (luhn 79927398713) #t)
    (check-equal? (luhn 79927398710) #f)

    ; my-sorted?
    (check-equal? (my-sorted? < '(2 5 6 9 11 34)) #t)
    (check-equal? (my-sorted? < '(7 25 4 15 11 34)) #f)
    (check-equal? (my-sorted? string<? '("alpha" "beta" "gamma")) #t)
    (check-equal? (my-sorted? string<? '("john" "zack" "bob")) #f)
    (check-equal? (my-sorted? < '()) #t)
    (check-equal? (my-sorted? < '(7)) #t)
    (check-equal? (my-sorted? > '(9 5 2)) #t)
    (check-equal? (my-sorted? < '(3 3)) #f)

    ; my-flatten
    (check-equal? (my-flatten '(1)) '(1))
    (check-equal? (my-flatten '((1 2) 3)) '(1 2 3))
    (check-equal? (my-flatten '(((4 3) 6) ((7 2 9) (5 1)))) '(4 3 6 7 2 9 5 1))
    (check-equal? (my-flatten '()) '())
    (check-equal? (my-flatten '(())) '())
    (check-equal? (my-flatten '(((((1)))))) '(1))
    (check-equal? (my-flatten '("a" (b ("c")) 4)) '("a" b "c" 4))

    ; my-list-ref
    (check-equal? (my-list-ref '(4 7 9) 0) 4)
    (check-equal? (my-list-ref '(4 7 9) 1) 7)
    (check-equal? (my-list-ref '(4 7 9) 2) 9)
    (check-equal? (my-list-ref '("a" #t 6.18) 1) #t)
    (check-exn #rx"Index out of bounds" (lambda () (my-list-ref '(4 7 9) 3)))
    (check-exn #rx"Index out of bounds" (lambda () (my-list-ref '() 0)))
    (check-exn #rx"Index out of bounds" (lambda () (my-list-ref '(4 7 9) -1)))
)
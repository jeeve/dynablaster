#lang racket

(require "engine.rkt")

(provide move-robot-default)

; intelligent robot
(define (move-robot-default f-r d c)
  (let* ([r (f-r d)]
         [x (random 100)]
         [danger? (lambda (x) (or (bomb? x) (fire? x)))]
         [something? (lambda (x) #t)]
         [escape (lambda (r d)
                   (cond [(not (empty? (sprite-left r danger? d c))) (go-right r d c)] 
                         [(not (empty? (sprite-right r danger? d c))) (go-left r d c)] 
                         [(not (empty? (sprite-up r danger? d c))) (go-down r d c)]
                         [(not (empty? (sprite-down r danger? d c ))) (go-up r d c)]                      
                         [(not (empty? (search-sprite (sprite-x r) (sprite-y r) bomb? d c)))
                          (cond  [(empty? (sprite-left r something? d c)) (go-left r d c)] 
                                 [(empty? (sprite-right r something? d c)) (go-right r d c)] 
                                 [(empty? (sprite-up r something? d c)) (go-up r d c)]
                                 [(empty? (sprite-down r something? d c)) (go-down r d c)]                     
                                 [else d])]))]) 
    (if (empty? r)
        d
        (cond
          ; fear of fire
          [(or (not (empty? (sprite-left r danger? d c))) 
               (not (empty? (sprite-right r danger? d c)))
               (not (empty? (search-sprite (sprite-x r) (sprite-y r) bomb? d c)))) 
           (if (empty? (sprite-up r something? d c))
               (go-up r d c)
               (if (empty? (sprite-down r something? d c))
                   (go-down r d c)
                   (escape r d)))] 
          [(or (not (empty? (sprite-up r danger? d c))) 
               (not (empty? (sprite-down r danger? d c)))
               (not (empty? (search-sprite (sprite-x r) (sprite-y r) bomb? d c))))
           (if (empty? (sprite-left r something? d c))
               (go-left r d c)
               (if (empty? (sprite-right r something? d c))
                   (go-right r d c)
                   (escape r d)))]
          ; intention
          [(and (> x 0) (<= x 10) (empty? (sprite-up r fire? d c))) (go-up r d c)]
          [(and (> x 10) (<= x 20) (empty? (sprite-down r fire? d c))) (go-down r d c)]
          [(and (> x 20) (<= x 30) (empty? (sprite-left r fire? d c))) (go-left r d c)]
          [(and (> x 30) (<= x 40) (empty? (sprite-right r fire? d c))) (go-right r d c)]
          [(and (> x 40) (<= x 42) (not (blocked? r d c))) (drop-bomb r d c)]
          [else d]))))
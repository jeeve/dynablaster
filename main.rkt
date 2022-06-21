#lang racket

(require 2htdp/universe 2htdp/image "engine.rkt" "robot.rkt" "config.rkt")

(provide world sprite
         game-size configuration default-configuration
         sprite-left sprite-right sprite-up sprite-down search-sprite
         sprite-x sprite-y sprite-dx sprite-dy sprite-energy distance
         go-left go-right go-up go-down drop-bomb
         bomb? fire? player? robot? blocked? brick? rock?
         player robot
         run move-robot-default)

;(define (game-size columns-count rows-count)
;  (struct-copy configuration default-configuration [columns-count columns-count] [rows-count rows-count]))

; at each clock tick
(define (tick w)
  (letrec ([c (world-configuration w)]
           [score-player (world-score-player w)]
           [score-robot (world-score-robot w)]
           [destruction 
            (lambda (d)
              (if (empty? (search-sprite (sprite-x (first d)) 
                                         (sprite-y (first d)) 
                                         fire? 
                                         (world-decor w) c))
                  (cons (first d) (tic-tac (rest d))) ; sprite not hit
                  (cond ; sprite hit 
                    [(and (player? (first d)) 
                          (energy0? (first d))) (begin ; the player dies
                                                  (set! score-robot (+ score-robot 1))
                                                  (cons (new-player (rest d) c) (rest d)))]
                    [(and (robot? (first d)) 
                          (energy0? (first d))) (begin ; the robot dies
                                                  (set! score-player (+ score-player 1)) 
                                                  (cons (new-robot (rest d) c) (rest d)))]
                    [else (tic-tac (rest d))])))]
           [tic-tac 
            (lambda (d)
              (if (empty? (rest d))
                  d
                  (cond [(bomb? (first d)) (cons (tic-tac-bomb (first d) d w) (tic-tac (rest d)))]
                        [(fire? (first d)) (if (energy0? (first d))
                                               (tic-tac (rest d))
                                               (if (or (> (abs (sprite-dx (first d))) 0) 
                                                       (> (abs (sprite-dy (first d))) 0))
                                                   (append (spread-fire (consume (first d)) (world-decor w) c) 
                                                           (tic-tac (rest d)))
                                                   (cons (consume (first d)) (tic-tac (rest d)))))]
                        [(brick? (first d)) (destruction d)]
                        [(player? (first d)) (destruction (cons (tic-tac-player-or-robot (first d) d IMAGE-PLAYER (ENERGY-PLAYER c)) (rest d)))]
                        [(robot? (first d)) (destruction (cons (tic-tac-player-or-robot (first d) d IMAGE-ROBOT (ENERGY-ROBOT c)) (rest d)))]
                        [else (cons (first d) (tic-tac (rest d)))])))]
           [move-robot (world-move-robot w)]
           [move-player (world-move-player w)]
           [d (tic-tac (world-decor w))])    
    (struct-copy world w 
                 [decor (move-player player (move-robot robot d c) c)]
                 [score-player score-player] [score-robot score-robot])))

; render
(define (render w)
  (letrec ([c (world-configuration w)]
           [DELTA (configuration-sprite-size c)]
           [image-title (text (configuration-title c) 15 'silver)]
           [place-sprites (lambda (sprites image)
                            (if (empty? sprites)
                                image
                                (place-image (if (fire? (first sprites))
                                                 (image-fire (first sprites)                                     
                                                             (world-decor w) c)
                                                 (sprite-image (first sprites)))
                                             (sprite-x (first sprites))
                                             (sprite-y (first sprites))
                                             (place-sprites (rest sprites) image))))]
           [score-background (overlay (rectangle (* DELTA 3) (- DELTA 8) 'outline 'black)   
                                      (rectangle (* DELTA 3) (- DELTA 8) 'solid 'silver))]
           [image-score (place-image (text (number->string (world-score-robot w)) 15 'red) 
                                     (- (WIDTH c) (* DELTA 2)) (/ DELTA 2)
                                     (place-image (text (number->string (world-score-player w)) 15 'blue) 
                                                  (* DELTA 2) (/ DELTA 2)
                                                  (place-image score-background (* DELTA 2) (/ DELTA 2)
                                                               (place-image score-background  
                                                                            (- (WIDTH c) (* DELTA 2)) (/ DELTA 2)
                                                                            (place-image image-title (/ (WIDTH c) 2) (/ DELTA 2)
                                                                                         (rectangle (WIDTH c) DELTA 'solid 'dimgray))))))])           
    (above image-score
           (place-sprites (world-decor w) (image-background c)))))

; keyboard handling
(define (keypress w s)
  (let* ([d (world-decor w)]
         [c (world-configuration w)]
         [j (player d)])   
    (if (empty? j)
        w
        (cond
          [(string=? s "up") (struct-copy world w [decor (go-up j d c)])]
          [(string=? s "down") (struct-copy world w [decor (go-down j d c)])]
          [(string=? s "left") (struct-copy world w [decor (go-left j d c)])]
          [(string=? s "right") (struct-copy world w [decor (go-right j d c)])]
          [(string=? s " ") (struct-copy world w [decor (drop-bomb j d c)])]
          [else w]))))

(define (initial-world move-robot move-player sound configuration)
  (let* ([nb-sprites (* (configuration-columns-count configuration) (configuration-rows-count configuration))]
         [d (make-decor (make-decor (image-border configuration)
                                    (quotient nb-sprites 5) 
                                    IMAGE-ROCK #f 'rock 0 configuration)
                        (quotient nb-sprites 3) 
                        IMAGE-BRICK #f 'brick 0 configuration)])
    (world (cons (new-robot d configuration)
                 (cons (new-player d configuration) d))
           move-robot move-player
           0 0 sound configuration)))

; let's go
(define (run [move-robot move-robot-default] [move-player (lambda (r d c) d)] 
             #:config [configuration default-configuration]
             #:sound [with-sound #t])
  (big-bang (initial-world move-robot move-player with-sound configuration)
            (on-tick tick 0.1)   
            (to-draw render)
            (on-key keypress)))

; To go, type 
; (run)
; or
; (run #:sound #f)
; or
; (run move-robot-default move-robot-default)
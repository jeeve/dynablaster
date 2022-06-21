#lang scribble/manual

@title{DynaBlaster: Htdp version of Dynablaster game}

@section{How to play}

To run the game, type 

@racketblock[(require (planet jeeve/dynablaster:1:14))
             
             (run) (code:comment "or (run #:sound #f) to play without sound effect")]

Use left, right, up and down keys to move blue player in the scene.

Drop bombs with space key and attack the red player.

Good luck !

If you want to see the computer play alone, type

@racketblock[(require (planet jeeve/dynablaster:1:14))
             
             (run move-robot-default move-robot-default)]

@section{Game configuration}

@racket[(run #:config (game-size 15 10))]

@section{Customize the behavior of the robot}

@racket[(run my-move-robot-function)]

Before, define a custom move-robot function. For example :

@racketblock[(define (my-move-robot-function f-r d c)
               (let ([r (f-r d)])
                 (if (empty? r) (code:comment "robot is not dead ?")
                     d
                     (if (empty? (sprite-left r (lambda (x) #t) d c)) (code:comment "something at left of robot ?")
                         (go-left r d c) (code:comment "go to left !")
                         d))))]

Also, you can start the game in automatically mode, the blue player is controlled by a function like the robot.
So you can easily compare the behavior of two algorithms.

@racket[(run my-move-robot-function my-move-player-function)]

You can use these functions and predicates :

@itemlist[
          
          @item{The player and robot sprite : @racket[player robot]}
           
           @item{Sprite informations : @racket[sprite-x sprite-y sprite-dx sprite-dy sprite-energy]}
           
           @item{Sprite actions  :  @racket[go-left go-right go-up go-down drop-bomb]}
           
           @item{Sprite predicates : @racket[bomb? fire? player? robot? blocked? brick? rock?]}
           
           @item{Sprite search :  @racket[sprite-left sprite-right sprite-up sprite-down search-sprite]}
           
           @item{Distance between two sprites : @racket[distance]}
           
           @item{Default move robot function : @racket[move-robot-default]}]



Do not hesitate to send me your move-robot functions (@author+email["jeeve" "jvjulien@free.fr"]) 

@section{Default move-robot function}

For information, the default move-robot has only random and defensive behavior. 
The code corresponding is

@racketblock[(define (move-robot-default f-r d c)
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
                       (code:comment "fear of fire")
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
                       (code:comment "intention")
                       [(and (> x 0) (<= x 10) (empty? (sprite-up r fire? d c))) (go-up r d c)]
                       [(and (> x 10) (<= x 20) (empty? (sprite-down r fire? d c))) (go-down r d c)]
                       [(and (> x 20) (<= x 30) (empty? (sprite-left r fire? d c))) (go-left r d c)]
                       [(and (> x 30) (<= x 40) (empty? (sprite-right r fire? d c))) (go-right r d c)]
                       [(and (> x 40) (<= x 42) (not (blocked? r d c))) (drop-bomb r d c)]
                       [else d]))))]
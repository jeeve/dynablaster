#lang racket

(require 2htdp/image racket/runtime-path (prefix-in g: racket/gui))

(provide (all-defined-out))

(struct configuration (sprite-size columns-count rows-count energy-bomb energy-fire energy-player energy-robot title))

(define default-configuration (configuration 32 15 10 10 4 30 30 "dynablaster"))        

(define (game-size columns-count rows-count)
  (struct-copy configuration default-configuration [columns-count columns-count] [rows-count rows-count]))

(define-runtime-path sound-file "medias/explode.wav")

(define-runtime-path grass-image-file "medias/grass.png")
(define-runtime-path rock-image-file "medias/rock.png")
(define-runtime-path brick-image-file "medias/brick.png")
(define-runtime-path bomb1-image-file "medias/bomb1.png")
(define-runtime-path bomb2-image-file "medias/bomb2.png")
(define-runtime-path player-image-file "medias/player.png")
(define-runtime-path robot-image-file "medias/robot.png")
(define-runtime-path fire-h-r-image-file "medias/fire-h-r.png")
(define-runtime-path fire-h-l-image-file "medias/fire-h-l.png")
(define-runtime-path fire-v-d-image-file "medias/fire-v-d.png")
(define-runtime-path fire-v-u-image-file "medias/fire-v-u.png")
(define-runtime-path fire-h-image-file "medias/fire-h.png")
(define-runtime-path fire-v-image-file "medias/fire-v.png")
(define-runtime-path fire-c-image-file "medias/fire-c.png")

(define IMAGE-EMPTY (rectangle 0 0 'solid 'green))

(define (load-image-png image-file)
  (make-object g:image-snip% (make-object g:bitmap% image-file 'png/mask)))

(define IMAGE-GRASS (load-image-png grass-image-file))

(define IMAGE-ROCK (load-image-png rock-image-file))

(define IMAGE-BRICK (load-image-png brick-image-file))

(define IMAGES-BOMB (list (load-image-png bomb1-image-file) 
                          (load-image-png bomb2-image-file)))

(define IMAGE-PLAYER (load-image-png player-image-file))

(define IMAGE-ROBOT (load-image-png robot-image-file))
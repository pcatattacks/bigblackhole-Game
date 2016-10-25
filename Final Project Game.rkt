;; This game is called "Big Blackhole". The goal is to escape the blackhole's
;; gravity and escape, while dodging asteroids that are being sucked into it.
;; The blackhole's gravity is constantly pulling your ship into it, so you must
;; use your engines to accelerate to avoid being sucked in.

;; You win when you move off the right edge of the window.

;; Press the SPACE key to fire engines and accelerate.

;; Press the UP and DOWN ARROW KEYS to move the ship upwards and downwards to
;; dodge the asteroids.

;; Remember, asteroids can destroy themselves, if they happen to collide with each other.
;; They're being sucked in with different velocities. Don't be surprised if many asteroids
;; destroy themselves at the start. However, the game is designed such that 'asteroid-count'
;; number of asteroids are always maintained on the screen. If one is destroyed, another one
;; comes right at you and replaces it!

;; You can EDIT THE DIFFICULTY of the game by -
;;   -    going to line 296 'Turnable Constants' and defining the variable
;;        'asteroid-count' to be a positive integer of your choice. The recommended
;;        integer is between 10 and 20. Go crazy if you wish.
;;   -    Changing the speed of the asteroids by going to line 171 and
;;        editing the first and second arguments of the (random-float) function to be
;;        more negative numbers. The greater the range, the more unpredictable the asteroids.
;;        The more negative the numbers, the faster the asteroids.

;; START THE GAME BY CALLING THE FUNCTION (bigblackhole).

(require 2htdp/image)
(require 2htdp/universe)
(require "struct-inheritance.rkt")

;;
;; keeping track of game objects
;;

(define all-game-objects '()) ;; this is a list of game objects

(define (destroy! object) ;; this removes game objects from the list, or 'destroys' them
  (set! all-game-objects
        (remove object all-game-objects)))

(define (add-game-object! object)
  (set! all-game-objects
        (cons object all-game-objects)))

(define the-player '())

;;
;; type definitions
;;

(define-struct game-object
  ([position #:mutable]
   [velocity #:mutable]
   radius))

(define-struct (player game-object) ()
  #:methods
  (define (render self) ;; done ;; to-do
    (rotate -90 (isosceles-triangle 30 40 "solid" "green")))
  (define (update self) ;; to-do
    (begin (when (equal? firing-engines? #t)
             (on-space-press))
           (when (equal? firing-up-engines? #t)
             (on-up-press))
           (when (equal? firing-down-engines? #t)
             (on-down-press))
           (set-game-object-velocity! self (posn-+ (game-object-velocity the-player)
                                                   (make-posn (* inter-frame-interval -4)
                                                              0))))))
  
(define-struct (blackhole game-object) ()
  #:methods
  (define (render self) ;; done ;; to-do
    (overlay (circle (/ (- window-height 5) 2) "outline" "white")
             (circle (/ (- window-height 5) 2) "solid" "black")))
  (define (update self) ;; done 
    0))

(define-struct (asteroid game-object) ()
  #:methods
  (define (render self) ;; done ;; to-do
    (circle 10 "solid" "brown"))
  (define (update self) ;; to-do
    ;(posn-+ (game-object-position self) - these two lines are unnecessary, update-physics! is already doing this for me.
     ;       (game-object-velocity self))))
    0))

;;;
;;; Handling Keyboard Input / Event Dispatch
;;;

(define firing-engines? false)
(define firing-up-engines? false)
(define firing-down-engines? false)

(define (on-key-press key) ;; whenever a keyboard event occurs, the game engine automatically calls this function
  (cond [(equal? key "up")
         (on-up-press)]
        [(equal? key "down")
         (on-down-press)]
        [(equal? key " ")
         (on-space-press)]
        [else null]))

(define (on-key-release key) ;; whenever a keyboard event occurs, the game engine automatically calls this function
  (cond [(equal? key "up")
         (on-up-release)]
        [(equal? key "down")
         (on-down-release)]
        [(equal? key " ")
         (on-space-release)]
        [else null]))

(define (on-up-press) ;; Called when the up arrow key is pressed - to-do
  (begin (set-game-object-velocity! the-player (posn-+ (make-posn 0
                                                                  (* inter-frame-interval -10))
                                                       (game-object-velocity the-player)))
         (set! firing-up-engines? #t)))

(define (on-up-release) ;; Called when the up arrow key is released - to-do
  (set! firing-up-engines? #f))

(define (on-down-press) ;; Called when the down arrow key is pressed - to-do
  (begin (set-game-object-velocity! the-player (posn-+ (make-posn 0
                                                                  (* inter-frame-interval 10))
                                                       (game-object-velocity the-player)))
         (set! firing-down-engines? #t)))

(define (on-down-release) ;; Called when the down arrow key is released - to-do
  (set! firing-down-engines? #f))

(define (on-space-press) ;; done ;; Called when the space bar is pressed. - to-do
  (begin
    (set-game-object-velocity! the-player
                             (posn-+ (game-object-velocity the-player)
                                     (make-posn (* inter-frame-interval 9)
                                                0)))
    (set! firing-engines? #t)))

(define (on-space-release)
  (set! firing-engines? #f))


;;;
;;; Object creation
;;;

(define (create-player) ;; creates player right in centre of window, with g towards left (blackhole) of -4 ms^-2. try experimenting with different g for more/less gravity
  (make-player (make-posn (* 0.5 window-width)
                          (* 0.5 window-height))
               (make-posn -4
                          0)
               18))

(define (create-blackhole) ;; creates blackhole, has position at extreme left, 0 velocity - fixed.
  (make-blackhole (make-posn 0
                            (* 0.5 window-height))
                  (make-posn 0 0)
                  (/ (- window-height 5)
                     2)
                  ))

(define (create-asteroid) ;; creates an asteroid object with random y position on extreme right of screen, and random velocity towards black hole, between 0 and -10. This varies asteroid speed and position.
  (make-asteroid (make-posn window-width
                            (* (random)
                               window-height))
                 (make-posn (random-float -150 -50)
                            0)
                 10))

;;;
;;; Driver loop / Main Game Loop
;;;

; (define (bigblackhole)
;   (begin (set! the-player (create-player))
;          (set! all-game-objects
;                (cons the-player
;                      (cons (create-blackhole)
;                            (build-list asteroid-count (λ (ignore) (create-asteroid)))))) ;; double check - you need to add more asteroids after a set number of frames, so list will change - more asteroids will be added by changing how you wrote the 'on-tick' function.
;          (big-bang all-game-objects
;                    (on-key (λ (ignore key)
;                              (begin (on-key-press key)
;                                     all-game-objects)))
;                    (on-release (λ (ignore key)
;                                  (begin (on-key-release key)
;                                         all-game-objects)))
;                    (on-tick (λ (game-objects)
;                               (begin (for-each update! game-objects) ;; done ;; still have to write an update! function - also, probs change update! to (map (λ (object) (update-object)) all-game-objects)
;                                      (update-physics!) ;; done ;; still have to write update-physics! function
;                                      (if (< (length ;; This code ensures that there are always asteroid-count number of asteroids on screen.
;                                              (filter asteroid? all-game-objects))
;                                             asteroid-count)
;                                          (add-game-object! (create-asteroid))
;                                          0)                                         
;                                      all-game-objects)) ;; - shouldn't all-game-objects be fed into the lambda, not within the begin expression?
;                             inter-frame-interval)
;                    (to-draw (λ (game-objects)
;                               (foldl (λ (object scene) ;; Ask - where is scene getting its input from?
;                                        (place-image (render object)
;                                                     (posn-x (game-object-position object))
;                                                     (posn-y (game-object-position object))
;                                                     scene))
;                                      (rectangle window-width window-height "solid" "black")
;                                      game-objects)) ;; Game objects isn't a defined list, all-game-objects is. shouldn't we use that?
;                             window-width
;                             window-height))))

;; ^ this is the old loop I had

;; The driver loop below is better, with a stop-when clause that displays a win-screen when you move off the right edge of the screen.


(define (bigblackhole)
  (begin (set! the-player (create-player))
         (set! all-game-objects
               (cons the-player
                     (cons (create-blackhole)
                           (build-list asteroid-count (λ (ignore) (create-asteroid)))))) ;; double check - you need to add more asteroids after a set number of frames, so list will change - more asteroids will be added by changing how you wrote the 'on-tick' function.
         (big-bang all-game-objects
                   (on-key (λ (ignore key)
                             (begin (on-key-press key)
                                    all-game-objects)))
                   (on-release (λ (ignore key)
                                 (begin (on-key-release key)
                                        all-game-objects)))
                   (on-tick (λ (game-objects)
                              (begin (for-each update! game-objects) ;; done ;; still have to write an update! function - also, probs change update! to (map (λ (object) (update-object)) all-game-objects)
                                     (update-physics!) ;; done ;; still have to write update-physics! function
                                     (if (< (length ;; This code ensures that there are always asteroid-count number of asteroids on screen.
                                             (filter asteroid? all-game-objects))
                                            asteroid-count)
                                         (add-game-object! (create-asteroid))
                                         0)                                         
                                     all-game-objects)) ;; - shouldn't all-game-objects be fed into the lambda, not within the begin expression?
                            inter-frame-interval)
                   (to-draw (λ (game-objects)
                              (foldl (λ (object scene) ;; Ask - where is scene getting its input from?
                                       (place-image (render object)
                                                    (posn-x (game-object-position object))
                                                    (posn-y (game-object-position object))
                                                    scene))
                                     (rectangle window-width window-height "solid" "black")
                                     game-objects)) ;; Game objects isn't a defined list, all-game-objects is. shouldn't we use that?
                            window-width
                            window-height)
                   (stop-when player-off-screen?
                              (λ (ignore)
                                (place-image (text "YOU WIN!" 20 "yellow")
                                           (* 0.5 window-width)
                                           (* 0.5 window-height)
                                           (rectangle window-width window-height "solid" "black")))))))

(define (player-off-screen? ignore)
  (if (>= (posn-x (game-object-position the-player))
               window-width)
      #t
      #f))
                   

;;;
;;; State update
;;;
                   
(define (update! object)
  (map update all-game-objects))

; (define (update-physics!)
;   (begin (for-each (λ (object)
;                      (begin (set-game-object-position! object
;                                                        (local [(define new-position
;                                                                  (posn-+ (posn-* inter-frame-interval
;                                                                                  (game-object-velocity object))
;                                                                          (game-object-position object)))]
;                                                          (make-posn (wrap (posn-x new-position) window-width)
;                                                                     (wrap (posn-y new-position) window-height))))))
;                    all-game-objects)
;          (handle-collisions all-game-objects))) 
;; done ;; to-do - write collision handling function
(define (update-physics!)
  (begin (for-each (λ (object)
                     (begin (set-game-object-position! object
                                                       (local [(define new-position
                                                                 (posn-+ (posn-* inter-frame-interval
                                                                                 (game-object-velocity object))
                                                                         (game-object-position object)))]
                                                         (make-posn (posn-x new-position)
                                                                    (wrap (posn-y new-position) window-height))))))
                   all-game-objects)
         (handle-collisions all-game-objects))) 


;;;
;;; Collision handling
;;;

(define (handle-collisions objects) ;; a recursive function that checks every object against every object, if its collided or not.
  (unless (empty? objects)
    (local [(define head (first objects))
            (define tail (rest objects))]
      (begin (for-each (λ (object)
                         (when (collided? head object)
                           (handle-collision head object)))
                       tail)
             (handle-collisions tail)))))

(define (collided? a b) ;; gives boolean value of whether the distance between the centres of the two objects is lesser than the sum of their radii.
  (< (distance-squared (game-object-position a)
                       (game-object-position b))
     (squared (+ (game-object-radius a)
                 (game-object-radius b)))))

(define (handle-collision a b) ;; if any object collides with any object, it is destroyed.
  (cond [(and
          (or (blackhole? a) (blackhole? b))
          (or (player? a) (player? b)))
         (destroy! the-player)]
        [(and
          (or (blackhole? a) (blackhole? b))
          (or (asteroid? a) (asteroid? b)))
         (if (asteroid? a)
             (destroy! a)
             (destroy! b))]
        [else (begin (destroy! a)
                     (destroy! b))]))

;; ^^ I've ensured that the blackhole is never destroyed, only objects that collide with it, or each other.

;; -----------------------------------------------------------------------------------
;; CONSTANTS

;;;
;;; Turnable constants
;;;

(define window-width 800)
(define window-height 600)
(define frame-rate 30)
(define inter-frame-interval (/ 1.0 frame-rate))
(define asteroid-count 20) ;; Change to change the number of asteroids on screen at any point.

;;
;; Fixed constants
;;

(define radians->rotation-coefficient
  (/ -360.0
     (* 2 pi)))

(define (radians->rotation radians)
  (+ (* radians radians->rotation-coefficient)
     -90))


;; -----------------------------------------------------------------------------------
;; PRE-DEFINED FUNCTIONS

;;;
;;; Randomization
;;;

(define random-color
  (local [(define colors
            (list (color 255 0 0)
                  (color 0 255 0)
                  (color 0 0 255)
                  (color 128 128 0)
                  (color 128 0 129)
                  (color 0 128 128)))]
    (λ () (random-element colors))))

(define (random-element list)
  (list-ref list
            (random (length list))))

(define (random-float min max)
  (+ min
     (* (random)
        (- max min))))

(define (random-velocity)
  (make-posn (random-float -10 10)
             (random-float -10 10)))

;;;
;;; Vector arithmetic
;;;

(define (posn-+ a b)
  (make-posn (+ (posn-x a)
                (posn-x b))
             (+ (posn-y a)
                (posn-y b))))

(define (posn-* k p)
  (make-posn (* k (posn-x p))
             (* k (posn-y p))))

(define (distance-squared p1 p2)
  (+ (squared (- (posn-x p1)
                 (posn-x p2)))
     (squared (- (posn-y p1)
                 (posn-y p2)))))

;;;
;;; Other arithmetic utilities
;;;

(define (wrap number limit)
  (cond [(< number 0)
         (+ number limit)]
        [(> number limit)
         (- number limit)]
        [else
         number]))

(define (squared x)
  (* x x))

# bigblackhole-Game
A 2D game I programmed in Racket (LISP-like). There's asteroids, a spaceship and a really big Black-Hole.

# Description

This game is called "Big Black-hole". The goal is to escape the blackhole's gravity and escape, while dodging asteroids that are being sucked into it. The blackhole's gravity is constantly pulling your ship into it, so you must use your engines to accelerate to avoid being sucked in.

You win when you move off the right edge of the window.

# Instructions

Press the SPACE key to fire engines and accelerate. 
Press the UP and DOWN ARROW KEYS to move the ship upwards and downwards to dodge the asteroids.

Remember, asteroids can destroy themselves, if they happen to collide with each other. They're being sucked in with different velocities. Don't be surprised if many asteroids destroy themselves at the start. However, the game is designed such that 'asteroid-count' number of asteroids are always maintained on the screen. If one is destroyed, another one comes right at you and replaces it!

START THE GAME BY CALLING THE FUNCTION (bigblackhole).

# You can EDIT THE DIFFICULTY of the game by:
- going to line 296 'Turnable Constants' and defining the variable 'asteroid-count' to be a positive integer of your choice. The recommended integer is between 10 and 20. Go crazy if you wish.
- Changing the speed of the asteroids by going to line 171 and editing the first and second arguments of the (random-float) function to be more negative numbers. The greater the range, the more unpredictable the asteroids. The more negative the numbers, the faster the asteroids.

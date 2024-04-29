######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

# Colours
BACKGROUND:
.word 0x000000

# Wall colour
WHITE:
.word 0xffffff  # white wall 

GRAY:
.word 0x8e9c9b

RED_BRICK_SCHEME:
# distinct colour scheme with red
.word 0x750000 
.word 0xF77777 
.word 0xA30000
.word 0xFF8A8A
.word 0xD10000 
.word 0xFC5858 
.word 0xF5A4A4 
.word 0xFF0000 


BLUE_BRICK_SCHEME:
# distinct colour scheme with blue
.word 0x003366 
.word 0x336699 
.word 0x6699CC 
.word 0x99CCFF 
.word 0x003399 
.word 0x0066CC 
.word 0x0099FF 
.word 0x33CCFF 


GREEN_BRICK_SCHEME:
# distinct colour scheme with green
.word 0x006600
.word 0x003300
.word 0x99FFCC
.word 0x00CC66
.word 0x009900
.word 0x33FF99
.word 0x66FFCC
.word 0xCCFFCC

BLACK:
    .word 0x000000
    
ORANGE:
    .word 0xffa500

RED:
	.word 0xFF0000

BROWN:
	.word 0x4a2511

PURPLE:
	.word 0xA020F0

##############################################################################
# Mutable Data
##############################################################################
# Ball:

myArray: 
initial_x: .word 3
initial_y: .word 30
initial_size: .word 8

Ball:
ball_x: .word 4
ball_y: .word 15
direction_x: .word 1 # right (-1 left)
direction_y: .word 1 # down 

LIVES:
number: .word 3
x1: .word 22
x2: .word 25
x3: .word 28
y: .word 3

SCOREBOARD:
	score: .word 0
	score_10s: .word 0
	score_100s: .word 0
	score_1: .word 3
	score_2: .word 9
	score_y: .word 0

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main: # Draw the scene 
    # Initialize the game
    
   # Set background to white
   la $a0, ADDR_DSPL    # Load the address
   lw $a0, 0($a0)       # load the memory of it 
   la $t0, WHITE        # load address of WHITE
   lw $t0, 0($t0)       # Load the value of WHITE into $t0
   li $t1, 0            # Initialize the loop counter to 0
   
   paint_background:
   sw $t0, 0($a0)  # Store the value of WHITE into the display memory at the address in $t0
   addi $a0, $a0, 4 # Increment the memory address by 4 bytes
   addi $t1, $t1, 1 # Increment the loop counter
   blt $t1, 1024, paint_background # Branch back to beginning of loop until all pixels drawn
   
   # Draw the gray line for ceiling
   la $t0, GRAY # load colour gray appropriately
   la $a0, ADDR_DSPL
   lw $a0, 0 ($a0)
   addi $a0, $a0, 640
   lw $t0, 0($t0)
   li $t1, 0 # set counter to 0
   
   loop_ceiling:
   sw $t0, 0($a0) # draw the pixel
   addi $a0, $a0, 4
   addi $t1, $t1, 1 
   blt $t1, 32, loop_ceiling # just need to draw top-most
   
   # Draw the two walls on left-most and right-most column
   la $a0, ADDR_DSPL
   lw $a0, 0($a0)
   addi $a0, $a0, 768
   la $a1, ADDR_DSPL
   lw $a1, 0 ($a1)
   addi $a1, $a1, 892 # right-mst
   li $t1, 0 # set index to 0
   
   # draw left line
   li $t1, 0 # start index at 0
   wall_1:
   	sw $t0, 0 ($a0)
   	sw $t0, 0 ($a1)
   	addi $a0, $a0, 128
   	addi $a1, $a1, 128
   	addi $t1, $t1, 1
   	blt $t1, 26, wall_1
  
  
  # DRAWING THE THREE BRICKS 
  la $a0, ADDR_DSPL # FIRST ROW
  lw $a0, 0 ($a0)
  addi $a0, $a0, 772
  la $a1, ADDR_DSPL # SECOND ROW
  lw $a1, 0 ($a1)
  addi $a1, $a1, 900
  la $t0, ADDR_DSPL 
  lw $t0, 0 ($t0)
  addi $t0, $t0, 1028
  
  # load address of colour schemes
  la $a2, RED_BRICK_SCHEME
  la $a3, BLUE_BRICK_SCHEME
  la $t5, GREEN_BRICK_SCHEME
  
  # draw 8 bricks with different colors from
  # RED_BRICK_SCHEME, BLUE_BRICK_SCHEME, GREEN_BRICK_SCHEME
  li $t1, 0 # index 
  li $t6, 4 # getting to next index of colour scheme
  
  draw_bricks:
    # calculate index into colour scheme
    mult $t1, $t6
    mflo $t3 #offset
    mflo $t4 
    mflo $t7
    add $t3, $a2, $t3 # get brick colour [RED]
    add $t4, $a3, $t4 # get brick colour [BLUE]
    add $t7, $t5, $t7 # get brick colour [GREEN]
    
    # load color from brick schemes
    lw $t3, 0($t3)
    lw $t4, 0 ($t4) 
    lw $t7, 0 ($t7) 
    
    # draw brick with color
    sw $t3, 0($a0) # RED
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    
    sw $t4, 0 ($a1) # BLUE
    addi $a1, $a1, 4
    sw $t4, 0 ($a1)
    
    sw $t7, 0 ($t0) # GREEN
    addi $t0, $t0, 4
    sw $t7, 0 ($t0)
    
    
    blt $t1, 7, not_last
    addi $t1, $t1, 1
    j finish
    
    not_last:
    	addi $a0, $a0, 4 # RED
    	sw $t3, 0($a0)
    	addi $a0, $a0, 4
    	sw $t3, 0($a0)
    	addi $a0, $a0, 4
    	addi $t1, $t1, 1
    	addi $a1, $a1, 4 # BLUE
    	sw $t4, 0($a1)
    	addi $a1, $a1, 4
    	sw $t4, 0($a1)
    	addi $a1, $a1, 4
    	addi $t4, $t4, 1
    	addi $t0, $t0, 4 # GREEN
    	sw $t7, 0($t0)
    	addi $t0, $t0, 4
    	sw $t7, 0($t0)
    	addi $t0, $t0, 4
    	addi $t7, $t7, 1
    
    finish:
    	blt $t1, 8, draw_bricks # just add 8 bricks 
    
    # DRAW PADDLE
    la $t0, myArray # fetch initial x and y 
    lw $t1, 0 ($t0)
    lw $t2, 4 ($t0)
    lw $t4, 8 ($t0) # size of the paddl
    move $a0, $t1 # memory address to draw on
    move $a1, $t2
    jal get_pixel
    
    move $a2, $v0 # return value in a0 
    la $t3, BLACK
    lw $a3, 0 ($t3) # colour
    
    jal drawPaddle
    
    # DRAW BALL
    la $t0, Ball # fetch initial x and y 
    lw $t1, 0 ($t0)
    lw $t2, 4 ($t0)
    move $a0, $t1 # memory address to draw on
    move $a1, $t2
    jal get_pixel
    
    move $a2, $v0 # return value in a0 
    la $t3, ORANGE
    lw $a3, 0 ($t3) # colour 
    jal draw_ball
    
    # Draw the three initial lives 
    jal draw_lives 
    
    # draw unbreakable bricks
    # a square with 3 by 3 pixels
    li $a0, 14
    li $a1, 17
    jal get_pixel
    move $a2, $v0
    la $t0, GRAY
    lw $t0, 0($t0)
    sw $t0, 0($a2)
    addi $a2, $a2, 4
    sw $t0, 0($a2)
    addi $a2, $a2, 4
    sw $t0, 0($a2)
    li $a0, 14
    li $a1, 18
    jal get_pixel
    move $a2, $v0
    la $t0, GRAY
    lw $t0, 0($t0)
    sw $t0, 0($a2)
    addi $a2, $a2, 4
    sw $t0, 0($a2)
    addi $a2, $a2, 4
    sw $t0, 0($a2)
    li $a0, 14
    li $a1, 19
    jal get_pixel
    move $a2, $v0
    la $t0, GRAY
    lw $t0, 0($t0)
    sw $t0, 0($a2)
    addi $a2, $a2, 4
    sw $t0, 0($a2)
    addi $a2, $a2, 4
    sw $t0, 0($a2)  
    
    b game_loop

###########################################################################################    

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    # Check collision (right + top + left + bottom) -> not white then change direction
    jal check_collision
    jal move_ball
    jal hits_bottom
    
    #  Move ball 
    
    # Pause for 100 milliseconds
    li $a0, 250            # Set delay time to 100 milliseconds
    li $v0, 32              # Load the system call code for delay
    syscall                 # Call the system call
    

    b game_loop

keyboard_input:                        # A key is pressed
    lw $a0, 4($t0)                  	# Load second word from keyboard
    beq $a0, 0x71, exit     		# Check if the key q was pressed
    beq $a0, 0x41, respond_to_left     # Check if A key was pressed
    beq $a0, 0x44, respond_to_right    # Check if D key was pressed
    beq $a0, 0x50, pause               # Pause the game when P is pressed 
    b game_loop

# This function runs when the user inputs A
# It retreives the location of the previous paddle
# It looks at the size of the paddle and gets to the last
# pixel to erase it.
# Instead draw at the front 
respond_to_left:
    # erase previous paddle (draw white)
    la $t0, myArray
    lw $t1, 0($t0) # load x into $t1
    ble $t1, 1, game_loop
    
    lw $t2, 4($t0) # load y into $t2
    lw $t4, 8($t0) # size into $t4
    move $a0, $t1 # memory address to draw on
    move $a1, $t2
    jal get_pixel
    
    # erase previous paddle
    move $a2, $v0
    la $a3, WHITE
    lw $a3, 0 ($a3)
    
    jal drawPaddle
    # DRAW A NEW PADDLE ONE TO THE LEFT
    la $t0, myArray   # load the address of myArray into $t0
    lw $t1, 0($t0)    # fetch initial x coordinate
    addi $t1, $t1, -1 # decrement x coordinate by 1
    sw $t1, 0($t0)    # store updated x coordinate back into myArray
    lw $t2, 4($t0)    # fetch y coordinate
#    add $t1, $t1, -1
    
    move $a0, $t1 # memory address to draw on
    move $a1, $t2
    jal get_pixel
    # draw a new paddle
    move $a2, $v0
    la $a3, BLACK
    lw $a3, 0 ($a3)
    
    jal drawPaddle
    
    b game_loop

   
respond_to_right:
    # erase previous paddle (draw white)
    la $t0, myArray
    lw $t1, 0($t0)
    bgt $t1, 22, game_loop
    
    lw $t2, 4($t0)
    lw $t4, 8($t0) # size of the paddle
    move $a0, $t1 # memory address to draw on
    move $a1, $t2
    jal get_pixel
    
    # erase previous paddle
    move $a2, $v0
    la $a3, WHITE
    lw $a3, 0 ($a3)
    
    jal drawPaddle
    
    # DRAW A NEW PADDLE ONE TO THE RIGHT
    la $t0, myArray   # load the address of myArray into $t0
    lw $t1, 0($t0)    # fetch initial x coordinate
    addi $t1, $t1, 1  # increment x coordinate by 1
    sw $t1, 0($t0)    # store updated x coordinate back into myArray
    lw $t2, 4($t0)    # fetch y coordinate
#    add $t1, $t1, 1
    
    move $a0, $t1 # memory address to draw on
    move $a1, $t2
    jal get_pixel
    
    # draw a new paddle
    move $a2, $v0
    la $a3, BLACK
    lw $a3, 0 ($a3)
    
    jal drawPaddle
    
    b game_loop

# HELPERS
drawPixels:
	sw $t7, 0($s0)  # Store the value of colour into the display memory at the address in $t7
    	addi $s0, $s0, 4 # Increment the memory address by 4 bytes
    	addi $t6, $t6, 1 # Increment the loop counter
    	blt $t6, $a3, drawPixels
    	
    	# jr $ra
    	
# draws a paddle of given size and color at given pixel position
# $a2 - pixel position
# $a3 - paddle color
# $t4 - paddle size (number of pixels)
drawPaddle:
    # initialize loop variables
    li $s0, 0    # paddle pixel counter
    move $s1, $a2 # current pixel position
    
drawPaddle_loop:
    # draw current paddle pixel
    sw $a3, 0($s1)

    # update loop variables
    addi $s0, $s0, 1         # increment paddle pixel counter
    addi $s1, $s1, 4         # move to next pixel position
#    blt $s0, $t4, drawPaddle_loop  # repeat loop if more pixels to draw
    blt $s0, 8, drawPaddle_loop  # repeat loop if more pixels to draw
        
    # reset 
    li $s0, 0
    li $s1, 0
    jr $ra



# given a pixel's location address, get x and y coordinates
get_coords:
# $a0 is the location address
	div $t0, $a0, 4 # store x coord in s7
	div $t1, $a0, 128 # store y coord in s6
	
	
	add $v0, $v0, $t0 # add the x address
	add $v1, $v1, $t1 # add the y address 

	jr $ra

# given an X and Y value, get the location address 
get_pixel:
	sll $t0, $a0, 2 # multiply x by 4 
	sll $t1, $a1, 7 # multiply y by 128 
	
	la $v0, ADDR_DSPL # store the result
	lw $v0, 0 ($v0)
	
	add $v0, $v0, $t0 # add the x address
	add $v0, $v0, $t1 # add the y address 

	jr $ra 

draw_ball: 
	move $t0, $a2
	move $t1, $a3
	sw $t1, 0($t0)  # just draw a pixel
	jr $ra
	
move_ball:
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push $ra
	
	la $t0, Ball # load the ball
    	lw $a0, 0 ($t0) # x position
    	lw $a1, 4 ($t0) # y position
    	lw $t3, 8 ($t0) # x direction
    	lw $t4, 12($t0) # y direction
    	
    	jal get_pixel
    	move $a2, $v0
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	addi $sp, $sp, -4  # allocate position
	sw $ra, 0($sp)     # save $ra 
	
    	la $a3, WHITE # turn the old pixel white
    	lw $a3, 0($a3)
    	jal draw_ball
    	
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	# draw a new one 
    	la $t0, Ball # load the ball
    	lw $a0, 0 ($t0) # x position
    	lw $a1, 4 ($t0) # y position
    	lw $t3, 8 ($t0) # x direction
    	lw $t4, 12($t0) # y direction
    	add $a0, $a0, $t3 # new x 
    	add $a1, $a1, $t4 # new y
    	sw $a0, 0 ($t0) # store them
    	sw $a1, 4 ($t0)
    	
    	addi $sp, $sp, -4  # allocate position
	sw $ra, 0($sp)     # save $ra 
	jal get_pixel
    	move $a2, $v0
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
	
	
    	addi $sp, $sp, -4  # allocate position
	sw $ra, 0($sp)     # save $ra 
    	la $a3, ORANGE # turn the old pixel white
    	lw $a3, 0($a3)
    	jal draw_ball
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	jr $ra
    	
check_collision:
	addi $sp, $sp, -4  # allocate position
	sw $ra, 0($sp)     # save $
	
	jal hit_horizontal  # check if the ball hits the walls  
	jal hit_vertical  # check if the ball hits top or bottom
	jal hit_diagonal # check if the ball hits the paddle digonally 
	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
	jr $ra 

hit_horizontal:
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 				 # push $ra
	
	la $t0, Ball # load the ball
    	lw $a0, 0 ($t0) # x position
    	lw $a1, 4 ($t0) # y position
    	lw $t3, 8 ($t0) # x direction
    	lw $t4, 12($t0) # y direction
    	
    	add $a0, $a0, $t3 # new x position
    	jal get_pixel
    	move $a2, $v0
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	# colour of the unit 
    	lw $t1, 0($v0) 
    	
    	beq $t1, 0xffffff, no_collision # normal ball movement
    	
    	# ball collides with something 
    	la $t0, Ball 
    	lw $t3, 8($t0) # make the ball go right moving forward
    	neg $t3, $t3 
    	sw $t3, 8 ($t0) 
    	
    	# ball may hit a break
    	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	 # push $ra
    	bne $t1, 0x8e9c9b, next # hits a brick
    	next:
    		bne $t1, 0x000000, hit_brick
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
	li $a0, 100
	li $a1, 1			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 100			# play at volume 80 (half) (0-127)
	li $v0, 33			# play midi tone syscall command
	syscall                         # make syscall to play the note
    	
    	jr $ra 

hit_vertical:
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push $ra
	
	la $t0, Ball # load the ball
    	lw $a0, 0 ($t0) # x position
    	lw $a1, 4 ($t0) # y position
    	lw $t3, 8 ($t0) # x direction
    	lw $t4, 12($t0) # y direction
    	
    	add $a1, $a1, $t4 # new y position
    	jal get_pixel
    	move $a2, $v0
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	# colour of the unit 
    	lw $t1, 0($v0) 
    	
    	beq $t1, 0xffffff, no_collision # normal ball movement
    	
    	# ball collides with something 
    	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push $ra
    	
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	la $t0, Ball 
    	lw $t4, 12($t0) # make the ball go right moving forward
    	neg $t4, $t4
    	sw $t4, 12 ($t0) 
    	
    	# ball may hit a break
    	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push $ra
	bne $t1, 0x8e9c9b, hit_brick # hits a brick
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
	li $a0, 100
	li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 80			# play at volume 80 (half) (0-127)
	li $v0, 33			# play midi tone syscall command
	syscall                         # make syscall to play the note
    	
    	jr $ra 

# changes the direction based on where it hits 

hit_diagonal: 
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 				 # push $ra
	
	la $t0, Ball # load the ball
    	lw $a0, 0 ($t0) # x position
    	lw $a1, 4 ($t0) # y position
    	lw $t3, 8 ($t0) # x direction
    	lw $t4, 12($t0) # y direction
    	
    	
    	add $a1, $a1, $t4 # new y position
    	add $a0, $a0, $t3 # new x position
    	jal get_pixel
    	move $a2, $v0
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	# colour of the unit 
    	lw $t1, 0($v0) 
    	
    	beq $t1, 0xffffff, no_collision # normal ball movement
    	
    	# ball collides with something 
    	la $t0, Ball 
    	lw $t3, 8($t0) 
    	lw $t4, 12($t0) # make the ball go right moving forward
    	neg $t3, $t3 
    	neg $t4, $t4
    	sw $t4, 12 ($t0) 
    	sw $t3, 8 ($t0)
    	
    	# ball may hit a break
    	addi $sp, $sp, -4  
	sw $ra, 0($sp) 				 # push $ra
    	bne $t1, 0x8e9c9b, hit_brick # hits a brick
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
	li $a0, 100
	li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 80			# play at volume 80 (half) (0-127)
	li $v0, 33			# play midi tone syscall command
	syscall                         # make syscall to play the note
    	
    	jr $ra 

   	
draw_lives:
	# store space in the stack 
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push 	
	la $t1, LIVES
	
	# first life 
	lw $a0, 4($t1)
	lw $a1, 16($t1)
	jal get_pixel
	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore	
	la $a2, RED
	lw $a2, 0 ($a2)
	sw $a2, 0 ($v0)
	
	# second life 
	la $t1, LIVES
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push
	lw $a0, 8($t1)
	lw $a1, 16($t1)
	jal get_pixel
	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore	
	la $a2, RED
	lw $a2, 0 ($a2)
	sw $a2, 0 ($v0)
	
	# third life 
	la $t1, LIVES
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push
	lw $a0, 12($t1)
	lw $a1, 16($t1)
	jal get_pixel
	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore	
	la $a2, RED
	lw $a2, 0 ($a2)
	sw $a2, 0 ($v0)
	
	jr $ra 
no_collision:
	jr $ra 

hit_brick:
	# once a brick pixel has been located
	# turn it into a different colour to denote 
	# it has been hit
	# check its adjacent blocks to see 
	# find the adjacent 
	beq $t1, 0x000000, next_hit
	beq $t1, 0xffffff, next_hit
	beq $t1, 0x8e9c9b, next_hit
	beq $t1, 0x4a2511, hit_brown
	beq $t1, 0xA020F0, hit_purple
	bne $t1, 0x4a2511, hit_right
	
	jr $ra

next_hit:
	jr $ra
hit_brown:
	la $t0, PURPLE
	lw $t0, 0($t0)
	sw $t0, ($a2)
	jr $ra
	
hit_right:
	la $t0, BROWN
	lw $t0, 0($t0)
	sw $t0, ($a2)
	jr $ra
	
hit_purple:
	la $t0, WHITE
	lw $t0, 0($t0)
	sw $t0, ($a2)
	jr $ra
	

hits_bottom:
	# check if the ball reaches the last row
	# decrement the lives by 1 
	# if lives is 2 now then erase first
	# if lives is 1 then erase second
	# if lives is 0 erase all -> go to exit 
	# set the ball to initial position after each 
	
	la $t0, Ball # load the ball
    	lw $a1, 4 ($t0) # y position
    	beq $a1, 31, life_ends # reached last row 
    	jr $ra 
    	life_ends:
    		la $t1, LIVES 
    		lw $t2, 0 ($t1)
    		addi $t2, $t2, -1 
    		sw $t2, 0 ($t1) 
    		beq $t2, 2, equals_two
    		beq $t2, 1, equals_one
    		beq $t2, 0, equals_zero
    		jal change_ball 
    	equals_two:
    		addi $sp, $sp, -4  
		sw $ra, 0($sp) 	# push
		lw $a0, 4($t1)
		lw $a1, 16($t1)
		jal get_pixel
		lw $ra, 0($sp) #pop the $ra
    		addi $sp, $sp, 4 #restore	
		la $a2, WHITE
		lw $a2, 0 ($a2)
		sw $a2, 0 ($v0)
		jal change_ball
	equals_one:
    		addi $sp, $sp, -4  
		sw $ra, 0($sp) 	# push
		lw $a0, 8($t1)
		lw $a1, 16($t1)
		jal get_pixel
		lw $ra, 0($sp) #pop the $ra
    		addi $sp, $sp, 4 #restore	
		la $a2, WHITE
		lw $a2, 0 ($a2)
		sw $a2, 0 ($v0)
		jal change_ball
	equals_zero:
    		addi $sp, $sp, -4  
		sw $ra, 0($sp) 	# push
		lw $a0, 12($t1)
		lw $a1, 16($t1)
		jal get_pixel
		lw $ra, 0($sp) #pop the $ra
    		addi $sp, $sp, 4 #restore	
		la $a2, WHITE
		lw $a2, 0 ($a2)
		sw $a2, 0 ($v0)
		j exit

# reset the ball position
change_ball:
	 # DRAW BALL
	 # erase the old one
    	la $t0, Ball # fetch initial x and y 
    	lw $t1, 0 ($t0)
    	lw $t2, 4 ($t0)
    	move $a0, $t1 # memory address to draw on
    	move $a1, $t2
    	
    	# store space in the stack  	
    	jal get_pixel
    
   	move $a2, $v0 # return value in a0 
    	la $t3, WHITE
    	lw $a3, 0 ($t3) # colour 
    	# store space in the stack 
	addi $sp, $sp, -4  
	sw $ra, 0($sp) 	# push 	
    	jal draw_ball
    	lw $ra, 0($sp) #pop the $ra
    	addi $sp, $sp, 4 #restore
    	
    	# reset
    	la $t0, Ball # fetch initial x and y 
    	li $a0, 10
    	li $a1, 25
    	sw $a0, 0($t0)
    	sw $a1, 4 ($t0)
    	jal get_pixel
    
   	move $a2, $v0 # return value in a0 
    	la $t3, ORANGE
    	lw $a3, 0 ($t3) # colour 
    	jal draw_ball
    	b game_loop
    	jr $ra

pause:    
    li $v0, 32
    li $a0, 10000
    syscall
    
    jr $ra
    
    #beq $a0, 0x50, then # Unpause the game when P is pressed
    #    then:
    #        jr $ra
    #jal pause

#pause:
#	li $v0, 30
#	syscall
#	
#	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
#	lw $t8, 0($t0)                  # Load first word from keyboard
#	beq $a0, 1, then # Unpause the game when P is pressed
#	j pause

#then:
#	lw $a0, 4($t0)                  	# Load second word from keyboard
#	beq $a0, 0x50, unpause # Unpause the game when P is pressed

#unpause:
#	jr $ra

#make_sound:
#	li $a1, 80			# play 150 ms tone
#	li $a2, 0			# play instrument 0 (piano)
#	li $a3, 80			# play at volume 80 (half) (0-127)
#	li $v0, 31			# play midi tone syscall command
#	syscall                         # make syscall to play the note
		
#	jr $ra

exit:
	over_sound:
	li $a0, 80
	li $a1, 1000				#Stores 100 in first argument
        li $a2, 121
        li $a3, 100 #pause for 100
        li $v0, 31
        syscall	
    	
	li $v0, 10
	syscall




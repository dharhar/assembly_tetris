################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
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
    
I_TYPE_HORIZONTAL:
    .byte 4, 4, 4    # differences of one address with the next
    
# I_TYPE_VERTICAL:
    # .space 16                       # 


##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
	
	
main:

        # Initialize the game
    lw $t0, ADDR_DSPL       # $t0 = base address for display

    li $t1, 0x383838        # COLOR_GRID_ONE
    li $t2, 0x1c1c1c        # COLOR_GRID_TWO
    
    add $t3, $zero, $zero #set index value ($t3) to zero
    
    li $t9, 0
    li $t8, 256
    add $t5, $t0, $t9
    
    j init_board
        
    addi $t2, $zero, 0	# h_count
    addi $t3, $zero, 0	# w_count
    addi $t4, $zero, 0  # even
    
    # Initialize the game
    li $t1, 0x525252            # set $t1 to grey
    
    
init_board:                             # draw a grid across the entire screen
        beq $t9, 4096, draw_border      # once the entire grid is drawn, jump to drawing the playing box
        
        div $t9, $t8
        mfhi $t7
        
        li $t3, 0
        
        beq $t7, 0, draw_even_row
        beq $t7, 128, draw_odd_row
        
        j exit
        
end_init_board:
        
    draw_even_row:                          # starts with gray two
        sw $t2, 0($t5)
        addi $t5, $t5, 4
        sw $t1, 0($t5)
        addi $t5, $t5, 4
        
        addi $t3, $t3, 4
        addi $t9, $t9, 8
        beq $t3, 64 init_board
        
        j draw_even_row
        
    draw_odd_row:                           # starts with gray one  
        sw $t1, 0($t5)
        addi $t5, $t5, 4
        sw $t2, 0($t5)
        addi $t5, $t5, 4
        
        
        addi $t3, $t3, 4
        addi $t9, $t9, 8
        beq $t3, 64, init_board
        
        j draw_odd_row

draw_border:
    
    li $t1, 0xa6a6a6     
    sw $t1, 776($t0)
    
    addi $a0, $zero, 21	# height of display
    addi $a1, $zero, 11	# width of display
    add $t0, $zero, $zero
    
    add $t2, $zero, $zero
    add $t3, $zero, $zero
    add $t5, $zero, $zero
    add $t8, $zero, $zero
    add $t9, $zero, $zero

    
    init_h:
        lw $t0, ADDR_DSPL           # $t0 = base address for display
        addi $t0, $t0, 3336         # move to the first byte where we want to draw the box

    draw_h:
        sw $t1, 0($t0)              # paint $t0 grey
        beq $t3, $a1, init_v        # if we've finished the bottom row, stop
        
        addi $t0, $t0, 4            # move to next pixel
        addi $t3, $t3, 1            # increment counter
        j draw_h                    # if not, continue
        
    init_v:
        lw $t0, ADDR_DSPL           # $t0 = base address for display
        addi $t0, $t0, 776
        
    draw_v:
        sw $t1, 0($t0)              # paint $t0 grey
        addi $t0, $t0, 128          # move to next pixel (downwards)
        addi $t2, $t2, 1            # increment counter
        
        beq $t2, $a0, up_v
        
        mul $t8, $a0, 2
        
        beq $t2, $t8, cover_background
        j draw_v
        
        
    up_v:
        lw $t0, ADDR_DSPL 
        addi $t0, $t0, 820          # go to the address for the top right of the box
        j draw_v
        
cover_background: 
    li $t1, 0x000000            # use a black color for the background
    init_draw_upper_sec: 
        lw $t0, ADDR_DSPL           # go back to the top  left corner of bitmap display     
        li $t2, 0                   # incrementer variable
    
    draw_upper_sec:
        beq $t2, 192, init_draw_lower_sec
        sw $t1, 0($t0)
        add $t0, $t0, 4
        addi $t2, $t2, 1
        j draw_upper_sec
    
    init_draw_lower_sec:
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 3456
        li $t2, 0       
        
    draw_lower_sec:
        beq $t2, 160, init_draw_left_sec
        sw $t1, 0($t0)
        add $t0, $t0, 4
        addi $t2, $t2, 1
        j draw_lower_sec
    
    init_draw_left_sec:
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 768
        li $t2, 0
        
    draw_left_sec:
        beq $t2, 21, init_draw_right_sec
        sw $t1, 0($t0)
        add $t0, $t0, 4
        sw $t1, 0($t0)
        add $t0, $t0, 124
        
        addi $t2, $t2, 1
        j draw_left_sec
        
    init_draw_right_sec:
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 768
        li $t2, 0
        # sw $t1, 0($t0)
    
    draw_right_sec:
        beq $t2, 21, init_colors
        li $t3, 0
        addi $t0, $t0, 56
        addi $t2, $t2, 1
        j draw_row_for_right_sec
        
        
    
    draw_row_for_right_sec:
        beq $t3, 18, draw_right_sec
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        addi $t3, $t3, 1
        j draw_row_for_right_sec
           
end_cover_background: 
        

init_colors:
    lw $t0, ADDR_DSPL
    li $t9, 0xffffff
    la $s0, I_TYPE_HORIZONTAL
    j draw_sample
        
draw_sample:                # test drawing an I type tile
    lb $t1, 0($s0)          # get first offset address
    addi $t0, $t0, 792      # go to the middle of the grid
    sw $t9, 0($t0)          # draw first square
    
    add $t0, $t0, $t1       # move to next address
    sw $t9, 0($t0)          # draw second square (first square + offset from I_TYPE_HORIZONTAL)
    
    lb $t1, 1($s0)
    add $t0, $t0, $t1
    sw $t9, 0($t0)
    
    lb $t1, 2($s0)
    add $t0, $t0, $t1
    sw $t9, 0($t0)
    
    j game_loop
        
# init_game_loop:
    # lw $t9, ADDR_KBRD               # load $t9 = base address for keyboard
    # lw $t8, 0($t9)                  # Load first word from keyboard
    
    
    #  function call here?
    # sw $t5, 0($t0)
    # sw $t5, 128($t0)
    # sw $t5, 256($t0)
    # sw $t5, 384($t0)
    j game_loop
    

respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
	
respond_to_W:
    addi $s1, $s1, 1                # increment variable that stores rotation
    addi $v0, $s1, 0                # ?
    j main

respond_to_A:
    # ...                             # move the tetromino right
    
    j game_loop

respond_to_S:
    # ...                             # move the tetromino left
    # addi $v0, $s1, 0
    j game_loop

respond_to_D:
    # ...                             # move the tetromino down
    
    j game_loop
    
    
keyboard_input:                     # handle key press
    lw $a0, 4($t9)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, respond_to_W
    beq $a0, 0x61, respond_to_A 
    beq $a0, 0x73, respond_to_S 
    beq $a0, 0x64, respond_to_D 
            

    li $v0, 1                       # ask system to print $a0
    syscall
    
    b main


game_loop:
	# 1a. Check if key has been pressed
	lw $t9, ADDR_KBRD               # load $t9 = base address for keyboard
    lw $t8, 0($t9)                  # Load first word from keyboard
	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
	
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop

exit:
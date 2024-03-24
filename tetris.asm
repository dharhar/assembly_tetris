################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
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
        
        div $t9, $t8                    # divide the current pixel we're at (t9 goes from the top left to the bottom left and increments by 256) by 128
        mfhi $t7                        # get the remainder of the result
        
        li $t3, 0                       # increment this by 4 to draw the actual rows in the helper functions, resets to 0 everytime a row is drawn
        
        beq $t7, 0, draw_even_row       # if the remainder is 0, then we're at even rows (row 0, 2, 4, ...)
        beq $t7, 128, draw_odd_row      # if the remainder is 128, then we're at odd rows (row 1, 3, 5, ...)
        
        j exit
        
end_init_board:
        
    draw_even_row:                          # starts with gray two
        sw $t2, 0($t5)                      # draw gray two in the first box
        addi $t5, $t5, 4                     
        sw $t1, 0($t5)                      # draw gray one in the second box
        addi $t5, $t5, 4
        
        addi $t3, $t3, 4
        addi $t9, $t9, 8                    # increment the total amount of boxes drawn in the grid
        beq $t3, 64 init_board              # once it reaches the end of the row, go back and see 
        
        j draw_even_row
        
    draw_odd_row:                           # starts with gray one  
        sw $t1, 0($t5)                      # same as above with the colors switched
        addi $t5, $t5, 4
        sw $t2, 0($t5)
        addi $t5, $t5, 4
        
        
        addi $t3, $t3, 4
        addi $t9, $t9, 8
        beq $t3, 64, init_board
        
        j draw_odd_row

draw_border:
    
    li $t1, 0xa6a6a6                # color of the border
    sw $t1, 776($t0)                # start drawing the border at this pixel
    
    addi $a0, $zero, 21	# height of display
    addi $a1, $zero, 11	# width of display
    add $t0, $zero, $zero
    
    add $t2, $zero, $zero           # reset values of temp registers
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
        
        beq $t2, $a0, up_v          # once it's done drawing the vertical section, move to the helper that draws the other vertical section
        
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
        lw $t0, ADDR_DSPL           # go back to the topleft corner of bitmap display     
        li $t2, 0                   # incrementer variable
    
    draw_upper_sec:
        beq $t2, 192, init_draw_lower_sec
        sw $t1, 0($t0)
        add $t0, $t0, 4
        addi $t2, $t2, 1
        j draw_upper_sec
    
    init_draw_lower_sec:
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 3456                 # move to the starting byte for the next section 
        li $t2, 0                           # reset incrementer
        
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
        beq $t2, 21, exit 
        li $t3, 0
        addi $t0, $t0, 56
        addi $t2, $t2, 1
        j draw_row_for_right_sec 
    
    draw_row_for_right_sec:            # helper method to draw a row for the section to the right of the playing box
        beq $t3, 18, draw_right_sec
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        addi $t3, $t3, 1
        j draw_row_for_right_sec
        
    
end_cover_background: 
        
# TEST
game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop

exit:
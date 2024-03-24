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
    
    add $t3, $zero, $zero   # set index value ($t3) to zero
    
    li $t9, 0
    li $t8, 96
    add $t5, $t0, $t9
    
    j init_board
        
    addi $t2, $zero, 0	# h_count
    addi $t3, $zero, 0	# w_count
    addi $t4, $zero, 0  # even
    
    # Initialize the game
    li $t1, 0x525252            # set $t1 to grey
    
init_board:
        beq $t9, 1008, draw_border
        
        div $t9, $t8
        mfhi $t7
        
        li $t3, 0
        
        beq $t7, 0, draw_even_row
        beq $t7, 48, draw_odd_row
        
        j exit
        
    end_init_board:
        
    draw_even_row:                          # starts with gray two
        sw $t2, 0($t5)
        addi $t5, $t5, 4
        sw $t1, 0($t5)
        addi $t5, $t5, 4
        
        addi $t3, $t3, 4
        addi $t9, $t9, 8
        beq $t3, 24 init_board
        
        j draw_even_row
        
    draw_odd_row:                           # starts with gray one  
        sw $t1, 0($t5)
        addi $t5, $t5, 4
        sw $t2, 0($t5)
        addi $t5, $t5, 4
        
        addi $t3, $t3, 4
        addi $t9, $t9, 8
        beq $t3, 24, init_board
        
        j draw_odd_row

draw_border:
    
    addi $a0, $zero, 21	# height of display
    addi $a1, $zero, 12	# width of display
    add $t0, $zero, $zero
    li $t1, 0xa6a6a6     
    add $t2, $zero, $zero
    add $t3, $zero, $zero
    add $t5, $zero, $zero
    add $t8, $zero, $zero
    add $t9, $zero, $zero

    
    init_h:
        lw $t0, ADDR_DSPL           # $t0 = base address for display
        subi $t6, $a0, 1
        mul $t5, $t6, 48
        add $t0, $t0, $t5

    draw_h:
        sw $t1, 0($t0)              # paint $t0 grey
        beq $t3, $a1, init_v        # if we've finished the bottom row, stop
        
        addi $t0, $t0, 4            # move to next pixel
        addi $t3, $t3, 1            # increment counter
        j draw_h                    # if not, continue
        
    init_v:
        lw $t0, ADDR_DSPL           # $t0 = base address for display
        
    draw_v:
        sw $t1, 0($t0)              # paint $t0 grey
        addi $t0, $t0, 48           # move to next pixel
        addi $t2, $t2, 1            # increment counter
        
        beq $t2, $a0, up_v
        
        mul $t8, $a0, 2
        
        beq $t2, $t8, exit
        j draw_v
        
        
    up_v:
        lw $t0, ADDR_DSPL 
        addi $t0, $t0, 44
        j draw_v
        
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
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
	
	
init:
	# Run the Tetris game.
    lw $t0, ADDR_DSPL       # $t0 = base address for display
        
    lw $s0, ADDR_DSPL       # $s0 = curr anchor location
    addi $s0, $s0, 800
    li $s1, 0               # $s1 = curr orientation
    li $s2, 0               # $s2 = curr shape
    
    
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
    
    ###
    
    
init_board:                             # draw a grid across the entire screen
        beq $t9, 4096, draw_border      # once the entire grid is drawn, jump to drawing the playing box
        
        div $t9, $t8
        mfhi $t7
        
        li $t3, 0
        
        beq $t7, 0, draw_even_row
        beq $t7, 128, draw_odd_row
        
        j game_loop
        
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
        beq $t2, 21, draw_new 
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

draw_new:
    jal i_type
    j game_loop

game_loop:
    li $v0, 32
	li $a0, 1

	syscall
	
    addi $t0, $t0, 200

    lw $t9, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t9)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    beq $t8, 0, game_loop
    
    j game_loop

keyboard_input:                     # A key is pressed
    lw $a0, 4($t9)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, respond_to_W
    beq $a0, 0x61, respond_to_A 
    beq $a0, 0x73, respond_to_S 
    beq $a0, 0x64, respond_to_D 
            
    li $v0, 1                       # ask system to print $a0
    syscall
    
    b game_loop

respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
	
respond_to_W:
    addi $s1, $s1, 1                # increment variable that stores rotation
    addi $v0, $s1, 0                # ?
    
    li $a3, 0                      # pass in how much to shift
    
    jal i_type
    
    j game_loop

respond_to_A:

    li $a3, -4                   # pass in how much to shift
    jal i_type
  
    j game_loop

respond_to_S:  
    li $a3, 128                      # pass in how much to shift
    jal i_type                  # move the tetromino down

    j game_loop

respond_to_D:                      # move the tetromino right
    li $a3, 4                      # pass in how much to shift
    jal i_type
    
    j game_loop
    

i_type:
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal erase_i
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    add $s0, $s0, $a3

    li $t8, 2
    div $s1, $t8
    mfhi $t7
    
    beq $t7, 0, i_vert
    beq $t7, 1, i_horz
    
    i_vert:
        li $t1, 0x47f5cf        # I-type: teal  
        
        li $t0, 0               # set starting position as anchor
        add $t0, $t0, $s0
        
        sw $t1, 0($t0)
        addi $t0, $t0, 128
        sw $t1, 0($t0)
        addi $t0, $t0, 128
        sw $t1, 0($t0)
        addi $t0, $t0, 128
        sw $t1, 0($t0)
        
        jr $ra
        
    i_horz:
        li $t1, 0x47f5cf        # I-type: teal    
        
        li $t0, 0               # set starting position as anchor
        add $t0, $t0, $s0
        
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        sw $t1, 0($t0)
        
        jr $ra
        
erase_i:

    li $t8, 2
    div $s1, $t8
    mfhi $t7
    
    lw $t9, 4($s0)
    beq $t9, 0x47f5cf, erase_i_horz         # check to see if last draw shape was h/v
    beq $t9, 0x000000, erase_i_vert
    
    erase_i_vert:
        li $t0, 0               # set starting position as anchor
        add $t0, $t0, $s0
        
        li $t1, 0x000000        # black   
        # li $t1, 0xeddb11
        sw $t1, 0($t0)
        addi $t0, $t0, 128
        sw $t1, 0($t0)
        addi $t0, $t0, 128
        sw $t1, 0($t0)
        addi $t0, $t0, 128
        sw $t1, 0($t0)
        jr $ra
        
    erase_i_horz:
        li $t0, 0               # set starting position as anchor
        add $t0, $t0, $s0
        
        li $t1, 0x000000        # black   
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        sw $t1, 0($t0)
        jr $ra
        jr $ra
    
  
exit:
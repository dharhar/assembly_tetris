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

GRAVITY_TIME:
    .word 100

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
    
main:                           # Initialize the game
    lw $t4, GRAVITY_TIME        # Load gravity timer
    lw $t0, ADDR_DSPL           # $t0 = base address for display

    li $t1, 0x383838            # COLOR_GRID_ONE
    li $t2, 0x1c1c1c            # COLOR_GRID_TWO
    
    add $t3, $zero, $zero       # set index value ($t3) to zero
    
    li $t9, 0                   # some initial values for drawing the grid
    li $t8, 256
    add $t5, $t0, $t9
    
    j init_board                # initialise the board
        
    addi $t2, $zero, 0          # stores counter for the height of the board 
    addi $t3, $zero, 0          # stores counter for the width of the board
    addi $t4, $zero, 0          # stores whether the current row is even or odd
    
    li $t1, 0x525252            # set $t1 to grey
    

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
        beq $t2, 21, draw_next
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

    draw_next:
        lw $t6, ADDR_DSPL
        li $t5, 0xffffff
        
        sw $t5, 960($t6)        # draw an arrow symbolizing the next tile
        sw $t5, 964($t6)
        sw $t5, 968($t6)
        sw $t5, 972($t6)
        sw $t5, 976($t6)
        sw $t5, 980($t6)
        sw $t5, 984($t6)
        
        sw $t5, 852($t6)
        sw $t5, 720($t6)
        sw $t5, 1108($t6)
        sw $t5, 1232($t6)
        
        li $t5, 0x47f5cf        # get teal colour
        sw $t5, 868($t6)
        sw $t5, 996($t6)
        sw $t5, 1124($t6)
        sw $t5, 1252($t6)
        
        
        
        # sw $t5, 700($t6)       # draw "next"
        # sw $t5, 712($t6)
        
        # sw $t5, 828($t6)
        # sw $t5, 832($t6)
        # sw $t5, 840($t6)
        
        # sw $t5, 956($t6)
        # sw $t5, 964($t6)
        # sw $t5, 968($t6)
        
        # sw $t5, 1084($t6)
        # sw $t5, 1096($t6)
        # sw $
        
        # li $t8, 0                       
        
        j draw_new
    
    
        
end_cover_background: 


draw_new:                   # draws a new tetromino (rn just an i type by default)
    lw $s0, ADDR_DSPL       # $s0 = curr anchor location
    addi $s0, $s0, 800      # so it starts in the top middle of the grid
    
    li $s1, 0               # $s1 = curr orientation
    li $s2, 0               # $s2 = curr shape
    
    jal i_type              # draws the new tetromino (how do u spell that man)
    j game_loop             # starts the main game loop once the first piece is drawn

game_loop:                  # main game loop
    li $v0, 32              # lowkey what do these do
	li $a0, 1               # oh its keyboard things okay

	syscall

    lw $t9, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t9)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    # Decrement gravity timer
    
    subi $t4, $t4, 1        # Decrement timer
    sw $t4, GRAVITY_TIME    # Store updated timer value
    
    beq $t4, 0, respond_to_S # If timer is 0, move Tetris piece downward
    
    # beqz
    beq $t8, 0, game_loop           # while there's no new keyboard input, do nothing
    
    j game_loop

keyboard_input:                     # A key is pressed
    lw $a0, 4($t9)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, respond_to_W     # Check if the key w was pressed
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x70, respond_to_P     # Check if the key p was pressed
            
    li $v0, 1                       # ask system to print $a0
    syscall
    
    b game_loop                     # once keyboard input is dealt with, loop back

respond_to_P:                       # display pause screen
    lw $t8, ADDR_KBRD               # to do: check if the another key was pressed again
    li $t7, 0
    j draw_pause_and_wait   
    
    draw_pause_and_wait:
        lw $t6, ADDR_DSPL
        li $t5, 0xffffff
        
        sw $t5, 1344($t6)       # draw pause symbol
        sw $t5, 1472($t6)
        sw $t5, 1600($t6)
        sw $t5, 1728($t6)
    
        sw $t5, 1352($t6)
        sw $t5, 1480($t6)
        sw $t5, 1608($t6)
        sw $t5, 1736($t6)
        # sw $
        
        li $v0, 32
        li $a0, 1
        syscall 
        
        # li $t8, 0                       
        
        
        lw $t7, 0($t8)                  # Load first word from keyboard
        beq $t7, 1, check_for_another_p
        # beq $t7, 0x70, erase_pause       # go back to game loop if p was pressed again
        
        j draw_pause_and_wait
    
    check_for_another_p:
        lw $t7, 4($t8)
        beq $t7, 0x70, erase_pause
        b draw_pause_and_wait
    
    erase_pause:
        lw $t6, ADDR_DSPL
        li $t5, 0x000000
        
        sw $t5, 1344($t6)       # draw pause symbol
        sw $t5, 1472($t6)
        sw $t5, 1600($t6)
        sw $t5, 1728($t6)
    
        sw $t5, 1352($t6)
        sw $t5, 1480($t6)
        sw $t5, 1608($t6)
        sw $t5, 1736($t6)
    
    
        li $t4, 100                 # reset gravity counter
        b game_loop

respond_to_Q:
    
	li $v0, 10                      # Quit gracefully
	syscall
	
respond_to_W:
    jal check_W

    addi $s1, $s1, 1                # increment variable that stores rotation
    addi $v0, $s1, 0                # sets "new key pressed" to zero again
    
    li $a3, 0                      # pass in how much to shift
    
    jal i_type                      # draw a new i type (i.e. deal with movement)
    
    jal check_frozen
    j game_loop                     # loop back once dealt with

respond_to_A:
    jal check_A                     # checks that piece can move left safely

    li $a3, -4                      # pass in how much to shift
    jal i_type                      # move the tetromino left
  
    jal check_frozen
    j game_loop                     # loop back once dealt with

respond_to_S:  
    li $t4, 100                     # Reload gravity timer
    jal check_S                     # checks that piece can move down safely
    
    li $a3, 128                     # pass in how much to shift
    jal i_type                      # move the tetromino down

    jal check_frozen
    j game_loop                     # loop back once dealt with

respond_to_D:                       # move the tetromino right
    jal check_D                     # checks that piece can move right safely
    
    li $a3, 4                       # pass in how much to shift
    jal i_type
    
    jal check_frozen
    j game_loop                      # loop back once dealt with
    
    
check_frozen:
    li $t8, 2                       # checks whether, after a piece has moved in some way, it is in a position where it should stop and a new one should load
    div $s1, $t8    
    mfhi $t7                        # remainder when curr orientation is divided by 2
    
    beq $t7, 0, check_frozen_vert        # if remainder is 0, piece is vertical   
    beq $t7, 1, check_frozen_horz        # if remainder is 1, piece is horizontal 
    
    check_frozen_vert:
        lw $t1, 512($s0)
        
        beq $t1, 0x47f5cf, draw_new
        beq $t1, 0xa6a6a6, draw_new
    
        jr $ra
        
    check_frozen_horz:
        li $t0, 0                       # counter to check all bottom edges of horizontal shape
        addi $t1, $s0, 128
       
        
        fh_start:
            lw $t2, 0($t1) 
            beq $t2, 0x47f5cf, draw_new
            beq $t2, 0xa6a6a6, draw_new
            
            addi $t0, $t0, 1
            addi $t1, $t1, 4
       
        blt $t0, 4, fh_start 
        jr $ra
        
check_W:
    li $t8, 2                       # checks that piece can rotate safely
    div $s1, $t8    
    mfhi $t7                        # remainder when curr orientation is divided by 2
    
    beq $t7, 0, check_W_vert        # if remainder is 0, piece is vertical   
    beq $t7, 1, check_W_horz        # if remainder is 1, piece is horizontal   

    check_W_vert:
  
        li $t8, 0                           # counter for loop
    
        addi $t7, $s0, 4                    # $t7 is the value the the right of the anchor position
    
        check_colour_1_W_vert:
            lw $t9, 0($t7)                                  # current position
            bne $t9, 0x383838, check_colour_2_W_vert        # if not equal to first grid colour, check second grid colour
            beq $t9, 0x383838, up_counters_W_vert           # if equal to the first grid colour, success to increase counter
            
        check_colour_2_W_vert:  
            bne $t9, 0x1c1c1c, game_loop                    # if not equal to second grid colour, piece shouldn't move
            beq $t9, 0x1c1c1c, up_counters_W_vert           # if equal to the second grid colour, success to increase counter
            
        up_counters_W_vert:                 # a counter kept to make sure all pixels next to the piece are checked
            addi, $t8, $t8, 1               # increase counter
            addi $t7, $t7, 4                # increase current pixel being looked at
            
            beq $t8, 4, check_pass          # check if all pixels have been checked
            
            j check_colour_1_W_vert         # if not all, loop back
        
    check_W_horz:
        li $t8, 0                           # counter for loop
        addi $t7, $s0, 128                  # sets the starting position, one below anchor
    
        check_colour_1_W_horz:
            lw $t9, 0($t7)                  # position of current pixel
            bne $t9, 0x383838, check_colour_2_W_horz        # if not equal to first grid colour, check second grid colour
            beq $t9, 0x383838, up_counters_W_horz           # if equal to the first grid colour, success to increase counter
            
        check_colour_2_W_horz:
            bne $t9, 0x1c1c1c, game_loop                    # if not equal to second grid colour, piece shouldn't move
            beq $t9, 0x1c1c1c, up_counters_W_horz           # if equal to the second grid colour, success to increase counter
            
        up_counters_W_horz:                 # a counter kept to make sure all pixels next to the piece are checked
            addi, $t8, $t8, 1               # increase counter
            addi $t7, $t7, 128              # increase current pixel being looked at
            
            beq $t8, 4, check_pass          # check if all pixels have been checked
            
            j check_colour_1_W_horz         # if not all, loop back

check_A:
    li $t8, 2                       # checks that piece can rotate safely
    div $s1, $t8    
    mfhi $t7                        # remainder when curr orientation is divided by 2
    
    beq $t7, 0, check_A_vert            # if remainder is 0, piece is vertical   
    beq $t7, 1, check_A_horz            # if remainder is 1, piece is horizontal   

    check_A_vert:
        li $t8, 0
        addi $t7, $s0, -4
        
        check_colour_1_A_horz:
            lw $t9, 0($t7)                
            bne $t9, 0x383838, check_colour_2_A_horz
            beq $t9, 0x383838, up_counters_A
            
        check_colour_2_A_horz:
            bne $t9, 0x1c1c1c, game_loop
            beq $t9, 0x1c1c1c, up_counters_A
            
        up_counters_A:
            addi, $t8, $t8, 1
            addi $t7, $t7, 128
            
            beq $t8, 4, check_pass
            
            j check_colour_1_A_horz
            
    check_A_horz:
        lw $t9, -4($s0)
        
        check_colour_1_A:
            bne $t9, 0x383838, check_colour_2_A
            beq $t9, 0x383838, check_pass
        check_colour_2_A:
            bne $t9, 0x1c1c1c, game_loop
            beq $t9, 0x1c1c1c, check_pass
        check_pass:
            jr $ra
    
check_S:

    li $t8, 2
    div $s1, $t8
    mfhi $t7
    
    beq $t7, 0, check_S_vert
    beq $t7, 1, check_S_horz
    
    check_S_vert:
        lw $t9, 512($s0)
        
        check_colour_1_S_vert:
            bne $t9, 0x383838, check_colour_2_S_vert
            beq $t9, 0x383838, check_pass
        check_colour_2_S_vert:
            bne $t9, 0x1c1c1c, draw_new
            beq $t9, 0x1c1c1c, check_pass
            
    check_S_horz:
        li $t8, 0                           # counter
        addi $t7, $s0, 128
    
        check_colour_1_S_horz:
            lw $t9, 0($t7)                    # position
            bne $t9, 0x383838, check_colour_2_S_horz
            beq $t9, 0x383838, up_counters
            
        check_colour_2_S_horz:
            bne $t9, 0x1c1c1c, draw_new
            beq $t9, 0x1c1c1c, up_counters
            
        up_counters:
            addi, $t8, $t8, 1
            addi $t7, $t7, 4
            
            beq $t8, 4, check_pass
            
            j check_colour_1_S_horz
 
check_D:
    li $t8, 2                       # checks that piece can rotate safely
    div $s1, $t8    
    mfhi $t7                        # remainder when curr orientation is divided by 2
    
    beq $t7, 0, check_D_vert
    beq $t7, 1, check_D_horz
    
    check_D_vert:
        lw $t9, 512($s0)
        
        check_colour_1_D_vert_bottom:
            bne $t9, 0x383838, check_colour_2_D_vert_bottom
            beq $t9, 0x383838, restart_here
        check_colour_2_D_vert_bottom:
            bne $t9, 0x1c1c1c, draw_new
            beq $t9, 0x1c1c1c, restart_here
            
        restart_here:
            li $t8, 0
            addi $t7, $s0, 4
        
        check_colour_1_D_vert:
            lw $t9, 0($t7)                
            bne $t9, 0x383838, check_colour_2_D_vert
            beq $t9, 0x383838, up_counters_D
            
        check_colour_2_D_vert:
            bne $t9, 0x1c1c1c, game_loop
            beq $t9, 0x1c1c1c, up_counters_D
            
        up_counters_D:
            addi, $t8, $t8, 1
            addi $t7, $t7, 128
            
            beq $t8, 4, check_pass
            
            j check_colour_1_D_vert

            
    check_D_horz:
        lw $t9, 16($s0)
        
        check_colour_1_D_horz:
            bne $t9, 0x383838, check_colour_2_horz
            beq $t9, 0x383838, check_pass
        check_colour_2_horz:
            bne $t9, 0x1c1c1c, game_loop
            beq $t9, 0x1c1c1c, check_pass
        check_pass:
            jr $ra
    
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
    
    ## FREAKING THING JUST WENT INTO THE WALL! BRUH!!! FIX THIS :((((
    
    lw $t9, 4($s0)
    beq $t9, 0x47f5cf, erase_i_horz         # check to see if last draw shape was h/v
    beq $t9, 0x000000, erase_i_vert
    
    erase_i_vert:
        li $t0, 0               # set starting position as anchor
        add $t0, $t0, $s0
        
        li $t1, 0x383838        # COLOR_GRID_ONE
        li $t2, 0x1c1c1c        # COLOR_GRID_TWO
        
        lw $t9, -4($s0)
        
        beq $t9, 0xa6a6a6, go_above_start_vert
        
        j go_above_end_vert
        
        go_above_start_vert:
            lw $t9, 4($s0)
                
            beq $t9, 0x383838, col_type_2
            beq $t9, 0x1c1c1c, col_type_1
            
        go_above_end_vert:
        
        beq $t9, 0x383838, col_type_2
        beq $t9, 0x1c1c1c, col_type_1
        
        col_type_1:
            col_type_1_a:
                beq $t0, 0x47f5cf, col_type_1_b
                sw $t1, 0($t0)
                addi $t0, $t0, 128
                
            col_type_1_b:
                beq $t0, 0x47f5cf, col_type_1_c
                sw $t2, 0($t0)
                addi $t0, $t0, 128
            
            col_type_1_c:
                beq $t0, 0x47f5cf, col_type_1_d
                sw $t1, 0($t0)
                addi $t0, $t0, 128
                
            col_type_1_d:
                beq $t0, 0x47f5cf, col_type_1_end
                sw $t2, 0($t0)
            
            col_type_1_end:
                jr $ra
            
        col_type_2:
        
            col_type_2_a:
                beq $t0, 0x47f5cf, col_type_2_b
                sw $t2, 0($t0)
                addi $t0, $t0, 128
                
            col_type_2_b:
                beq $t0, 0x47f5cf, col_type_2_c
                sw $t1, 0($t0)
                addi $t0, $t0, 128
                
            col_type_2_c:
                beq $t0, 0x47f5cf, col_type_2_d
                sw $t2, 0($t0)
                addi $t0, $t0, 128
                
            col_type_2_d:
                beq $t0, 0x47f5cf, col_type_2_end
                sw $t1, 0($t0)
                
            col_type_2_end:
                jr $ra
       
        
    erase_i_horz:
        li $t0, 0               # set starting position as anchor
        add $t0, $t0, $s0
        
        li $t1, 0x383838        # COLOR_GRID_ONE
        li $t2, 0x1c1c1c        # COLOR_GRID_TWO
        
        lw $t9, -4($s0)
        beq $t9, 0xa6a6a6, go_above_start
        beq $t9, 0x47f5cf, go_above_start
        
        j go_above_end
        
        go_above_start:
            lw $t9, 16($s0)
                
            beq $t9, 0x383838, row_type_1
            beq $t9, 0x1c1c1c, row_type_2
            
        go_above_end:
        
        beq $t9, 0x383838, row_type_2
        beq $t9, 0x1c1c1c, row_type_1
        
        row_type_1:
            row_type_1_a:
                beq $t0, 0x47f5cf, row_type_1_b
                sw $t1, 0($t0)
                addi $t0, $t0, 4
            
            row_type_1_b:
                beq $t0, 0x47f5cf, row_type_1_c
                sw $t2, 0($t0)
                addi $t0, $t0, 4
                
            row_type_1_c:
                beq $t0, 0x47f5cf, row_type_1_d
                sw $t1, 0($t0)
                addi $t0, $t0, 4
            
            row_type_1_d:   
                beq $t0, 0x47f5cf, row_type_1_end
                sw $t2, 0($t0)
            
            row_type_1_end:
                jr $ra
        
        row_type_2:
            row_type_2_a:  
                beq $t0, 0x47f5cf, row_type_2_b
                sw $t2, 0($t0)
                addi $t0, $t0, 4
                
            row_type_2_b:
                beq $t0, 0x47f5cf, row_type_2_c   
                sw $t1, 0($t0)
                addi $t0, $t0, 4
                
            row_type_2_c:
                beq $t0, 0x47f5cf, row_type_2_d
                sw $t2, 0($t0)
                addi $t0, $t0, 4
                
            row_type_2_d:
                beq $t0, 0x47f5cf, row_type_2_end
                sw $t1, 0($t0)
                
            row_type_2_end:
                jr $ra
  
exit:
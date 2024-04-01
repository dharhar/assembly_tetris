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
    
MUSIC_TIMER:
    .word 19200
    
GAME_OVER_MUSIC_TIMER:
    .word 4820

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
    li $a3, 0
    lw $s7, GRAVITY_TIME        # Load gravity timer
    lw $s6, MUSIC_TIMER
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

draw_new:                   # draws a new tetromino (rn just an i type by default)  
    lw $s0, ADDR_DSPL       # $s0 = curr anchor location
    addi $s0, $s0, 800      # so it starts in the top middle of the gridf
    
    li $s1, 0               # $s1 = curr orientation
    li $s2, 0               # $s2 = curr shape
    
    lw $t6, 128($s0)                    # check the colour of the tetromino where we're supposed to draw it
    beq $t6, 0x47f5cf, game_over        # checks if we can draw the tetromino (if not, game over)
    
    jal i_type              # draws the new tetromino (how do u spell that man)
    jal check_frozen
    j game_loop             # starts the main game loop once the first piece is drawn

game_over:
    li $v0, 32
    li $a0, 500            # wait for a bit
    lw $s5, GAME_OVER_MUSIC_TIMER
    syscall 
    
    jal play_game_over
    # j draw_game_over_screen
    

play_game_over:
    subi $s5, $s5, 20
    
    li $v0, 32
    li $a0, 1
    syscall
    
    li $v0, 31
    li $a1, 600                      # all notes same length
    li $a2, 0                        # set instrument to piano
    li $a3, 100
    
    beq $s5, 4800, play_game_over_1
    beq $s5, 4200, play_game_over_2
    beq $s5, 3600, play_game_over_3
    beq $s5, 3000, play_game_over_4
    beq $s5, 2400, play_game_over_5
    beq $s5, 1800, play_game_over_6
    beq $s5, 1200, play_game_over_7
    
    j play_game_over
    
    play_game_over_1:
        li $a0, 81            
        syscall   
        li $a0, 64
        syscall
        li $a0, 60
        syscall
        li $a0, 53
        j play_game_over
        
    play_game_over_2:
        li $a0, 72                            
        syscall   
        j play_game_over
    
    play_game_over_3:
        li $a0, 75                            
        syscall   
        li $a0, 65
        syscall
        li $a0, 62
        syscall
        li $a0, 55
        syscall
        j play_game_over
    
    play_game_over_4:
        li $a0, 74         
        syscall
        j play_game_over
        
    play_game_over_5:
        li $a0, 72                            
        syscall
        li $a0, 48
        syscall
        j play_game_over
    
    play_game_over_6:
        li $a0, 69                        
        syscall   
        j play_game_over
    
    play_game_over_7:
        li $a0, 72         
        syscall
        li $a0, 69
        syscall
        li $a0, 64
        syscall
        li $a0, 59
        syscall
        li $a0, 55
        syscall
        li $a0, 48
        syscall
        # li $s5, 4820 # set to 1220 because game loop decremenets by 20 after returning
        j draw_game_over_screen
    
draw_game_over_screen:
    
    li $t0, 0
    li $t1, 0x000000
    li $t2, 0xffffff
    lw $s0, ADDR_DSPL
    li $v0, 32
    li $a0, 1
    j draw_black_bg

    draw_black_bg:                      # draw the background
        sw $t2, 0($s0)
        sw $t2, 4($s0)
        sw $t2, 8($s0)
        sw $t2, 12($s0)
        sw $t2, 16($s0)
        sw $t2, 20($s0)
        sw $t2, 24($s0)
        sw $t2, 28($s0)
        syscall
        sw $t1, 0($s0)
        sw $t1, 4($s0)
        sw $t1, 8($s0)
        sw $t1, 12($s0)                
        sw $t1, 16($s0)
        sw $t1, 20($s0)
        sw $t1, 24($s0)
        sw $t1, 28($s0)                 # small deleting animation
        
        addi $s0, $s0, 32
        addi $t0, $t0, 8
        beq $t0, 1024, draw_game_over
        
        j draw_black_bg
    
    draw_game_over:
        lw $s0, ADDR_DSPL
        addi $s0, $s0, 408              # move to the top left side of screen
        sw $t2, 4($s0)
        sw $t2, 8($s0)
        sw $t2, 12($s0)
        sw $t2, 24($s0)
        sw $t2, 28($s0)
        sw $t2, 32($s0)
        sw $t2, 40($s0)
        sw $t2, 56($s0)
        sw $t2, 64($s0)
        sw $t2, 68($s0)
        sw $t2, 72($s0)
        sw $t2, 76($s0)
        
        syscall
        addi $s0, $s0, 128
        sw $t2, 0($s0)
        sw $t2, 20($s0)
        sw $t2, 32($s0)
        sw $t2, 40($s0)
        sw $t2, 44($s0)
        sw $t2, 52($s0)
        sw $t2, 56($s0)
        sw $t2, 64($s0)
        
        syscall
        addi $s0, $s0, 128
        sw $t2, 0($s0)
        sw $t2, 8($s0)
        sw $t2, 12($s0)
        sw $t2, 20($s0)
        sw $t2, 24($s0)
        sw $t2, 28($s0)
        sw $t2, 32($s0)
        sw $t2, 40($s0)
        sw $t2, 48($s0)
        sw $t2, 56($s0)
        sw $t2, 64($s0)
        sw $t2, 68($s0)
        sw $t2, 72($s0)
                
        syscall
        addi $s0, $s0, 128
        sw $t2, 0($s0)
        sw $t2, 12($s0)
        sw $t2, 20($s0)
        sw $t2, 32($s0)
        sw $t2, 40($s0)
        sw $t2, 56($s0)
        sw $t2, 64($s0)
        
        syscall
        addi $s0, $s0, 128
        sw $t2, 0($s0)
        sw $t2, 4($s0)
        sw $t2, 8($s0)
        sw $t2, 12($s0)
        sw $t2, 20($s0)
        sw $t2, 32($s0)
        sw $t2, 40($s0)
        sw $t2, 56($s0)
        sw $t2, 64($s0)
        sw $t2, 68($s0)
        sw $t2, 72($s0)
        sw $t2, 76($s0)
        
        syscall
        addi $s0, $s0, 256
        sw $t2, 0($s0)
        sw $t2, 4($s0)
        sw $t2, 8($s0)
        sw $t2, 20($s0)
        sw $t2, 36($s0)
        sw $t2, 44($s0)
        sw $t2, 48($s0)
        sw $t2, 52($s0)
        sw $t2, 56($s0)
        sw $t2, 64($s0)
        sw $t2, 68($s0)
        sw $t2, 72($s0)
        
        syscall
        addi $s0, $s0, 128
        sw $t2, 0($s0)
        sw $t2, 12($s0)
        sw $t2, 20($s0)
        sw $t2, 36($s0)
        sw $t2, 44($s0)
        sw $t2, 64($s0)
        sw $t2, 76($s0)
        
        syscall
        addi $s0, $s0, 128
        sw $t2, 0($s0)
        sw $t2, 12($s0)
        sw $t2, 20($s0)
        sw $t2, 24($s0)
        sw $t2, 32($s0)
        sw $t2, 36($s0)
        sw $t2, 44($s0)
        sw $t2, 48($s0)
        sw $t2, 52($s0)
        sw $t2, 64($s0)
        sw $t2, 68($s0)
        sw $t2, 72($s0)
        sw $t2, 76($s0)
        
        syscall
        addi $s0, $s0, 128
        sw $t2, 0($s0)
        sw $t2, 12($s0)
        sw $t2, 24($s0)
        sw $t2, 28($s0)
        sw $t2, 32($s0)
        sw $t2, 44($s0)
        sw $t2, 64($s0)
        sw $t2, 72($s0)
        
        syscall
        addi $s0, $s0, 128
        sw $t2, 4($s0)
        sw $t2, 8($s0)
        sw $t2, 12($s0)
        sw $t2, 28($s0)
        sw $t2, 44($s0)
        sw $t2, 48($s0)
        sw $t2, 52($s0)
        sw $t2, 56($s0)
        sw $t2, 64($s0)
        sw $t2, 76($s0)
        
    draw_score:
        addi $s0, $s0, 768
        sw $t2, 4($s0)              # draw the R
        sw $t2, 8($s0)
        sw $t2, 12($s0)
        sw $t2, 128($s0)
        sw $t2, 144($s0)
        sw $t2, 256($s0)
        sw $t2, 260($s0)
        sw $t2, 264($s0)
        sw $t2, 268($s0)
        sw $t2, 384($s0)
        sw $t2, 392($s0)
        sw $t2, 512($s0)
        sw $t2, 524($s0)
        sw $t2, 640($s0)
        sw $t2, 656($s0)
        
        addi $s0, $s0, 60           # draw the Q
        sw $t2, 4($s0)
        sw $t2, 8($s0)
        sw $t2, 12($s0)
        sw $t2, 128($s0)
        sw $t2, 144($s0)
        sw $t2, 256($s0)
        sw $t2, 272($s0)
        sw $t2, 384($s0)
        sw $t2, 392($s0)
        sw $t2, 400($s0)
        sw $t2, 512($s0)
        sw $t2, 524($s0)
        sw $t2, 644($s0)
        sw $t2, 648($s0)
        sw $t2, 656($s0)
        
    
        
    draw_press_R_to_retry:
        li $v0, 32
        li $a0, 1
        syscall
    
        lw $t9, ADDR_KBRD
        lw $t8, 4($t9)
        beq $t8, 0x72, main                 # player presses r, retry 
        beq $t8, 0x71, respond_to_Q         # player presses q, quit
        j draw_press_R_to_retry

game_loop:                  # main game loop
    jal play_korobeniki
    subi $s6, $s6, 15
    

    li $v0, 32              # wait system call
	li $a0, 1               # 1 millisecond argument

	syscall	

    lw $t9, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t9)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    
    subi $s7, $s7, 1                # decrement gravity timer
    beq $s7, 0, respond_to_S        # if gravity timer hits 0, move piece down
    
    
    beq $t8, 0, game_loop           # while there's no new keyboard input, do nothing
    
    # j game_loop

play_korobeniki:
    li $v0, 31
    li $a2, 0                        # set instrument to piano
    li $a3, 100                      # set constant volume
    beq $s6, 19200, play_music_1      # first bar
    beq $s6, 18900, play_music_E1
    beq $s6, 18600, play_music_2
    beq $s6, 18300, play_music_3
    beq $s6, 18000, play_music_4
    beq $s6, 17700, play_music_E1
    beq $s6, 17400, play_music_5
    beq $s6, 17100, play_music_6
    
    beq $s6, 16800, play_music_7      # second bar
    beq $s6, 16500, play_music_A1
    beq $s6, 16200, play_music_8
    beq $s6, 15900, play_music_9
    beq $s6, 15600, play_music_10
    beq $s6, 15300, play_music_A1
    beq $s6, 15000, play_music_11
    beq $s6, 14700, play_music_12
    
    beq $s6, 14400, play_music_13        # third bar
    beq $s6, 14100, play_music_B1
    beq $s6, 13800, play_music_B0
    beq $s6, 13500, play_music_14
    beq $s6, 13200, play_music_15
    beq $s6, 12900, play_music_B1
    beq $s6, 12600, play_music_16
    beq $s6, 12300, play_music_B1
    
    beq $s6, 12000, play_music_17           # fourth bar
    beq $s6, 11700, play_music_A1
    beq $s6, 11400, play_music_18
    beq $s6, 11100, play_music_A1
    beq $s6, 10800, play_music_19
    beq $s6, 10500, play_music_A1
    beq $s6, 10200, play_music_A0 
    beq $s6, 9900, play_music_A1
     
    
    # play rest notes in game loop (10800 - 9300 = 1500 rest here -> one and a half beats)
    
    beq $s6, 9600, play_music_D0
    beq $s6, 9300, play_music_21
    beq $s6, 9000, play_music_D0
    beq $s6, 8700, play_music_22
    beq $s6, 8400, play_music_23
    beq $s6, 8100, play_music_D1
    beq $s6, 7800, play_music_24
    beq $s6, 7500, play_music_25
   
    beq $s6, 7200, play_music_26                    # sixth bar
    beq $s6, 6900, play_music_C1
    beq $s6, 6600, play_music_C0
    beq $s6, 6300, play_music_27
    beq $s6, 6000, play_music_28
    beq $s6, 5700, play_music_C1
    beq $s6, 5400, play_music_29
    beq $s6, 5100, play_music_30
    
    beq $s6, 4800, play_music_13                    # seventh bar / same as third
    beq $s6, 4500, play_music_B1
    beq $s6, 4200, play_music_B0
    beq $s6, 3900, play_music_14
    beq $s6, 3600, play_music_15
    beq $s6, 3300, play_music_B1
    beq $s6, 3000, play_music_16
    beq $s6, 2700, play_music_B1
    
    beq $s6, 2400, play_music_17                   # eighth bar / same as fourth \
    beq $s6, 2100, play_music_A1
    beq $s6, 1800, play_music_18
    beq $s6, 1500, play_music_A1
    beq $s6, 1200, play_music_19
    beq $s6, 900, play_music_A1
    beq $s6, 600, play_music_A0
    beq $s6, 300, play_music_A1
    beq $s6, 0, play_music_pause_one_beat_reset

    jr $ra
   
    #################################
    
    play_music_pause_one_beat_reset:
        li $v0, 32
        li $a0, 600
        # syscall
        li $s6, 19215 # set to 19220 because game loop decremenets by 20 after returning
        jr $ra
    
    #################################
    
    play_music_E0:
        li $a0, 52               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_E1:
        li $a0, 64               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_A0:
        li $a0, 45               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_A1:
        li $a0, 57               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_B0:
        li $a0, 47               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_B1:
        li $a0, 59               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_D0:
        li $a0, 50               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_D1:
        li $a0, 62               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_C0:
        li $a0, 48               
        li $a1, 300                   
        syscall   
        jr $ra
    
    play_music_C1:
        li $a0, 60               
        li $a1, 300                   
        syscall   
        jr $ra
    
    
    #################################
    
    play_music_26:
        li $a0, 76         
        li $a1, 900                   
        syscall   
        li $a0, 48               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_27:
        li $a0, 72               
        li $a1, 300                   
        syscall   
        li $a0, 60               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_28:
        li $a0, 76           
        li $a1, 600                   
        syscall  
        li $a0, 48               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_29:
        li $a0, 74                            
        li $a1, 300                   
        syscall  
        li $a0, 48               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_30:
        li $a0, 72                    
        li $a1, 300               # 77 is f                   
        syscall   
        li $a0, 60               
        li $a1, 300                   
        syscall
        jr $ra
    
    #################################
    
    play_music_21:
        li $a0, 74                              
        li $a1, 600                   
        syscall   
        li $a0, 62               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_22:
        li $a0, 77                 
        li $a1, 300                   
        syscall   
        li $a0, 62               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_23:
        li $a0, 81               
        li $a1, 600                   
        syscall   
        li $a0, 50               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_24:
        li $a0, 79                
        li $a1, 300                   
        syscall   
        li $a0, 50               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_25:
        li $a0, 77                    
        li $a1, 300                    
        syscall   
        li $a0, 62               
        li $a1, 300                   
        syscall
        jr $ra
        
    #################################
    
    play_music_17:
        li $a0, 72                    
        li $a1, 600                   
        syscall   
        li $a0, 45               
        li $a1, 300                   
        syscall  
        jr $ra
        
    play_music_18:
        li $a0, 69                    
        li $a1, 600                   
        syscall   
        li $a0, 45               
        li $a1, 300                   
        syscall  
        jr $ra
        
    play_music_19:
        li $a0, 69                    
        li $a1, 600                   
        syscall   
        li $a0, 45               
        li $a1, 300                   
        syscall  
        jr $ra
 
 ##################################
 
    play_music_13:
        li $a0, 71                    
        li $a1, 900                   
        syscall   
        li $a0, 47               
        li $a1, 300                   
        syscall
        jr $ra
 
    play_music_14:
        li $a0, 72                    
        li $a1, 300                   
        syscall   
        li $a0, 59               
        li $a1, 300                   
        syscall
        jr $ra
    
    play_music_15:
        li $a0, 74                    
        li $a1, 600                   
        syscall   
        li $a0, 47               
        li $a1, 300                   
        syscall
        jr $ra
    
    play_music_16:
        li $a0, 76                    
        li $a1, 600                   
        syscall   
        li $a0, 47               
        li $a1, 300                   
        syscall
        jr $ra
 
 ############################
 
    play_music_7:
        li $a0, 69                    
        li $a1, 600                   
        syscall
        li $a0, 45               
        li $a1, 300                   
        syscall
        jr $ra
    
    play_music_8:
        li $a0, 69                    
        li $a1, 300                   
        syscall
        li $a0, 45               
        li $a1, 300                   
        syscall
        jr $ra
        
    play_music_9:
        li $a0, 72                    
        li $a1, 300                   
        syscall   
        li $a0, 57               
        li $a1, 300                   
        syscall
        jr $ra
 
    play_music_10:
        li $a0, 76                    
        li $a1, 600                   
        syscall   
        li $a0, 45               
        li $a1, 300                   
        syscall
        jr $ra
 
    play_music_11:
        li $a0, 74                    
        li $a1, 300                   
        syscall   
        li $a0, 45               
        li $a1, 300                   
        syscall
        jr $ra
 
    play_music_12:
        li $a0, 72                    
        li $a1, 300                   
        syscall   
        li $a0, 57               
        li $a1, 300                   
        syscall
        jr $ra
 
 ####################################
 
    play_music_1:
        li $a0, 76                    # pitch is E1
        li $a1, 600                   # duration is 600 ms
        syscall
        li $a0, 52               
        li $a1, 300                   
        syscall   
        jr $ra
        
    play_music_2:
        li $a0, 71                    
        li $a1, 300                   
        syscall
        li $a0, 52               
        li $a1, 300                   
        syscall   
        jr $ra
        
    play_music_3:
        li $a0, 72                    
        li $a1, 300                   
        syscall
        li $a0, 64               
        li $a1, 300                   
        syscall   
        jr $ra
        
    play_music_4:
        li $a0, 74                    
        li $a1, 600                   
        syscall
        li $a0, 52               
        li $a1, 300                   
        syscall   
        jr $ra
        
    play_music_5:
        li $a0, 72                    
        li $a1, 300                   
        syscall
        li $a0, 52               
        li $a1, 300                   
        syscall   
        jr $ra
        
    play_music_6:
        li $a0, 71                    
        li $a1, 600                   
        syscall
        jr $ra
        


keyboard_input:                     # A key is pressed
    lw $a0, 4($t9)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, respond_to_W     # Check if the key w was pressed
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x70, respond_to_P
            
    li $v0, 1                       # ask system to print $a0
    syscall
    
    b game_loop                     # once keyboard input is dealt with, loop back

respond_to_P:
    lw $t8, ADDR_KBRD
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
    
    li $v0, 31                      # MIDI out
    li $a0, 60                      # pitch
    li $a1, 300                     # duration
    li $a2, 115                     # instrument
    li $a3, 127                     # volume (max)
    
    syscall
    

    addi $s1, $s1, 1                # increment variable that stores rotation
    addi $v0, $s1, 0                # sets "new key pressed" to zero again
    
    li $a3, 0                      # pass in how much to shift
    
    jal i_type                      # draw a new i type (i.e. deal with movement)
    
    jal check_frozen
    j game_loop                     # loop back once dealt with

respond_to_A:
    jal check_A                     # checks that piece can move left safely

    
    li $v0, 31                      # MIDI out
    li $a0, 60                      # pitch
    li $a1, 300                     # duration
    li $a2, 115                     # instrument
    li $a3, 127                     # volume (max)
    
    syscall

    li $a3, -4                      # pass in how much to shift
    jal i_type                      # move the tetromino left
  
    jal check_frozen
    j game_loop                     # loop back once dealt with

respond_to_S:
    lw $s7, GRAVITY_TIME                     # reset gravity timer
    jal check_S                    
    # checks that piece can move down safely
    
    
    li $v0, 31                      # MIDI out
    li $a0, 100                      # pitch
    li $a1, 300                     # duration
    li $a2, 115                     # instrument
    li $a3, 127                     # volume (max)
    
    syscall
    
    li $a3, 128                     # pass in how much to shift
    jal i_type                      # move the tetromino down

    jal check_frozen
    j game_loop                     # loop back once dealt with

respond_to_D:                       # move the tetromino right
    jal check_D                     # checks that piece can move right safely
    
    li $v0, 31                      # MIDI out
    li $a0, 60                      # pitch
    li $a1, 300                     # duration
    li $a2, 115                     # instrument
    li $a3, 127                     # volume (max)
    
    syscall
    
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
        
        beq $t1, 0x47f5cf, check_completed_rows
        beq $t1, 0xa6a6a6, check_completed_rows
        
        ## HERE INSTEAD OF DRAW NEW, DO A CHECK FOR FULL ROWS!! (MAYBE? IDK)
    
        jr $ra
        
    check_frozen_horz:
        li $t0, 0                       # counter to check all bottom edges of horizontal shape
        addi $t1, $s0, 128
       
        
        fh_start:
            lw $t2, 0($t1) 
            beq $t2, 0x47f5cf, check_completed_rows
            beq $t2, 0xa6a6a6, check_completed_rows
            
            # CHANGE BACK TO DRAW NEW ^^? IDK
            
            addi $t0, $t0, 1
            addi $t1, $t1, 4
       
        blt $t0, 4, fh_start 
        jr $ra
        
check_completed_rows:
    li $t0, 0                       # row counter
    li $t1, 0                       # column counter
    
    li $t8, 2                       # checks whether, after a piece has moved in some way, it is in a position where it should stop and a new one should load
    div $s1, $t8    
    mfhi $t7                        # remainder when curr orientation is divided by 2
    
    beq $t7, 0, check_complete_row_vert        # if remainder is 0, piece is vertical   
    beq $t7, 1, check_complete_row_horz        # if remainder is 1, piece is horizontal 
    
    check_complete_row_vert:
        li $t7, 0                               # counter for each pixel of the vertical block
        add $a0, $s0, $0                        # put the anchor position in $a0
        
        check_complete_row_vert_loop:
            jal check_row_complete
            
            addi $t7, $t7, 1
            addi $a0, $a0, 128
            
            beq $t7, 4, draw_new
            j check_complete_row_vert_loop
    
    check_complete_row_horz:
        add $a0, $s0, $0
        jal check_row_complete
        j draw_new
    
    check_row_complete:
        lw $t1, ADDR_DSPL                       # set $t1 to be the base address of the display
        sub $t2, $a0, $t1                       # subtract the current address of the pixel being looked at from the base address and store in $t2
        div $t2, $t2, 128                       # div by 128 to see what row we're on
        sll $t2, $t2, 7                         # shift this value left by 7 i.e. multiply by 128 to get the beginning of the row
        add $t2, $t2, $t1                       # add this back to the base address to get the starting pixel of the row and store in $t2
        add $a1, $t2, $zero                     # also save this in $a1 to use later
        
        li $t0, 0                               # starting counter
        
        check_row_complete_loop:
            lw $t1, 0($t2)                      # load the colour in $t2, the curr pixel, into $t1
            beq $t1, 0x383838, exit_check_complete_row_loop        # if the colour is the first grid colour, the row isn't complete
            beq $t1, 0x1c1c1c, exit_check_complete_row_loop        # if the colour is the second grid colour, the row isn't complete
            
            addi $t0, $t0, 1                    # add one to the current column counter
            addi $t2, $t2, 4                    # go to the next pixel
            
            beq $t0, 14, shift_row_down         # if we've got to the end of the row and not broken out of the loop, the row is complete
            
            j check_row_complete_loop           # loop again

        shift_row_down:             

            add $t1, $a1, $zero                 # set $t1 as the first pixel of the row we're looking at
            addi $t1, $t1, 128
            
            shift_row_down_loop:
                lw $t2, ADDR_DSPL                       # set $t2 to be the base address of the display
                sub $t3, $t1, $t2                       # get the difference between the current pixel and the base address
                
                lw $t4, -128($t1)                         # get colour from pixel above
                 
                beq $t4, 0x383838, paint_grid_colour_1
                beq $t4, 0x1c1c1c, paint_grid_colour_2
                beq $t4, 0x47f5cf, paint_grid_piece_colour
                
                shift_row_down_loop_restart:
                
                addi $t1, $t1, -4
                
                ble $t3, 128, exit_check_complete_row_loop          # if we're at the first row, stop

                j shift_row_down_loop
                
            paint_grid_colour_1:
                li $t5, 0x1c1c1c
                sw $t5, 0($t1) 
                j shift_row_down_loop_restart
                
            paint_grid_colour_2:
                li $t5, 0x383838
                sw $t5, 0($t1)  
                j shift_row_down_loop_restart
                
            paint_grid_piece_colour:
                li $t5, 0x47f5cf
                sw $t5, 0($t1)  
                j shift_row_down_loop_restart
            
        exit_check_complete_row_loop:
            jr $ra
            


check_W:
    li $t8, 2                       # checks that piece can rotate safely
    div $s1, $t8    
    mfhi $t7                        # remainder when curr orientation is divided by 2
    
    beq $t7, 0, check_W_vert        # if remainder is 0, piece is vertical   
    beq $t7, 1, check_W_horz        # if remainder is 1, piece is horizontal   

    check_W_vert:
  
        li $t8, 0                           # counter for loop
    
        addi $t7, $s0, 4                    # $t7 is the value the to the right of the anchor position
    
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
            
            beq $t8, 3, check_pass          # check if all pixels have been checked
            
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
                # lw $t
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
            lw $t9, -128($s0)
                
            beq $t9, 0x383838, row_type_2
            beq $t9, 0x1c1c1c, row_type_1
            
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
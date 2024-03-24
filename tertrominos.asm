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
    
I_TYPE_HORIZONTAL:
    .byte '0', '4', '8', 'c'        # addresses for the next bytes
    
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
lw $t0, ADDR_DSPL       # $t0 = base address for display
    
lw $s0, ADDR_DSPL       # $s0 = curr anchor location
addi $s0, $s0, 200
li $s1, 0               # $s1 = curr orientation
li $s2, 0               # $s2 = curr shape

jal i_type
    
main:

    li $v0, 32
	li $a0, 1

	syscall
	
    
    addi $t0, $t0, 8

    lw $t9, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t9)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    beq $t8, 0, main
    
    b main

keyboard_input:                     # A key is pressed
    lw $a0, 4($t9)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, respond_to_W
    beq $a0, 0x61, respond_to_A 
    beq $a0, 0x73, respond_to_S 
    beq $a0, 0x64, respond_to_D 
            
    li $v0, 1                       # ask system to print $a0
    syscall
    
    b main

respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
	
respond_to_W:
    addi $s1, $s1, 1                # increment variable that stores rotation
    addi $v0, $s1, 0                # ?
    jal i_type
    
    # xor $t1, $s1, 1
    # li $s1, 0
    # add $s1, $s1, $t1
    
    j main

respond_to_A:
    # ...                             # move the tetromino right
    
    j main

respond_to_S:
    # ...                             # move the tetromino left
    addi $v0, $s1, 0
    j main

respond_to_D:
    # ...                             # move the tetromino down
    
    j main
    

i_type:
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal erase_i
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
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
    
    beq $t7, 1, erase_i_vert
    beq $t7, 0, erase_i_horz
    
    erase_i_vert:
        li $t0, 0               # set starting position as anchor
        add $t0, $t0, $s0
        
        li $t1, 0x000000        # black   
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
    
    
j_type:
    li $t1, 0x0e298c        # J-type: navy
    sw $t1, 0($t0)
    addi $t0, $t0, 128
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    
l_type:
    li $t1, 0xed7011        # L-type: orange
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    subi $t0, $t0, 128
    sw $t1, 0($t0)
    
o_type:
    li $t1, 0xeddb11        # o-type: yellow
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 128
    sw $t1, 0($t0)
    subi $t0, $t0, 4
    sw $t1, 0($t0)
    
s_type:
    li $t1, 0x0b9c31        # s-type: green
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 124
    sw $t1, 0($t0)
    subi $t0, $t0, 4
    sw $t1, 0($t0)
    
t_type:
    li $t1, 0x7e27b8        # t-type: purple
    sw $t1, 0($t0)
    addi $t0, $t0, 124
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    
z_type:
    li $t1, 0xeb3d9a        # z-type: pink
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 128
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)

exit:
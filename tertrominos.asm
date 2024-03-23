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

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 8
    
    j exit


i_type:
    li $t1, 0x47f5cf        # I-type: teal    
    sw $t1, 0($t0)
    addi $t0, $t0, 128
    sw $t1, 0($t0)
    addi $t0, $t0, 128
    sw $t1, 0($t0)
    addi $t0, $t0, 128
    sw $t1, 0($t0)
    
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
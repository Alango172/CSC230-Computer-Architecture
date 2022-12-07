# This code assumes the use of the "Bitmap Display" tool.
#
# Tool settings must be:
#   Unit Width in Pixels: 32
#   Unit Height in Pixels: 32
#   Display Width in Pixels: 512
#   Display Height in Pixels: 512
#   Based Address for display: 0x10010000 (static data)
#
# In effect, this produces a bitmap display of 16x16 pixels.


	.include "bitmap-routines.asm"

	.data
TELL_TALE:
	.word 0x12345678 0x9abcdef0	# Helps us visually detect where our part starts in .data section
	
	.globl main
	.text	
main:
	addi $a0, $zero, 0
	addi $a1, $zero, 0
	addi $a2, $zero, 0x00ff0000
	jal draw_bitmap_box
	
	addi $a0, $zero, 11
	addi $a1, $zero, 6
	addi $a2, $zero, 0x00ffff00
	jal draw_bitmap_box
	
	addi $a0, $zero, 8
	addi $a1, $zero, 8
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	
	addi $a0, $zero, 2
	addi $a1, $zero, 3
	addi $a2, $zero, 0x00000000
	jal draw_bitmap_box

	addi $v0, $zero, 10
	syscall

# Draws a 4x4 pixel box in the "Bitmap Display" tool
# $a0: row of box's upper-left corner
# $a1: column of box's upper-left corner
# $a2: colour of box

draw_bitmap_box:
	addi $sp, $sp, -12	# Made space for storing the return adress
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	addi $s0, $zero, 4 	# Loop count for drawing rows 
	addi $s1, $zero, 4	# Loop count for drawing collums
	
draw_row:
	beq $s1, $zero, end
	add $a0, $a0, $zero 	# Print the  pixel 
	add $a1, $a1, $zero
	jal set_pixel
	
	addi $a0, $a0, 1	# Move the the pixel below
	subi $s0, $s0, 1	# Row loop count -1
	beq $s0, $0, reset_row_move	# Reset the pointer when we have 4 rows drawn
	j draw_row		# If we do not have 4 drawn rows, draw it 
	
reset_row_move:
	addi $a0, $a0, -4	# Set the row # back to the upper row 
	addi $s0, $s0, 4	# Reset the row loop count to 4
	addi $a1, $a1, 1	# Move to the next collumn
	subi $s1, $s1, 1	# Subtract 1 from the collumn loop count 
	j draw_row	
	
end:
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)  	# Load the return adress and set back the stack pointer
	addi $sp, $sp, 12
	jr $ra

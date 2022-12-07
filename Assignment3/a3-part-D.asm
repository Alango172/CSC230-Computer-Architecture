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
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
BOX_ROW:
	.word	0x0
BOX_COLUMN:
	.word	0x0

	.eqv LETTER_a 97
	.eqv LETTER_d 100
	.eqv LETTER_w 119
	.eqv LETTER_x 120
	.eqv BOX_COLOUR 0x0099ff33
	
	.globl main
	
	.text	
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	# initialize variables
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)
	
	lw $a0, BOX_ROW		# Draw the initial box 
	lw $a1, BOX_COLUMN
	addi $a2, $zero, BOX_COLOUR
	jal draw_bitmap_box
	
check_for_event:
	la $s0, KEYBOARD_EVENT_PENDING
	lw $s1, 0($s0)
	beq $s1, $zero, check_for_event
	
	la $t0, KEYBOARD_EVENT			# Get the keyboard event from address
	lw $t1, 0($t0)
	beq $t1, LETTER_a, go_left		# Test the event and decide its moving direction
	beq $t1, LETTER_d, go_right 
	beq $t1, LETTER_w, go_up
	beq $t1, LETTER_x, go_down
	beq $zero, $zero, Skip			# Ignore the key if is not a,d,w,x,
	
Skip:						# Ignore other letters by setting Pending to 0,   	
	sw $zero, KEYBOARD_EVENT_PENDING	# and go back to the check for event for the next letter
	beq $zero, $zero, check_for_event
	
go_up:
	addi $s3, $s3, -1 		# Row - 1, go up
	beq $zero, $zero, cover_draw
	
go_down:
	addi $s3, $s3, 1		# Row + 1, go down
	beq $zero, $zero, cover_draw

go_right:
	addi $s2, $s2, 1		# Column + 1, go right 
	beq $zero, $zero, cover_draw

go_left:
	addi $s2, $s2, -1 		# Column - 1, go left
	beq $zero, $zero, cover_draw
	
cover_draw:
	lw $a0, BOX_ROW			# Load parameters of the box from adress
	lw $a1, BOX_COLUMN
	addi $a2, $zero, 0x00000000	# Draw the black box to cover it
	jal draw_bitmap_box
	
	sw $s2, BOX_COLUMN		# Store the parameters for the next movement
	sw $s3, BOX_ROW
	add $a0, $s3, $zero		# Draw the box 
	add $a1, $s2, $zero
	addi $a2, $zero, BOX_COLOUR
	jal draw_bitmap_box
	
	beq $zero, $zero, Skip		# Repeat the process with next key pressed
	

	# Should never, *ever* arrive at this point
	# in the code.	

	addi $v0, $zero, 10

.data
    .eqv BOX_COLOUR_BLACK 0x00000000
.text
	
	addi $v0, $zero, BOX_COLOUR_BLACK
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
	add $a0, $a0, $zero 	
	add $a1, $a1, $zero	
	jal set_pixel		# Print the pixel
	
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


	.kdata

	.ktext 0x80000180
#
# You can copy-and-paste some of your code from part (a)
# to provide elements of the interrupt handler.
#
__kernel_entry:
	mfc0 $k0, $13		# $13 is the "cause" register in Coproc0
	andi $k1, $k0, 0x7c	# bits 2 to 6 are the ExcCode field (0 for interrupts)
	srl  $k1, $k1, 2	# shift ExcCode bits for easier comparison
	bne $zero, $k1, __exit_exception
		
	andi $k1, $k0, 0x0100	# examine bit 8
	bne $k1, $zero, __is_keyboard_interrupt	 # if bit 8 set, then we have a keyboard interrupt.
	beq $zero, $zero, __exit_exception	# otherwise, we return exit kernel
	
__is_keyboard_interrupt:
	la $k0, KEYBOARD_EVENT_PENDING
	lw $k1, 0($k0)
	addi $k1, $zero, 1
	sw $k1, KEYBOARD_EVENT_PENDING

	la $k0, 0xffff0004
	lw $t7, 0($k0)
	sw $t7, KEYBOARD_EVENT
	beq $zero, $zero, __exit_exception	# Kept here in case we add more handlers.
	
__exit_exception:
	eret


.data

# Any additional .text area "variables" that you need can
# be added in this spot. The assembler will ensure that whatever
# directives appear here will be placed in memory following the
# data items at the top of this file.

	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE


.eqv BOX_COLOUR_WHITE 0x00FFFFFF
	

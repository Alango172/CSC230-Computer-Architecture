	.data
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
KEYBOARD_COUNTS:
	.space  128
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
	
	
	.eqv    LETTER_a 97
	.eqv	LETTER_b 98
	.eqv	LETTER_c 99
	.eqv 	LETTER_D 100
	.eqv 	LETTER_space 32
	
	
	.text  
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
				# Enable keyboard device to generate interrupts
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)


check_for_event:
	la $s0, KEYBOARD_EVENT_PENDING
	lw $s1, 0($s0)
	beq $s1, $zero, check_for_event
	
	la $t0, KEYBOARD_EVENT
	lw $t1, 0($t0)
	beq $t1, LETTER_space, Print_count	# Print the message if click the space
	blt $t1, LETTER_a, Skip			# Ignore if the insert letter has a value lower than a
	bgt $t1, LETTER_D, Skip			# Ignore if the insert letter has a value grater than d
	
	la $t0, KEYBOARD_COUNTS			# Get the address of keyboard count
	subi $t1, $t1, 97  			# Let a=0, b=1, c=2, d=3
	sll $t1, $t1, 2				# Shift left logic for 2 places, to get the lenght of a word
	add $t0, $t1, $t0   			# Get the address for each letter
	lw $t2, 0($t0)				# Load word of the letter position to add count
	addi $t2, $t2, 1			# Count++
	sw $t2, 0($t0)		# Store it back to the address
	beq $zero, $zero, Skip			# Set the pending to 0 and go back to check the next letter
			
Print_count:
	la $a0, KEYBOARD_COUNTS
	addi $a1, $zero, 4			# Set 4 spaces for printing letter count for a,b,c,d
	jal dump_array
	
Skip:						# Ignore other letters by setting Pending to 0, 
	la $t3, KEYBOARD_EVENT_PENDING  	# and go back to the check for event for the next letter
	sw $zero, KEYBOARD_EVENT_PENDING	
	beq $zero, $zero, check_for_event
	
dump_array:
	addi $sp, $sp, -16	
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	move $s0, $a0		# Move the data address in the argument to $s0
	
loop:	
	beq $a1, 0, end		# Set the ending condition 
	lw $a0, 0($s0)		# Load word to get the integer to print, give it to $a0
	addi $v0, $zero, 1	# Set the $v0 to be 1 for printing integer
	syscall
	
	la $a0, SPACE		# Print the sting SPACE
	addi $v0, $zero, 4
	syscall
	
	addi $s0, $s0, 4	# Move 4 bits forward since we need to load a word each time
	subi $a1, $a1, 1	# Minus 1 the loop counter after each loop
	j loop
	
end:
	la $a0, NEWLINE		# Move to a Newline at the end to a dumb_jump
	addi $v0, $zero, 4
	syscall
	
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra
	
	
	.kdata

	.ktext 0x80000180
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
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

	

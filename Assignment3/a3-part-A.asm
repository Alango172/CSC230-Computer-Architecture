
	.data
ARRAY_A:
	.word	21, 210, 49, 4
ARRAY_B:
	.word	21, -314159, 0x1000, 0x7fffffff, 3, 1, 4, 1, 5, 9, 2
ARRAY_Z:
	.space	28
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
		
	
	.text  
main:	
	la $a0, ARRAY_A
	addi $a1, $zero, 4
	jal dump_array
	
	la $a0, ARRAY_B
	addi $a1, $zero, 11
	jal dump_array
	
	la $a0, ARRAY_Z
	lw $t0, 0($a0)
	addi $t0, $t0, 1
	sw $t0, 0($a0)
	addi $a1, $zero, 9
	jal dump_array
		
	addi $v0, $zero, 10
	syscall

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	
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
	
	
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

# UVic CSC 230, Fall 2020
# Assignment #1, part C

# Student name: Chaofan Cai 	
# Student number: V00940471


# Compute M / N, where M must be in $8, N must be in $9,
# and M / N must be in $15.
# N will never be 0


.text
start:
	lw $8, testcase2_M
	lw $9, testcase2_N

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	xor $15, $15, $15

loop:	
	blt $8, $9, exit   # if M is less than N, exit the loop 
 	sub $8, $8, $9     # if M is greater than N, do the subtraction 
 	addi $15, $15, 1   # Add 1 to the result 
 	bge $8, $9, loop   # If M is still greater than N, continue loop 
 	
	

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

exit:
	add $2, $0, 10
	syscall
		

.data

# testcase1: 370 / 120 = 3
#
testcase1_M:
	.word	370
testcase1_N:
	.word 	120
	
# testcase2: 24156 / 77 = 313
#
testcase2_M:
	.word	24156
testcase2_N:
	.word 	77
	
# testcase3: 33 / 120 = 0
#
testcase3_M:
	.word	33
testcase3_N:
	.word 	120

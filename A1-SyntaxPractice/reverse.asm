# UVic CSC 230, Fall 2020
# Assignment #1, part B

# Student name: Chaofan Cai 
# Student number: V00940471


# Compute the reverse of the input bit sequence that must be stored
# in register $8, and the reverse must be in register $15.


.text
start:
	lw $8, testcase1   # STUDENTS MAY MODIFY THE TESTCASE GIVEN IN THIS LINE
	
# STUDENTS MAY MODIFY CODE BELOW 
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	xor $15, $15, $15   # Initialize $15 to be 0
	addi $10, $0, 32    # Initialize $10 for loop counter
		
loop: 	
 	beq $10, 0, exit    # If $8 is 0, exit the loop 
	addi $9, $0, 1	    # Create a mask equal to 1 for getting bit 1	
	and $9, $8, $9      # Use and logic to test if the right most bit is 1
	srl $8, $8, 1       # Shift right the original number for 1 place
	sub $10, $10, 1     # Subtract 1 from the loop counter
	
	sll $15, $15, 1     # Shift left the reversed number for 1 place
	beq $9, 1, tag      # If the right most bit of $8 is 1, we go to tag 
	
	j loop              # Go back to the loop 
  
tag: 	
	add $15, $15, 1     # Add 1 to the reverse number $15	
	j loop              # Go back to the loop 
	

	nop
	#add $15, $0, -10

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

exit:
	add $2, $0, 10
	syscall 
	
	

.data

testcase1:
	.word	0x00200020    # reverse is 0x04000400

testcase2:
	.word 	0x00300020    # reverse is 0x04000c00
	
testcase3:
	.word	0x1234fedc     # reverse is 0x3b7f2c48

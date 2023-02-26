# UVic CSC 230, Fall 2020
# Assignment #1, part A

# Student name: Chaofan Cai 
# Student number: V00940471


# Compute odd parity of word that must be in register $8
# Value of odd parity (0 or 1) must be in register $15


.text

start:
	lw $8, testcase1  # STUDENTS MAY MODIFY THE TESTCASE GIVEN IN THIS LINE
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	xor $9, $9, $9  #Initialize $9 for storing bits counted
	
loop: 	
	beq $8, 0, quit    #If the testing number is equal to 0, quit the loop
	addi $10, $0, 1    #Initialize $10 as 1, every loop to be the mask
	and $10, $8, $10   #Use and logic instruction to test the right most bit 
	srl $8, $8, 1      #Shift right the test number for 1 bit each loop
	
	bne $10, 1, loop   #If the mask is not equal to 1, go to the loop for another iteration 
	add $9, $9, 1	   #If the mask is still 1, add 1 count to the counter
	j loop    	   #Go to the loop after adding the counter 

quit:	
	and $15, $9, 1     #Test parity of the bits counted, 
	beq $15, 1, parity #If the right most bit is 1, means it has odd number of bits
	add $15, $15, 1    #If it is not 1, means we need to add 1 to make it 
	j exit 	
		
parity: 
	sub $15, $15, 1    # If parity is odd, we do not need subtract 1
	

	nop
	#addi $15, $0, -10


# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE


exit:
	add $2, $0, 10
	syscall 
		

.data

testcase1:
	.word	0x00200020    # odd parity is 1

testcase2:
	.word 	0x00300020    # odd parity is 0
	
testcase3:
	.word  0x1234fedc     # odd parity is 0


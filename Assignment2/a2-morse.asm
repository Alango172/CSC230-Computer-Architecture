# Name: Chaofan Cai 
# Student ID: V00940471
.text


main:	



# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	## Test code that calls procedure for part A
	#jal save_our_souls

	## morse_flash test for part B
	#addi $a0, $zero, 0x42   # dot dot dash dot
	#jal morse_flash
	
	## morse_flash test for part B
	# addi $a0, $zero, 0x37   # dash dash dash
	# jal morse_flash
		
	## morse_flash test for part B
	#addi $a0, $zero, 0x32  	# dot dash dot
	#jal morse_flash
			
	## morse_flash test for part B
	#addi $a0, $zero, 0x11   # dash
	#jal morse_flash	
	
	# flash_message test for part C
	 #la $a0, test_buffer
	 #jal flash_message
	
	# letter_to_code test for part D
	# the letter 'P' is properly encoded as 0x46.
	#addi $a0, $zero, 'P'
	#jal letter_to_code
	
	# letter_to_code test for part D
	# the letter 'A' is properly encoded as 0x21
	#addi $a0, $zero, 'A'
	#jal letter_to_code
	
	# letter_to_code test for part D
	# the space' is properly encoded as 0xff
	#addi $a0, $zero, ' '
	#jal letter_to_code
	
	# encode_message test for part E
	# The outcome of the procedure is here
	# immediately used by flash_message
	la $a0, message03
	la $a1, buffer01
	jal encode_message
	la $a0, buffer01
	jal flash_message
	
	
	# Proper exit from the program.
	addi $v0, $zero, 10
	syscall

	
	
###########
# PROCEDURE
save_our_souls:
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long           # 3 dots
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long          # 3 dash
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on 
	jal delay_short
	jal seven_segment_off 
	jal delay_long
	jal seven_segment_on 
	jal delay_short
	jal seven_segment_off   
	jal delay_long          # 3 dots
	jr $31


# PROCEDURE
morse_flash:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	addi $t3, $0, 0xff 
	beq $a0, $t3, make_space   # Display long if there is space
	
	
	andi $s0, $a0, 0xf0   # Get the lenght of the sequence from the high nybble
	srl $s0, $s0, 4       # Let the high nybble be a number
	andi $s1, $a0, 0xf    # Get the dot-dash sequence from the low nybble
	addi $s3, $0, 8       # Dot-dash checker
	addi $t0, $0, 4
	sub $t1, $t0, $s0       # Calculate the checker position 
	beq $s3, 8, set_checker 

flash_loop: 
	beq $s3, $0, end_flash
	and $s2, $s1, $s3     	 # And the dot-dash sequence with checker to determine dash or dot
	beq $s2, $0, show_dot	 # If the bit is 0, show dot
	beq $s2, $s2, show_dash  # Else show dash
	
set_checker:
	beq $t1, $0, flash_loop
	sub $t1,$t1, 1
	srl $s3, $s3, 1
	j set_checker
	
make_space:
	jal delay_long
	jal delay_long
	jal delay_long

show_dash:
	
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long

	srl $s3, $s3, 1      # Shift left the checker 
	subi $s0, $s0, 1
	j flash_loop
	
	
show_dot:
	
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	
	srl $s3, $s3, 1      # Shift left the checker 
	subi $s0, $s0, 1
	j flash_loop
	
end_flash:
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	jr $ra

###########
# PROCEDURE
flash_message:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	add  $s0, $zero, $a0    # Get the date memory adress

message_loop:
	lb $a0, 0($s0)  
	beq $a0, $0, end_message
	jal morse_flash
	addi $s0, $s0, 1
	j message_loop
	
end_message:
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
	
	
###########
# PROCEDURE
letter_to_code:
	addi $t4, $0, 0x20 # space
        beq $a0, $t4, aspace # check there is space or not
	
	la $t0, codes
	add $s1, $0, $0     # The availavle length
	add $s2, $0, $0     # Dot-dash sequence 
	
outer_loop:
	lb $t1, 0($t0)      # Load byte from adress
	beq $t1, $0, end_encoding    # While men[T] != 0
	beq $t1, $t4, aspace  # If mem[T] = space, make $v0 = oxff	
	beq $a0, $t1, letter_to_be_converted   # If the letter = a letter in the table start convertion
	add $t0, $t0, 8
	j outer_loop

letter_to_be_converted:
	add $t0, $t0, 1     # T = T + 1 
	lbu  $t1, 0($t0)      # Load byte from adress
	beq $t1, $0, end_encoding    # While men[T] != 0
	beq $t1, '.', set_dot    # If men[T] = '.', set 0 to the sequence 
	beq $t1, '-', set_dash   # If men[T] = '-', set 1 to the sequence

set_dot:
	addi $s1, $s1, 1    # Add count to the available length
	sll $s2, $s2, 1     # Shift left 1 bit dot-dash sequence
 	j letter_to_be_converted     # Go back to the inner loop

set_dash:
	addi $s1, $s1, 1    # Add count to the available length
	sll $s2, $s2, 1
	addi $s2, $s2, 1    # Set 1 for dash in dot dash sequence
	j letter_to_be_converted    # Go back to the inner loop 
	
aspace:
	addi $v0, $0, 0xff
	
end_encoding:
	sll $s1, $s1, 4       # xxxxyyyy  for length and dot dash structure 
	add $v0, $s1, $s2     # Return Value 
	jr $ra	


###########
# PROCEDURE
encode_message: 
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	add $s0, $a0, $0

read_adress:
	lb $t0, 0($s0)
	bne $t0, $0, read_write
	j exit
	
read_write:
	add $a0, $t0, $0
	jal letter_to_code
	sb   $v0, ($a1)
	addi $s0, $s0, 1
	addi $a1, $a1, 1
	j read_adress
	  	
exit:	
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

#############################################
# DO NOT MODIFY ANY OF THE CODE / LINES BELOW

###########
# PROCEDURE
seven_segment_on:
	la $t1, 0xffff0010     # location of bits for right digit
	addi $t2, $zero, 0xff  # All bits in byte are set, turning on all segments
	sb $t2, 0($t1)         # "Make it so!"
	jr $31


###########
# PROCEDURE
seven_segment_off:
	la $t1, 0xffff0010	# location of bits for right digit
	sb $zero, 0($t1)	# All bits in byte are unset, turning off all segments
	jr $31			# "Make it so!"
	

###########
# PROCEDURE
delay_long:
	add $sp, $sp, -4	# Reserve 
	sw $a0, 0($sp)
	addi $a0, $zero, 600
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31

	
###########
# PROCEDURE			
delay_short:
	add $sp, $sp, -4
	sw $a0, 0($sp)
	addi $a0, $zero, 200
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31




#############
# DATA MEMORY
.data
codes:
	.byte 'A', '.', '-', 0, 0, 0, 0, 0
	.byte 'B', '-', '.', '.', '.', 0, 0, 0
	.byte 'C', '-', '.', '-', '.', 0, 0, 0
	.byte 'D', '-', '.', '.', 0, 0, 0, 0
	.byte 'E', '.', 0, 0, 0, 0, 0, 0
	.byte 'F', '.', '.', '-', '.', 0, 0, 0
	.byte 'G', '-', '-', '.', 0, 0, 0, 0
	.byte 'H', '.', '.', '.', '.', 0, 0, 0
	.byte 'I', '.', '.', 0, 0, 0, 0, 0
	.byte 'J', '.', '-', '-', '-', 0, 0, 0
	.byte 'K', '-', '.', '-', 0, 0, 0, 0
	.byte 'L', '.', '-', '.', '.', 0, 0, 0
	.byte 'M', '-', '-', 0, 0, 0, 0, 0
	.byte 'N', '-', '.', 0, 0, 0, 0, 0
	.byte 'O', '-', '-', '-', 0, 0, 0, 0
	.byte 'P', '.', '-', '-', '.', 0, 0, 0
	.byte 'Q', '-', '-', '.', '-', 0, 0, 0
	.byte 'R', '.', '-', '.', 0, 0, 0, 0
	.byte 'S', '.', '.', '.', 0, 0, 0, 0
	.byte 'T', '-', 0, 0, 0, 0, 0, 0
	.byte 'U', '.', '.', '-', 0, 0, 0, 0
	.byte 'V', '.', '.', '.', '-', 0, 0, 0
	.byte 'W', '.', '-', '-', 0, 0, 0, 0
	.byte 'X', '-', '.', '.', '-', 0, 0, 0
	.byte 'Y', '-', '.', '-', '-', 0, 0, 0
	.byte 'Z', '-', '-', '.', '.', 0, 0, 0
	
message01:	.asciiz "A A A"
message02:	.asciiz "SOS"
message03:	.asciiz "WATERLOO"
message04:	.asciiz "DANCING QUEEN"
message05:	.asciiz "CHIQUITITA"
message06:	.asciiz "THE WINNER TAKES IT ALL"
message07:	.asciiz "MAMMA MIA"
message08:	.asciiz "TAKE A CHANCE ON ME"
message09:	.asciiz "KNOWING ME KNOWING YOU"
message10:	.asciiz "FERNANDO"

buffer01:	.space 128
buffer02:	.space 128
test_buffer:	.byte 0x30 0x37 0x30 0x00    # This is SOS

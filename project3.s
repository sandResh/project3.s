  
.data
	theString: .space 1001
	singleString: .space 1001

	#Error Messages
	INVALID_INPUT: .asciiz  "Invalid input"

.text
	main:
		#Taking user input as string
		li $v0, 8
		la $a0, theString
		syscall

		li $v0, 1
		la $a0, singleString
		syscall

        la $a0, theString

        jal subRoutineA
        
		#Exiting the program
		li $v0, 10
		syscall

subRoutineA:
	la $s3, singleString
	la $t0, singleString 
	add $s4, $0, $a0

	charLoop:
		lb $t1, ($s4)

		beq $t1, 10, exitCharLoop
		beq $t1, 0, exitCharLoop
		beq $t1, 44, exitCharLoop

		sb $t1, ($t0)

		addi $t0, $t0, 1
		addi $s4, $s4, 1

		j charLoop

	exitCharLoop:

	# If the character is coma.
	li $t3, 0  
	sb $t3, ($t0) # Store the eos character.

	seq $s6, $t1, 10
	beq $t1, 10, skip

	seq $s6, $t1, 0

	skip:

	move $s5, $ra
	move $a0, $s3
	jal subRoutineB
	move $ra, $s5

	li $v0, 11
	li $a0, '\n'
	syscall

	li $v0, 1
	la $a0, singleString
	syscall

	# If the character is not coma, end the function.
	beq $s6, 1, exitFunction

	# Print coma.
	li $v0, 11
	li $a0, ','
	syscall

	la $t0, singleString
	addi $s4, $s4, 1
	j charLoop

	exitFunction:

	jr $ra



subRoutineB:

		move $t0, $a0
		li $s0, 0				# Initializing registers to store value of decimal
		li $s7, 0				# Flag to help check space in the middle of string($s0 is 1 after first non space character is encountered, otherwise 0)
		li $t4, 1				# Initializing power to be multiplied
		li $s1, 30				# Base
	#Checking if the length of string is less than or equal to 4
	li $t1, 0   # Counter, at the end $t1 will have number of characters(non space) in the string
	length:

		lb $t2, 0($t0)

		li $v0, 11
		move $a0, $t2
		syscall

		li $v0, 11
		li $a0, '\n'
		syscall

		beq $t2, 10, checkEmpty     # If \n is encountered move to converting part
		addi $t0, $t0, 1
		beq $t2, 32, checkSpaceLen    # If current character is space move to beginning of the loop without incrementing the counter
		li $s7, 1		     # Whenever nonspace character is encountered set $s7 to 1
		addi $t1, $t1, 1

		li $v0, 11
		move $a0, $t2
		syscall

		bgt $t1, 4, tooLong
		j length

	convert:
		beq $t1, 0, printDecimal
		addi $t0, $t0, -1     # Move one character backward in the string
		lb $t2, 0($t0)
		beq $t2, 32, checkSpace   # If character is space go to checkSpace to check whether the space is at middle of string or not
		li $s7, 1			# Whenever nonspace character is encountered set $s7 to 1
		addi $t1, $t1, -1		# Decrement $t1 by 1

		# Pass the argument in $a0.
		move $a0, $t2
		move $t8, $ra

		jal subRoutineC

		move $ra, $t8

		j compute


	

	# Ignore the spaces at the end of theString, if space found in the middle print error message
	checkSpace:
		addi $t0, $t0, -1         # Go to one character backward in the string
		lb $t2, 0($t0)
		addi $t1, $t1, -1
		beq $t2, 32, checkSpace   # If character ahead is also space, go to checkSpace
		beq $s7, 1, invalidChar          # If character is not space, check whether a non space character is encountered already, if yes($s7=1) add one to the length($t1)
		add $t0, $t0, 1				# Before going back to convert increment character in the string, because character is decremented at the beginning of 								convert
		j convert 					# jump to convert
	
	checkSpaceLen:
		beq $s7, 0, length
		add $t1, $t1, 1
		j length

	checkEmpty:
		beq $t1, 0, empty
		li $s7, 0 		# Reset $s7 to 0 before converting
		j convert

	compute:
		mult $v0, $t4 					# Multilpy the value with power
		mflo $v0					    # Move result of multiplication to $t5
		add $s0, $s0, $v0 				# Increment the decimal value by result of multiplication
		mult $t4, $s1					# Multiply the power by 30
		mflo $t4
		j convert    					# Jump back to convert

	printDecimal:
		li $v0, 1
		add $a0, $s0, $zero
		syscall
		jr $ra

	empty:
 		li $v0, 4
 		la $a0, INVALID_INPUT
 		syscall
 		jr $ra
	
	tooLong:
		li $v0, 11
		li $a0, 'X'
		syscall

	 	li $v0, 4
	 	la $a0, INVALID_INPUT
	 	syscall
	 	jr $ra

	invalidChar:
	 	li $v0, 4
	 	la $a0, INVALID_INPUT
	 	syscall
	 	jr $ra


subRoutineC:

	blt $a0, 48, invalidChar2      	# If char is less than 48, invalid char
	blt $a0, 58, convertNum2  	# If char is between 48 and 57, char is a number

	blt $a0, 65, invalidChar2
	blt $a0, 85, convertUpper2
	blt $a0, 97, invalidChar2
	blt $a0, 117, convertLower2

	j invalidChar2

	convertNum2:
		addi $t5, $a0, -48				# Get the value of number character

		move $v0, $t5
		jr $ra

	convertUpper2:
		addi $t5, $a0, -55

		move $v0, $t5
		jr $ra

	convertLower2:
		addi $t5, $a0, -87

		move $v0, $t5
		jr $ra

	invalidChar2:
	 	li $v0, 4
	 	la $a0, INVALID_INPUT
	 	syscall

	 	li $v0, 8
	 	syscall

	 	jr $ra


# table of responsibilities of registrators 
# $s0 -> flag of gameloop
# $s1 -> aux of small works (using in distributionOfPieces)
# $s2 -> aux of small works (using in distribution Of Pieces for receive piece address)
# $s3 -> aux of small works (using in piecesIterator)
# $s4 -> aux of small works (using in the noRepeatRandomNum routine)
# $s5 -> flag of playerIterator
# $t3 -> aux for parse Iterators
# $t4 -> aux of small works (using in isRepeatedNumLoop how var for aux load num of noRepeatNumArray)
# $t5 -> aux of small works (using in noRepeatRandomNum how var for save random number)
# $t6 -> aux of small works (using in isRepeatedNumLoop how flag for beq)
# $t7 -> aux of small works (using in isRepeatedNum for iterator while)


.data
pieces: .word 0, 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 33, 34, 35, 36, 43, 44, 45, 46, 55, 56, 66
jogador1: .word -0 -1 -1 -1 -1 -1 -1
jogador2: .word -2 -1 -1 -1 -1 -1 -1
jogador3: .word -3 -1 -1 -1 -1 -1 -1
jogador4: .word -4 -1 -1 -1 -1 -1 -1

noRepeatNumArray: .word -6 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1   # use for don't repeat random integer in 0 - 27

.text

# Tabuleiro: 1|2 => 2|5 => 1|2 => 2|5 

addi $s5,$zero,0	#define player iterator to 0

distributionOfPieces: beq $s1,28, distributionOfPiecesEnd # while($s1 != 28) 
	# distribution address of pieces for players...
	addi $s3, $zero,0 				# $s3 = 0 
	piecesIterator:	slti $t0, $s3, 7		# for i=0;i<7;i++
		beq $t0, $zero,piecesIteratorEnd 	# $t0 == 0 end loop
		jal noRepeatRandomNum			# calls noRepeatRandomNum()				
		
		# save $t5 into player[$s3] (obs: $t5 is the position in pieces array)
		beq $s5, 0, givePiecesPlayer1		# if $s5(player iterator) ==  1 
		beq $s5, 1, givePiecesPlayer2		# if $s5(player iterator) ==  2 
		beq $s5, 2, givePiecesPlayer3		# if $s5(player iterator) ==  3 
		beq $s5, 3, givePiecesPlayer4		# if $s5(player iterator) ==  4 
		
		exitGivePiecesToPlayer:
		addi $s1, $s1, 1 
		addi $s3, $s3, 1			# $s3 += 1
	j piecesIterator 				# back to piecesIterator
	piecesIteratorEnd:
	addi $s5, $s5, 1				# $s5 (player iterator) += 1	 						# $s1 += 1
j distributionOfPieces 					# back to distributionOfPieces
distributionOfPiecesEnd:

# switch between who will receive the pieces
givePiecesPlayer1:mul $t3, $s3, 4
	 sw $t5, jogador1($t3)		# jogador1[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	j exitGivePiecesToPlayer
	
givePiecesPlayer2:mul $t3, $s3, 4
	 sw $t5, jogador2($t3)		# jogador2[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	j exitGivePiecesToPlayer
	
givePiecesPlayer3:mul $t3, $s3, 4
	 sw $t5, jogador3($t3)		# jogador3[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	j exitGivePiecesToPlayer

givePiecesPlayer4:mul $t3, $s3, 4
	 sw $t5, jogador4($t3)		# jogador4[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	j exitGivePiecesToPlayer
#########################################################

addi $s0, $zero, 1 # flag for gameLoop ($s0 = 1)
#gameLoop: beq $s0, 0, gameLoopEnd # $s0 == 0 then go to gameLoopEnd


# jogador X 
# peça escolhilda é valida ? 
# joga a peça
# printa o tabuleiro
#limpa a peça de jogadorX

# if Jogador X tem zero peças ? 
# if se o jogo fechou  
# jogador X + 1

#	j gameLoop # back to 'gameLoop'
#gameLoopEnd: 	addi $v0, $zero, 10 #syscal of end program
#		syscall

addi $v0, $zero, 10 #syscal of end program
	syscall

noRepeatRandomNum:
	li $v0, 42            	# system call to generate random int
	la $a1, 27       	# where you set the max integer on random
	syscall
	
	addi $t5, $a0, 0  	#t5 = random num
	
	# after here, needed to analyze if the random number is not repeat
	addi $t7, $zero, 0  				#t7 =0
	isRepeatedNumLoop: slti $t6, $t7, 27		# for j=0;j<28;j++  (this condiction is saved in $t6)
		beq $t6, $zero,isRepeatedNumLoopEnd     # if ($t6 == 0)
		
		mul $t3, $t7, 4
		lw $t4, noRepeatNumArray($t3)    	# $t4 = noRepeatNumArray[$t7] (obs: $t3 equal to $t7 * 4)
		beq $t4,$t5, isRepeatNum		# if(true)
		
		addi $t7, $t7, 1			# $t7 += 1
	j isRepeatedNumLoop	
		  	  	
	isRepeatedNumLoopEnd:
	mul $t3, $s1, 4	
	sw $t5, noRepeatNumArray($t3)			# if don't have problem, need save this random number into noRepeatNumArray (obs: $t3 equal to $s1 * 4)
	jr $ra   					# in here return to the next line of jal command of this routine

isRepeatNum:
	j noRepeatRandomNum
	
	


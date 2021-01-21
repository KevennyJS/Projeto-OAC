# table of responsibilities of registrators 
# $s0 -> flag of gameloop
# $s1 -> aux of small works (using in distributionOfPieces for iterator pieces)
# $s5 -> flag of playerIterator
# $t3 -> aux for parse Iterators
# $t4 -> aux of small works (using in player 1 count)
# $t5 -> aux of small works (using in player 2 count)
# $t6 -> aux of small works (using in player 3 count)
# $t7 -> aux of small works (using in player 4 count)


.data
pieces: .word 0, 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 33, 34, 35, 36, 43, 44, 45, 46, 55, 56, 66
jogador1: .word -0 -1 -1 -1 -1 -1 -1
jogador2: .word -2 -1 -1 -1 -1 -1 -1
jogador3: .word -3 -1 -1 -1 -1 -1 -1
jogador4: .word -4 -1 -1 -1 -1 -1 -1

.text

# Tabuleiro: 1|2 => 2|5 => 1|2 => 2|5 


distributionOfPieces: slti $t0, $s1, 28			# for i=0;i<28;i++ 
		beq $t0, $zero,distributionOfPiecesEnd 	# $t0 == 0 end loop

		li $v0, 42            	# system call to generate random int
		la $a1, 4       	# where you set the max integer on random
		syscall				
		
		addi $s5, $a0, 0 	# $s5 = random num (0 - 3)
		# save $t5 into player[$s3] (obs: $t5 is the position in pieces array)
		beq $t4, 7, player1FullPieces
		beq $s5, 0, givePiecesPlayer1		# if $s5(player iterator) ==  1 
			player1FullPieces:
			
		beq $t5, 7, player2FullPieces
		beq $s5, 1, givePiecesPlayer2		# if $s5(player iterator) ==  2 
			player2FullPieces:
		
		beq $t6, 7, player3FullPieces	
		beq $s5, 2, givePiecesPlayer3		# if $s5(player iterator) ==  3 
			player3FullPieces:
			
		beq $t7, 7, player4FullPieces
		beq $s5, 3, givePiecesPlayer4		# if $s5(player iterator) ==  4 
			player4FullPieces:
		
		exitGivePiecesToPlayer:
		
j distributionOfPieces 					# back to distributionOfPieces
distributionOfPiecesEnd:

# switch between who will receive the pieces
givePiecesPlayer1:mul $t3, $t4, 4
	 sw $s1, jogador1($t3)		# jogador1[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	 addi $t4, $t4, 1
	 addi $s1, $s1, 1 		# iterator pieces		
	j exitGivePiecesToPlayer
	
givePiecesPlayer2:mul $t3, $t5, 4
	 sw $s1, jogador2($t3)		# jogador2[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	 addi $t5, $t5, 1
	 addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer
	
givePiecesPlayer3:mul $t3, $t6, 4
	 sw $s1, jogador3($t3)		# jogador3[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	 addi $t6, $t6, 1
	 addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer

givePiecesPlayer4:mul $t3, $t7, 4
	 sw $s1, jogador4($t3)		# jogador4[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	 addi $t7, $t7, 1
	 addi $s1, $s1, 1 		# iterator pieces
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

	


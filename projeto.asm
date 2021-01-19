# table of responsibilities of registrators 
# $s0 -> flag of gameloop
# $s1 -> aux of small works
# $s2 -> aux of small works
# $s3 -> aux of small works
# $s7 -> aux for player iterator

.data
pieces: .word 0, 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 33, 34, 35, 36, 43, 44, 45, 46, 55, 56, 66
jogador1: .word -1 -1 -1 -1 -1 -1 -1
jogador2: .word -1 -1 -1 -1 -1 -1 -1
jogador3: .word -1 -1 -1 -1 -1 -1 -1
jogador4: .word -1 -1 -1 -1 -1 -1 -1

.text

# Tabuleiro: 1|2 => 2|5 => 1|2 => 2|5 

addi $s0, $zero, 1 # flag for gameLoop ($s0 = 1)

gameLoop: beq $s0, 0, gameLoopEnd # $s0 == 0 then go to gameLoopEnd

distributionOfPieces: beq $s1,28, distributionOfPiecesEnd # while($s1 != 28)
	# distribution address of pieces for players...
	addi $s3, $zero,0 			# $s3 = 0 
	piecesIterator:	slti $t0, $s3, 7	# for i=0;i<7;i++
	beq $t0, $zero,piecesIteratorEnd 	#$t0 == 0 end loop
	
	# la $s2, pieces + randomNumber() # load piece adress to $s2
	# jogadorX[i] = $s2 # load $s2 in jodadorX: .word [i]
	
	addi $s3, $s3, 1			# $s3 += 1
	j piecesIterator 			# back to piecesIterator
	
	piecesIteratorEnd:	 		
	addi $s1, $s1, 1 			# $s1 += 1
	j distributionOfPieces 			# back to distributionOfPieces
distributionOfPiecesEnd:

# jogador X 
# peça escolhilda é valida ? 
# joga a peça
# printa o tabuleiro
#limpa a peça de jogadorX

# if Jogador X tem zero peças ? 
# if se o jogo fechou  
# jogador X + 1

	j gameLoop # back to 'gameLoop'
gameLoopEnd: 	addi $v0, $zero, 10 #syscal of end program
		syscall

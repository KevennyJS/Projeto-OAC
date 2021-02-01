# table of responsibilities of registrators 
# $s0 -> flag of gameloop
# $s1 -> aux of small works (using in distributionOfPieces for iterator pieces) | (after distribution of pieces) -> use in loop at parse word to asciiz | using in game loop for botChoicePiece
# $s2 -> using with a flag to signalize the "I don't have piece for this round"
# $s4 -> (in Gameloop) using to save piece choice in round
# $s5 -> flag of playerIterator
# $s6 -> file descriptor
# $s7 -> aux for parse .word to asciiz | (after using for pass piece for verification) 
# $t1 -> aux for parse .word to asciiz | (using for pass piece for verification)
# $t2 -> aux for parse .word to asciiz 
# $t3 -> aux for parse Iterators | (after distribution of pieces) -> use in parse word to asciiz
# $t4 -> aux of small works (using in player 1 count) | (after distribution of pieces) -> use in parse word to asciiz
# $t5 -> aux of small works (using in player 2 count) | 
# $t6 -> aux of small works (using in player 3 count) | 
# $t7 -> aux of small works (using in player 4 count) | (using for save verification results)


.data
pieces: .word 0, 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 33, 34, 35, 36, 43, 44, 45, 46, 55, 56, 66
jogador1: .word -0 -1 -1 -1 -1 -1 -1
jogador2: .word -2 -1 -1 -1 -1 -1 -1
jogador3: .word -3 -1 -1 -1 -1 -1 -1
jogador4: .word -4 -1 -1 -1 -1 -1 -1
board:    .space 428  # 107 * 4 = 428 # 0->1->2->3->4->5->6->11->12->13->14->15->16->22->23->24->25->26->33->34->35->36->43->44->45->46->55->56->66

str_exit: .asciiz "test.txt"
data_jogadorForOut: .asciiz "-1 -1 -1 -1 -1 -1 -1" 
data_jogadorForOut_end:

prompt_selectPiece: .asciiz "Select piece: (0-6)"
reply_prompt_pieceNumber: .space 2 # including '\0'


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

addi $s5, $zero,0 	#set player1 to first player 

#GAMELOOP
addi $s0, $zero, 1 # flag for gameLoop ($s0 = 1)
gameLoop: beq $s0, 0, gameLoopEnd # $s0 == 0 then go to gameLoopEnd

# in here write in file player 1 pieces
bne $s5, 0, updatePlayerOutputEnd	# if (s5 != 0) jump to updatePlayerOutputEnd
updatePlayerOutput:
jal setJogadorOut			# load info in jogadorOut for file_write
jal file_open
jal file_write
jal file_close
updatePlayerOutputEnd:

bne $s5, 0, inputPieceOfPlayer1End      # if (s5 != 0) jump to inputPieceOfPlayer1End

#TODO verify if have possible piece

inputPieceOfPlayer1:
# Print prompt
la $a0, prompt_selectPiece # address of string to print
li $v0, 4
syscall

# Input piece
la $a0, reply_prompt_pieceNumber # address to store string at
li $a1, 2 # maximum number of chars (including '\0')
li $v0, 8
syscall

# TODO verify if player select correct piece

lw   $t1, reply_prompt_pieceNumber	# $t1 = input_prompt 

inputPieceOfPlayer1End:

addi $s2, $zero, 0 	#set flag of have piece to zero
beq $s5, 0, botChoicePieceEnd      # if (s5 == 0) jump to botChoicePieceEnd
botChoicePiece: slti $t0, $s1, 7			# for i=0;i<28;i++ 
		beq $t0, $zero, botChoicePieceEnd 	# $t0 == 0 end loop
		
		jal pieceVerification			# ($t1 for piece selected, $t7 result of verification)
		beq $t7, 1, botChoicePieceOkay
		j botChoicePiece			# back to botChoicePiece
botChoicePieceOkay:
	addi $s2, $zero, 1				# this is a valid piece for play, so this player[$s5] have piece to play		
botChoicePieceEnd:

beq $s2, 0, pre_round_end # if player $t5 not have piece, so go to next round

# $t1 save piece choice in $t1
mul  $t1, $t1, 4 			# $t1 = position in bytes of pieces in jogadorX

bne $s5, 0, selectPiecePlayer1End      # if (s5 != 0) jump to selectPiecePlayer1End
selectPiecePlayer1:
lw   $t2, jogador1($t1)			# $t2 = jogador[$t1]
selectPiecePlayer1End:

bne $s5, 1, selectPiecePlayer2End      # if (s5 != 0) jump to selectPiecePlayer1End
selectPiecePlayer2:
lw   $t2, jogador2($t1)			# $t2 = jogador[$t1]
selectPiecePlayer2End:

bne $s5, 2, selectPiecePlayer3End      # if (s5 != 0) jump to selectPiecePlayer1End
selectPiecePlayer3:
lw   $t2, jogador3($t1)			# $t2 = jogador[$t1]
selectPiecePlayer3End:

bne $s5, 3, selectPiecePlayer4End      # if (s5 != 0) jump to selectPiecePlayer1End
selectPiecePlayer4:
lw   $t2, jogador4($t1)			# $t2 = jogador[$t1]
selectPiecePlayer4End:


# TODO para salvar o numero no tabuleiro vai ter que tira o mod 10 , pq ai separa o numero em dois , e mesmo que o numero não seja uma dezena ele se transforma em dezena. 
# joga a peça
# printa o tabuleiro
#limpa a peça de jogadorX

# if Jogador X tem zero pieces ? 
# if se o jogo fechou  
# jogador X + 1
pre_round_end:
j gameLoop # back to 'gameLoop'
gameLoopEnd: 	addi $v0, $zero, 10 #syscal of end program
		syscall


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

file_open:
    li   $v0, 13       # system call for open file
    la   $a0, str_exit     # output file name
    li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
    li   $a2, 0        # mode is ignored
    syscall            # open a file (file descriptor returned in $v0)
    move $s6, $v0      # save the file descriptor 
    jr $ra
file_write:
    li $v0, 15
    move $a0, $s6      			# file descriptor 
    la $a1, data_jogadorForOut		#$a1 = address of output buffer
    la $a2, data_jogadorForOut_end	#$a2 = number of characters to write
    la $a3, data_jogadorForOut		#  byte of str_data_end - bytes of srt_data 
    subu $a2, $a2, $a3  		# computes the length of the string, this is really a constant
    syscall
    jr $ra
file_close:
    li $v0, 16  
    move $a0, $s6       # file descriptor to close
    syscall
    jr $ra
	
	
setJogadorOut:

addi $s1, $zero,0	# this register use with iterator in loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

loopOfPieces: slti $t0, $s1, 7			# for i=0;i<28;i++ 
		beq $t0, $zero,loopOfPiecesEnd 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 			# $t1 = position in bytes of pieces in jogadorX
	lw   $t2, jogador1($t1)			# $t2 = jogador[$t1]
	 
	li   $s7, 10				# $s7 = 10
	div  $t2, $s7		
	mfhi $s7				# $s7 = 1st number
	mflo $t2				# $t2 = 2nd number
	
	addi $t2, $t2, 48			# parse to ascii
	addi $s7, $s7, 48			# parse to ascii
	
	sb   $t2, data_jogadorForOut($t4)	# jogadorForOut[$t4] = $t2
	addi $t4, $t4, 1			# position + 1
	sb   $s7, data_jogadorForOut($t4)	# jogadorForOut[$t4] = $s7
	addi $t4, $t4, 2			# position + 2  (2 because blank space) 	
	
	addi $s1, $s1, 1			# $s1 += 1
	j loopOfPieces # back to loop
loopOfPiecesEnd:

jr $ra		# End rotine


pieceVerification: # $t1 for piece selected, $t7 result of verification
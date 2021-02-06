# table of responsibilities of registrators 
# $s0 -> (Main Works)flag of gameloop  
# $s1 -> aux of small works (using in distributionOfPieces for iterator pieces) | (after distribution of pieces) -> use in loop at parse word to asciiz | using in game loop for botChoicePiece | using for board output
# $s2 -> (Main Works)using with a flag to signalize the "I don't have piece for this round"
# $s3 -> (Main Works)last piece of board (position)
# $s4 -> (Main Works)(in Gameloop) using to save piece choice in round
# $s5 -> (Main Works)flag of playerIterator
# $s6 -> aux of small works using to save file descriptor
# $s7 -> aux for parse .word to asciiz | (after using for pass piece for verification)
# $t1 -> aux for parse .word to asciiz | (using for pass piece for verification)
# $t2 -> aux for parse .word to asciiz | (using in play_piece_in_board)
# $t3 -> aux for parse Iterators | (after distribution of pieces) -> use in parse word to asciiz | piece verification
# $t4 -> aux of small works (using in player 1 count) | (after distribution of pieces) -> use in parse word to asciiz | piece verification
# $t5 -> aux of small works (using in player 2 count) | piece verification
# $t6 -> aux of small works (using in player 3 count) | piece verification
# $t7 -> aux of small works (using in player 4 count) | (using for save verification results)
# $t8 -> aux of small works (using in play_piece_in_board)


.data
pieces: .word 0, 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 33, 34, 35, 36, 43, 44, 45, 46, 55, 56, 66
jogador1: .word -0 -1 -1 -1 -1 -1 -1
jogador2: .word -1 -1 -1 -1 -1 -1 -1
jogador3: .word -2 -1 -1 -1 -1 -1 -1
jogador4: .word -3 -1 -1 -1 -1 -1 -1
board:    .word 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99 

str_player1_exit: .asciiz "player1.txt"
data_jogadorForOut: .asciiz "-1 -1 -1 -1 -1 -1 -1" 
data_jogadorForOut_end:

str_board_exit: .asciiz "board.txt"
data_board_out: .asciiz "-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1" 
data_board_out_end:

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

##########################################################################################

addi $s5, $zero,0 	# set player1 to first player 
addi $s3, $zero,0	# set last piece position

#GAMELOOP
addi $s0, $zero, 1 # flag for gameLoop ($s0 = 1)
gameLoop: beq $s0, 0, gameLoopEnd # $s0 == 0 then go to gameLoopEnd

# in here write in file player 1 pieces
bne $s5, 0, updatePlayerOutputEnd	# if (s5 != 0) jump to updatePlayerOutputEnd
updatePlayerOutput:
jal setJogadorOut			# load info in jogadorOut for file_write
jal player1_file_open
jal player1_file_write
jal file_close
updatePlayerOutputEnd:

update_board_Output:
jal set_board_out			# load info in jogadorOut for file_write
jal board_file_open
jal board_file_write
jal file_close
update_board_OutputEnd:

bne $s5, 0, inputPieceOfPlayer1End      # if (s5 != 0) jump to inputPieceOfPlayer1End

#verify if have possible piece
addi $s1, $zero, 0 	# $s1 set to zero
addi $t7, $zero, 0 	# $t7 set to zero
has_possible_pieces: slti $t0, $s1, 7			# for i=0;i<7;i++ 
		beq $t0, $zero, botChoicePieceEnd 	# $t0 == 0 end loop
		
		jal pieceVerification			# ($s1 with param)(return => $t1 for piece selected, rerturn => $t7 result of verification)
		bne $t7, 0, has_possible_pieces_End
			
		addi $s1, $s1, 1			# $s1 += 1
		j has_possible_pieces			# back loop
has_possible_pieces_End:

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
	
	# have problem in here
	lb   $t1, reply_prompt_pieceNumber	# $t1 = input_prompt # $t1 recive bytes number(ascii code in dec)
	sub  $t1, $t1, 48 			
	jal pieceVerification			# ($t1 for piece selected, $t7 result of verification)
	bne $t7, 0, botChoicePieceOkay		# "botChoicePieceOkay" is a point where the piece is valid, and $ s2 is set to 1, (so there is a piece available in the round)

inputPieceOfPlayer1End:

addi $s2, $zero, 0 	# set flag of have piece to zero
beq $s5, 0, botChoicePieceEnd      # if (s5 == 0) jump to botChoicePieceEnd
addi $s1,$zero, 0 	# $s1 set to zero
botChoicePiece: slti $t0, $s1, 7			# for i=0;i<7;i++ 
		beq $t0, $zero, pre_round_end 		# $t0 == 0 end loop
		
		jal pieceVerification			# ($s1 with param)(return => $t1 for piece selected, rerturn => $t7 result of verification)
		bne $t7, 0, botChoicePieceOkay
			
		addi $s1, $s1, 1			# $s1 += 1
		j botChoicePiece			# back loop
botChoicePieceOkay:
	addi $s2, $zero, 1				# this is a valid piece for play, so this player[$s5] have piece to play		
botChoicePieceEnd:

beq $s2, 0, pre_round_end 				# if player $t5 not have piece, so go to next round

# $t1 save piece choice in $t1
mul  $t1, $t1, 4 			# $t1 = position in bytes of pieces in jogadorX

# TODO para salvar o numero no tabuleiro vai ter que tira o mod 10 , pq ai separa o numero em dois , e mesmo que o numero n�o seja uma dezena ele se transforma em dezena. 
# TODO play the piece
jal play_piece_in_board


# TODO if Jogador X tem zero pieces ? 
# TODO if se o jogo fechou


pre_round_end:

beq  $s5, 3, playerIteratorReset 	# if #s5 == 3 goto playerIteratorReset

addi $s5, $s5, 1	# jogador X + 1
j playerIteratorResetEnd

playerIteratorReset:
addi $s5, $zero, 0	# ($s5)jogador = 0
playerIteratorResetEnd:

addi $s0, $s0, 1 # flag for gameLoop ($s0 += 1)
j gameLoop # back to 'gameLoop'
gameLoopEnd: 	addi $v0, $zero, 10 #syscal of end program
		syscall

############################################################################################
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

player1_file_open:
    li   $v0, 13       				# system call for open file
    la   $a0, str_player1_exit      # output file name
    li   $a1, 1       				# Open for writing (flags are 0: read, 1: write)
    li   $a2, 0        				# mode is ignored
    syscall            				# open a file (file descriptor returned in $v0)
    move $s6, $v0      				# save the file descriptor 
    jr $ra
player1_file_write:
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
	
################################################################################################
setJogadorOut:

addi $s1, $zero,0	# this register use with iterator in loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

loopOfPieces: slti $t0, $s1, 7			# for i=0;i<7;i++ 
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

##########################################################################################

pieceVerification: # ($s1 with param)(return => $t1 for piece selected, rerturn => $t7 result of verification) 
										# if $t7 == 1, first place of board is valid, if t7 == 2 last place of board is valid
addi $t1, $s1, 0				# $t1 = $s1(iteretor for on botChoicePiece)

	mul  $t1, $t1, 4 			# $t1 = position in bytes of pieces in jogador .word
	
bne $s5, 0, verifyPiecePlayer1End		# if ($s5 != 0)
verifyPiecePlayer1:
	lw   $t2, jogador1($t1)			# $t2 = jogador[$t1]				
verifyPiecePlayer1End:			

bne $s5, 1, verifyPiecePlayer2End		# if ($s5 != 1)
verifyPiecePlayer2:
	lw   $t2, jogador2($t1)			# $t2 = jogador[$t1]
verifyPiecePlayer2End:

bne $s5, 2, verifyPiecePlayer3End		# if ($s5 != 2)
verifyPiecePlayer3:
	lw   $t2, jogador3($t1)			# $t2 = jogador[$t1]
verifyPiecePlayer3End:

bne $s5, 3, verifyPiecePlayer4End		# if ($s5 != 3)
verifyPiecePlayer4:
	lw   $t2, jogador4($t1)			# $t2 = jogador[$t1]
verifyPiecePlayer4End:
	  
	# player's piece
	li   $t5, 10				# $t5 = 10
	div  $t2, $t5		
	mfhi $t2				# $t2 = 1st number
	mflo $t3				# $t3 = 2nd number
	
	# validate first round six's bomb
	bne $s0, 1, is_not_first_Round
	bne $t2, 6, pieceVerificationEnd		# first part of player's piece is diff of '6'
	bne $t2, 6, pieceVerificationEnd		# first part of player's piece is diff of '6'
	j pieceVerificationEndOkay2		# this piece is '66'
	is_not_first_Round:
	
	#first piece of board
	lw   $t4, board($zero)			# $t4 = board[0]
	
	div  $t4, $t5				# $t4 / ($t5 = 10)
	mfhi $t4				# $t4 = 1st number
	
	beq  $t2, $t4, pieceVerificationEndOkay1 # if $t2 == $t4 is valid
	beq  $t3, $t4, pieceVerificationEndOkay1 # if $t2 == $t4 is valid
	
	#last piece of board
	mul  $t6, $s3, 4			# $s3 -> last piece of board (position)
	lw   $t4, board($t6)			# $t4 = board[0]
	
	beq $t4, -1, pieceVerificationEndOkay2	# if last piece of board equal -1, so not have pieces in board
	
	div  $t4, $t5				# $t4 / ($t5 = 10)
	mflo $t4				# $t4 = 2nd number
	
	beq  $t2, $t4, pieceVerificationEndOkay2 # if $t2 == $t4 is valid
	beq  $t3, $t4, pieceVerificationEndOkay2 # if $t2 == $t4 is valid
	
	addi $t7, $zero, 0	# $t7 = 0
	j pieceVerificationEnd	# go to end rotine
	
pieceVerificationEndOkay1:
	addi $t7, $zero, 1	# $t7 = 1
	j pieceVerificationEnd
pieceVerificationEndOkay2:
	addi $t7, $zero, 2	# $t7 = 1
pieceVerificationEnd:
jr $ra		# End rotine

############################################################################################
play_piece_in_board:	#($t1 for piece index) 
# if $t7 == 1, first place of board is valid, if t7 == 2 last place of board is valid
mul  $t1, $t1, 4 			# $t1 = position in bytes of pieces in jogador .word

li  $t8, 99							# charge $t8 with number that represents null in logic game

bne $s5, 0, setPiecePlayer1End		# if ($s5 != 0)
setPiecePlayer1:
	lw   $t2, jogador1($t1)			# $t2 = jogador[$t1]
	sw	 $t8, jogador1($t1) 		# jogador[$t1] = 99
setPiecePlayer1End:			

bne $s5, 1, setPiecePlayer2End		# if ($s5 != 1)
setPiecePlayer2:
	lw   $t2, jogador2($t1)			# $t2 = jogador[$t1]
	sw	 $t8, jogador2($t1) 		# jogador[$t1] = 99
setPiecePlayer2End:

bne $s5, 2, setPiecePlayer3End		# if ($s5 != 2)
setPiecePlayer3:
	lw   $t2, jogador3($t1)			# $t2 = jogador[$t1]
	sw	 $t8, jogador3($t1) 		# jogador[$t1] = 99
setPiecePlayer3End:

bne $s5, 3, setPiecePlayer4End		# if ($s5 != 3)
setPiecePlayer4:
	lw   $t2, jogador4($t1)			# $t2 = jogador[$t1]
	sw	 $t8, jogador4($t1) 		# jogador[$t1] = 99
setPiecePlayer4End:

beq $t7, 1, play_first_place_board
beq $t7, 2, play_last_place_board

play_first_place_board:
# for (int i = 0; i<($s3+1)) # precisa deslocar todas pe�as uma casa pra frente
# board[i+1] = board[i]

play_last_place_board:
mul $t8, $s3, 4		# last position number * 4
sw $t2, board($t8)	# board[$t8] 

# TODO clear position after play

play_place_board_end:
jr $ra #end rotine


##########################################################################################
set_board_out:

addi $s1, $zero,0	# this register use with iterator in boar_loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

board_loopOfPieces: slti $t0, $s1, 28			# for i=0;i<28;i++ 
		beq $t0, $zero,board_loopOfPiecesEnd 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 				# $t1 = position in bytes of pieces in boardX
	lw   $t2, board($t1)			# $t2 = board[$t1]
	 
	li   $s7, 10					# $s7 = 10
	div  $t2, $s7		
	mfhi $s7						# $s7 = 1st number
	mflo $t2						# $t2 = 2nd number
	
	addi $t2, $t2, 48				# parse to ascii
	addi $s7, $s7, 48				# parse to ascii
	
	sb   $t2, data_board_out($t4)	# data_board_out[$t4] = $t2
	addi $t4, $t4, 1				# position + 1
	sb   $s7, data_board_out($t4)	# data_board_out[$t4] = $s7
	addi $t4, $t4, 2				# position + 2  (2 because blank space) 	
	
	addi $s1, $s1, 1				# $s1 += 1
	j board_loopOfPieces # back to loop
board_loopOfPiecesEnd:

jr $ra		# End rotine

##########################################################################################

board_file_open:
    li   $v0, 13       				# system call for open file
    la   $a0, str_board_exit		# output file name
    li   $a1, 1       				# Open for writing (flags are 0: read, 1: write)
    li   $a2, 0        				# mode is ignored
    syscall            				# open a file (file descriptor returned in $v0)
    move $s6, $v0      				# save the file descriptor 
    jr $ra
board_file_write:
    li $v0, 15
    move $a0, $s6      				# file descriptor 
    la $a1, data_board_out		#$a1 = address of output buffer
    la $a2, data_board_out_end	#$a2 = number of characters to write
    la $a3, data_board_out		#  byte of str_data_end - bytes of srt_data 
    subu $a2, $a2, $a3  			# computes the length of the string, this is really a constant
    syscall
    jr $ra
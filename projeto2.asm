# $s0 -> gameloop
# $s5 -> player iterator
# $s3 -> lastpiece board
# $t1 -> piece that will be played 
# $t7 -> results of pieces verification
# $s2 -> has pieces in round 
# $s4 -> with flag for first round at piece six six
.data
pieces: .word 0, 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 33, 34, 35, 36, 44, 45, 46, 55, 56, 66
jogador1: .word -0, -1, -1, -1, -1, -1, -1	# save pieces
jogador2: .word -1, -1, -1, -1, -1, -1, -1	# save pieces
jogador3: .word -2, -1, -1, -1, -1, -1, -1	# save pieces
jogador4: .word -3, -1, -1, -1, -1, -1, -1	# save pieces
board:    .word 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99 

data_jogadorForOut: .asciiz "-1 -1 -1 -1 -1 -1 -1 \n"
data_board_out: .asciiz "-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 \n" 

prompt_selectPiece: .asciiz "*Select piece: (0-6)"

round_info_prompt_str: .asciiz "* Round: " 		# 9 positions
player_info_prompt_str: .asciiz "-*Player now: " 	# 10 positions
var_number_info_str: 	.asciiz "000"			# including '\0'

player_pieces_prompt_str: .asciiz "--*Player(1) Pieces: "
board_prompt_str: .asciiz "--*Board Pieces: "

player1_win_prompt_str: .asciiz "\n**** Player 1 GANHOU ****"
player2_win_prompt_str: .asciiz "\n**** Player 2 GANHOU ****"
player3_win_prompt_str: .asciiz "\n**** Player 3 GANHOU ****"
player4_win_prompt_str: .asciiz "\n**** Player 4 GANHOU ****"


.text

addi $t0, $zero, 0		#$t0 = 0
distributionOfPieces: slti $t0, $s1, 28			# for i=0;i<28;i++ 
		beq $t0, $zero,distributionOfPiecesEnd 	# $t0 == 0 end loop

		li $v0, 42            	# system call to generate random int
		la $a1, 4       		# where you set the max integer on random
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

## ====== GAMELOOP ====== ##
addi $s4, $zero, 1 # true for first round need six bomb
addi $s5, $zero, 0 # $s5 = 0
addi $s0, $zero, 1 # flag for gameLoop ($s0 = 1)
gameLoop: beq $s0, 0, gameLoopEnd # $s0 == 0 then go to gameLoopEnd

jal set_player1_str		#parse array to string
jal set_board_out_str	#parse array to string
jal print_round_info
jal print_board_info
jal print_player_pieces_info


bne $s5, 0, inputPieceOfPlayer1End      # if (s5 != 0) jump to inputPieceOfPlayer1End
#verify if have possible piece
addi $s1, $zero, 0 	# $s1 set to zero
addi $t7, $zero, 0 	# $t7 set to zero

has_possible_pieces: slti $t0, $s1, 7			# for i=0;i<7;i++ 
 	beq $t0, $zero, pre_round_end 	# $t0 == 0 end loop
	
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
	li $v0, 5
	syscall		#return int on $v0
	
	add $s1, $zero,$v0		# $s1 = $v0		$s1 used in pieceVerification
	add $t1, $s1,$zero
	jal pieceVerification			# ($t1 for piece selected, $t7 result of verification)
	bne $t7, 0, botChoicePieceOkay		# "botChoicePieceOkay" is a point where the piece is valid, and $ s2 is set to 1, (so there is a piece available in the round)
inputPieceOfPlayer1End:

addi $s2, $zero, 0 	# set flag of have piece to zero
beq  $s5, 0, botChoicePieceEnd      # if (s5 == 0) jump to botChoicePieceEnd
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

beq $s2, 0, pre_round_end 

# $t1 save piece choice in $t1
jal play_piece_in_board		# need($t1,$t7)

bne $s5,0, player1_end_game_verify_call_end
jal player1_end_game_verify
player1_end_game_verify_call_end:

bne $s5,1,player2_end_game_verify_call_end 
jal player2_end_game_verify
player2_end_game_verify_call_end:

bne $s5,2, player3_end_game_verify_call_end 
jal player3_end_game_verify
player3_end_game_verify_call_end:

bne $s5,3, player4_end_game_verify_call_end
jal player4_end_game_verify
player4_end_game_verify_call_end:

pre_round_end:

beq  $s5, 3, playerIteratorReset 	# if #s5 == 3 goto playerIteratorReset

addi $s5, $s5, 1	# jogador X + 1
j playerIteratorResetEnd

playerIteratorReset:
addi $s5, $zero, 0	# ($s5)jogador = 0
playerIteratorResetEnd:

addi $s0, $s0, 1 # flag for gameLoop ($s0 += 1)
j gameLoop # back to 'gameLoop'

gameLoopEnd:
#exit program
addi $v0, $zero, 10 #syscal of end program
syscall
## ====== END GAMELOOP ====== ##

############################################################################################
# switch between who will receive the pieces
givePiecesPlayer1:
	mul $t3, $t4, 4			# $t3 = $t4($t4 is a quant interator of pieces player 1)
	mul $t9, $s1, 4
	lw $t8, pieces($t9)
	sw $t8, jogador1($t3)		# jogador1[$t3] = $s2  (obs: $t3 equal to $t3 * 4)
	addi $t4, $t4, 1
	addi $s1, $s1, 1 		# iterator pieces		
	j exitGivePiecesToPlayer
	
givePiecesPlayer2:
	mul $t3, $t5, 4	# $t3 = $t5($t5 is a quant interator of pieces player 2)
	mul $t9, $s1, 4
	lw $t8, pieces($t9)
	sw $t8, jogador2($t3)		# jogador2[$t3] = $s2  (obs: $t3 equal to $t3 * 4)
	addi $t5, $t5, 1
	addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer
	
givePiecesPlayer3:
	mul $t3, $t6, 4	# $t3 = $t6($t6 is a quant interator of pieces player 3)
	mul $t9, $s1, 4
	lw $t8, pieces($t9)
	sw $t8, jogador3($t3)		# jogador3[$t3] = $s2  (obs: $t3 equal to $t3 * 4)
	addi $t6, $t6, 1
	addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer

givePiecesPlayer4:
	mul $t3, $t7, 4	# $t3 = $t7($t7 is a quant interator of pieces player 4)
	mul $t9, $s1, 4
	lw $t8, pieces($t9)
	sw $t8, jogador4($t3)		# jogador4[$t3] = $s2  (obs: $t3 equal to $t3 * 4)
	addi $t7, $t7, 1
	addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer

###############################################################################################
set_board_out_str:

addi $s1, $zero,0	# this register use with iterator in boar_loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

board_loopOfPieces: slti $t0, $s1, 28			# for i=0;i<28;i++ 
		beq $t0, $zero, board_loopOfPiecesEnd 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 				# $t1 = position in bytes of pieces in boardX
	lw   $t2, board($t1)			# $t2 = board[$t1]
	 
	li   $s7, 10					# $s7 = 10
	div  $t2, $s7		
	mflo $t2						# $t2 = 1nd number
	mfhi $s7						# $s7 = 2st number
	
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

################################################################################################
set_player1_str:

addi $s1, $zero,0	# this register use with iterator in loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

set_player_loop_piece: slti $t0, $s1, 7			# for i=0;i<7;i++ 
		beq $t0, $zero,set_player_loop_piece_end 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 			# $t1 = position in bytes of pieces in jogadorX
	lw   $t2, jogador1($t1)			# $t2 = jogador[$t1]
	 
	li   $s7, 10				# $s7 = 10
	div  $t2, $s7		
	mflo $t2				# $t2 = 1nd number
	mfhi $s7				# $s7 = 2st number
	
	addi $t2, $t2, 48			# parse to ascii
	addi $s7, $s7, 48			# parse to ascii
	
	sb   $t2, data_jogadorForOut($t4)	# jogadorForOut[$t4] = $t2
	addi $t4, $t4, 1			# position + 1
	sb   $s7, data_jogadorForOut($t4)	# jogadorForOut[$t4] = $s7
	addi $t4, $t4, 2			# position + 2  (2 because blank space) 	
	
	addi $s1, $s1, 1			# $s1 += 1
	j set_player_loop_piece # back to loop
set_player_loop_piece_end:

jr $ra		# End rotine

################################################################################################
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
	mflo $t2				# $t2 = 1st number # ex: if number is 65, lo = 6 
	mfhi $t3				# $t3 = 2nd number
	
	beq $t2, 9, invalid_first_piece		# if player piece equal to 9, is not valid

	# validate first round six's bomb
	bne $s4, 1, is_not_first_Round
	bne $t2, 6, invalid_first_piece		# first part of player's piece is diff of '6'
	bne $t3, 6, invalid_first_piece		# first part of player's piece is diff of '6'
	li $s4, 0
	j pieceVerificationEndOkay2		# this piece is '66'
	is_not_first_Round:
	
	#first piece of board
	lw   $t4, board($zero)			# $t4 = board[0]
	
	div  $t4, $t5				# $t4 / ($t5 = 10)
	mflo $t4					# $t4 = 1st number
	
	beq  $t2, $t4, pieceVerificationEndOkay1 # if $t2 == $t4 is valid
	beq  $t3, $t4, pieceVerificationEndOkay1 # if $t2 == $t4 is valid
	
	#last piece of board
	subi $t6, $s3, 1
	mul  $t6, $t6, 4			# $s3 -> last piece of board (position)
	lw   $t4, board($t6)			# $t4 = board[0]
	
	div  $t4, $t5				# $t4 / ($t5 = 10)
	mfhi $t4					
	# $t4 = 2nd number
	
	beq  $t2, $t4, pieceVerificationEndOkay2 # if $t2 == $t4 is valid
	beq  $t3, $t4, pieceVerificationEndOkay2 # if $t2 == $t4 is valid
	
	li $t7,0
	j pieceVerificationEnd	# go to end rotine
	
pieceVerificationEndOkay1:
	addi $t1, $s1, 0
	addi $t7, $zero, 1	# $t7 = 1
	j pieceVerificationEnd
pieceVerificationEndOkay2:
	addi $t1, $s1, 0
	addi $t7, $zero, 2	# $t7 = 1
pieceVerificationEnd:
jr $ra		# End rotine

invalid_first_piece:
addi $t7, $zero, 0		# $t7 = 0
jr $ra


###############################################################################################

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
li $t5, 10

div  $t2, $t5
mfhi $t8	# get piecePlayeX[1]

lw $s6, board($zero)	# get first piece of board
div $s6, $t5	
mflo $s6	# get pieceboard[0]

beq $t8, $s6, switch_piece_place1_call_end

j switch_piece
switch_piece_place1_call_end:

subi $s1, $s3, 1
subi $t0, $zero, 1		 # $t0 = 0
reposition_board_loop: beq $t0, $s1, reposition_board_loop_end			# for i=s3;i>0+1;i--  	
		addi $t9, $s1, 1							# $t9 = nextpostion

		mul $t8, $s1, 4								# $t8 = ($s1*4)
		lw  $s6, board($t8)							# $t6 = board[$t8]
		
		mul  $t9, $t9, 4
		sw $s6, board($t9)							# board[$s1+1] = board[$s1]
		
		subi $s1, $s1, 1							# $s1 = $s1 - 1
		
		j reposition_board_loop					#´back loop
reposition_board_loop_end: 

sw $t2, board($zero)								# board[0] = $t2
j play_place_board_end

play_last_place_board: 

li $t5, 10

div  $t2, $t5
mflo $t8	# get piecePlayeX[0]

subi $s1, $s3, 1
mul $s1, $s1, 4
lw $s6, board($s1)	# get first piece of board
div $s6, $t5	
mfhi $s6	# get pieceboard[1]

beq $t8, $s6, switch_piece_place2_call_end

j switch_piece

switch_piece_place2_call_end:
mul $t8, $s3, 4		# last position number * 4
sw $t2, board($t8)	# board[$t8]

play_place_board_end:
addi $s3, $s3, 1	#$s3+=1
jr $ra #end rotine

switch_piece:
	li   $t5, 10				# $t5 = 10
	div  $t2, $t5		
	mflo $t2				# $t2 = 1st number # ex: if number is 65, hi = 6 
	mfhi $t3				# $t3 = 2nd number
	
	mul $t3, $t3, 10
	add $t2, $t3, $t2

	beq $t7, 1,switch_piece_place1_call_end
	beq $t7, 2,switch_piece_place2_call_end
##########################################################################################
print_player_pieces_info:	
	# Print prompt round info
	la $a0, player_pieces_prompt_str # address of string to print
	li $v0, 4
	syscall

	# Print prompt round info
	la $a0, data_jogadorForOut # address of string to print
	li $v0, 4
	syscall

	jr $ra

##########################################################################################
print_board_info:	
	# Print prompt round info
	la $a0, board_prompt_str # address of string to print
	li $v0, 4
	syscall

	# Print prompt round info
	la $a0, data_board_out # address of string to print
	li $v0, 4
	syscall

	jr $ra


###############################################################################################
print_round_info:	# (need)$s0,$s5 | (use)$t7,$t8,$t9

	# Print prompt round info
	la $a0, round_info_prompt_str # address of string to print
	li $v0, 4
	syscall

	# round number
	addi $t7, $zero, 0
	li   $t9, 10				# $t9 = 10
	div  $s0, $t9		
	mfhi $t9				# $t9 = 1st number
	mflo $t8				# $t8 = 2nd number
	
	addi $t8, $t8, 48			# parse to ascii
	addi $t9, $t9, 48			# parse to ascii
	
	sb   $t8, var_number_info_str($t7)	# jogadorForOut[$t7] = $t3
	addi $t7, $t7, 1			# position + 1
	sb   $t9, var_number_info_str($t7)	# jogadorForOut[$t7] = $t4	
	addi $t7, $t7, 1
	li   $t9, 0xa
	sb   $t9, var_number_info_str($t7)
		
	# Print var
	la $a0, var_number_info_str  # address of string to print
	li $v0, 4
	syscall

	# Print prompt player info
	la $a0, player_info_prompt_str # address of string to print
	li $v0, 4
	syscall

	# round number
	addi $t7, $zero, 0
	
	li   $t8,48
	sb   $t8, var_number_info_str($t7)	# jogadorForOut[$t7] = $t3
	addi $t7, $t7, 1
	
	addi $t8, $s5, 49			# parse to ascii
	
	sb   $t8, var_number_info_str($t7)	# jogadorForOut[$t7] = $t3
	addi $t7, $t7, 1			# position + 1
	li   $t8, 0xa
	sb   $t8, var_number_info_str($t7)
		

	# Print var
	la $a0, var_number_info_str  # address of string to print
	li $v0, 4
	syscall

	jr $ra
###################################################################################
player1_end_game_verify:
addi $s1, $zero,0	# this register use with iterator in loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

endgame_verify_player1_loop: slti $t0, $s1, 7			# for i=0;i<7;i++ 
		beq $t0, $zero,endgame_verify_player1_loop_end 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 			# $t1 = position in bytes of pieces in jogadorX
	lw   $t2, jogador1($t1)			# $t2 = jogador[$t1]

	bne $t2, 99, is_not_endgame_player1
	
	addi $s1, $s1, 1			# $s1 += 1
	j endgame_verify_player1_loop # back to loop
endgame_verify_player1_loop_end:

li $s0, 0	# set final
# print "player 1 ganhou!!! " 
	la $a0, player1_win_prompt_str # address of string to print
	li $v0, 4
	syscall
	# end game
	addi $v0, $zero, 10 #syscal of end program
	syscall
is_not_endgame_player1:
jr $ra		# End rotine
###################################################################################
player2_end_game_verify:
addi $s1, $zero,0	# this register use with iterator in loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

endgame_verify_player2_loop: slti $t0, $s1, 7			# for i=0;i<7;i++ 
		beq $t0, $zero,endgame_verify_player2_loop_end 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 			# $t1 = position in bytes of pieces in jogadorX
	lw   $t2, jogador2($t1)			# $t2 = jogador[$t1]

	bne $t2, 99, is_not_endgame_player2
	
	addi $s1, $s1, 1			# $s1 += 1
	j endgame_verify_player2_loop # back to loop
endgame_verify_player2_loop_end:

li $s0, 0	# set final
# print "player 2 ganhou!!! "
	la $a0, player2_win_prompt_str # address of string to print
	li $v0, 4
	syscall 
	# end game
	addi $v0, $zero, 10 #syscal of end program
	syscall
is_not_endgame_player2:
jr $ra		# End rotine
####################################################################################
player3_end_game_verify:
addi $s1, $zero,0	# this register use with iterator in loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

endgame_verify_player3_loop: slti $t0, $s1, 7			# for i=0;i<7;i++ 
		beq $t0, $zero,endgame_verify_player3_loop_end 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 			# $t1 = position in bytes of pieces in jogadorX
	lw   $t2, jogador3($t1)			# $t2 = jogador[$t1]

	bne $t2, 99, is_not_endgame_player3
	
	addi $s1, $s1, 1			# $s1 += 1
	j endgame_verify_player3_loop # back to loop
endgame_verify_player3_loop_end:

li $s0, 0	# set final
# print "player 3 ganhou!!! "
	la $a0, player3_win_prompt_str # address of string to print
	li $v0, 4
	syscall
	# end game
	addi $v0, $zero, 10 #syscal of end program
	syscall
is_not_endgame_player3:
jr $ra		# End rotine
####################################################################################
player4_end_game_verify:
addi $s1, $zero,0	# this register use with iterator in loopOfPieces
addi $t4, $zero,0	# this register use with iterator in jogadorOut

endgame_verify_player4_loop: slti $t0, $s1, 7			# for i=0;i<7;i++ 
		beq $t0, $zero,endgame_verify_player4_loop_end 	# $t0 == 0 end loop
	mul  $t1, $s1, 4 			# $t1 = position in bytes of pieces in jogadorX
	lw   $t2, jogador4($t1)			# $t2 = jogador[$t1]

	bne $t2, 99, is_not_endgame_player4
	
	addi $s1, $s1, 1			# $s1 += 1
	j endgame_verify_player4_loop # back to loop
endgame_verify_player4_loop_end:

li $s0, 0	# set final
# print "player 3 ganhou!!! " 
	la $a0, player4_win_prompt_str # address of string to print
	li $v0, 4
	syscall
	# end game
	addi $v0, $zero, 10 #syscal of end program
	syscall
is_not_endgame_player4:
jr $ra		# End rotine

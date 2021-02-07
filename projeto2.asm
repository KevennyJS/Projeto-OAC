# $s0 -> gameloop
# $s5 -> player iterator

.data
pieces: .word 0, 1, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 33, 34, 35, 36, 43, 44, 45, 46, 55, 56, 66
jogador1: .word -0, -1, -1, -1, -1, -1, -1	# save pieces
jogador2: .word -1, -1, -1, -1, -1, -1, -1	# save pieces
jogador3: .word -2, -1, -1, -1, -1, -1, -1	# save pieces
jogador4: .word -3, -1, -1, -1, -1, -1, -1	# save pieces
board:    .word 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99 

data_jogadorForOut: .asciiz "-1 -1 -1 -1 -1 -1 -1"

prompt_selectPiece: .asciiz "Select piece: (0-6)"
reply_prompt_pieceNumber: .space 2 # including '\0'

round_info_prompt_str: .asciiz "* Round: " 		# 9 positions
player_info_prompt_str: .asciiz "| Player: " 		# 10 positions
var_number_info_str: 	.space 3 			# including '\0'

player_pieces_prompt_str: .asciiz "Player Pieces: "

ln_str: .space 1					# it's '\n'


.text
li $t0, 0xa
sb $t0, ln_str($zero) 

addi $t0, $zero, 0		#$t0 = 0
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

## ====== GAMELOOP ====== ##
addi $s0, $zero, 1 # flag for gameLoop ($s0 = 1)
gameLoop: beq $s0, 0, gameLoopEnd # $s0 == 0 then go to gameLoopEnd

jal set_player1_str
jal print_player_pieces_info



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
	sw $t8, jogador1($t3)		# jogador1[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	addi $t4, $t4, 1
	addi $s1, $s1, 1 		# iterator pieces		
	j exitGivePiecesToPlayer
	
givePiecesPlayer2:
	mul $t3, $t5, 4	# $t3 = $t5($t5 is a quant interator of pieces player 2)
	mul $t9, $s1, 4
	lw $t8, pieces($t9)
	sw $t9, jogador2($t3)		# jogador2[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	addi $t5, $t5, 1
	addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer
	
givePiecesPlayer3:
	mul $t3, $t6, 4	# $t3 = $t6($t6 is a quant interator of pieces player 3)
	mul $t9, $s1, 4
	lw $t8, pieces($t9)
	sw $t9, jogador3($t3)		# jogador3[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	addi $t6, $t6, 1
	addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer

givePiecesPlayer4:
	mul $t3, $t7, 4	# $t3 = $t7($t7 is a quant interator of pieces player 4)
	mul $t9, $s1, 4
	lw $t8, pieces($t9)
	sw $t9, jogador4($t3)		# jogador4[$s3] = $s2  (obs: $t3 equal to $s3 * 4)
	addi $t7, $t7, 1
	addi $s1, $s1, 1 		# iterator pieces
	j exitGivePiecesToPlayer
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
	mfhi $s7				# $s7 = 1st number
	mflo $t2				# $t2 = 2nd number
	
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
###################################################################################

print_nextline:
	la $a0, ln_str  # address of string to print
	li $v0, 4
	syscall

jr $ra

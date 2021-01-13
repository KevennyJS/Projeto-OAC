# table of responsibilities of registrators 
# $s0 -> flag of gameloop
# $s1 -> aux of small works

.data
hexdigits: .asciiz "1|2", "0|1", "0|2", "0|3", "0|3", "0|4", "0|5", "0|6", "1|0", "1|1", "1|2", "1|3", "1|3", "1|4", "1|5", "1|6","2|0", "2|1", "2|2", "2|3", "2|3", "2|4", "2|5", "2|6","3|0", "3|1", "3|2", "3|3", "3|3", "3|4", "3|5", "3|6","4|0", "4|1", "4|2", "4|3", "4|3", "4|4", "4|5", "4|6","5|0", "5|1", "5|2", "5|3", "5|3", "5|4", "5|5", "5|6","6|0", "6|1", "6|2", "6|3", "6|3", "6|4", "65|5","6|6"
teste: .asciiz "seila"

.text
la $a0, hexdigits+3 # 1|2 -    +2 = 2   +1 = |2  sem nada = 1|2 
li $v0, 4
syscall

addi $s0, $zero, 1 # flag for roundLoop ($s0 = 1)

gameLoop: beq $s0, 0, gameLoopEnd # $s0 == 0 then go to gameLoopEnd
# addi $s1, $zero, 7 # flag 7 for while of distributionOfPieces
distributionOfPieces:
distributionOfPiecesEnd:
	j gameLoop # back to 'gameLoop'
	
gameLoopEnd: 	addi $v0, $zero, 10 #syscal of end program
		syscall
#Name: Leman Yan
#Class: CS 260 Spring 2019
#Professor: Subash Shankar
#Date:3/26/19
#Objective: Make a cross on the image based on values m or n
.data
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels

m: .word 12
n: .word 21

.text

#Check if m and n are odd or even. If odd then increment by 1 else do nothing
lw $s0, m($zero) #s0 <- m
lw $s1, n($zero) #s1 <- n

#Check if m or n are less than 1. If it is then exit the program
slti $s6, $s0, 1 #If m<1 s6=1 else s6=0
beq $s6, 1, Exit #If m<1 go to Exit
slti $s7, $s1, 1 #If n<1 s7=1 else s7=0
beq $s7, 1, Exit #If n<1 go to Exit


addi $s2, $s0, 0 #s2 <-m
addi $s3, $s1, 0 #s3 <- n
andi $s2,1 #If LSB OF m is 1 then return 1 else 0
andi $s3, 1 #If LSB OF n is 1 then return 1 else 0

beq $s2, 0, checkN #If m is even then go check if n is even, Else m is odd 
addi $s0, $s0, 1 #Increment m by 1 so it is now even

checkN:
beq $s3, 0, next #If n is even then go to next. Else n is odd 
addi $s1, $s1, 1 #Increment n by 1 so it is now even

next:
add $s4, $s0, $s0 #s4 <- m+m
add $s4, $s4, $s1 #s4 < m+m+n
slti $s5, $s4, 257 #If m+m+n < 257, s5=1 else s5=0
beq $s5, 0, Exit #If m+m+n >= 257. Cross cannot fit in image so go to Exit

#Get n/2
addi $s2, $s1, 0 #s2 <- n
srl $s2, $s2, 1 #s2 <- n/2

#Get (m+n+m)/2 
addi $s3, $s0, 0 #s3 <- m
add $s3, $s3, $s3 #s3 <- m+m
add $s3, $s3, $s1 #s3 <- m+m+n
srl $s3, $s3, 1 #s3 <- (m+m+n)/2



################ DRAW YELLOW BACKGROUND AND BLUE RECTANGLE #############################
la $t0, frameBuffer #t0 gets address of the image
li $t1, 0x00FFFF00 # Yellow
li $t2, 0x000000FF #Blue

addi $t3, $zero, 0 #t3 <- 0 Use t3 as an index
addi $t4, $zero, 0 #t4 <- row index
addi $t5, $zero, 255 #t5 <- row
addi $t6, $zero, 0 #t6 <-column index
addi $t7, $zero, 512 #t7 <- column should not be 511

#Get the rectangle boundaries 
addi $s4, $zero, 127 #s4 <- 127
sub $s4, $s4, $s2 #s4 <- 127-n/2 

addi $s5, $zero, 127 #s5 <- 127
add $s5, $s5, $s2 #s5 <- 127+n/2
addi $s5, $s5, 1 #s5 <- 128+n/2
 
addi $s6, $zero, 255 #s6 <- 255
sub $s6, $s6, $s3 #s6 <- 255-(m+m+n)/2

addi $s7, $zero, 255 #s7 <- 255
add $s7,$s7, $s3 #s7 <- 255+(m+m+n)/2
addi $s7, $s7, 1 #s7 <- 256+(m+m+n)/2

drawYellow: 

beq $t6, $t7, resetCol #If column index == column go to resetColumn. Else continue 

slt $t8, $t6, $s6 #if col index < 255-(m+m+n)/2 t8 gets 1 else 0
beq $t8, 1, before #cols <  255-(m+m+n)/2 get yellow 

slt $t8, $t6, $s7 # if col index < 256+(m+m+n)/2 t8 gets 1 else 0
beq $t8, 0, before # cols >=  256+(m+m+n)/2 get yellow 

slt $t8, $t4, $s4 #if row index < 128-n/2 t8 gets 1 else 0
beq $t8, 1, before #row index <128-n/2 go to before

slt $t8, $t4, $s5 #if row index < 128+n/2 t8 gets 1 else 0
beq $t8, 0, before #row index >= 128+n/2 go to before

j makeBlue

before:
sw $t1, ($t0)    #Make the pixel at this address yellow
after: #Skip over making the pixel yellow but instead make it blue
addi $t0, $t0, 4 #t4 <- t4+4 Add to the address
addi $t3, $t3, 1 #t2 <- t2+1 Add to the index
addi $t6, $t6, 1 #t6 <- t6 +1 Add to column

bne $t3, 131071, drawYellow #if $t2 != 131072 then jump into the loop



################### Draw blue rectangle     #######################


la $t5, frameBuffer #$t5 <- address of image

addi $t0, $zero, 0 #t0 <- 0 Overall index
addi $t1, $zero, 0 #t1 <- row index
addi $t2, $zero, 255 #t2 <- row
addi $t3, $zero, 0 #t3 <-column index
addi $t4, $zero, 512 #t4 <- column Not 511 because the last column will become yellow

#Get the rectangle boundaries 
addi $s4, $zero, 255 #s4 <- 255
sub $s4, $s4, $s2 #s4 <- 255-n/2 

addi $s5, $zero, 255 #s5 <- 255
add $s5, $s5, $s2 #s5 <- 255+n/2
addi $s5, $s5, 1 #s5 <- 256+n/2
 
addi $s6, $zero, 127 #s6 <- 127
sub $s6, $s6, $s3 #s6 <- 127-(m+m+n)/2

addi $s7, $zero, 127 #s7 <- 127
add $s7,$s7, $s3 #s7 <- 127+(m+m+n)/2
addi $s7, $s7, 1 #s7 <- 128+(m+m+n)/2

li $t6, 0x000000FF #t6 <- color Blue

drawFirstRect:

beq $t3, $t4, resetColumn #If column index == column go to resetColumn. Else continue 

slt $t7, $t3, $s4 #If column index < 255-n/2 t7=1 , else t7=0 
beq $t7, 1, doNothing #If t7==1 go to doNothing, else continue

slt $t7, $t3, $s5 #If column index < 256+n/2 else column index >= 256+n/2
beq $t7, 0, doNothing #If t7=0 go to doNothing

slt $t7, $t1, $s6 #If row index < 127-(m+m+n)/2 else 0
beq $t7, 1, doNothing #If t7=0 go to doNothing

slt $t7, $t1, $s7 #If row index < 128+(m+m+n)/2 t7=1 else row index >= 128+(m+m+n)/2
beq $t7,0, doNothing #If t7=0 go to doNothing

sw $t6, ($t5)     #Make the pixel blue at this address
#addi $t1, $t1, 1 #t1 <- t1+1 ---- Was making an error because I was kept on adding to the row index
addi $t3, $t3, 1 #t3 <- t3+1
addi $t0, $t0, 1 #t0 <- t0 +1 
addi $t5, $t5, 4 #t5 <- t5+4

bne $t0, 131071, drawFirstRect #if $t2 != 131072 then jump into the loop

Exit:
li $v0,10 # exit code
syscall

#Reset column index and add 1 to the row index
resetColumn: 
addi $t3, $zero, 0 #t3 <- 0 Reset column index
addi $t1, $t1, 1 #t1 <- t1+1 Add 1 to row index

j drawFirstRect

#Do nothing to the pixel but continue
doNothing: 

#addi $t1, $t1, 1 #t1 <- t1+1
#sw $t6, ($t5)     #Make the pixel blue at this address
addi $t3, $t3, 1 #t3 <- t3+1
addi $t0, $t0, 1 #t0 <- t0 +1 
addi $t5, $t5, 4 #t5 <- t5+4
beq $t0,, 131071, Exit #Has an error if I remove this because it goes out of scope

j drawFirstRect

makeBlue:
sw $t2, ($t0)    #Make the pixel at this address blue
j after

resetCol:
addi $t6, $zero, 0 #t3 <- 0 Reset column index
addi $t4, $t4, 1 #t1 <- t1+1 Add 1 to row index

j drawYellow



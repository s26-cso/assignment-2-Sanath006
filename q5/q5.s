.data 
filename: .asciz "input.txt"
mode: .asciz "r"
yes: .asciz "yes\n"
no: .asciz "no\n"

.text
.globl main

main:
    la a0, filename#a0 contains the name of the file which is "input.txt"
    la a1 , mode#a1 contains the mode of opening the file which is read mode
    call fopen#we call the fopen function which returns a pointer to the file
    mv s0 , a0#now a0 contains the file pointer (file *) which we will store in s 
    li s1 , 0 # s1 = 0

find_length:
    li t1 , -1 # t1 = -1 (to check for EOF)
    mv a0 , s0 #now a0 has the file pointer
    call fgetc #gets the current character from the file
    mv t0 , a0 #stores that word in t0 (to check for EOF)
    beq t0 , t1 , length_found #if the character we got is -1 , then we have reached eof
    addi s1 , s1 , 1 # keeps adding 1 to find the length
    j find_length #the loop

length_found:
    mv a0 , s0 
    call rewind #moves the file pointer back to the start
    li s2 , 0

actual_func:
    mv s3, s1 # s3 stores the index from the end
    sub s3 , s3, s2 #s3 =  n - i
    addi s3, s3 , -1 #s3 = n -1 -i 
    bge s2 , s3, yes_palindrome #if we have successfully compared characters till the 2 indexes meet, then the string is a palindrome

    mv a0 , s0
    mv a1 , s2
    li a2, 0
    call fseek # Basically moves the file pointer to s1 position 

    mv a0 , s0
    call fgetc
    mv t3 , a0 #gets and stores the character at s1 positon at t3

    mv a0 , s0
    mv a1 , s3
    li a2 , 0
    call fseek # Basically moves the file pointer to s3 position 

    mv a0 , s0
    call fgetc
    mv t4 , a0 #gets and stores the character at s3 positon at t4
    bne t3 , t4 , not_palindrome #compares the 2 characters to check for equality, if not equal , then not a palindrome
    addi s3 , s3, -1 #basic 2 pointer , move left to the right and right to the left till they meet
    addi s2 , s2 , 1
    j actual_func

yes_palindrome:
    la a0 , yes
    call printf
    j exit

not_palindrome:
    la a0 , no
    call printf
    j exit

exit:
    li a0, 0
    ret

.data 
filename: .asciz "input.txt"
mode: .asciz "r"
yes: .asciz "yes\n"
no: .asciz "no\n"
.text
.globl main
main:
    la a0, filename
    la a1, mode
    call fopen
    mv s0, a0
    li s1, 0
find_length:
    li t1, -1
    mv a0, s0
    call fgetc
    mv t0, a0
    beq t0, t1, length_found
    addi s1, s1, 1
    j find_length
length_found:
    mv a0, s0
    call rewind
    li s2, 0
actual_func:
    mv s3, s1
    sub s3, s3, s2
    addi s3, s3, -1
    bge s2, s3, yes_palindrome
    mv a0, s0
    mv a1, s2
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    mv t3, a0
    mv a0, s0
    mv a1, s3
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    mv t4, a0
    bne t3, t4, not_palindrome
    addi s2, s2, 1
    j actual_func
yes_palindrome:
    la a0, yes
    call printf
    j exit
not_palindrome:
    la a0, no
    call printf
    j exit
exit:
    li a0, 0
    ret

.data
fmt_int:  .asciz "%d"
fmt_sp:   .asciz " "
fmt_nl:   .asciz "\n"
space:    .asciz " "

.text
.global main

main:
    addi sp, sp, -80#allocate bigger stack frame (changed layout)
    sd ra, 72(sp)#save return address
    sd s7, 64(sp)#extra saved reg (structure change)
    sd s6, 56(sp)#save arr base
    sd s5, 48(sp)#save temp/current
    sd s4, 40(sp)#save argv base
    sd s3, 32(sp)#save n
    sd s2, 24(sp)#save stack ptr
    sd s1, 16(sp)#save result ptr
    sd s0, 8(sp)#save arr ptr

    mv s3, a0#argc
    addi s3, s3, -1#n = argc-1
    blez s3, done#no elements → exit

    slli t0, s3, 2#t0 = n*4 (size)

    mv s4, a1#save argv early (important)

    mv a0, t0#size
    call malloc
    mv s0, a0#arr base

    mv a0, t0#reload size
    call malloc
    mv s1, a0#result base

    mv a0, t0#reload size again
    call malloc
    mv s2, a0#stack base

    mv s6, s0#preserve arr base (avoid corruption)

    li t1, 1#i = 1

read_loop:
    bgt t1, s3, prep#if i>n → done reading

    slli t0, t1, 3#argv offset (8 bytes each)
    add t0, s4, t0
    ld a0, 0(t0)#argv[i]

    addi sp, sp, -16#align stack
    sd t1, 8(sp)
    sd s0, 0(sp)

    call atoi#convert string → int

    ld t1, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 16

    sw a0, 0(s0)#store into arr
    addi s0, s0, 4#move ptr
    addi t1, t1, 1#i++
    j read_loop

prep:
    mv s0, s6#restore arr base

    li t5, -1#stack top = -1
    addi t1, s3, -1#i = n-1

outer_loop:
    blt t1, zero, print_phase#if i<0 → print

    slli t0, t1, 2
    add t0, s0, t0
    lw s5, 0(t0)#current element

inner_loop:
    blt t5, zero, no_elem#if stack empty

    slli t0, t5, 2
    add t0, s2, t0
    lw t2, 0(t0)#top index

    slli t0, t2, 2
    add t0, s0, t0
    lw t3, 0(t0)#value at that index

    ble t3, s5, pop_case#if <= current → pop
    j found_case

pop_case:
    addi t5, t5, -1#pop stack
    j inner_loop

no_elem:
    slli t0, t1, 2
    add t0, s1, t0
    li t2, -1
    sw t2, 0(t0)#result[i] = -1
    j push_case

found_case:
    slli t0, t1, 2
    add t0, s1, t0
    sw t2, 0(t0)#store index
    j push_case

push_case:
    addi t5, t5, 1#top++
    slli t0, t5, 2
    add t0, s2, t0
    sw t1, 0(t0)#push i

    addi t1, t1, -1#i--
    j outer_loop

print_phase:
    li t1, 0#i=0

print_loop:
    bge t1, s3, done#if done

    slli t0, t1, 2
    add t0, s1, t0
    lw a1, 0(t0)#load result

    addi sp, sp, -16#align
    sd t1, 0(sp)
    la a0, fmt_int
    call printf
    ld t1, 0(sp)
    addi sp, sp, 16

    addi t0, s3, -1
    beq t1, t0, skip_sp#if last → no space

    addi sp, sp, -16#align
    sd t1, 0(sp)
    la a0, fmt_sp
    call printf
    ld t1, 0(sp)
    addi sp, sp, 16

skip_sp:
    addi t1, t1, 1#i++
    j print_loop

done:
    addi sp, sp, -16#align for printf
    sd ra, 8(sp)#save ra
    la a0, fmt_nl
    call printf
    ld ra, 8(sp)
    addi sp, sp, 16

    ld s7, 64(sp)#restore regs (different order for variation)
    ld s6, 56(sp)
    ld s5, 48(sp)
    ld s4, 40(sp)
    ld s3, 32(sp)
    ld s2, 24(sp)
    ld s1, 16(sp)
    ld s0, 8(sp)
    ld ra, 72(sp)
    addi sp, sp, 80#restore stack

    li a0, 0#return 0
    call exit

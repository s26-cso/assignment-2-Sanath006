.global make_node
make_node:
    addi sp, sp, -16#allocate stack space
    sd ra, 0(sp)#save return address
    sd s1, 8(sp)#save s1
    mv s1, a0#store input value
    li a0, 24#size of node = 24 bytes
    call malloc#allocate memory
    mv t0, a0#t0 = node pointer
    sw s1, 0(t0)#store value
    sd zero, 8(t0)#left = NULL
    sd zero, 16(t0)#right = NULL
    mv a0, t0#return node pointer
    ld ra, 0(sp)#restore return address
    ld s1, 8(sp)#restore s1
    addi sp, sp, 16#restore stack
    ret#return

.global insert
insert:
    addi sp, sp, -32#allocate stack
    sd ra, 0(sp)#save return address
    sd s2, 8(sp)#save root
    sd s3, 16(sp)#save value
    mv s2, a0#s2 = root
    mv s3, a1#s3 = value
    beqz s2, insert_create#if root NULL → create node
    lw t0, 0(s2)#load node value
    blt s3, t0, go_left#if value < node → left
    bgt s3, t0, go_right#if value > node → right
    mv a0, s2#equal → return node
    j insert_done#exit

go_left:
    ld a0, 8(s2)#load left child
    mv a1, s3#pass value
    call insert#recursive call
    sd a0, 8(s2)#update left pointer
    mv a0, s2#return root
    j insert_done#exit

go_right:
    ld a0, 16(s2)#load right child
    mv a1, s3#pass value
    call insert#recursive call
    sd a0, 16(s2)#update right pointer
    mv a0, s2#return root
    j insert_done#exit

insert_create:
    mv a0, s3#pass value
    call make_node#create node

insert_done:
    ld ra, 0(sp)#restore return address
    ld s2, 8(sp)#restore s2
    ld s3, 16(sp)#restore s3
    addi sp, sp, 32#restore stack
    ret#return


.global get
get:
    addi sp, sp, -32#allocate stack
    sd ra, 0(sp)#save return address
    sd s2, 8(sp)#save node
    sd s3, 16(sp)#save key
    mv s2, a0#s2 = node
    mv s3, a1#s3 = key
    beqz s2, not_found#if NULL → not found
    lw t0, 0(s2)#load node value
    beq t0, s3 , found#if equal → found
    blt s3, t0, search_left#if key < node → left
    ld a0, 16(s2)#go right
    mv a1, s3
    call get
    j get_exit#exit

search_left:
    ld a0, 8(s2)#go left
    mv a1, s3
    call get
    j get_exit#exit

found:
    mv a0, s2#return node pointer
    j get_exit#exit

not_found:
    li a0, 0#return NULL

get_exit:
    ld ra, 0(sp)#restore return address
    ld s2, 8(sp)#restore s2
    ld s3, 16(sp)#restore s3
    addi sp, sp, 32#restore stack
    ret#return


.global getAtMost
getAtMost:
    addi sp, sp, -48#allocate stack
    sd ra, 0(sp)#save return address
    sd s2, 8(sp)#save key
    sd s3, 16(sp)#save node
    sd s4, 24(sp)#save node value
    mv s2, a0#s2 = key
    mv s3, a1#s3 = node
    beqz s3, atm_null#if NULL → return -1
    lw s4, 0(s3)#load node value
    beq s4, s2, atm_exact#if equal → return
    blt s4, s2, atm_right_case#if node < key → right
    ld a1, 8(s3)#go left
    mv a0, s2
    call getAtMost
    j atm_exit#exit

atm_right_case:
    ld a1, 16(s3)#go right
    mv a0, s2
    call getAtMost
    li t1, -1#check failure
    bne a0, t1, atm_exit#if found → return
    mv a0, s4#else current node is answer
    j atm_exit#exit

atm_exact:
    mv a0, s4#exact match
    j atm_exit#exit

atm_null:
    li a0, -1#no valid value

atm_exit:
    ld ra, 0(sp)#restore registers
    ld s2, 8(sp)
    ld s3, 16(sp)
    ld s4, 24(sp)
    addi sp, sp, 48#restore stack
    ret

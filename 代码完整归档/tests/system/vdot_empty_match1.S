    .section .text
    .globl _start
_start:
    li t0,0x200
    csrs mstatus,t0
    li sp,0x80008000
    li t0,2
    vsetvli zero,t0,e32,m1,tu,mu
    li t1,0x01010101
    vmv.v.x v4,t1
    li t1,0x02020202
    vmv.v.x v6,t1
    li t0,8
    vsetvli zero,t0,e8,m1,tu,mu
    li t5,1
    rdcycle s1
.L:
    addi t5,t5,-1
    bnez t5,.L
    rdcycle s2
    sub s3,s2,s1
    li a1,'O'
    jal ra,putc
    mv a1,s3
    jal ra,hex4
    li a1,10
    jal ra,putc
.Halt:j .Halt
hex4:
    mv s4,a1
    li s5,12
    li s6,4
    mv s7,ra
1:
    srl t2,s4,s5
    andi t2,t2,15
    li t3,10
    bltu t2,t3,2f
    addi t2,t2,55
    j 3f
2:  addi t2,t2,48
3:  mv a1,t2
    jal ra,putc
    addi s5,s5,-4
    addi s6,s6,-1
    bnez s6,1b
    mv ra,s7
    ret
putc:
    li t0,0x40600008
4:lbu t2,0(t0)
    andi t2,t2,8
    bnez t2,4b
    li t0,0x40600004
    sb a1,0(t0)
    ret


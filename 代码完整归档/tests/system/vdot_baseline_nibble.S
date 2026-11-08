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
    vmv.v.i v16,0
    li t5,1
    rdcycle s1
.L:
    vmv.v.i v8,0
    vsll.vi v12,v4,24
    vsra.vi v12,v12,24
    vsll.vi v13,v6,24
    vsra.vi v13,v13,24
    vmacc.vv v8,v12,v13
    vsll.vi v12,v4,16
    vsra.vi v12,v12,24
    vsll.vi v13,v6,16
    vsra.vi v13,v13,24
    vmacc.vv v8,v12,v13
    vsll.vi v12,v4,8
    vsra.vi v12,v12,24
    vsll.vi v13,v6,8
    vsra.vi v13,v13,24
    vmacc.vv v8,v12,v13
    vsll.vi v12,v4,0
    vsra.vi v12,v12,24
    vsll.vi v13,v6,0
    vsra.vi v13,v13,24
    vmacc.vv v8,v12,v13
    vredsum.vs v24,v8,v16
    addi t5,t5,-1
    bnez t5,.L
    rdcycle s2
    sub s3,s2,s1
    li a1,'B'
    jal ra,putc
    andi a1,s3,15
    li t0,10
    bltu a1,t0,.D
    addi a1,a1,55
    j .P
.D: addi a1,a1,48
.P: jal ra,putc
    li a1,10
    jal ra,putc
.H: j .H
putc:
    li t0,0x40600008
1:lbu t2,0(t0)
    andi t2,t2,8
    bnez t2,1b
    li t0,0x40600004
    sb a1,0(t0)
    ret


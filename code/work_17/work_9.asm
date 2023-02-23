;程序名称:
;功能:请编写一个可定义各种移位宏指令的宏。
;所定义的宏指令所移位的次数不限于1或者CL，而可以是常数或者其他8位寄存器。
;=======================================
assume      cs:code
BIT_MOV MACRO reg,num
            mov cl,num
            shl reg,cl
ENDM


code segment
    start:
          mov     al,1
          BIT_MOV al,3
          mov     ax,4c00h    ;dos中断
          int     21H
code ends
    end     start
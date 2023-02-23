;程序名称:
;功能:请编写一个撤销堆栈中局部变量的宏。该宏与题7所定义的宏相对应。
;提7：请编写一个在堆栈中定义若干局部变量的宏。可通过基于BP寄存器的相对寻址访问这些局部变量。
;=======================================
assume      cs:code,ds:data

data segment

data ends

code segment
    start:
          mov ax,data     ;初始化数据段
          mov ds,ax

          mov ax,4c00h    ;dos中断
          int 21H
code ends
    end     start
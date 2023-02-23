;程序名称:
;功能:
;=======================================
STACK1 MACRO NUM
        assume ss:stack
        ;堆栈段
        stack segment
              db NUM dup(0)
        stack ends
        mov  ax,stack                 ;初始化堆栈段
        mov  ss,ax
ENDM
assume      cs:code,ds:data

data segment

data ends

code segment
    start:
          STACK1
          mov ax,data     ;初始化数据段
          mov ds,ax

          mov ax,4c00h    ;dos中断
          int 21H
code ends
    end     start
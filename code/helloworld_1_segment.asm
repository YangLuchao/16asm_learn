;程序名称:
;功能: 打印出helloworld，且只有代码段
;=======================================
assume      cs:code

code segment
    start:
    hello db  'hello world asm ! $'    ;定义hello
          mov ax,code                  ;初始化数据段，将代码段初始化为数据段
          mov ds,ax

          mov dx,offset hello          ;打印
          mov ah,9H
          int 21H

          mov ax,4c00h                 ;dos中断
          int 21H
code ends
    end     start
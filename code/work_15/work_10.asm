;程序名称:
;功能:利用字符串操作指令写一个清屏的过程。只考虑字符显示方式。
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
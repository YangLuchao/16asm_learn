;程序名称:
;功能:请编写一个能够根据某个符号值采用不同方法显示字符的宏。
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
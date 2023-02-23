;程序名称:
;功能:写一个在屏幕上（或打印机上）列出小于65535的素数（质数）。
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
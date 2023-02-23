;程序名称:
;功能:
;=======================================
assume      cs:code,ds:data
;代码量少空间复杂度时间复杂度都低，效率就也高了。
data segment
    tmp    dw 1      ;dw模拟对齐
    tmp1   dw 1      ;dw模拟对齐
    tmp2   dw 1      ;dw模拟对齐
    val    db 31h    ;
    al_len =  2
data ends

code segment
    start:
          mov ax,data                        ;初始化数据段
          mov ds,ax

          mov ax,word ptr ds:[0+al_len*3]    ;将val的值放入ax寄存器中

          mov ax,4c00h                       ;dos中断
          int 21H
code ends
    end     start
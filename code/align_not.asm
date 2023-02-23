;程序名称:
;功能:
;=======================================
assume      cs:code,ds:data
;没有对齐要求出每个变量的长度才能找到目标变量的地址，代码量和计算量都大，效率也就低了
data segment
    tmp      db 1      ;db模拟没有
    tmp1     dw 1      ;dw
    tmp2     dd 1      ;dd
    val      db 31h    ;
    tmp_len  =  1
    tmp1_len =  2
    tmp2_len =  4
data ends

code segment
    start:
          mov ax,data                   ;初始化数据段
          mov ds,ax

          mov ax,word ptr ds:[1+2+4]    ;将val的值放入ax寄存器中

          mov ax,4c00h                  ;dos中断
          int 21H
code ends
    end     start
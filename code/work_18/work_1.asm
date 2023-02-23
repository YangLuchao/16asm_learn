;程序名称:
;功能:请利用重复汇编的方法定义一个缓冲区。
;缓冲区有100个双字构成，每个双字的高字部分的初值依次是2,4,6……,200，低字部分的初值总是0.
;=======================================
assume      cs:code,ds:data

data segment
    NUM  =     1
         TABLE LABEL 	WORD
         REPT  100                ;重复块开始，规定重复次数
         DW    (NUM+NUM) shl 8    ;需重复的语句1
    NUM  =     NUM + 1            ;需重复的语句2
ENDM                              ;重复块结束
data ends

code segment
    start:
          mov ax,data     ;初始化数据段
          mov ds,ax

          mov ax,4c00h    ;dos中断
          int 21H
code ends
    end     start
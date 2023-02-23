;程序名称:
;功能:设计程序中有8个标号，分别是NEXT1,NEXT2,……,NEXT8.
;请利用重复汇编的方法定义由上述8个标号构成的散转表，每项由段值和偏移构成。
;=======================================
assume      cs:code,ds:data

data segment
         COMTAB LABEL 	WORD
         IRPC   X,12345678
         DW     NEXT&X
ENDM
data ends

code segment
    start:
          mov  ax,data       ;初始化数据段
          mov  ds,ax
          IRPC X,12345678
NEXT&X:
          JMP  OVER
ENDM
    OVER: 
          mov  ax,4c00h      ;dos中断
          int  21H
code ends
    end     start
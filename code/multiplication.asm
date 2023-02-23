;程序名称:
;功能:乘法实现
;=======================================
assume      cs:code,ds:data
;234*123 = 
;234*3 + 2340*2 + 23400*1
;
;3*1 =
;0000 0011
;0000 0001
;0000 0011
;
;3*2 =
;0000 0011
;0000 0010
;0000 0110
;
;3*3 =
;0000 0011
;0000 0011
;0000 0011
;0000 0110
;0000 1001
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
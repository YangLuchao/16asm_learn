;程序名称:
;功能: 设一个32位有符号数存放在DX:AX中，请写一个求其补码的程序。并输出补码
;=======================================
assume      cs:code,ds:data

data segment
    val1 dw 1234H    ;低16位，放入AX
    val2 dw 0045H    ;高16位，放入dx
data ends

code segment
    start:
          mov ax,data     ;初始化数据段
          mov ds,ax
    ;val1放入AX，val2放入dx
    ;分别对ax,dx取反
    ;分别对AX,dx加1
          mov ax,val1
          mov dx,val2

          not ax
          not dx
          add ax,1h       ;低位正常加1
          adc dx,0        ;高位，带位加1

          mov ax,4c00h    ;dos中断
          int 21H
code ends
    end     start
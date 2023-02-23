;程序名称:
;功能:请写一个程序统计AX寄存器中置1位的个数
;=======================================
assume      cs:code,ds:data

data segment
    val    dw 'df'                   ;要统计1的个数的数据,
    count  dw ?,'$$'                 ;1的个数
    hexTab dw '01','02','03','04'    ;16进制转10进制地址表
           dw '05','06','07','08'
           dw '09','10','11','12'
           dw '13','14','15','16'
data ends
;将准备的数据挪到ax中，每次带位右移
;将最后一位挪到CF中，再用adc bl,0，带位加，循环完后就知道有多少个1了
code segment
    start:
          mov  ax,data            ;初始化数据段
          mov  ds,ax

          mov  si,-1              ;初始化变址寄存器
          MOV  cx,16              ;初始化计数器
          MOV  ax,val             ;初始化ax
          XOR  BX,bx              ;bx清空

    next: 
          ror  ax,1               ;右移1位
          adc  bx,0               ;带位加
          loop next

          mov  dx,hexTab[bx]      ;十六进制转10进制
          mov  count,dx           ;存入变量中

          MOV  dx,offset count    ;打印输出
          mov  ah,9
          int  21h

          mov  ax,4c00h           ;dos中断
          int  21H
code ends
    end     start
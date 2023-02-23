;程序名称:
;功能:请写一个可把某个十六进制数转换为对应的二进制数ASII码串的示例程序
;=======================================
assume      cs:code,ds:data
;16进制转ASCII码
;这个不用转吧，直接输出就是ASCII码
data segment
    val  db 2EH,44H,56H    ;需要被转换的16进制数
         db 78H,5FH,6EH
         db 4AH,3EH,3BH
         db 24H
data ends

code segment
    start:
          mov ax,data          ;初始化数据段
          mov ds,ax

          mov dx,offset val    ;输出
          mov ah,9
          int 21H

          mov ax,4c00h         ;dos中断
          int 21H
code ends
    end     start
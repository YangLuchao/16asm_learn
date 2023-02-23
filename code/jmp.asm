;程序名称: jmp.asm
;功能: 屏幕显示十六位进制数
;=======================================
assume      cs:code,ds:data
data segment
    xxx    dw 1234h
    yyy    dw 5678h
    zzz    dd ?
    string db 'asm!','$'
data ends

code segment
    start:
          mov ax,data             ;初始化数据段
          mov ds,ax
    ;
          MOV al,1
          mov ah,2
          jmp $+4                 ;跳4个字节，+4从本行开始算，跳两行
          nop                     ;每个nop指令是两个字节
          nop
          nop
          nop

          mov dx,offset string    ;打印string
          mov ah,9
          int 21h                 ;子程序中断

          mov ax,4c00h            ;程序中断
          int 21h                 ;dos中断
code ends
    end     start
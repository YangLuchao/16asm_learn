;程序名称:
;功能:请编写一个清除键盘缓冲区的宏。
;=======================================
assume      cs:code
CLEAR_JP_BUFF MACRO                           ;清空键盘缓冲区
                  LOCAL next
                  mov   ax,0040h              ;初始化数据段
                  mov   es,ax
                  mov   bx,001CH
    next:         
                  inc   bx
                  inc   bx
                  mov   word ptr es:[bx],0    ;清空
                  cmp   bx,003DH
                  jnz   next
ENDM

code segment
    start:
          CLEAR_JP_BUFF

          mov           ax,4c00h    ;dos中断
          int           21H
code ends
    end     start
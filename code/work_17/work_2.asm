;程序名称:
;功能:编写一个利用BIOS显示I/O程序实现回车换行的宏
;=======================================
;定义换行宏
NEWLINE MACRO
            mov ah,9
            mov al,0dh
            mov cx,1
            int 10h
            mov ah,9
            mov al,0ah
            mov cx,1
            int 10h
ENDM
assume      cs:code

code segment
    start:
          NEWLINE

          mov     ax,4c00h    ;dos中断
          int     21H

code ends
    end     start
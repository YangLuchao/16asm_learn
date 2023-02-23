;程序名称:
;功能:写一个清屏程序
;=======================================
assume      cs:code,ds:data
count = 2000
data segment
data ends

code segment
      start:
            MOV AX,0B800H
            MOV DS,AX
         
            mov si,-1
      clear:
            inc si
            inc si
            cmp si,count
            jz  over
            MOV BX,si
            MOV AL,0
            MOV AH,07H
            MOV [BX],AX
            jmp clear
      over: 
            mov ax,4c00h       ;dos中断
            int 21H
code ends
    end     start
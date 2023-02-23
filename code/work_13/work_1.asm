;程序名称:
;功能:写一个程序采用直接填充显示缓冲区的方法在屏幕上循环显示26个大写字母。
;当按任一键后终止程序，通过调用BIOS键盘缓冲管理模块的1号功能判别是否有按键按下。
;=======================================
assume      cs:code,ds:data
count = 26
count1 = 4000
data segment
data ends

code segment
       start: 
              MOV AX,0B800H
              MOV DS,AX

              mov si,-2
              mov cl,-1
       clear: 
              mov ah,1
              int 16h
              jc  over
              inc si
              inc si
              cmp si,count1
              jz  flush1
       next:  
              inc cl
              cmp cl,count
              jz  flush
       disply:
              MOV BX,si
              add cl,41H
              MOV AL,cl
              MOV AH,07H
              MOV [BX],AX
              sub cl,41H
              jmp clear
        
       flush: 
              mov cl,0
              jmp disply
       flush1:
              mov si,0
              jmp next

       over:  
              mov ax,4c00h        ;dos中断
              int 21H
code ends
    end     start
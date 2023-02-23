;程序名：t8-2.asm
;功能：略
assume cs:code,ds:data
data segment para public                ;类型为PARA
         mess db'HELLO!',0DH,0AH,'$'
data ends
code segment para public        ;定位类型为PARA
    start:
          mov ax,data
          mov ds,ax
          mov dx,offset mess

          mov ah,9
          int 21h
code ends
end start
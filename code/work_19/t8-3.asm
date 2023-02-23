;程序名：t8-3.asm
;功能：略
assume cs:code,ds:data
data segment para public
    ;类型为PARA
         db ' OK'
data ends
;
code segment para public        ;定位类型为PARA
         mov ax,4c00h
         int 21h
code ends
end
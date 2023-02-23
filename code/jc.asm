;程序名称:  jc指令测试
;功能:     jc命令测试，打印出相应字符
;======================
assume      cs:code,ds:data

data        segment
string db 'hello world asm!','$'
number db 1,2,3,4,5,6
data        ends

code        segment
start:
        mov     ax,data
        mov     ds,ax
        ;
        mov     si,offset number
        mov     al,ds:[si]
        cmp     al,[si+1]
        jc      over
        ;jc     无符号 小于
        mov     dx,offset string
        mov     ah,9
        int     21H
over:   mov     ax,4c00h
        int     21H
code        ends

    end    start
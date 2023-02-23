;程序名称:
;功能:编写一个实现数据块移动的近过程
;数据块移动
;定义
;数据块长度
;源数据段值
;源数据始偏移
;目标地址段值
;目标地址偏移
;rep movsb复制数据块
;=======================================
assume      cs:code,ds:data

data segment
    datalen db 36                                        ;数据长度
    source  db '1234567890qwertyuiopasdfghjklzxcvbnm'    ;源数据
    target  db 40 dup(0)                                 ;目标数据
data ends

code segment
    start:   
             mov ax,data             ;初始化数据段
             mov ds,ax
             mov si,offset source

             mov ax,data
             mov es,ax
             mov di,offset target

             xor cx,cx
             mov cl,datalen
             cld                     ;df置0，递增

             rep movsb               ;执行数据移动

             mov ax,4c00h            ;dos中断
             int 21H
    ;description
dataMove PROC
            
             ret
dataMove ENDP
code ends
    end     start
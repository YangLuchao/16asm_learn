;程序名称:
;功能:大写字母转小写字母，并显示字符串
;=======================================
assume      cs:code,ds:data

data segment
    message db "HELLO WELCOME TO ASM!", 0dh, 0ah,'$'    ;win系统换行符为0d0ah，linux系统换行符为0ah
data ends

code segment
    start:  
            mov   ax,data              ;初始化数据段
            mov   ds,ax

            mov   si,offset message
    next:   
            mov   al,[si]
            cmp   al, 0dh
            jz    putout
            call  uptolw
            mov   [si],al
            inc   si
            jmp   next

    putout:                            ;打印输出
            mov   dx,offset message
            mov   ah, 09h
            int   21h

            mov   ax,4c00h             ;dos中断
            int   21H
    ;子程序名称:uptolw
    ;功能:大写字母转换为小写字母
    ;入口参数:AL=字符ASCII码
    ;出口参数:AL=字符ASCII码
    ;其他说明:无
    ;=======================================
uptolw PROC
            pushf                      ;保护标志寄存器
    ;push ax
            cmp   al,'A'
            jb    uptolwl
            cmp   al,'Z'
            ja    uptolwl
            add   al,'a'-'A'           ;可以直接写20h
    uptolwl:
    ;pop ax
            popf
    ;恢复标志寄存器
            ret
           
uptolw ENDP
code ends
    end     start
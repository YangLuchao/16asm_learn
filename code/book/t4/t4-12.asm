;程序名称:
;写一个程序，它用二进制数形式显示所按键的ASCII码
;分析：
;1:利用1号功能调用接受一个字符
;2:通过移位法从高到低依次把其ASCII码值的各位析出，换成ASCII码
;3:利用2号功能调用显示输出
;功能：用二进制数形式显示所按键的ASCII码
;=======================================
;只有代码段
assume      cs:code
code segment
        start:  
                mov  ah,1            ;1号功能，读一个键，放到al中
                int  21h
                
                call newline         ;回车换行
                mov  bl,al           ;出口参数AL=读到字符的ASCII码，放到bl中
                mov  cx,8            ;1个ASCII字符8位，循环8次
        next:   
                shl  bl,1            ;bl左移一位,移出的最高位放入到cf中
                mov  dl,30h          ;30H挪到dl中
                adc  dl,0            ;转换为ASCII码，带位加
                mov  ah,2            ;二号功能，输出一个在DL中的字符
                int  21h
                Loop next

                mov  dL,'B'          ;显示二进制数表示符B
                mov  ah ,2           ;二号功能
        ;显示二进制数表示符
                int  21h
                mov  ax,4c00h        ;dos中断
                int  21H
        ;----------------------------------------------
        ;子程序名：newline
        ;功能：形成回车和换行（光标移到下一行首)
        ;入口参数：无
        ;出口参数：无
        ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
                push ax
                push dx
                mov  dl,0dh          ;回车符的ASCII码
                mov  ah,2
        ;显示回车符
                int  21h
                mov  dl,0ah          ;换行符的ASCII码
                mov  ah,2
        ;显示换行符
                int  21h
                pop  dx
                pop  ax
                ret
newline endp
        ;----------------------------------------------
code ends
    end     start
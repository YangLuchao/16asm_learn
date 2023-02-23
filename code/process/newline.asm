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
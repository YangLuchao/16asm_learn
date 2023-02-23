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
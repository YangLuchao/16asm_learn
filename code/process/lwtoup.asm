      ;子程序名称:lwtoup
      ;功能:小写字母转换为转写字母
      ;入口参数:AL=字符ASCII码
      ;出口参数:AL=字符ASCII码
      ;其他说明:无
      ;=======================================
lwtoup PROC
                 pushf                 ;保护标志寄存器
      ;push ax
                 cmp   al,'a'
                 jb    lwtou1
                 cmp   al,'z'
                 ja    lwtou1
                 sub   al,'a'-'A'      ;可以直接写20h
      lwtou1:    
      ;pop ax
                 popf
      ;恢复标志寄存器
                 ret
lwtoup ENDP
      ;-----------------------------
       ;子程序名称:lwUpFlip
       ;功能:大小写翻转
       ;入口参数:AL=字符ASCII码
       ;出口参数:AL=字符ASCII码
       ;其他说明:无
       ;=======================================
lwUpFlip proc
                    call  isEnglesh
                    jc    over                 ;不是英文字符,退出
                    call  isUp                 ;判断是不是大写
                    jc    filp                 ;不是大写,是小写
                    call  uptolw               ;大写转小写
                    jmp   lwUpFlipOver
       filp:        
                    call  lwtoup               ;大写转小写
       lwUpFlipOver:ret
lwUpFlip endp
       ;子程序名称:lwtoup
       ;功能:小写字母转换为转写字母
       ;入口参数:AL=字符ASCII码
       ;出口参数:AL=字符ASCII码
       ;其他说明:无
       ;=======================================
lwtoup PROC
                    pushf                      ;保护标志寄存器
       ;push ax
                    cmp   al,'a'
                    jb    lwtou1
                    cmp   al,'z'
                    ja    lwtou1
                    sub   al,'a'-'A'           ;可以直接写20h
       lwtou1:      
       ;pop ax
                    popf
       ;恢复标志寄存器
                    ret
lwtoup ENDP
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
       ;-----------------------------
       ;子程序名称:isUp
       ;功能:判断大写还是小写
       ;入口参数:AL=字符ASCII码
       ;出口参数:CF标，CF置1不是大写，CF置0位是大写
       ;其他说明:无
       ;=======================================
isUp proc
                    CMP   AL,'A'               ;小于'a'不是大写，CF=1
                    JB    isUp2
                    CMP   AL,'Z'+1             ;在'a'~'z'之间是大写,cf=0
                    JB    isUp1
       isUp1:       CMC                        ;cf取反
       isUp2:       RET
isUp endp
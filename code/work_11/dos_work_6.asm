;程序名称:
;功能:先从键盘上输入一个字符串，然后下一行显示过滤去字母符号的字符串，最后在另一行显示大小写字母翻转的字符串。
;=======================================
assume      cs:code,ds:data
;常量定义
mlength = 128
data segment
       buff db mlength              ;缓冲区最大长度
            db ?                    ;字符串实际长度，出口参数之一
            db mlength dup(0)       ;符合0AH号功能调用所需的缓冲区
data ends

code segment
       start:       
                    mov   ax,data              ;初始化数据段
                    mov   ds,ax
       ;
       ;输入字符串
                    mov   ah,0ah               ;DOS十号功能，接受一个字符串，回车键结束
                    mov   dx,offset buff       ;入口参数，缓冲区首地址，存放缓冲区最大容量
                    int   21h                  ;输出提示

                    call  newline              ;新换一行

                    mov   SI,-1
       next1:       
                    inc   si                   ;
                    mov   al,buff[si+2]
                    cmp   al,0dh               ;遇到回车结束循环
                    jz    next3
                    call  isEnglesh            ;不是回车，判断是不是英文字符
                    jc    display1             ;不是英文字符，直接显示
                    jmp   next1
       display1:    
                    call  putch
                    jmp   next1

       
       next3:       
                    call  newline              ;新换一行
                    mov   SI,-1
       next2:       
                    inc   si                   ;
                    mov   al,buff[si+2]
                    cmp   al,0dh               ;遇到回车结束循环
                    jz    over
                    call  isEnglesh
                    jc    display2             ;不是英文字符，直接显示
                    call  lwUpFlip             ;大小写翻转
       display2:    
                    call  putch
                    jmp   next2
       
       over:        
                    mov   ax,4c00h             ;dos中断
                    int   21H

       ;-----------------------------
       ;判断是不是英文字符
       ;入口参数：al
       ;出口参数：CF标，CF置1不是英文字符，CF置0位是英文字符
isEnglesh PROC
                    CMP   AL,'A'               ;小于'A'不是英文字符，CF=1
                    JB    isEnglesh2
                    CMP   AL,'Z'+1             ;在'A'~'F'之间是英文,cf=0
                    JB    isEnglesh1
                    CMP   AL,'a'               ;小于'a'不是英文字符，CF=1
                    JB    isEnglesh2
                    CMP   AL,'z'+1             ;在'a'~'z'之间是英文字符,cf=0
       isEnglesh1:  CMC                        ;cf取反
       isEnglesh2:  RET
isEnglesh endp
       ;-----------------------------
       ;----------------------------------------------
       ;子程序名：newline
       ;功能：形成回车和换行（光标移到下一行首)
       ;入口参数：无
       ;出口参数：无
       ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
                    push  ax
                    push  dx
                    mov   dl,0dh               ;回车符的ASCII码
                    mov   ah,2
       ;显示回车符
                    int   21h
                    mov   dl,0ah               ;换行符的ASCII码
                    mov   ah,2
       ;显示换行符
                    int   21h
                    pop   dx
                    pop   ax
                    ret
newline endp
       ;----------------------------------------------
       ;-----------------------------
       ;显示一个字符
       ;入口参数：al
       ;出口参数：标志输出设备
putch PROC
                    PUSH  DX
                    MOV   DL,AL
                    MOV   AH,2
                    INT   21H
                    POP   DX
                    RET
putch ENDP
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
code ends
    end     start
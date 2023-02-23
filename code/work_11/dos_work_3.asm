;程序名称:
;功能:写一个程序把从键盘上接收到的小写字母用大写字母显示出来，其他字符原样显示。按回车键结束程序。
;=======================================
assume      cs:code,ds:data
;常量定义
cr = 0dh          ;回车符 
data segment
data ends

code segment
      start:     
                 mov   ax,data         ;初始化数据段
                 mov   ds,ax
      ;数据准备
            
      next:      
                 call  getch           ;从键盘上获取一个值
                 cmp   al,cr           ;是否回车符，对比一下是不是回车符
                 jz    over            ;是回车，结束
                 call  isEnglesh       ;不是回车，判断是不是英文字符
                 jc    display         ;不是英文字符，直接显示
                 call  islow           ;是英文字符，判断是小写还是大写
                 jnc   display         ;是大写，直接显示
                 call  lwtoup          ;不是大写，转换大写后显示
      display:   
                 call  putch
                 jmp   next

      over:      
                 mov   ax,4c00h        ;dos中断
                 int   21H
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
      ;接受一个字符但不显示，存到al中
      ;入口参数：标志输入设备
      ;出口参数：al
getch PROC
                 MOV   AH,8            ;接受一个字符但不显示,
                 INT   21H
                 RET
getch ENDP
      ;-----------------------------
      ;-----------------------------
      ;判断是不是英文字符
      ;入口参数：al
      ;出口参数：CF标，CF置1不是英文字符，CF置0位是英文字符
isEnglesh PROC
                 CMP   AL,'A'          ;小于'A'不是英文字符，CF=1
                 JB    isEnglesh2
                 CMP   AL,'Z'+1        ;在'A'~'F'之间是英文,cf=0
                 JB    isEnglesh1
                 CMP   AL,'a'          ;小于'a'不是英文字符，CF=1
                 JB    isEnglesh2
                 CMP   AL,'z'+1        ;在'a'~'z'之间是英文字符,cf=0
      isEnglesh1:CMC                   ;cf取反
      isEnglesh2:RET
isEnglesh endp
      ;-----------------------------
      ;-----------------------------
      ;判断是不是英文字符
      ;入口参数：al
      ;出口参数：CF标，CF置1是小写，CF置0位是大写
islow proc
                 CMP   AL,'a'          ;小于'a'不是小写，CF=1
                 JB    islow2
      islow1:    CMC                   ;cf取反
      islow2:    RET
islow endp
      ;-----------------------------

code ends
    end     start
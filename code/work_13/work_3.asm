;程序名称:
;功能:写程序把屏幕上显示的大写字母全部变换成对应的小写字母。
;=======================================
assume      cs:code,ds:data
COLUM = 80;列
line = 25;行
data segment
    colum_count db -1
    line_count  db -1
data ends

code segment
    start:     
               mov  ax,data              ;初始化数据段
               mov  ds,ax

    ;计算光标位子
    outer:     
               add  line_count,1         ;行+1
               cmp  line_count,line
               jz   over
    iner:      
               add  colum_count,1        ;列+1
               cmp  colum_count,COLUM
               jz   home
    ;光标位子计算完成
               mov  ah,2                 ;移动光标位子
               mov  dh,line_count
               mov  dl,colum_count
               int  10h
               mov  ah,8H                ;8号功能，获取光标处的字符和属性
               int  10h
               call isEnglesh
               jc   iner                 ;不是英文字符，处理下一个字符
               call isUp
               jnc  iner                 ;是大写，处理下一个字符
               SUB  AL,20H               ;转大写
               call putch
               jmp  iner

    home:      
               mov  colum_count,-1
               jmp  outer

    over:      
               mov  ax,4c00h             ;dos中断
               int  21H
    ;-----------------------------
    ;判断是不是英文字符
    ;入口参数：al
    ;出口参数：CF标，CF置1不是英文字符，CF置0位是英文字符
isEnglesh PROC
               CMP  AL,'A'               ;小于'A'不是英文字符，CF=1
               JB   isEnglesh2
               CMP  AL,'Z'+1             ;在'A'~'F'之间是英文,cf=0
               JB   isEnglesh1
               CMP  AL,'a'               ;小于'a'不是英文字符，CF=1
               JB   isEnglesh2
               CMP  AL,'z'+1             ;在'a'~'z'之间是英文字符,cf=0
    isEnglesh1:CMC                       ;cf取反
    isEnglesh2:RET
isEnglesh endp
    ;-----------------------------
    ;-----------------------------
    ;子程序名称:isUp
    ;功能:判断大写还是小写
    ;入口参数:AL=字符ASCII码
    ;出口参数:CF标，CF置1不是大写，CF置0位是大写
    ;其他说明:无
    ;=======================================
isUp proc
               CMP  AL,'A'               ;小于'a'不是大写，CF=1
               JB   isUp2
               CMP  AL,'Z'+1             ;在'a'~'z'之间是大写,cf=0
               JB   isUp1
    isUp1:     CMC                       ;cf取反
    isUp2:     RET
isUp endp
    ;-----------------------------
    ;显示一个字符
    ;入口参数：al
    ;出口参数：标志输出设备
putch PROC
               PUSH DX
               MOV  DL,AL
               MOV  AH,2
               INT  21H
               POP  DX
               RET
putch ENDP
    ;-----------------------------
    ;----------------------------------------------
    ;子程序名：newline
    ;功能：形成回车和换行（光标移到下一行首)
    ;入口参数：无
    ;出口参数：无
    ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
               push ax
               push dx
               mov  dl,0dh               ;回车符的ASCII码
               mov  ah,2
    ;显示回车符
               int  21h
               mov  dl,0ah               ;换行符的ASCII码
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
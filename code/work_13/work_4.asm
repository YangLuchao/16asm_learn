;程序名称:
;功能:写一个程序统计当前屏幕上显示的字母个数。
;=======================================
assume      cs:code,ds:data
COLUM = 80;列
line = 25;行
data segment
    colum_count db -1
    line_count  db -1
    buff1       db 5 dup(0),24h
    count       dw 0
data ends

code segment
    start:     
               mov  ax,data              ;初始化数据段
               mov  ds,ax

    ;计算光标位子
    outer:     
               add  line_count,1         ;行+1
               cmp  line_count,line
               jz   print
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
               add  count,1              ;计数+1
               jmp  iner
    home:      
               mov  colum_count,-1
               jmp  outer
    

    print:     
               mov  ax,count
               mov  bx,offset buff1
               call btoasc
               MOV  dx,offset buff1
               mov  ah,9
               int  21H

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
    ;子程序名称:
    ;子程序名：btoasc
    ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
    ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
    ;=======================================
btoasc PROC
               push bp                   ;保存主程序栈基址
               MOV  bp,sp                ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
               push SI
               push cx
               push dx
               push bx
    ;==================子程序代码开始==============
               MOV  SI,5                 ;置循环次数
               MOV  CX,10                ;置除数10
    BTOASC1:   XOR  DX,DX                ;把被除数扩展成32位
               DIV  CX                   ;除操作
               ADD  DL,30H               ;余数为BCD码，转换为ASCII码
               DEC  SI                   ;调整循环计数器
               MOV  [BX][SI],DL          ;保存所得ASCII码
               OR   SI,SI                ;判断si是否清零
               JNZ  BTOASC1              ;否，继续
    ;==================子程序代码结束==============
               pop  bx
               pop  dx
               pop  cx
               pop  si
               MOV  sp,bp                ;释放定义的局部变量的空间(SUB sp,4)
               pop  BP
               RET
btoasc ENDP
code ends
    end     start
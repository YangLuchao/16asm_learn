;程序名称:
;功能:请写一个程序实现如下功能：把指定开始地址的内存区域作为存放16位字数组的缓冲区。依次顺序显示其值。
;具体要求是:开始地址由键盘输入，每次在一行中以多种进制形式显示一个子单元的内容，行首标上用十六进制表示的存储单元的段值和偏移
;=======================================
assume      cs:code,ds:data

data segment
    mess  db 'input cs: $'    ;请输入段值
    mess2 db 'imput ip: $'    ;请输入偏移
    buff0 db ?,?,?,?          ;段值
    buff1 db ?,?,?,?          ;偏移
    buff2 db 16 dup(0),'$'    ;值
data ends

code segment
    start:     
               mov  ax,data            ;初始化数据段
               mov  ds,ax

    ;输入段值
               mov  dx,offset mess
               call dispmess

               MOV  si,-1
               mov  di,-1
    loop1:     
               inc  si
               inc  di
               cmp  si,4
               jz   next
               call getch              ;获取一个字符放到al中
               call ishex              ;判断16进制数
               jc   getstr2            ;cf=1,响铃
               mov  buff0[si],al
               mov  buff2[di],al
               call putch
               jmp  loop1
    getstr2:   
               call bell               ;输出个响铃，警告
               JMP  loop1
    
    ;输入偏移
    next:      
               call newline
               mov  dx,offset mess2
               call dispmess
               mov  buff2[di],':'

               MOV  si,-1
    loop2:     
               inc  si
               inc  di
               cmp  si,4
               jz   input_over
               call getch              ;获取一个字符放到al中
               call ishex              ;判断16进制数
               jc   getstr3            ;cf=1,响铃
               mov  buff1[si],al
               mov  buff2[di],al
               call putch
               jmp  loop2
    getstr3:   
               call bell               ;输出个响铃，警告
               JMP  loop2
           
    input_over:
    ;将输入的段值转为2进制存入bx中
               mov  al,buff0[0]
               call atobin             ;ascii码转bin，结果保存到al中
               mov  bh,al              ;al挪到bh低4位
               MOV  cx,4               ;位移准备
               shl  bh,cl              ;将bh低4位挪到高4位
               mov  al,buff0[1]
               call atobin
               add  bh,al              ;将al低4位加到bh低4位
               mov  al,buff0[2]
               call atobin             ;ascii码转bin，结果保存到al中
               mov  bl,al              ;al挪到bh低4位
               MOV  cx,4               ;位移准备
               shl  bl,cl              ;将bh低4位挪到高4位
               mov  al,buff0[3]
               call atobin
               add  bl,al              ;将al低4位加到bh低4位
    ;将输入的偏移转为2进制存入si中
               mov  al,buff1[0]
               call atobin             ;ascii码转bin，结果保存到al中
               mov  dh,al              ;al挪到bh低4位
               MOV  cx,4               ;位移准备
               shl  dh,cl              ;将bh低4位挪到高4位
               mov  al,buff1[1]
               call atobin
               add  dh,al              ;将al低4位加到bh低4位
               mov  al,buff1[2]
               call atobin             ;ascii码转bin，结果保存到al中
               mov  dl,al              ;al挪到bh低4位
               MOV  cx,4               ;位移准备
               shl  dl,cl              ;将bh低4位挪到高4位
               mov  al,buff1[3]
               call atobin
               add  dl,al              ;将al低4位加到bh低4位
               mov  si,dx
    ;设置段值
               mov  ax,bx              ;初始化数据段
               mov  ds,ax
               mov  dx,[si]
    ;数据段还原
               mov  ax,data
               mov  ds,ax
               inc  di
               mov  buff2[di],dh
               mov  buff2[di+2],dl
    ;一个字16位
    
               call newline
               mov  dx,offset buff2
               mov  ah,9
               int  21H

               mov  ax,4c00h           ;dos中断
               int  21H
    ;-----------------------------
    ;显示由DX所指的提示信息，其他子程序说明信息略
    ;9号子程序功能，在屏幕显示一个字符串
    ;入口参数：dx：输出字符串的首地址，字符串需要以’$‘结尾
dispmess proc
               mov  ah,9
               int  21h
               ret
dispmess endp
    ;接受一个字符但不显示，存到al中
    ;入口参数：标志输入设备
    ;出口参数：al
getch PROC
               MOV  AH,8               ;接受一个字符但不显示,
               INT  21H
               RET
getch ENDP
    ;-----------------------------
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
               mov  dl,0dh             ;回车符的ASCII码
               mov  ah,2
    ;显示回车符
               int  21h
               mov  dl,0ah             ;换行符的ASCII码
               mov  ah,2
    ;显示换行符
               int  21h
               pop  dx
               pop  ax
               ret
newline endp
    ;----------------------------------------------
    ;----------------------------------------------
    ;判断是不是16进制数
    ;入口参数：AL
    ;出口参数：CF标，CF置1不是16进制数，CF置0位是16进制数
    ;CMP指令，配合JB指令，执行跳转CF置1
ishex PROC
               CMP  AL,'0'             ;和'0'对比
               JB   ISHEX2             ;小于0不是ascii码，CF=1
               CMP  AL,'9'+1           ;在'0'~'9'之间，是ascii,cf=0
               JB   ISHEX1
               CMP  AL,'A'             ;小于''A'不是ascii码，CF=1
               JB   ISHEX2
               CMP  AL,'F'+1           ;在''A'~'F'之间是ascii,cf=0
               JB   ISHEX1
               CMP  AL,'a'             ;小于''a'不是ascii码，CF=1
               JB   ISHEX2
               CMP  AL,'f'+1           ;在''a'~'f'之间是ascii,cf=0
    ISHEX1:    CMC                     ;cf取反
    ISHEX2:    RET
ishex ENDP
    ;----------------------------------------------
    ;-----------------------------
    ;响铃
    ;入口参数:无
    ;出口参数:标志输出设备
bell PROC
               MOV  AL,07h
               CALL PUTCH
               RET
bell ENDP
    ;-----------------------------
    ;----------------------------------------------
    ;ascii转2进制的值
    ;入口参数：al=需要转二进制值的ascii码
    ;出口参数：al=已转好的2进制值
atobin PROC
               SUB  AL,30H
               CMP  AL,9
               JBE  ATOBIN1
               SUB  AL,7
               CMP  AL,15
               JBE  ATOBIN1
               SUB  AL,20H
    ATOBIN1:   RET
atobin ENDP
    ;----------------------------------------------
code ends
    end     start
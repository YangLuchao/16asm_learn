;程序名称:
;功能:写一个程序统计当前工作目录下文件TEST.TXT中的各十进制数字符和字母符的个数。
;执行流程：
;1:输入文件名
;2:打开文件
;3:循环计数
;4:输出长度
;=======================================
assume      cs:code,ds:data
mlength = 128
data segment
    numLen dw 0               ;数字长度
    engLen dw 0               ;字母长度
    buff1  db 5 dup(0),24h    ;给转换成的十进制数预留槽位
    buff2  db 5 dup(0),24h    ;给转换成的十进制数预留槽位
    ;文件名1
    FNAME1 db 'test.txt',0
    BUFFER DB ?               ;缓冲区
data ends

code segment
    start:     
               mov  ax,data             ;初始化数据段
               mov  ds,ax
    ;2打开文件
               MOV  DX,OFFSET FNAME1
               MOV  AX,3D00H            ;为读打开指定文件
               INT  21H
               MOV  BX,AX               ;保存文件1文件柄
    
    ;3:循环计数
    CONT:      
               CALL READCH              ;从文件中读一个字符
               CMP  AL,1AH              ;读到文件结束符吗？
               JZ   contOver            ;是，转
               CALL isEnglesh
               jnc  engAdd              ;是英文字符，转
               CALL isNum               ;显示所读字符
               jnc  numAdd              ;是数字，转
               jmp  CONT
    engAdd:    
               add  engLen,1
               jmp  CONT
    numAdd:    
               add  numLen,1
               jmp  CONT
    contOver:  
               call newline
               mov  ax,engLen
               mov  bx,offset buff1
               call btoasc
               MOV  dx,offset buff1
               mov  ah,9
               int  21H

               call newline
               mov  ax,numLen
               mov  bx,offset buff2
               call btoasc
               MOV  dx,offset buff2
               mov  ah,9
               int  21H
    
    over:      
               mov  ax,4c00h            ;dos中断
               int  21H
    ;子程序名称:
    ;子程序名：btoasc
    ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
    ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
    ;=======================================
btoasc PROC
               push bp                  ;保存主程序栈基址
               MOV  bp,sp               ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
               push SI
               push cx
               push dx
               push bx
    ;==================子程序代码开始==============
               MOV  SI,5                ;置循环次数
               MOV  CX,10               ;置除数10
    BTOASC1:   XOR  DX,DX               ;把被除数扩展成32位
               DIV  CX                  ;除操作
               ADD  DL,30H              ;余数为BCD码，转换为ASCII码
               DEC  SI                  ;调整循环计数器
               MOV  [BX][SI],DL         ;保存所得ASCII码
               OR   SI,SI               ;判断si是否清零
               JNZ  BTOASC1             ;否，继续
    ;==================子程序代码结束==============
               pop  bx
               pop  dx
               pop  cx
               pop  si
               MOV  sp,bp               ;释放定义的局部变量的空间(SUB sp,4)
               pop  BP
               RET
btoasc ENDP
    ;子程序名：newline
    ;功能：形成回车和换行（光标移到下一行首)
    ;入口参数：无
    ;出口参数：无
    ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
               push ax
               push dx
               mov  dl,0dh              ;回车符的ASCII码
               mov  ah,2
    ;显示回车符
               int  21h
               mov  dl,0ah              ;换行符的ASCII码
               mov  ah,2
    ;显示换行符
               int  21h
               pop  dx
               pop  ax
               ret
newline endp
    ;----------------------------------------------
    ;-----------------------------
    ;判断是不是英文字符
    ;入口参数：al
    ;出口参数：CF标，CF置1不是英文字符，CF置0位是英文字符
isEnglesh PROC
               CMP  AL,'A'              ;小于'A'不是英文字符，CF=1
               JB   isEnglesh2
               CMP  AL,'Z'+1            ;在'A'~'F'之间是英文,cf=0
               JB   isEnglesh1
               CMP  AL,'a'              ;小于'a'不是英文字符，CF=1
               JB   isEnglesh2
               CMP  AL,'z'+1            ;在'a'~'z'之间是英文字符,cf=0
    isEnglesh1:CMC                      ;cf取反
    isEnglesh2:RET
isEnglesh endp
    ;-----------------------------
    ;----------------------------------------------
    ;判断是不是数字
    ;入口参数：AL
    ;出口参数：CF标，CF置1不是数字，CF置0位是数字
isNum PROC
               CMP  AL,'0'
               JB   isNum2
               CMP  AL,'9'+1
    isNum1:    CMC
    isNum2:    RET
isNum ENDP
    ;----------------------------------------------
    ;子程序名：READCH
    ;功能：读取文件的一个字符
    ;入口参数：预留的缓冲区首地址
    ;出口参数：无
    ;说明：提前打开文件
    ;       cf置1，字符读取错误
READCH PROC
               MOV  CX,1                ;读字节数
               MOV  DX,OFFSET BUFFER    ;读缓冲区地址
               MOV  AH,3FH              ;功能调用号
               INT  21H                 ;读
               JC   READCH2             ;读出错，转
               CMP  AX,CX               ;判文件是否结束
               MOV  AL,1AH              ;设文件已结束，置文件结束符
               JB   READCH1             ;文件确已结束，转
               MOV  AL,BUFFER           ;文件未结束，取所读字符
    READCH1:   
               CLC                      ;cf状态符清0
    READCH2:   
               RET
READCH ENDP
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
code ends
    end     start
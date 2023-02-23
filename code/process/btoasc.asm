    ;----------------------------------------------
    ;子程序名：btoasc，以算法转10进制
    ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
    ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
			;    buff1       db 5 dup(0),24h
    		;    count       dw 0
	        ;    mov  ax,count
            ;    mov  bx,offset buff1
            ;    call btoasc
            ;    MOV  dx,offset buff1
            ;    mov  ah,9
            ;    int  21H
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
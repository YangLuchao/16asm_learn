;程序名称:
;功能:把16位二进制数转换为对应十进制数ASCII码串。
;作为入口参数的二进制数是有符号的，采用补码形式表示。
;通过堆栈传递入口参数。
;过程SUBD是远过程，堆栈由子程序平衡
;=======================================
assume      cs:code,ds:data

data segment
        val  dw 0fd23h              ;要转换的二进制数
        flag db '-'
        buff db 5 dup(?),24h        ;给转换成的十进制数预留槽位
data ends

code segment
        start:  
                mov  ax,data               ;初始化数据段
                mov  ds,ax

                mov  ax,val
                mov  bx,offset buff
                push ax
                push bx
                call btoasc

                mov  dx,offset flag        ;打印输出
                mov  ah,9
                int  21h

                mov  ax,4c00h              ;dos中断
                int  21H
        ;子程序名称:
        ;子程序名：btoasc
        ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
        ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
        ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
        ;=======================================
btoasc PROC far                            ;远过程
                push bp                    ;保存主程序栈基址
                MOV  bp,sp                 ;将当前栈顶作为栈底，建立堆栈框架
        ;用bp寄存器作为堆栈的基址
        ;bp+2获取返回地址IP
        ;bp+4获取返回地址段值(CS)
        ;bp+6获取入口参数
                push SI
                push cx
                push dx
                push bx
        ;==================子程序代码开始==============
                mov  ax,[bp+8]             ;要转换的数据地址
                mov  bx,[bp+6]             ;预留槽位的位置
                MOV  SI,5                  ;置循环次数
                MOV  CX,10                 ;置除数10
        BTOASC1:XOR  DX,DX                 ;把被除数扩展成32位
                IDIV CX                    ;除操作
                ADD  DL,30H                ;余数为BCD码，转换为ASCII码
                DEC  SI                    ;调整循环计数器
                MOV  [BX][SI],DL           ;保存所得ASCII码
                OR   SI,SI                 ;判断si是否清零
                JNZ  BTOASC1               ;否，继续
        ;==================子程序代码结束==============
                pop  bx
                pop  dx
                pop  cx
                pop  si
                MOV  sp,bp                 ;释放定义的局部变量的空间(SUB sp,4)
                pop  BP
                RET  4                     ;子程序平衡堆栈
btoasc ENDP
code ends
    end     start
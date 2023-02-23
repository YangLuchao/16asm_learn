;程序名称:
;功能:把由十进制数ASCII码组成的字符串转换为对应的数值
;入口参数:通过堆栈传递入口参数
;出口参数:AX=转换得到的二进制数
;=======================================
assume      cs:code,ds:data

data segment
        val  db '123'        ;需要转换的字符
data ends

code segment
        start:  
                mov  ax,data              ;初始化数据段
                mov  ds,ax

                MOV  bx,offset val
                push bx
                call DTOBIN

                mov  ax,4c00h             ;dos中断
                int  21H
        ;子程序名称:
        ;功能:把由十进制数ASCII码组成的字符串转换为对应的数值
        ;入口参数:通过堆栈传递入口参数
        ;出口参数:AX=转换得到的二进制数
        ;其他说明:算法如下：Y =((((0*10+d_n)*10+d_{n-1})*10+...)*10+d_2)*10+d_1
        ;=======================================
DTOBIN PROC
                push bp                   ;保存主程序栈基址
                MOV  bp,sp                ;将当前栈顶作为栈底，建立堆栈框架
        ;用bp寄存器作为堆栈的基址
        ;bp+2获取返回地址IP
        ;bp+4获取返回地址段值(CS)
        ;bp+6获取入口参数
        ;==================子程序代码开始==============
                PUSH BX                   ;暂存
                PUSH CX
                PUSH DX
                mov  bx,[BP+4]
                XOR  AX,AX                ;设置初值0
                MOV  CL,[BX]              ;将首位数挪到cl中
                INC  BX                   ;bx+1
                XOR  CH,CH                ;CX=n
                JCXZ DTOBIN2              ;cx=0跳出子程序
        DTOBIN1:MOV  DX,10                ;dx作为乘数
                MUL  DX                   ;Y*10
                MOV  DL,[BX]              ;取下一个数字符
                INC  BX                   ;inc+1
                AND  DL,OFH               ;转成BCD码
                XOR  DH,DH                ;清空高位
                ADD  AX,DX                ;Y*10+di
                LOOP DTOBIN1
        DTOBIN2:POP  DX
                POP  CX
                POP  BX
        ;==================子程序代码结束==============
                MOV  sp,bp                ;释放定义的局部变量的空间(SUB sp,4)
                pop  BP
                RET  2
DTOBIN ENDP
code ends
    end     start
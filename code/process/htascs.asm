    ;----------------------------------------
    ;子程序名称:
    ;功能:把16位二进制数转换为4位十六进制数ASCII码的
    ;入口参数:DX=需要转换的二进制数,DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数:十六进制数ASCII码串按高位到低位依次存放在指定的缓冲区中
    ;其他说明:转换方法：把16位二进制数向左循环移位四次，使高四位变为低4位，
    ;析出低四位调用子程序htoasc转换1位十六进制ASCII码，循环四次
    ;=======================================
htascs PROC
            push bp                ;保存主程序栈基址
            MOV  bp,sp             ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
            push CX
            push dx
            push ax
            push bx
    ;==================子程序代码开始==============
            mov  CX,4
    HTASCS1:ROL  DX,1              ;循环左移4位,高四位成为低四位
            ROL  DX,1
            ROL  DX,1
            ROL  DX,1
            MOV  AL,DL             ;复制出低四位
            CALL HTOASC            ;转换得ASCII码
            MOV  [BX],AL           ;保存
            INC  BX                ;调整缓冲区指针
            LOOP HTASCS1           ;重复四次
    ;==================子程序代码结束==============
            pop  bx
            pop  ax
            pop  dx
            pop  cx
            MOV  sp,bp             ;释放定义的局部变量的空间(SUB sp,4)
            pop  BP
            RET
htascs ENDP
    ;----------------------------------------
    ;子程序名：htleasc
    ;功能：一位十六进制数转换为ASCII
    ;入口参数：al=待转换的十六进制数
    ;出口参数：al=转换后的ASCII
htoasc proc near
            and  al,0fh            ;清空高四位
            add  al,30h            ;+30h
            cmp  al,39h            ;和39H比较
            jbe  htoascl           ;小于等于就跳出
            add  al,7h             ;否则+7后跳出
    htoascl:
            ret
htoasc endp
    ;----------------------------------------
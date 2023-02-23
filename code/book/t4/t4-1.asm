;程序名称:
;功能:写一个把用ASCII码表示的两位十进制数转换为对应的十进制的子程序
;转换的算法为：设X为十位数，Y为个位数，计算10X+Y
;子程序名：subr
;=======================================
assume      cs:code,ds:data

data segment
    num  db 31h,30h
    val  db ?
data ends

code segment
    start:
          mov  ax,data      ;初始化数据段
          mov  ds,ax

          mov  dh,num[0]    ;第一个数放到dh中
          mov  dl,num[1]    ;第二个数放到dl中

          call subr
          mov  val,al

          mov  ax,4c00h     ;dos中断
          int  21H
          
    ;子程序名称:subr
    ;功能:两位ASCII码十进制数转换为十进制
    ;入口参数:dh高位十进制，dl低位十进制
    ;出口参数:AL
    ;其他说明:无
    ;=======================================
subr PROC
          push bp           ;保存主程序栈基址
          MOV  bp,sp        ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
          push dx           ;保护dx
    ;==================子程序代码开始==============
          MOV  AL,DH        ;'1'，挪到al中
          AND  AL,0FH       ;清空高4位
          MOV  AH,10        ;10挪到ah中，作为乘数
          MUL  AH           ;al * ah (1 * 10) = 10
          MOV  AH,DL        ;'2'，挪到AH中
          AND  AH,0FH       ;清空高4位
          ADD  AL,AH        ;乘积加值
    ;==================子程序代码结束==============
          pop  dx           ;弹出dx
          MOV  sp,bp        ;释放定义的局部变量的空间(SUB sp,4)
          pop  BP
          RET
subr ENDP
code ends
    end     start
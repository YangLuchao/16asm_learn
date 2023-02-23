;程序名：t7-2.asm
;功能： 写一个测量字符串长度的子程序
assume cs:code,ds:data,ss:stack
;定义结构说明
parm struc
    preg    dw  ?   ;对应BP寄存器保存单元，子程序堆栈栈底，偏移是0,1
    retadr  dd  ?   ;对应返回地址,偏移是2,3,4,5(段值:偏移)
    stroff  dw  ?   ;对应入口参数中的偏移,6,7
    strseg  dw  ?   ;对应入口参数中的段值,8,9
parm ends

;堆栈段
stack segment
              db 16 dup(0)
stack ends
;数据段
data segment
        buff    db 5 dup(0),'$'
        strmess db 'ra',0
        len     dw 8 dup(0)
data ends

;代码段
code segment
        start:  
                mov  ax,stack                 ;初始化堆栈段
                mov  ss,ax
                mov  sp,10                    ;准备10个字节，为子程序调用做准备

                mov  ax,data                  ;初始化数据段
                mov  ds,ax

                push ds                       ;压入参数的段值
                mov  dx,offset strmess
                push dx                       ;压入参数的偏移
    
                call far ptr strlen           ;调用远过程计算字符串长度

                mov  bx,offset buff           ;字符缓冲区偏移
        ;显示字符串长度
                call btoasc                   ;转ASCII
                mov  dx,offset buff           ;打印输出
                mov  ah,9
                int  21h

                mov  ax,4c00h                 ;退出到dos
                int  21h
STRLEN PROC FAR
                PUSH BP
                MOV  BP,SP                    ;堆栈框架，主程序的栈顶做子程序栈底

                PUSH DS                       ;保护子存钱
                PUSH SI

                MOV  DS,[BP].STRSEG           ;取字符串首地址的段值
                MOV  SI,[BP].STROFF           ;取字符串首地址的偏移
                XOR  AL,AL
        STRLEN1:
                CMP  BYTE PTR [SI],AL
                JZ   STRLEN2
                INC  SI
                JMP  STRLEN1
        STRLEN2:
                MOV  AX,SI
                SUB  AX,[BP].STROFF

                POP  SI                       ;保护寄存器
                POP  DS
                POP  BP
                RET  4                        ;两个参数，堆栈平衡
STRLEN ENDP
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
                push bp                       ;保存主程序栈基址
                MOV  bp,sp                    ;将当前栈顶作为栈底，建立堆栈框架
        ;用bp寄存器作为堆栈的基址
        ;bp+2获取返回地址IP
        ;bp+4获取返回地址段值(CS)
        ;bp+6获取入口参数
                push SI
                push cx
                push dx
                push bx
        ;==================子程序代码开始==============
                MOV  SI,5                     ;置循环次数
                MOV  CX,10                    ;置除数10
        BTOASC1:XOR  DX,DX                    ;把被除数扩展成32位
                DIV  CX                       ;除操作
                ADD  DL,30H                   ;余数为BCD码，转换为ASCII码
                DEC  SI                       ;调整循环计数器
                MOV  [BX][SI],DL              ;保存所得ASCII码
                OR   SI,SI                    ;判断si是否清零
                JNZ  BTOASC1                  ;否，继续
        ;==================子程序代码结束==============
                pop  bx
                pop  dx
                pop  cx
                pop  si
                MOV  sp,bp                    ;释放定义的局部变量的空间(SUB sp,4)
                pop  BP
                RET
btoasc ENDP
code ends
end start
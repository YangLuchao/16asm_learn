;程序名称:
;功能:请写一个程序实现如下功能：
;把内存单元F000:000H开始的200个字节作为无符号整数，求他们的和，
;并利用十进制数在屏幕显示出来
;把该区域作为100个无符号16位的字，求他们的和，并利用十进制数在屏幕显示。
;=======================================
assume      cs:code,ds:data

data segment
    buff1 db 5 dup(0),'$'    ;前200的和
    buff2 db 5 dup(0),'$'    ;前100的和
data ends

code segment
    start:  
            mov  ax,0f000h          ;段值
            mov  ds,ax

            MOV  si,-1              ;偏移
    
    loop1:  
            inc  si                 ;si+1
            cmp  si,200             ;循环200次
            jmp  next
            add  ax,[si]            ;不会进位
            jmp  loop1

    next:   
            mov  ax,data            ;段值
            mov  ds,ax
            mov  bx,offset buff1
            push ax
            push bx
            call btoasc

            MOV  dx,offset buff1
            mov  ah,9
            int  21H

            call newline

            mov  ax,0f000h          ;段值
            mov  ds,ax
            MOV  si,-1              ;偏移
    loop2:  
            inc  si                 ;si+1
            cmp  si,100             ;循环100次
            jmp  next2
            add  ax,[si]            ;不会进位
            jmp  loop2

    next2:  
            mov  ax,data            ;段值
            mov  ds,ax
            mov  bx,offset buff2
            push ax
            push bx
            call btoasc
            MOV  dx,offset buff2
            mov  ah,9
            int  21H


            mov  ax,4c00h           ;dos中断
            int  21H
    ;子程序名称:
    ;子程序名：btoasc
    ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
    ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
    ;=======================================
btoasc PROC far                     ;远过程
            push bp                 ;保存主程序栈基址
            MOV  bp,sp              ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
            push SI
            push cx
            push dx
            push bx
    ;==================子程序代码开始==============
            mov  ax,[bp+8]          ;要转换的数据地址
            mov  bx,[bp+6]          ;预留槽位的位置
            MOV  SI,5               ;置循环次数
            MOV  CX,10              ;置除数10
    BTOASC1:XOR  DX,DX              ;把被除数扩展成32位
            IDIV CX                 ;除操作
            ADD  DL,30H             ;余数为BCD码，转换为ASCII码
            DEC  SI                 ;调整循环计数器
            MOV  [BX][SI],DL        ;保存所得ASCII码
            OR   SI,SI              ;判断si是否清零
            JNZ  BTOASC1            ;否，继续
    ;==================子程序代码结束==============
            pop  bx
            pop  dx
            pop  cx
            pop  si
            MOV  sp,bp              ;释放定义的局部变量的空间(SUB sp,4)
            pop  BP
            RET  4                  ;子程序平衡堆栈
btoasc ENDP
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
code ends
    end     start
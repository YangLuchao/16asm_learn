;程序名称:
;功能:写一个程序判别屏幕上是否显示字符串'AB'。
;在屏幕的最底行显示提示信息，按任意键终止程序
;=======================================
assume      cs:code,ds:data
COLUM = 80;列
line = 24;行
data segment
        colum_count db -1
        line_count  db -1
        last_letter db 0                        ;上一个字符
        buff        db 'has ab flag : $'
        count       dw 0
        buff1       db 5 dup(0),24h
data ends

code segment
        start:  
                mov  ax,data                  ;初始化数据段
                mov  ds,ax

        ;计算光标位子
        outer:  
                add  line_count,1             ;行+1
                cmp  line_count,line
                jz   home1
        iner:   
                mov  ah,1                     ;1号功能，判断键盘有没有输入
                int  16h                      ;执行16号中断
                jc   over                     ;有输入，执行完成
                add  colum_count,1            ;列+1
                cmp  colum_count,COLUM
                jz   home
        ;光标位子计算完成
                mov  ah,2                     ;移动光标位子
                mov  dh,line_count
                mov  dl,colum_count
                int  10h
                mov  ah,8H                    ;8号功能，获取光标处的字符和属性
                int  10h
                cmp  al,'A'
                jz   aflag
                cmp  al,'B'
                jz   bflag
                mov  last_letter,0
                jmp  iner

        aflag:  
                mov  last_letter,1
                jmp  iner
        bflag:  
                cmp  last_letter,1
                jz   isa
                mov  last_letter,0
                jmp  iner
        isa:    
                mov  ah,2                     ;移动光标位子
                mov  dh,24
                mov  dl,0
                int  10h
        ;ab个数+1，并输出
                add  count,1
                mov  ax,count
                mov  bx,offset buff1
                call btoasc
                MOV  dx,offset buff
                mov  ah,9
                int  21H
                MOV  dx,offset buff1
                mov  ah,9
                int  21H
                jmp  iner
        home:   
                mov  colum_count,-1
                jmp  outer
        home1:  
                mov  line_count,-1
                jmp  outer

        over:   
                mov  ax,4c00h                 ;dos中断
                int  21H
        ;----------------------------------------------
        ;子程序名称:
        ;子程序名：btoasc
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
    end     start
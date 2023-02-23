;程序名称:
;功能:请写一个程序实现如下功能，把内存单元F000：0000H开始的1024个字节作为有符号数，
;分别统计其中的正数，负数和0的个数，并显示。
;=======================================
assume      cs:code,ds:data

data segment
    zore         dw 0               ;为0计数
    negative     dw 0               ;为负数计数
    positive     dw 0               ;为整数计数
    zore_str     db 5 dup(0),'$'    ;0的个数
    negative_str db 5 dup(0),'$'    ;负数的个数
    positive_str db 5 dup(0),'$'    ;正数的个数
data ends
;设，已在F000：0000H开始的内存区域安排了1024个16位有符号数
;循环取数，每次判断一个两个字符
;判断0值，减0，jz为0
;判断正数还是负数，带位左移1位，最高位挪到cf中，jb(cf=1)为正，jnb(cf=0)为负
;极端情况下0，正数，负数都有可能有1024个，所以要拿dw类型来存储
;首先2进制转10进制，然后10进制转ASCII码
code segment
    start:        
                  mov  ax,0f000H                 ;初始化数据段
                  mov  ds,ax

                  mov  si,-1                     ;初始化si
                  mov  cx,1024                   ;初始化计数器

    loop1:        
                  mov  ax,0f000H                 ;定义数据段
                  mov  ds,ax
                  inc  si                        ;si+1
                  mov  ax,[si]                   ;将数挪到ax中
                  sub  ax,0H                     ;减0
                  jz   zore_falg                 ;为0，跳到zore
                  rol  ax,1                      ;左移1位，将最高位挪到cf中
                  jb   positive_flag             ;cf=1为正
                  jmp  negative_flag             ;cf=0为负
    zore_falg:    
                  mov  ax,data                   ;数据段挪回来
                  mov  ds,ax
                  mov  ax,zore
                  add  ax,1
                  mov  zore,ax                   ;加1挪回
                  loop loop1
                  jmp  to_ascii                  ;转ascii

    positive_flag:
                  mov  ax,data                   ;数据段挪回来
                  mov  ds,ax
                  mov  ax,positive
                  add  ax,1
                  mov  positive,ax               ;加1挪回
                  loop loop1
                  jmp  to_ascii                  ;转ascii

    negative_flag:
                  mov  ax,data                   ;数据段挪回来
                  mov  ds,ax
                  mov  ax,negative
                  add  ax,1
                  mov  negative,ax               ;加1挪回
                  loop loop1

    to_ascii:     
                  mov  ax,data                   ;数据段挪回来
                  mov  ds,ax
    
                  mov  ax,zore
                  mov  bx,offset zore_str
                  push ax
                  push bx
                  call btoasc

                  MOV  dx,offset zore_str
                  mov  ah,9
                  int  21H

                  call newline

                  mov  ax,negative
                  mov  bx,offset negative_str
                  push ax
                  push bx
                  call btoasc

                  MOV  dx,offset negative_str
                  mov  ah,9
                  int  21H

                  call newline

                  mov  ax,positive
                  mov  bx,offset positive_str
                  push ax
                  push bx
                  call btoasc

                  MOV  dx,offset positive_str
                  mov  ah,9
                  int  21H

                  mov  ax,4c00h                  ;dos中断
                  int  21H
    ;子程序名称:
    ;子程序名：btoasc
    ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
    ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
    ;=======================================
btoasc PROC far                                  ;远过程
                  push bp                        ;保存主程序栈基址
                  MOV  bp,sp                     ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
                  push SI
                  push cx
                  push dx
                  push bx
    ;==================子程序代码开始==============
                  mov  ax,[bp+8]                 ;要转换的数据地址
                  mov  bx,[bp+6]                 ;预留槽位的位置
                  MOV  SI,5                      ;置循环次数
                  MOV  CX,10                     ;置除数10
    BTOASC1:      XOR  DX,DX                     ;把被除数扩展成32位
                  IDIV CX                        ;除操作
                  ADD  DL,30H                    ;余数为BCD码，转换为ASCII码
                  DEC  SI                        ;调整循环计数器
                  MOV  [BX][SI],DL               ;保存所得ASCII码
                  OR   SI,SI                     ;判断si是否清零
                  JNZ  BTOASC1                   ;否，继续
    ;==================子程序代码结束==============
                  pop  bx
                  pop  dx
                  pop  cx
                  pop  si
                  MOV  sp,bp                     ;释放定义的局部变量的空间(SUB sp,4)
                  pop  BP
                  RET  4                         ;子程序平衡堆栈
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
                  mov  dl,0dh                    ;回车符的ASCII码
                  mov  ah,2
    ;显示回车符
                  int  21h
                  mov  dl,0ah                    ;换行符的ASCII码
                  mov  ah,2
    ;显示换行符
                  int  21h
                  pop  dx
                  pop  ax
                  ret
newline endp
    ;----------------------------------------------
code ends
    end     start
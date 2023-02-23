;程序名称:
;功能:写一个能够显示当前工作目录下文件TEST.TXT长度的程序。改进程序使其可显示任一指定文件长度，文件标识由键盘输入。
;执行流程：
;1:输入文件名
;2:打开文件
;3:循环计数
;4:输出长度
;=======================================
assume      cs:code,ds:data
mlength = 128
data segment
    ;文件名1
    FNAME1  db mlength           ;缓冲区最大长度
            db ?                 ;字符串实际长度，出口参数之一
            db mlength dup(0)    ;符合0AH号功能调用所需的缓冲区
    HANDLE1 DW 0                 ;存放文件1的文件柄
    buff    DB 512 dup(0)        ;缓冲区
    buff1   db 5 dup(0),24h      ;给转换成的十进制数预留槽位
    len     dw 0
data ends

code segment
    start:    
              mov  ax,data                   ;初始化数据段
              mov  ds,ax

    ;1:输入文件名
    ;1.1:输入文件1的文件名
              mov  ah,0ah                    ;DOS十号功能，接受一个字符串，回车键结束
              mov  dx,offset FNAME1          ;入口参数，缓冲区首地址，存放缓冲区最大容量
              int  21h                       ;输出提示
    ;1.2:将文件1名的换行符换为00：算法：FNAME1[2][FNAME1[0]][1]
              xor  bx,bx
              MOV  bl,FNAME1[1]
              mov  FNAME1[bx][2],0
    ;2打开文件
              MOV  DX,OFFSET FNAME1[2]
              MOV  AX,3D00H                  ;为读打开指定文件
              INT  21H
              MOV  HANDLE1,AX                ;保存文件1文件柄
    
    ;3:循环计数
              xor  cx,cx
    CONT1:    
              MOV  DX,OFFSET buff            ;读目标文件
              MOV  CX,512                    ;读取长度=缓冲区长度
              MOV  BX,HANDLE1                ;设置源文件文件柄
              MOV  AH,3FH                    ;读取源文件
              INT  21H
              JC   over                      ;读出错，转
              OR   AX,AX                     ;目标文件读完了？
              JZ   processok                 ;是，转结束
              add  len,AX                    ;写到目标文件的长度等于读出的长度
              JNC  CONT1                     ;写正确，继续
    ;关闭文件1,2,3
    processok:
              MOV  BX,HANDLE1
              MOV  AH,3EH
              INT  21H
    ;4:输出长度
              call newline

              mov  ax,len
              mov  bx,offset buff1
              push ax
              push bx
              call btoasc

              MOV  dx,offset positive_str
              mov  ah,9
              int  21H

    over:     
              mov  ax,4c00h                  ;dos中断
              int  21H
    ;子程序名称:
    ;子程序名：btoasc
    ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
    ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
    ;=======================================
btoasc PROC                                  ;远过程
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
    BTOASC1:  XOR  DX,DX                     ;把被除数扩展成32位
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
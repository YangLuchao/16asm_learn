;程序名称:
;功能:写一个在屏幕上（或打印机上）列出小于65535的素数（质数）
;素数的判断条件：
;只能被1和自己整除
;偶数肯定不是素数
;
;=======================================
assume      cs:code,ds:data

data segment
    count dw ?               ;素数计数
    num   dw 2               ;数字，初始化为2
    buff  db 5 dup(0),'$'    ;
data ends

code segment
    start:  
            mov  ax,data           ;初始化数据段
            mov  ds,ax

    ;外层循环
    loop1:  
            add  num,1
            MOV  ax,num            ;数字挪到cx中
            cmp  ax,6              ;完成判断
            jz   over              ;打印
            ror  ax,1              ;右移1位判断奇偶
            jnc  loop1             ;偶数，不是素数
            rol  ax,1              ;左移还原
            mov  si,2
    ;内层循环，奇数判断素数
    loop2:  
            inc  si                ;si+1
            cmp  si,num            ;余数和除数对比
            jnz  num_1             ;除数和被除数相等，素数+1
            cwd                    ;字扩展为双字
            mov  bx,si             ;除数挪到dx中
            div  bx                ;ax/bx
            cmp  dx,0              ;余数是否等于0
            jz   loop2             ;余数=0，被整除，不是素数，计算下一个被数

    num_1:  
            add  count,1           ;素数+1
            jmp  loop1             ;计算下一个数

    over:   
            mov  ax,count
            mov  bx,offset buff
            push ax
            push bx
            call btoasc

            MOV  dx,offset buff
            mov  ah,9
            int  21H

            mov  ax,4c00h          ;dos中断
            int  21H
    ;子程序名称:
    ;子程序名：btoasc
    ;入口参数：AX=欲转换的二进制数 DS:BX=存放转换所得ASCII码串的缓冲区首地址
    ;出口参数：十进制数ASCII码串按万位到个位的顺序依次存放在指定的缓冲区
    ;其他说明:算法：把16位二进制数除以10余数为个位数的BCD码，商再除以10,余数为十位数的BCD码，循环5次
    ;=======================================
btoasc PROC far                    ;远过程
            push bp                ;保存主程序栈基址
            MOV  bp,sp             ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
            push SI
            push cx
            push dx
            push bx
    ;==================子程序代码开始==============
            mov  ax,[bp+8]         ;要转换的数据地址
            mov  bx,[bp+6]         ;预留槽位的位置
            MOV  SI,5              ;置循环次数
            MOV  CX,10             ;置除数10
    BTOASC1:XOR  DX,DX             ;把被除数扩展成32位
            IDIV CX                ;除操作
            ADD  DL,30H            ;余数为BCD码，转换为ASCII码
            DEC  SI                ;调整循环计数器
            MOV  [BX][SI],DL       ;保存所得ASCII码
            OR   SI,SI             ;判断si是否清零
            JNZ  BTOASC1           ;否，继续
    ;==================子程序代码结束==============
            pop  bx
            pop  dx
            pop  cx
            pop  si
            MOV  sp,bp             ;释放定义的局部变量的空间(SUB sp,4)
            pop  BP
            RET  4                 ;子程序平衡堆栈
btoasc ENDP
code ends
    end     start
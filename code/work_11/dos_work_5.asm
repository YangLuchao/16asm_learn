;程序名称:
;功能:先用2位十六进制数显示ASCII码，再用3位八进制显示ASCII码。
;=======================================
;键盘输入1，程序接收的是31H
;将31H再显示出来
assume      cs:code,ds:data
;常量定义
mlength = 128;缓冲区最大长度
data segment
        buff db mlength               ;缓冲区最大长度
             db ?                     ;字符串实际长度，出口参数之一
             db mlength dup(0)        ;符合0AH号功能调用所需的缓冲区
data ends

code segment
        start:  
                mov  ax,data         ;初始化数据段
                mov  ds,ax
        ;
        ;转ascii
                call getch           ;获取一个字符放到al中
                MOV  dl,al           ;暂存到ah中
                MOV  cx,4            ;右移准备
                shr  ax,cl
                call htoasc
                call putch
                mov  al,dl
                call htoasc
                call putch

        over:   
                mov  ax,4c00h        ;dos中断
                int  21H
        ;-----------------------------
        ;接受一个字符但不显示，存到al中
        ;入口参数：标志输入设备
        ;出口参数：al
getch PROC
                MOV  AH,8            ;接受一个字符但不显示,
                INT  21H
                RET
getch ENDP
        ;-----------------------------
        ;-----------------------------
        ;显示一个字符
        ;入口参数：al
        ;出口参数：标志输出设备
putch PROC
                PUSH DX
                MOV  DL,AL
                MOV  AH,2
                INT  21H
                POP  DX
                RET
putch ENDP
        ;子程序名：htleasc
        ;功能：一位十六进制数转换为ASCII
        ;入口参数：al=待转换的十六进制数
        ;出口参数：al=转换后的ASCII
htoasc proc near
                and  al,0fh          ;清空高四位
                add  al,30h          ;+30h
                cmp  al,39h          ;和39H比较
                jbe  htoascl         ;小于等于就跳出
                add  al,7h           ;否则+7后跳出
        htoascl:
                ret
htoasc endp
        ;----------------------------------------
code ends
    end     start
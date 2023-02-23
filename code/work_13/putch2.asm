;程序名称:
;功能:写一个程序采用十六进制数的形式显示所按键的扫描码及对应的ASCII码。
;当连续两次按回车键时，中止程序
;=======================================
assume      cs:code,ds:data
cr = 0dh        ;回车符
data segment
        lastInput db 0                      ;前一次的输入值
        buff      db 0,0,' ',0,0,24h        ;4个字节的缓冲区
        tmp       db ?
data ends

code segment
        start:  
                mov  ax,data               ;初始化数据段
                mov  ds,ax
        input:  
        ;输出到屏幕
                call newline
                MOV  lastInput,al
                mov  ah,0
                int  16h
                cmp  al,cr                 ;判断是否为回车符
                jz   check                 ;为回车符，检查程序是否完成
                MOV  tmp,al
                xchg al,ah
                call ahtoasc
                mov  buff[0],ah
                mov  buff[1],al
                mov  al,tmp
                call ahtoasc
                mov  buff[3],ah
                mov  buff[4],al
                mov  dx,offset buff
                mov  ah,9h
                int  21h
                jmp  input

        check:  
                cmp  lastInput,cr          ;是否为回车符
                MOV  lastInput,al
                jnz  input                 ;不是回车符，输入下一个字符
        over:   
                mov  ax,4c00h              ;dos中断
                int  21H
        ;----------------------------------------------
        ;子程序名：newline
        ;功能：形成回车和换行（光标移到下一行首)
        ;入口参数：无
        ;出口参数：无
        ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
                push ax
                push dx
                mov  dl,0dh                ;回车符的ASCII码
                mov  ah,2
        ;显示回车符
                int  21h
                mov  dl,0ah                ;换行符的ASCII码
                mov  ah,2
        ;显示换行符
                int  21h
                pop  dx
                pop  ax
                ret
newline endp
        ;----------------------------------------------
        ;子程序名称:ahtoasc
        ;功能:把8位二进制数转换为2位十六进制数的ASCII
        ;入口参数:AL=欲转换的8位二进制数
        ;出口参数:AH=十六进制数高位的ASCII码,AL=十六进制数低位的ASCII码
        ;其他说明:1.近过程，2.除AX寄存器外，不影响其他寄存器3.调用了htoasc实现十六进制到ASCII码转换
        ;=======================================
ahtoasc PROC
                mov  ah,al                 ;al复制到ah
                shr  al,1                  ;AL右移4位
                shr  al,1
                shr  al,1
                shr  al,1
                call htoasc                ;调用子程序
                xchg ah,al                 ;al,ah对调
                call htoasc                ;调用子程序
                RET
ahtoasc ENDP
        ;子程序名称:htoasc
        ;功能:一位十六进制数转换为ASCII
        ;入口参数:al=待转换的十六进制数,ds:bx=存放转换得到的ASCII码串的缓冲区首地址
        ;出口参数:出口参数：al=转换后的ASCII
        ;其他说明:无
        ;=======================================
htoasc PROC
                and  al,0fh                ;清空高四位
                add  al,30h                ;+30h
                cmp  al,39h                ;小于等于39H
                jbe  htoascl               ;
                add  al , 7h               ;+7H
        htoascl:
                ret
htoasc ENDP
code ends
    end     start
;程序名称:
;功能:把8位二进制数转换为2位十六进制数的ASCII码
;=======================================
assume      cs:code,ds:data

data segment
    num  db 12h         ;需要转16位的二进制数
    buff db 2 dup(?)    ;预留的16位槽位
         db '$'
data ends

code segment
    start:  
            mov  ax,data           ;初始化数据段
            mov  ds,ax

            mov  al,num            ;用al传参
            mov  bx,offset buff    ;用bx传参

            call ahtoasc           ;调用子程序

            mov  buff,ah           ;用ax传出口参数
            mov  buff+1,al         ;用ax传出口参数

            mov  dx,offset buff    ;打印输出
            mov  ah,9
            int  21h

            mov  ax,4c00h          ;dos中断
            int  21H
    ;子程序名称:ahtoasc
    ;功能:把8位二进制数转换为2位十六进制数的ASCII
    ;入口参数:AL=欲转换的8位二进制数
    ;出口参数:AH=十六进制数高位的ASCII码,AL=十六进制数低位的ASCII码
    ;其他说明:1.近过程，2.除AX寄存器外，不影响其他寄存器3.调用了htoasc实现十六进制到ASCII码转换
    ;=======================================
ahtoasc PROC
            mov  ah,al             ;al复制到ah
            shr  al,1              ;AL右移4位
            shr  al,1
            shr  al,1
            shr  al,1
            call htoasc            ;调用子程序
            xchg ah,al             ;al,ah对调
            call htoasc            ;调用子程序
            RET
ahtoasc ENDP
    ;子程序名称:htoasc
    ;功能:一位十六进制数转换为ASCII
    ;入口参数:al=待转换的十六进制数,ds:bx=存放转换得到的ASCII码串的缓冲区首地址
    ;出口参数:出口参数：al=转换后的ASCII
    ;其他说明:无
    ;=======================================
htoasc PROC
            and  al,0fh            ;清空高四位
            add  al,30h            ;+30h
            cmp  al,39h            ;小于等于39H
            jbe  htoascl           ;
            add  al , 7h           ;+7H
    htoascl:
            ret
htoasc ENDP
code ends
    end     start
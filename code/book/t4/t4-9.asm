;程序名称:
;功能:写一个测量字符串长度的子程序
;=======================================
assume      cs:code,ds:data
stack segment
              db 16 dup(0)        ;自定义栈，16个字节
stack ends
data segment
        strmess db 'reqrew323',0,24h        ;需要测量的字符创
        len     dw ?                        ;存值预留的槽位
data ends

code segment
        start:  
                mov  ax,stack                   ;初始化堆栈段
                mov  ss,ax
                mov  sp,16                      ;初始化栈顶指针sp

                mov  ax,data                    ;初始化数据段
                mov  ds,ax

                mov  si,offset strmess          ;堆栈传参
                push ds
                push si
                call strlen                     ;调用子程序
                add  sp,4                       ;组程序负责堆栈平衡
                mov  len,ax                     ;结果放到变量中

                mov  ax,4c00h                   ;dos中断
                int  21H
        ;功能：测量字符串的长度
        ;入口参数：字符串起始地址的段值和偏移值在堆栈中
        ;出口参数：AX=字符串的长度
        ;说明：堆栈如下
        ;       |       |ffff
        ;BP     |DS     |BP+6
        ;       |SI     |BP+4
        ;SP     |IP     |BP+2
        ;BP=SP  |BP     |
        ;       |DS     |
        ;       |SI     |
        ;       |       |0000
strlen proc
                push bp                         ;构建堆栈框架，堆栈图如下
                mov  bp,sp
        ;保护寄存器
                push ds
                push si
        ;取入口参数
                mov  ds,[bp+6]                  ;数据段的段值
                mov  si,[bp+4]                  ;数据段的偏移
                mov  al,0
        strlenl:
                cmp  byte ptr ds:[si],al
                jz   strlen2                    ;看有咩有结束
                inc  si                         ;没有结束，处理下一个字符si+1
                jmp  strlenl
        strlen2:
                mov  ax,si                      ;将计算出的si放入到ax中
                sub  ax,[bp+4]                  ;减去si的初始值
        ;恢复寄存器
                pop  si
                pop  ds
        ;mov sp,bp
                pop  bp
                ret
strlen endp
code ends
    end     start
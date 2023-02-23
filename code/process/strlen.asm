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
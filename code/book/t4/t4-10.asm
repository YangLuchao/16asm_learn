;程序名：t4-10.asm
;例6:写一个字符串中的大写字母改写为小写字母的子程序（近过程）
;设字符串以0结尾。CALL后续去传递字符串的起始地址的段值和偏移
assume cs:code,ds:data

data segment
    message db "HELLO WELCOME TO ASM!", 0dh, 0ah, 0,'$'
data ends

code segment
    start:  
            mov  ax,data              ;初始化代码段
            mov  ds,ax

            call strlwr               ;call 后传参
            dw   offset message
            dw   seg message

            mov  dx,offset message    ;打印
            mov  ah,09h
            int  21h

            mov  ax,4c00h
            int  21h
    ;子程序名：strlwr
    ;功能：把字符串中的大写字母改写小写字母
    ;入口参数：字符串的起始地址的段值和偏移在CALL后续区
    ;出口参数：无
strlwr proc
            push bp                   ;构建堆栈框架
            mov  bp,sp
    ;保护寄存器
            push ax
            push si
            push ds
    ;call strlwr
    ;dw   offset message       ;message的偏移
    ;dw   seg message          ;message的段值
    ;编译器编译后为：
    ;cs地址  硬编码   反编译的汇编代码
    ;0000   E81000  call 0018(strlwr)
    ;0008   0000
    ;000a   6a
    ;000b   07
    ;call strlwr 将0000压入堆栈
    ;后续再使用
    ;mov si,[bp+2] bp+2是call 后第一条指令的地址 所以[bp+2]=0008
    ;si=cs:[0008]
    ;取段值：mov ds,cs:[si+2] -> cs:[0008+2=000a]=076a ds=076a
    ;取偏移：mov si,cs:[si] ->	cs:[0008]=0000 si=0000
    ;后续返回
            add  word ptr [bp+2],4    ;[bp+2]=0008+4=000c
            mov  si,[bp+2]
            mov  ds,cs:[si+2]         ;取入口参数-段值
            mov  si,cs:[si]
    ;大写切小写
    strlwr1:
            mov  al,[si]
            cmp  al,'$'
            jz   strlwr3
            cmp  al,'A'
            jb   strlwr2
            cmp  al,'Z'
            ja   strlwr2
            add  al,'a'-'A'
            mov  [si],al
    strlwr2:
            inc  si
            jmp  strlwr1
    strlwr3:
            add  word ptr [bp+2],4    ;修改返回 执行mov dx,offset message
    ;弹出寄存器
            pop  ds
            pop  si
            pop  ax
    ;销毁堆栈架构
            pop  bp
            ret
strlwr endp
code ends
    end     start
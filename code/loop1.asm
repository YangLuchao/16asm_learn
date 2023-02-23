;程序名称:loop1.asm
;功能:查找第一个非'A'字符，找到后-BX保存该字符的偏移地址，找不到BX=0FFFFH，并输出
;=======================================
assume      cs:code,ds:data

data segment
    buff  db 'AXsdadas','$'    ;定义需要处理的数据
    A     db 41H               ;A字符的ASCII码
    dor   db 24H               ;$字符的ASCII码
    flag1 db '0FFFFH','$'      ;没有找到标识
data ends

code segment
    start:  
            mov ax,data            ;初始化代码段
            mov ds,ax

    ;循环buff 取出每一个字段与A变量对比
    ;相同继续循环，不同跳出循环，需要记录指针的位置
    ;循环到与$符号相同的字段，指针修改为0FFFFH
    ;打印出字段
    ;退出程序
            mov si,0               ;变址寄存器
            
    next:   
            xor ax,ax              ;ax清空
            mov ah,dor             ;$存入AH中
            MOV AL,buff[si]        ;要判断的值放入到AL中
            cmp al,ah              ;al和AH对比
            jz  notFind            ;相等，执行完成，没有找到
            cmp al,A               ;对比A字符和AL中的字符
            jnz find               ;相等，跳到find标号，不等，继续执行
            inc si                 ;变址寄存器加1
            jmp next               ;跳入下一次循环

    find:   
            mov dx,si
            mov ah,9H
            int 21H
            jmp over
    notFind:
            MOV dx,offset flag1
            mov ah,9H
            int 21H
            jmp over
    over:   
            mov ax,4c00h           ;dos中断
            int 21H
code ends
    end     start
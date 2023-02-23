;程序名称:
;功能:编写一个把字符串中的小写字母转换为大写（字符串以0结尾）的远过程
;=======================================
assume      cs:code,ds:data

data segment
    source db 'qwertyuiopasdfghjklzxcvbnm1234567890',0,'$'    ;源数据
data ends

code segment
    start:  
            mov   ax,data             ;初始化数据段
            mov   ds,ax

            mov   si,offset source

    ;作为参数压入栈
            push  ds
            push  si

            call  far PTR lowToUp

            mov   dx,offset source
            mov   ah,9
            int   21h

            mov   ax,4c00h            ;dos中断
            int   21H

lowToUp PROC far
            push  bp                  ;保存主程序栈基址
            MOV   bp,sp               ;将当前栈顶作为栈底，建立堆栈框架
    ;保护寄存器
            push  ds
            push  si
            push  cx
            push  ax
    ;==================子程序代码开始==============
            mov   ds,[bp+8]           ;预留槽位的位置
            mov   si,[bp+6]

    ;计算字符串长度
            cld                       ;df置0，递增
    next:   
            LODSB
            cmp   al,0
            jz    over
            cmp   al,'a'
            jb    over
            cmp   al,'z'
            ja    over
            sub   al,20h
            MOV   [SI-1],AL           ;注意指针已被调整
            jmp   next
    ;==================子程序代码结束==============
    over:   
            pop   ax
            pop   cx
            pop   si
            pop   ds
            pop   BP
            RET   4                   ;堆栈平衡由子程序完成
lowToUp ENDP
code ends
    end     start
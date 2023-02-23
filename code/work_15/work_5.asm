;6.1.1字符串操作指令LODS
;程序名：t6-1.asm
;功能：字符串中的大写字母转换为小写字母（字符以0结尾）
;子程序：strlwr
;作业：改写上节视频例1和例2，通过堆栈传递入口参数
assume cs:code,ds:data
data segment
        strl db 'TFhlltVDhkHH',0,'$'
data ends
code segment
        start:  
                mov   ax,data
                mov   ds,ax
                mov   si,offset strl

                PUSH  ds
                PUSH  si

                call  far PTR strlwr

                mov   dx,offset strl
                mov   ah,9
                int   21h

                mov   ax,4c00h
                int   21h
        ;子程序名：strlwr
        ;功能：字符串中的大写字母转换为小写字母（字符以0结尾）
        ;入口参数：DS:SI=字符串首地址的段值：偏移
        ;出口参数：无
strlwr proc far
                push  bp                    ;保存主程序栈基址
                MOV   bp,sp                 ;将当前栈顶作为栈底，建立堆栈框架
        ;保护寄存器
                push  ds
                push  si
                push  cx
                push  ax
        ;==================子程序代码开始==============
                mov   ds,[bp+8]             ;预留槽位的位置
                mov   si,[bp+6]
            
                cld                         ;清方向位
                jmp   short strlwr2
        strlwr1:
                sub   al,'A'
                cmp   al,'Z'-'A'
                ja    strlwr2
                add   al,'a'
                mov   [si-1],al             ;注意调整指针
        strlwr2:
                lodsb                       ;取一字符，同时调整指针
                and   al,al                 ;判断是否0结尾
                jnz   strlwr1
       
                pop   ax
                pop   cx
                pop   si
                pop   ds
                pop   BP
                RET   4                     ;堆栈平衡由子程序完成
strlwr endp

code ends
end start
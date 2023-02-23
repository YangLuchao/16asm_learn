;程序名称:
;功能:写一个优化的程序片段，统计字符串的长度，设字符串以0结尾
;=======================================
assume      cs:code,ds:data

data segment
    string db 'abcdef','0'    ;要查找的字符串
    ASCII  DB ?,'$'           ;存放对应的 ASCII码
data ends
;拿出每一个字段，和0对比，不同，拿出下一个字段，相同计数器加1，输出计数器
;0的ASCII码值为：30H
code segment
    start: 
           mov ax,data            ;初始化数据段
           mov ds,ax

           mov si,0               ;准备工作，计数器置0
           MOV AL,30H             ;准备0的ASCII码
    next:  
           cmp al,string[si]
           jz  change             ;16位转ASCII码
           inc si
           jmp next               ;没有找到0，继续查找
        
    change:                       ;将16进制转为10进制
           inc si                 ;要输出的长度，所以要加1
           mov ax,si              ;将si的值移动到ax中
           AND AL,0fh             ;确保在0至F之间 将高4位清0
           CMP AL,9               ;和9对比，
           JG  LAB1               ;大于9，跳
           ADD AL,30H             ;小于等于9，加30H转ASCII码
           JMP LAB2               ;跳转，将值放到变量中
    LAB1:  ADD AL,37H             ;大于9，加37H转ASCII码
    LAB2:  MOV ASCII,AL           ;代码复用，将值放到变量中
        
           mov dx,offset ASCII    ;打印输出
           mov ah,9
           int 21H
           
           mov ax,4c00h           ;dos中断
           int 21H
code ends
    end     start
;程序名称:
;功能: 写一个程序，滤去某个字符串中的空格符号（ASSCII码20h），字符串0结尾
;=======================================
assume      cs:code,ds:data

data segment
    string db 's d s sds dgdf ghgj rt sdf','0'    ;需要处理的字符串
    blank  db 20H                                 ;空格的ASCII码
    zore   db 30H                                 ;0的ASCII码
data ends
;拿出每一个字符
;判断是否等于0，相等，跳到打印，不等继续执行
;判断是否与20H相等
;不等，拿出下一个字符对比
;相等，该字符后的每一个字符的位置-1
code segment
    start: 
           mov  ax,data             ;初始化数据段
           mov  ds,ax

           mov  si,-1               ;准备，变址寄存器置0
           mov  al,blank            ;空格的ASCII码放到AL中
           mov  ah,zore             ;0的ASCII码放入AH中

    next:  
           inc  si                  ;变址寄存器加1
           CMP  ah,string[si]       ;和0对比
           jz   print               ;相同，跳到打印
           cmp  al,string[si]       ;和空格对比
           jnz  next                ;不同，对比下一个字符
           push si                  ;暂存si
           jmp  remove              ;相同，将空格remove掉
           

    remove:
           inc  si
           xor  bx,bx               ;将bx清空
           mov  bl,string[si]       ;将下一个值放到bl中
           MOV  string[si-1],bl     ;暂存的值替换掉string中的空格
           xor  bx,bx               ;将bx清空
           MOV  bl,string[si]       ;当前字符挪到bl中
           cmp  bl,zore             ;看有没有到结尾
           jnz  remove              ;没有到结尾，继续处理下一个字符
           mov  bh,24H              ;最后置$
           MOV  string[si],bh       ;到结尾了，将下一个字符置0
           pop  si                  ;处理完，弹出si
           JMP  next
          
    print: 
           mov  dx,offset string    ;打印输出
           mov  ah,9
           int  21H

           mov  ax,4c00h            ;dos中断
           int  21H
code ends
    end     start
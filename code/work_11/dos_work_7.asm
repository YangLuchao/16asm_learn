;程序名称:
;功能:先从键盘上输入一个较长的字符串和一个较短的字符串，字符串以$结尾，
;然后判断较短的字符串是否是较长字符串的子串，最后显示提示信息说明判断结果
;=======================================
assume      cs:code,ds:data
;常量定义
mlength = 128
data segment
    str1      db mlength           ;缓冲区最大长度
              db ?                 ;字符串实际长度，出口参数之一
              db mlength dup(0)    ;符合0AH号功能调用所需的缓冲区
    str2      db mlength           ;缓冲区最大长度
              db ?                 ;字符串实际长度，出口参数之一
              db mlength dup(0)    ;符合0AH号功能调用所需的缓冲区
    child_len db ?                 ;子串长度，要与指针对比，所以减1
    flag      db 0                 ;默认为不存在标识
data ends

code segment
    start:     
               mov  ax,data           ;初始化数据段
               mov  ds,ax

    ;输入长字符串
               mov  ah,0ah            ;DOS十号功能，接受一个字符串，回车键结束
               mov  dx,offset str1    ;入口参数，缓冲区首地址，存放缓冲区最大容量
               int  21h               ;输出提示
               call newline           ;新换一行

    ;输入短字符串
               mov  ah,0ah            ;DOS十号功能，接受一个字符串，回车键结束
               mov  dx,offset str2    ;入口参数，缓冲区首地址，存放缓冲区最大容量
               int  21h               ;输出提示
               xor  ax,ax
               mov  al,str2[1]
               xchg child_len,al      ;保存子串长度
               call newline           ;新换一行

    ;准备
               MOV  si,1              ;si指向字符串
               mov  di,1              ;di指向子串
    
    loop1:     
               inc  si                ;si+1
               inc  di                ;di+1
               cmp  str1[si],0dh      ;判断字符串是否遍历完成
               jz   display           ;字符串遍历完成，退出
               mov  ah,str1[si]       ;分别放入AL，AH中
               mov  al,str2[di]
               cmp  ah,al             ;比较
               jnz  no                ;不相等，跳
               xor  dx,dx
               add  dl,child_len
               cmp  di,dx             ;相等，di与子串长度对比
               jz   child_over        ;相等子串已匹配到
               jmp  loop1             ;子串还没有匹配完成
               
    no:        
               mov  di,-1             ;di初始化为-1，下次循环加上去
               jmp  loop1             ;跳到循环开始
    child_over:
               mov  al,1              ;相等子串已匹配到
               mov  flag,al           ;将标匹配识置为1

    display:   
               cmp  al,1
               jnz  over
               mov  al,31H
               call putch

    over:      
               mov  ax,4c00h          ;dos中断
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
               mov  dl,0dh            ;回车符的ASCII码
               mov  ah,2
    ;显示回车符
               int  21h
               mov  dl,0ah            ;换行符的ASCII码
               mov  ah,2
    ;显示换行符
               int  21h
               pop  dx
               pop  ax
               ret
newline endp
    ;----------------------------------------------
    ;-----------------------------
    ;显示一个字符
    ;入口参数：al
    ;出口参数：标志输出设备
putch PROC
               PUSH DX
               MOV  DL,AL
               MOV  AH,2
               INT  21H
               POP  DX
               RET
putch ENDP
    ;-----------------------------
code ends
    end     start
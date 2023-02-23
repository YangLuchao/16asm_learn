;程序名称:
;功能:先从键盘上输入一个字符串，然后再在另一行相反顺序显示该字符串
;=======================================
assume      cs:code,ds:data
;常量定义
cr = 0dh          ;回车符 
mlength = 128     ;缓冲区预定义长度
data segment
      buff db mlength             ;缓冲区最大长度
           db ?                   ;字符串实际长度，出口参数之一
           db mlength dup(0)      ;符合0AH号功能调用所需的缓冲区
data ends

code segment
      start:  
              mov  ax,data             ;初始化数据段
              mov  ds,ax
      ;数据准备
              mov  ah,0ah              ;DOS十号功能，接受一个字符串，回车键结束
              mov  dx,offset buff      ;入口参数，缓冲区首地址，存放缓冲区最大容量
              int  21h                 ;输出提示

              call newline             ;新换一行

              xor  ax,ax
              mov  al,buff[1]          ;字符串长度放入变址寄存器中
              add  ax,1
              mov  si,ax               ;字符串实际起始地址3
      
      dispal: 
              MOV  AL,buff[si]         ;准备入口参数
              dec  si                  ;si-1
              cmp  si,0                ;si=0字符串反向读完
              jz   over                ;结束
              call putch               ;输出
              jmp  dispal              ;处理下一个字符串


      over:   
              mov  ax,4c00h            ;dos中断
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
              mov  dl,0dh              ;回车符的ASCII码
              mov  ah,2
      ;显示回车符
              int  21h
              mov  dl,0ah              ;换行符的ASCII码
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
code ends
    end     start
;程序名称:
;功能:写一个程序在屏幕上依次循环显示10个数字符号，每行显示13个。最初所显示的两行如下所示
;0 1 2 3 4 5 6 7 8 9 0 1 2
;3 4 5 6 7 8 9 0 1 2 3 4 5
;=======================================
assume      cs:code,ds:data

data segment
    val  db '0 1 2 3 4 5 6 7 8 9 0 1 2',0ah
         db '3 4 5 6 7 8 9 0 1 2 3 4 5',0
data ends

code segment
    start:
          mov  ax,data       ;初始化数据段
          mov  ds,ax
    ;数据准备
          mov  si,-1         ;初始化变址寄存器

    next: 
          inc  si            ;si+1
          mov  al,val[si]    ;准备入口参数
          cmp  al,0          ;判断字符串有没有读完
          jz   over          ;读完了，退出
          call putch         ;没有读完，输出每个字符串
          jmp  next          ;处理下一个字符串

    over: 
          mov  ax,4c00h      ;dos中断
          int  21H
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
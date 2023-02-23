;程序名称:
;功能:设计一个以ASCII码表示的十进制数字串转换为二进制数的子程序。
;设表示的十进制数不大于65535。
;=======================================
assume      cs:code,ds:data

data segment
    buff   db 5,"65535"    ;准备的二进制数
    result dw ?
data ends

code segment
    start:  
            mov  ax,data           ;初始化数据段
            mov  ds,ax

            MOV  BX,OFFSET BUFF    ;bx传入口参数
            call dtobin
            mov  result,ax         ;ax传出口参数

            mov  ax,4c00h          ;dos中断
            int  21H
    ;功能：把用ASCII码表示的十进制数字串转换为二进制数
    ;入口参数：DS:BX=缓冲区首地址，第一个字节为十进制数字串长度！
    ;出口参数：AX=转换得到的二进制数
    ;算法：迭代法y=y*10+x,y初始值为0
dtobin proc
            push bx                ;保护寄存器
            push cx
            push dx
            xor  ax,ax             ;ax清空
            mov  cl,[bx]           ;循环次数
            xor  ch,ch             ;cx=n
            inc  bx                ;inc+1
            jcxz dtobin2           ;cx=0 子程序完成
    dtobin1:
            mov  dx,10             ;乘数准备
            mul  dx                ;ax=Y*10
            mov  dl,[bx]           ;取下一个数字符
            inc  bx                ;bx+1
            and  dl,0fh            ;清空高4位
            xor  dh,dh             ;dh清空
            add  ax,dx             ;ax+x
            Loop dtobin1           ;计算下一个数
    dtobin2:
            pop  dx
            pop  cx
            pop  bx
            ret
dtobin endp
code ends
    end     start
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
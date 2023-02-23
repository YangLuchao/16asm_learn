;程序名称:
;功能:把寄存器AL和BL中的位依次交叉，得到的16位结果存放在DX寄存器中。
;=======================================
assume      cs:code
;AL，BL均有8位，循环八次，每次循环将al,bl分别右移一位，并dx依次右移两位
code segment
    start:
          mov  ax,code     ;初始化数据段
          mov  ds,ax

          mov  al,61H      ;a挪到al中
          mov  bl,62H      ;b挪到bl中
          MOV  cx,8        ;初始化

    next: 
          ror  al,1        ;al右移一位到cf
          ror  dx,1        ;cf中的一位移到dx中
          ror  bl,1        ;bl右移一位到cf
          ror  dx,1        ;cf中的一位移到DX中
          loop next

          mov  ax,4c00h    ;dos中断
          int  21H
code ends
    end     start
;程序名称:
;功能:依次重复寄存器AL中的每一位，得到16位的结果存放到DX寄存器中
;=======================================
assume      cs:code,ds:data

data segment
    val  db 11h    ;预定义AL中的数据 11h = 0001 0001，重复后，dx中的数据应该0000 0011 0000 0011
data ends

code segment
    start:
          mov  ax,data     ;初始化数据段
          mov  ds,ax
    ;一共8位，循环8次，每次位移1位到CF位，CF位中取出，再移回来，再移到CF位中，在冲CF中取出放入dx中
          mov  cx,8        ;初始化计数器
          mov  al,val      ;初始化AL的值
    next: 
          ror  al,1        ;将最后一位移入CF
          rcr  dx,1        ;将CF的值移入到dx
          rol  al,1        ;复原
          ror  al,1        ;将最后一位移入CF
          rcr  dx,1        ;将CF的值移入到dx
          loop next

          mov  ax,4c00h    ;dos中断
          int  21H
code ends
    end     start
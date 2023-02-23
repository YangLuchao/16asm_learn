;程序名称: add.asm
;功能:计算1234:5678H开始的内存中100个16位无符号整数的和
;注意有进位，结果保存到dx:ax，或者result中
;执行流程：
    ;1:定位数据段 ax,1234H
    ;2:偏移起始地址5678H
    ;3:cx作为计数器，初始100
    ;3.1:清空cf
    ;4:si为变址寄存器,每次执行-2
    ;5:ax为规约累加器
    ;6:dx保存进位
    ;6.1:每次执行，计数器减1
    ;7:结果保存到result中
;======================
assume      cs:code,ds:data

data segment
      result dd ?
data ends

code segment
      start:
      ;
      ;1:定位数据段
            mov ax,1234H
            mov ds,ax
      ;2：偏移地址5678H
            mov si,5678H
      ;准备
      ;3：cx作为计数器
            mov cx,100
            XOR dx,dx
            mov ax,0
      ;3.1:清空cf
            clc
      next: 
      ;5:累加
            add ax,word ptr ds:[si]
      ;6:进位保存到dx中
            adc dx,0
            inc si
            inc si
      ;6.1：计数器减一
            DEC cx
            jnz next

      ;跳出循环
      ;还原数据段地址
            MOV bx,data
            mov ds,bx
      ;7:结果存到result中
            mov word ptr ds:[result],ax
            mov word ptr ds:[result+2],dx

      ;结束
            mov AH,4ch
            int 21h
code ends
    end     start
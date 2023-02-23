;程序名称:loop.asm
;功能:十六进制数转为ASCII输出
;=======================================
assume      cs:code,ds:data
data segment
      val    dw 1234h
      result db ?,?,?,?,'H','$'
data ends

code segment
      start:
            mov  ax,data               ;初始化数据段
            mov  ds,ax
      ;
      ;1:将val放入AX中
      ;2:4个数字，循环4次，定义CX =4
      ;3:每次循环将将AX 复制到BX中
      ;4:拿到bl的值，用bl的与掩码0fh做与运算，清空高4位
      ;5:bl再加30h得到ASCII码对应的值
      ;6:填充到result中
      ;7:si-1
      ;准备工作
            mov  ax,val                ;数据
            mov  cx,4                  ;初始化计数器
            mov  si,3                  ;初始化变址寄存器
      next: 
            MOV  bx,ax                 ;将AX保存到BX中
            and  bl,0fh                ;将BL与0f做与操作，清空高4位 ，bl = 0011 0100 and 0f = 0000 1111 = 0000 0100 = 4
            add  bl,30h                ;转ASCII码

            MOV  result[si],bl         ;计算结果填充到result中
            DEC  si                    ;si变址寄存器-1
            push cx                    ;占存cx
            mov  cl,4                  ;为左移做准备
            shr  ax,cl                 ;右移4位
            pop  cx                    ;还原cx
            loop next                  ;计数器减1，判断CX是否为0，不为0继续循环
        
            xor  ax,ax
            mov  ah,09H                ;打印
            mov  dx,offset result
            int  21H

            mov  ax,4c00h              ;dos中断
            int  21H
code ends
    end     start
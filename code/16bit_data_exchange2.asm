;程序名称:
;功能:次重复四次寄存器AL中的每一位，得到32位的结果存放dx:ax寄存器中
;=======================================
assume      cs:code,ds:data

data segment
      val  db 55h      ;预定义AL中的数据 55h = 0101 0101，重复后，dx中的数据应该为：0000 1111 0000 1111 0000 1111 0000 1111 :ax=0f0f dx=0f0f
data ends

code segment
      start:
            mov  ax,data       ;初始化数据段
            mov  ds,ax
      ;每一位重复4次，一共8位，两层循环，分两次循环
      ;第一次、第二次分别第一层循环4次,第二层循环4次
      ;每次二层每次循环 循环右移1位到cf,将CF带位右移到ax中
      ;第一次两层循环将ax16位占满
      ;第二次两次循环将dx16位占满
            mov  bl,val        ;变量保存到BX中
      ;第一次两层循环
            xor  cx,cx
            mov  cx,4          ;循环4次的计数器
            xor  ax,ax         ;ax清空
      ;第一次第一层循环
      next1:
            push cx            ;外围循环计数器保护起来
            xor  cx,cx
            mov  cx,4          ;内层循环计数器
            jmp  next2
      next6:
            shr  bx,1          ;右移1位,将已处理的那一位挪走
            pop  cx
            loop next1
            jmp  next3         ;无条件跳到第二次循环处
      ;第一次第二层循环
      next2:
            ror  bx,1          ;循环右移1位
            rcr  ax,1          ;带位循环一位
            rol  bx,1          ;循环左移1位，复原
            loop next2
            JMP  next6         ;强制调回next6

      ;第二次两层循环
      next3:
            xor  cx,cx
            mov  cx,4
            XOR  dx,dx         ;dx清空
      ;第二次第一层循环
      next4:
            push cx            ;外围循环计数器保护起来
            xor  cx,cx
            mov  cx,4          ;内层循环计数器
            jmp  next5
      next7:
            shr  bx,1          ;右移1位,将已处理的那一位挪走
            pop  cx
            loop next4
            jmp  over          ;无条件跳到over
      ;第二次第二层循环
      next5:
            ror  bx,1          ;循环右移1位
            rcr  dx,1          ;带位循环一位
            rol  bx,1          ;循环左移1位，复原
            loop next5
            jmp  next7         ;强制调回next7
      over: 
            mov  ax,4c00h      ;dos中断
            int  21H
code ends
    end     start
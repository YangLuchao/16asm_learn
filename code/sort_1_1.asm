;程序名称:
;功能:功能：实现3个无符号数由小到大排序。
;算法：3个无符号数两两比较，比较3次。
;a->b a->c b->c
;程序结构：分支结构。
;方法一：使用3个寄存器进行比较
;=======================================
assume      cs:code,ds:data

data segment
      vals db 3,2,1      ;需要比较的三个数
data ends

code segment
      start:
            mov  ax,data         ;初始化数据段
            mov  ds,ax

      ;准备
            xor  ax,ax
            xor  bx,bx
            xor  dx,dx
            MOV  al,vals[0]      ;第一个数放到vals中
            MOV  bl,vals[1]      ;第二个数放到vals中
            MOV  dl,vals[2]      ;第三个数放到vals中
      ;第一次比较
            cmp  ax,bx           ;第一个数和第二个数对比
            jb   cmp2            ;ax大于bx,交换
            xchg ax,bx           ;交换
      ;第二次比较
      cmp2: 
            cmp  ax,dx           ;第一个数和第三个数比较
            jb   cmp3            ;将第一个数和第三个数交换
            xchg ax,dx           ;交换
      cmp3: 
            cmp  bx,dx           ;第二个数和第三个数比较
            jb   over            ;将第二个和第三个数交换
            xchg bx,dx           ;交换
      over: 
            mov  ax,4c00h        ;dos中断
            int  21H
code ends
    end     start
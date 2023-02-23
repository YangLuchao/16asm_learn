;程序名称:
;功能:实现3个无符号数由小到大排序。
;算法：3个无符号数两两比较，比较3次。
;程序结构：分支结构。
;方法二：使用1个寄存器进行比较
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
            xor  ax,ax           ;清空AX
            mov  al,vals[0]      ;第一个数放al
      ;第一次比较
            cmp  al,vals[1]
            jb   cmp_2
            xchg ah,vals[1]
            xchg al,vals[1]
            xchg ah,vals[0]
      ;第二次比较
      cmp_2:
            cmp  al,ah
            ja   xchg2
          

      over: 
            mov  ax,4c00h        ;dos中断
            int  21H
code ends
    end     start
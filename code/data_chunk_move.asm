;程序名称:
;功能: 请写一个实现数据块移动的示例程序
;=======================================
assume      cs:code,ds:data

data segment
    chunk1 db 'ab'          ;需要被移动的数据块
    len    =  $-chunk1      ;需要被移动的数据块的长度
    chunk2 db len dup(0)    ;预留的内存块
data ends
;循环处理数据块的每一个数据，将数据移动到预留的内存地址
;数据挪动后，旧地址的值置零
code segment
    start:
          mov  ax,data          ;初始化数据段
          mov  ds,ax

          mov  si,-1            ;初始化变址寄存器
          mov  cx,len           ;初始化计数器
          XOR  Ax,ax            ;清空ax
        
    next: 
          inc  si               ;si+1
          mov  al,chunk1[si]    ;数据挪到AL中
          MOV  chunk2[si],al    ;移动到新地址
          MOV  chunk1[si],ah    ;就内存清空
          loop next

          mov  ax,4c00h         ;dos中断
          int  21H
code ends
    end     start
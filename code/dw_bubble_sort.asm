;程序名称:
;功能:设从地址F000:000H开始的内存区域是缓冲区，存放一组单字节的正数或者负数，以0结尾，
;请编写一个程序确定其中最大的正数和最小的负数。
;优化例7排序程序，设buffer缓冲区中有10个单字节无符号数整数，写一个程序将它们由小到大排序，假设10个数据：23,12,45,32,127,3,9,58,81,72
;=======================================
assume      cs:code,ds:data
;排序
;冒泡排序，从小到大排序
;外层循环，循环len-1次，指针i
;内层循环，每次循环len-1-i次,指针j
;内层循环，每次拿[j]和[j+1]进行对比
;[j]>[j+1],[j]与[j+1]的值进行交换
;完成排序
data segment
    vals dw 23,12,45,32,127,3,9,58,81,72,-1    ;准备的有符号数，两正两负
    len  dw 0                                  ;数据长度
data ends

code segment
    start:         
                   mov  ax,data           ;初始化数据段
                   mov  ds,ax

                   mov  si,-2             ;初始化变址寄存器
                   mov  dx,0              ;初始化

    ;数据长度计算
    count_len:     
                   mov  len,dx
                   inc  si                ;si+1
                   inc  si                ;si+1
                   xor  ax,ax             ;ax清空
                   cmp  ax,vals[si]       ;值和0对比
                   jz   len_count_over    ;等于0，跳出长度计数
                   inc  dx
                   jmp  count_len         ;跳回循环入口

    ;数据长度计算完成
    len_count_over:
                   mov  ax,len
                   sub  ax,1
                   mov  len,ax
                   mov  si,-1             ;外层循环指针
    ;外层循环
    loop1:         
                   inc  si                ;外层循环指针+1
                   cmp  si,len            ;判断是否循环完成
                   jnb  over
                   mov  di,-1             ;初始化内层指针
    ;内层循环
    loop2:         
                   inc  di                ;内层循环指针+1
                   mov  ax,len
                   sub  ax,si
                   cmp  di,ax             ;判断内层循环是否完成
                   jnb  loop1             ;继续外层循环
                   mov  bx,di
                   add  bx,bx
                   MOV  ax,vals[bx]       ;di处的值放入ax中
                   MOV  dx,vals[bx][2]    ;di+1处的值放入dx中
                   cmp  ax,dx             ;比大小
                   jnl  swap              ;ax>dx,两个值交换
                   jmp  loop2             ;继续内层循环
    ;数据交换
    swap:          
                   xchg ax,dx             ;ax与dx的值交换
                   mov  bx,di
                   add  bx,bx
                   MOV  vals[bx],ax       ;ax的值放回到变量中
                   MOV  vals[bx][2],dx    ;dx的值放回变量中
                   jmp  loop2             ;继续内层循环
    over:          
                   mov  ax,4c00h          ;dos中断
                   int  21H
code ends
    end     start
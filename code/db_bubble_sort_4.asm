;程序名称:
;功能:冒泡排序，方法4：外循环n-1，内循环n-1-di，前后两两比较,从大到小排序
;=======================================
assume      cs:code,ds:data
;排序
;冒泡排序，从大到小排序
;外层循环，循环len-1次，指针i
;内层循环，每次循环len-1-i次,指针j
;内层循环，每次拿[j]和[j+1]进行对比
;[j]>[j+1],[j]与[j+1]的值进行交换
;完成排序
data segment
      vals db -1,1,2        ;准备的有符号数，两正两负
      len  =  $-vals-1      ;len保存循环次数
data ends

code segment
      start:
            mov  ax,data              ;初始化数据段
            mov  ds,ax

      ;准备
            mov  si,-1                ;外层循环指针
      ;外层循环
      loop1:
            inc  si                   ;外层循环指针+1
            cmp  si,word ptr len      ;判断是否循环完成
            jnb  over
            mov  di,-1                ;初始化内层指针
      ;内层循环
      loop2:
            inc  di                   ;内层循环指针
            xor  ax,ax                ;清空ax
            mov  al,len
            sub  ax,si
            cmp  di,ax                ;判断内层循环是否完成
            jnb  loop1                ;继续外层循环
            MOV  al,vals[di]          ;di处的值放入ax中
            MOV  dl,vals[di][1]       ;di+1处的值放入dx中
            cmp  dl,al                ;比大小
            jnl  swap                 ;ax>dx,两个值交换
            jmp  loop2                ;继续内层循环
      ;数据交换
      swap: 
            xchg al,dl                ;ax与dx的值交换
            MOV  vals[di],al          ;ax的值放回到变量中
            MOV  vals[di][1],dl       ;dx的值放回变量中
            jmp  loop2                ;继续内层循环
      over: 
            mov  ax,4c00h             ;dos中断
            int  21H
code ends
    end     start
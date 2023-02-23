;程序名称:
;功能:冒泡排序，方法3：外循环n-1，内循环n-1-di，前后两两比较,内循环发现一次都没有交换，意味着排序完成
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
      vals       db 2,-1,1,3      ;准备的有符号数，两正两负
      len        =  $-vals-1      ;len保存循环次数
      xchg_count db 0             ;内层循环交换次数
data ends

code segment
      start:    
                mov  ax,data              ;初始化数据段
                mov  ds,ax

      ;准备
                xor  bx,bx
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
                jnb  xchg_zore            ;判断本次内层循环有咩有数据交换
                MOV  al,vals[di]          ;di处的值放入ax中
                MOV  dl,vals[di][1]       ;di+1处的值放入dx中
                cmp  al,dl                ;比大小
                jnl  swap                 ;ax>dx,两个值交换
                jmp  loop2                ;继续内层循环
      ;数据交换
      swap:     
                xchg al,dl                ;ax与dx的值交换
                MOV  vals[di],al          ;ax的值放回到变量中
                MOV  vals[di][1],dl       ;dx的值放回变量中
                MOV  al,xchg_count
                inc  al                   ;交换1次，+1
                mov  xchg_count,al
                jmp  loop2                ;继续内层循环

      xchg_zore:
                cmp  bl,xchg_count        ;上次内层循环次数位0，证明已排序完成
                jz   over
                mov  xchg_count,bl        ;交换次数计数器清0
                jmp  loop1                ;交换数不为0，证明还需要排序
      

      over:     
                mov  ax,4c00h             ;dos中断
                int  21H
code ends
    end     start
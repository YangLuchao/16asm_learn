;程序名称:
;功能:冒泡排序，方法2：外循环n-1，内循环n-1-si，前后两两比较
;要求该程序具有可重入性，并且至少使用一个安排在堆栈中的变量
;=======================================
assume      cs:code,ds:data
;排序
;冒泡排序，从x到小排序
;外层循环，循环len-1次，指针i
;内层循环，每次循环len-1-i次,指针j
;内层循环，每次拿[j]和[j+1]进行对比
;[j]>[j+1],[j]与[j+1]的值进行交换
;完成排序
data segment
      vals dw 6,5,4,3,2,1      ;
      len  =  $-vals-1         ;len保存循环次数
data ends

code segment
      start:     
                 mov  ax,data             ;初始化数据段
                 mov  ds,ax

                 mov  ax,len              ;循环次数放入ax寄存器
                 mov  bx,offset vals
                 call bubbleSort          ;调用子程序

      over:      
                 mov  ax,4c00h            ;dos中断
                 int  21H
      ;子程序名称:bubbleSort
      ;功能:选择排序
      ;入口参数:ax=循环次数，bx=需要排序的首地址
      ;出口参数:需要排序的数字已排序完成
      ;其他说明:
      ;bp-2存放循环次数
      ;bp-4存放外层循环指针si
      ;bp-6存放内层循环指针di
      ;=======================================
bubbleSort PROC
                 push bp                  ;保存主程序栈基址
                 MOV  bp,sp               ;将当前栈顶作为栈底，建立堆栈框架
      ;用bp寄存器作为堆栈的基址
      ;bp+2获取返回地址IP
      ;bp+4获取返回地址段值(CS)
      ;bp+6获取入口参数
      ;==================子程序代码开始==============
                 SUB  sp,6                ;预留2个字节的空间,作为局部变量的槽位
      ;
                 mov  [bp-2],ax           ;循环次数放入局部变量
                 mov  [bp-4],-2           ;bp-4存放外层循环指针
      ;暂存寄存器
                 push ax
                 push si
      ;外层循环
      loop1:     
                 add  [bp-4],2            ;外层循环指针+1
                 mov  ax,[bp-4]
                 cmp  ax,[bp-2]           ;判断是否循环完成
                 jnb  over
                 mov  [bp-6],-2           ;bp-6存放外层循环指针
      ;内层循环
      loop2:     
                 add  [bp-6],2            ;内层循环指针+1
                 mov  ax,[bp-2]
                 sub  ax,[bp-4]
                 cmp  [bp-6],ax           ;判断内层循环是否完成
                 jnb  loop1
                 mov  si,[bp-6]           ;继续外层循环
                 MOV  ax,[bx][si]         ;值放入ax中
                 cmp  ax,[bx][si][2]      ;di+1处的值放入dl中,比大小
                 jnl  swap                ;al>dl,两个值交换
                 jmp  loop2               ;继续内层循环
      ;数据交换
      swap:      
                 xchg [bx][si],ax         ;交换
                 xchg [bx][si][2],ax      ;
                 xchg [bx][si],ax         ;
                 jmp  loop2               ;继续内层循环
      ;弹出寄存器
                 push si
                 POP  AX
      ;==================子程序代码结束==============
                 MOV  sp,bp               ;释放定义的局部变量的空间(SUB sp,6)
                 pop  BP
                 RET
bubbleSort ENDP
code ends
    end     start
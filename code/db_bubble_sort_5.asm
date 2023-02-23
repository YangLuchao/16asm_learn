;程序名称:
;功能:冒泡排序，方法5：不用两两比较，第一位数和其余数比较，小就交换
;=======================================
assume      cs:code,ds:data
;排序
;手推算法;
;外层循环条件 si=0;si<len-1;si++
;内层循环条件 di=si+1;di<=len-1;di++
;算法：不用两两比较，第一位数和其余数比较，小就交换
;初始数据:       6,5,4,3,2,1
;si = 0 bi =1 	5,6,4,3,2,1
;si = 0 bi =2 	4,6,5,3,2,1
;si = 0 bi =3 	3,6,5,4,2,1
;si = 0 bi =4 	2,6,5,4,3,1
;si = 0 bi =5 	1,6,5,4,3,2
;si = 1 bi =2 	1,5,6,4,3,2
;si = 1 bi =3 	1,4,6,5,3,2
;si = 1 bi =4 	1,3,6,5,4,2
;si = 1 bi =5 	1,2,6,5,4,3
;si = 2 bi =3 	1,2,5,6,4,3
;si = 2 bi =4 	1,2,4,6,5,3
;si = 2 bi =5 	1,2,3,6,5,4
;si = 3 bi =4 	1,2,3,5,6,4
;si = 3 bi =5 	1,2,3,4,6,5
;si = 4 bi =5 	1,2,3,4,5,6
data segment
    vals db 2,1,-1      ;准备的有符号数，两正两负
    len  =  $-vals-1    ;len保存循环次数
data ends

code segment
    start:
          mov  ax,data            ;初始化数据段
          mov  ds,ax

    ;准备
          mov  si,-1              ;外层循环指针
    ;外层循环
    loop1:
          inc  si                 ;外层循环指针+1
          cmp  si,word ptr len    ;判断是否循环完成
          jnb  over
          mov  di,si              ;初始化内层指针
    ;内层循环
    loop2:
          inc  di                 ;内层循环指针
          cmp  di,word ptr len    ;判断是否循环完成
          ja   loop1              ;继续外层循环
          xor  ax,ax
          MOV  al,vals[si]        ;di处的值放入ax中
          MOV  ah,vals[di]        ;di+1处的值放入dx中
          cmp  al,ah              ;比大小
          jnl  swap               ;ax>dx,两个值交换
          jmp  loop2              ;继续内层循环
    ;数据交换
    swap: 
          xchg al,ah              ;ax与dx的值交换
          MOV  vals[si],al        ;ax的值放回到变量中
          MOV  vals[di],ah        ;dx的值放回变量中
          jmp  loop2              ;继续内层循环
    over: 
          mov  ax,4c00h           ;dos中断
          int  21H
code ends
    end     start
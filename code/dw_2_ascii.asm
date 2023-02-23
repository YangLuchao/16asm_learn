;程序名称:
;功能:请写一个可把某个字变量的值转换为对应的二进制数ASII码串的示例程序
;=======================================
assume      cs:code,ds:data
;字变量转ascii码串
;字变量16位，转二进制并输出
;循环16次
;通过01地址表将0和1转换为ASCII码
;每次带位左移1位，移到cf中，可以用jb(cf=1),jnb(cf=0)判断
data segment
    val          dw '45'         ;字变量
    result       db 16 dup(0)    ;预留槽位
    dor          db '$'
    one_zore_tab db '0','1'      ;0,1地址表
data ends

code segment
    start:
          mov  ax,data               ;初始化数据段
          mov  ds,ax

          MOV  cx,16D                ;初始化计数器
          mov  ax,val                ;val挪到ax中
          MOV  si,-1                 ;初始化变址寄存器
          
    loop1:
          inc  si                    ;si+1
          rol  AX,1                  ;带位左移1位到CF中
          jb   one                   ;跳到1
          jmp  zore                  ;跳到0
    
    one:  
          mov  bl,one_zore_tab[1]    ;将1挪到bl中
          MOV  result[si],bl         ;结果挪到预留的槽位
          loop loop1                 ;处理下一位
          jmp  over
    
    zore: 
          mov  bl,one_zore_tab       ;将0挪到BL中
          MOV  result[si],bl         ;结果挪到预留槽位
          loop loop1                 ;
          jmp  over

    over: 
          mov  dx,offset result
          mov  ah,9
          int  21H

          mov  ax,4c00h              ;dos中断
          int  21H
code ends
    end     start

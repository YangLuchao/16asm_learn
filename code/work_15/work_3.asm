;程序名称:
;功能:编写一个实现字符串拷贝的近过程。通过堆栈传递作为参数的源和目标字符串首地址的偏移
;=======================================
assume      cs:code,ds:data

data segment
    datalen db 36                                        ;数据长度
    source  db '1234567890qwertyuiopasdfghjklzxcvbnm'    ;源数据
    target  db 40 dup(0)                                 ;目标数据
data ends

code segment
    start:   
             mov  ax,data             ;初始化数据段
             mov  ds,ax
             push ds
             mov  si,offset source
             push si

             mov  ax,data
             mov  es,ax
             push es
             mov  di,offset target
             push di

             xor  cx,cx
             mov  cl,datalen
             CALL FAR PTR copyData

             mov  ax,4c00h            ;dos中断
             int  21H
    ;=======================================
copyData PROC far
             push bp                  ;保存主程序栈基址
             MOV  bp,sp               ;将当前栈顶作为栈底，建立堆栈框架
    ;保护寄存器
             push ds
             push es
             push si
             push di
             push cx
             push bx
    ;==================子程序代码开始==============
             mov  ds,[bp+12]          ;要转换的数据地址
             mov  si,[bp+10]
             mov  es,[bp+8]           ;预留槽位的位置
             mov  di,[bp+6]

             cld                      ;df置0，递增
             rep  movsb               ;执行数据移动
    ;==================子程序代码结束==============
    over:    
             pop  bx
             pop  cx
             pop  si
             pop  es
             pop  ds
             pop  BP
             RET  8                   ;堆栈平衡由子程序完成
copyData ENDP
code ends
    end     start
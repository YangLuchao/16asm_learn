;程序名称:
;功能:通过调整BIOS中的键盘中断处理程序(9H)，可使到所按的大写字母全部变换为对应的小写字母。
;写一个测试程序验证上述方法。
;重写9H中断
;新建中断，将目标中断与新建中断替换后，新建中断包含原中断，包含后实现自己的逻辑
;=======================================
assume      cs:code,ds:data

data segment
data ends

code segment
       start: 
              mov   ax,0                            ;初始化数据段
              mov   ds,ax
       ;关中断
              CLI                                   ;关中断
              MOV   BX,9*4                          ;准备设置9号中断向量
              MOV   si,WORD PTR[BX]                 ;置偏移暂存SI
              MOV   di,WORD PTR[BX+2]               ;置段值暂存di
       ;将9号中断挪到188号中断
              MOV   bx,188*4
              MOV   WORD PTR[BX],si                 ;置偏移
              MOV   WORD PTR[BX+2],di               ;置段值
       ;将9号中断设置为自己的逻辑
              MOV   BX,9*4
              MOV   WORD PTR[BX],OFFSET new9h       ;置偏移
              MOV   WORD PTR[BX+2],SEG new9h        ;置段值
              STI                                   ;关中断

              mov   ax,4c00h                        ;dos中断
              int   21H
          
new9h PROC
              push  ax
              push  es
              push  bx
              pushf
       ;先执行原9号中断
              int   188
       ;从键盘缓冲区中获取当次输入的值
              mov   ax,0040h                        ;初始化数据段
              mov   es,ax
       ;头指针指向键盘缓冲区当前输入字符的地址
              MOV   BX,es:[001AH]
              mov   ax,es:[bx]                      ;获取键盘缓冲区的值，al就是ascii码
              CMP   AL,'a'                          ;小于'a'不是小写英文字符
              JB    new9h1
              CMP   AL,'z'                          ;大于'a'不是小写英文字符
              ja    new9h1                          ;
              sub   al,20h                          ;转大写
              mov   es:[bx],ax                      ;后塞回去
       new9h1:
              popf
              pop   bx
              pop   es
              pop   ax
              iret
new9h ENDP
code ends
    end     start
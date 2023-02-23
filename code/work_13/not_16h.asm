;程序名称:
;功能:不使用软中断指令INT调用16H中断处理程序
;=======================================
assume      cs:code,ds:data

data segment
data ends

code segment
      start:
            mov ax,0040H                    ;初始化数据段
            mov ds,ax

            mov si,word ptr ds:[001AH]
            MOV di,word ptr ds:[001CH]
            cmp si,di
            MOV bx,001AH
            jz  over                        ;头尾指针相等，没有键可以读
      ;用头指针获取值
            mov ax,ds:[bx]                  ;al中保存的键盘输入的ASCII码

      over: 
            mov ax,4c00h                    ;dos中断
            int 21H
code ends
    end     start
;程序名称:
;功能:定位类型解释
;=======================================
assume      cs:code,ds:data

data segment para
    a    db 'a'
data ends

code segment byte
    start:
          mov ax,data     ;初始化数据段
          mov ds,ax

          mov ax,4c00h    ;dos中断
          int 21H
code ends
    end     start
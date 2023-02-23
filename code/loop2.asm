;程序名称:loop2.asm
;功能:查找第一个非'A'字符，找到后-BX保存该字符的偏移地址，找不到BX=0FFFFH，并输出
;=======================================
assume      cs:code,ds:data
;todo 未开发完成
data segment
    buff  db 'AXsdadas','$'    ;定义需要处理的数据
    len   =  $-buff            ;buff的长度，这种写法就可以用长度来进行循环
    A     db 41H               ;A字符的ASCII码
    dor   db 24H               ;$字符的ASCII码
    flag1 db '0FFFFH','$'      ;没有找到标识
data ends

code segment
    start:
          mov  ax,data     ;初始化数据段
          mov  ds,ax

          mov  cx,len      ;做准备
    next: 
          xor  ax,ax       ;ax清零
    ;...
    ;当前代码逻辑和loop1完全相同，只是循环方式有差异
    ;...
          loop next
    over: 
          mov  ax,4c00h    ;dos中断
          int  21H
code ends
    end     start
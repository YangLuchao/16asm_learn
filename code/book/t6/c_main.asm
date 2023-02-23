;c的main函数
assume cs:code,ds:data,ss:stack
stack segment
            dw 256 dup(?)
stack ends
data segment
           mess db'HELLO', 0dh, 0ah,'$'
data ends
code segment
main proc far
      start:
      ;psp 0偏移处是:int 20h
            push ds                  ;把PSP的段值压入堆栈
            xor  ax,ax
            push ax                  ;把0000H偏移压入堆栈

      ;-----业务代码
            mov  ax,data             ;设置代码段
            mov  ds,ax
            mov  dx,offset mess      ;打印输出
            mov  ah,9
            int  21h
      ;-----业务代码

            ret
      ;ret
      ;等价于
      ;pop ip
      ;pop cs
      ;call cs:ip
      ;转PSP的偏移0处执行
main endp
code ends
end start
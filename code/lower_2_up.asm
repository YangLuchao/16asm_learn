;程序名称:
;功能: 写一个优化的程序片段，实现把字符串中的小写字母变换为对应的大写字母，设字符串以0结尾
;=======================================
assume      cs:code,ds:data

data segment
    string db 'abcdefghijklmnop@qrstuvwxyz','$'
data ends

code segment
    ;根据ASCII码可知，a~z的十六位值在61H~7AH，所以在处理前要判断在61H<=字<=7AH,否则不处理
    ;根据ASCII码可知，小写转大写,只需要将第6位置为0即可,-20H
    start:
          mov  ax,data             ;初始化数据段
          mov  ds,ax

          mov  si,0                ;初始化变址寄存器
    next: 
          xor  ax,ax
          mov  al,string[si]       ;将变址寄存器指向的值放到AL中
          inc  si                  ;si+1
          cmp  al,24H              ;读到$符，字符串处理完成,跳到结束
          jz   over
          cmp  al,61H
          jb   next                ;小于a,不处理当前字符，处理下一个字符
          cmp  al,7AH
          jg   next                ;大于z，不处理当前字符，处理下一个字符
          sub  al,20H              ;转大写
          push si
          dec  si
          mov  string[si],al
          pop  si
          jmp  next

    over: 
          xor  ax,ax               ;打印输出
          mov  ah,9H
          mov  dx,offset string
          int  21H

          mov  ax,4c00h            ;dos中断
          int  21H
code ends
    end     start
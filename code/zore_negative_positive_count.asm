;程序名称:
;功能:设已在地址F000：0000H开始的内存区域安排了1024个16位有符号数。
;编写一个程序统计其中的正数，负数和零的个数，并分别转换为十进制ASCII码串
;=======================================
assume      cs:code,ds:data

data segment
    resutl   dw ?,'  ',?,'  ',?,'$$'    ;0的个数，正数的个数，负数的个数
    zore     dw 0                       ;为0计数
    negative dw 0                       ;为负数计数
    positive dw 0                       ;为整数计数
data ends
;设，已在F000：0000H开始的内存区域安排了1024个16位有符号数
;循环取数，每次判断一个两个字符
;判断0值，减0，jz为0
;判断正数还是负数，带位左移1位，最高位挪到cf中，jb(cf=1)为正，jnb(cf=0)为负
;极端情况下0，正数，负数都有可能有1024个，所以要拿dw类型来存储
;首先2进制转10进制，然后10进制转ASCII码
;2进制转10进制 见代码片段：unsigned_2_to_10.asm
code segment
    start:        
                  mov  ax,0f000H        ;初始化数据段
                  mov  ds,ax

                  mov  si,-1            ;初始化si
                  mov  cx,1024D         ;初始化计数器

    loop1:        
                  mov  ax,0f000H        ;定义数据段
                  mov  ds,ax
                  inc  si               ;si+1
                  mov  ax,[si]          ;将数挪到ax中
                  sub  ax,0H            ;减0
                  jz   zore_falg        ;为0，跳到zore
                  rol  ax,1             ;左移1位，将最高位挪到cf中
                  jb   positive_flag    ;cf=1为正
                  jmp  negative_flag    ;cf=0为负
    zore_falg:    
                  mov  ax,data          ;数据段挪回来
                  mov  ds,ax
                  mov  ax,zore
                  add  ax,1
                  mov  zore,ax          ;加1挪回
                  loop loop1
                  jmp  to_ascii         ;转ascii

    positive_flag:
                  mov  ax,data          ;数据段挪回来
                  mov  ds,ax
                  mov  ax,positive
                  add  ax,1
                  mov  positive,ax      ;加1挪回
                  loop loop1
                  jmp  to_ascii         ;转ascii

    negative_flag:
                  mov  ax,data          ;数据段挪回来
                  mov  ds,ax
                  mov  ax,negative
                  add  ax,1
                  mov  negative,ax      ;加1挪回
                  loop loop1

    to_ascii:     
    ;2进制转10进制 见代码片段：unsigned_2_to_10.asm

                  mov  ax,4c00h         ;dos中断
                  int  21H
code ends
    end     start
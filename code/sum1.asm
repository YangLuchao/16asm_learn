;程序名称:
;功能:设已在地址F000:000H开始的内存区域安排了100个字节的无符号8位二进制数。
;请编写一个程序求他们的和，并转换为对应十进制数的ASCII码串。
;=======================================
assume      cs:code,ds:data

data segment

data ends
;数据段起始地址为0F000H
;循环100次
;ax为累加器
code segment
    start:
          mov  ax,0f000H    ;初始化数据段
          mov  ds,ax

          xor  ax,ax        ;准备，ax清空
          mov  SI,-1        ;变址寄存器初始化
          MOV  CL,100D      ;初始化计数器

    loop1:
          inc  si           ;si+1
          clc               ;cf位置0
          add  al,[si]      ;al做累加
          adc  ah,0         ;加进位
          loop loop1        ;循环加下一个数

          mov  ax,4c00h     ;dos中断
          int  21H
code ends
    end     start
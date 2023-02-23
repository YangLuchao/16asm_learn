;程序名称:
;功能:设已在地址F000:000H开始的内存区域安排了100个字节的无符号8位二进制数。
;请编写一个程序求他们的和，并转换为对应十进制数的ASCII码串。
;=======================================
assume      cs:code,ds:data

data segment
    sum    db ?,?,?,?,'$'        ;存放检验和
    hexTab db '0','1','2','3'    ;ascii码
           db '4','5','6','7'
           db '8','9','a','b'
           db 'c','d','e','f'
data ends

code segment
    start:
          MOV  AX,data
          MOV  DS,AX            ;设置数据段寄存器值为0F000H

          MOV  SI,0F000H        ;设置偏移为0
          MOV  CX,100           ;设置循环计数器

    LOOP2:                      ;从0f000出准备数据
          mov  [si],1eH
          inc  si
          loop LOOP2

          MOV  SI,0F000H        ;设置偏移为0
          MOV  CX,100           ;设置循环计数器
          XOR  AX,AX            ;检验和清0
          XOR  dx,dX            ;检验和清0

    LOOP1:
          mov  dl,[si]          ;求和
          add  ax,dx
          inc  SI
          loop LOOP1            ;跳回loop1
    
          push ax               ;暂存ax
          and  ah,0f0H          ;清空低四位，处理第一个字符
          mov  cl,12            ;准备右移12位
          shr  ax,cl            ;ax右移12位
          mov  si,ax
          MOV  bh,hexTab[si]    ;表中映射
          MOV  sum,bh
          pop  ax               ;弹出ax

          push ax               ;暂存ax
          and  ah,0fH           ;清空高四位，处理第二个字符
          mov  cl,8             ;准备右移8位
          shr  ax,cl            ;ax右移8位
          mov  si,ax
          MOV  bh,hexTab[si]    ;表中映射
          MOV  sum[1],bh
          pop  ax               ;弹出ax

          push ax               ;暂存ax
          and  ax,00f0H         ;清空低四位，处理第三个字符
          mov  cl,4             ;准备右移4位
          shr  ax,cl            ;ax右移4位
          mov  si,ax
          MOV  bh,hexTab[si]    ;表中映射
          MOV  sum[2],bh
          pop  ax               ;弹出ax

          push ax               ;暂存ax
          and  ax,000fH         ;清空高四位，处理第四个字符
          mov  si,ax
          MOV  bh,hexTab[si]    ;表中映射
          MOV  sum[3],bh
          pop  ax               ;弹出ax

          mov  dx,offset sum    ;打印输出
          mov  ah,9
          int  21H

          mov  ax,4c00h         ;dos中断
          int  21H
code ends
    end     start
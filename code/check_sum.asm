;程序名称:
;功能:请编写一个程序求从地址F000:0000H开始的64K字节内存区域的检验和，并转换为16进制数的ASCII码
;=======================================
assume      cs:code,ds:data
;所谓字检验和是指，结果只用字表示，忽略可能产生的进位
;转ASCII码，一个字变量共16位，每4位为一个字符
data segment
    sum    db ?,?,?,?,'$'        ;存放检验和
    hexTab db '0','1','2','3'
           db '4','5','6','7'
           db '8','9','a','b'
           db 'c','d','e','f'
data ends

code segment
    start:
          MOV  AX,0F000H
          MOV  DS,AX            ;设置数据段寄存器值为0F000H
          MOV  SI,0             ;设置偏移为0
          MOV  CX,64            ;设置循环计数器
          XOR  AX,AX            ;检验和清0

    LOOP1:
          push CX               ;暂存CX
          JMP  LOOP2
    
    LOOP2:
          mov  cx,1024
          JMP  LOOP3
    
    LOOP3:
          ADD  AX,[SI]          ;求和
          inc  SI
          inc  SI
          loop LOOP3            ;第二次循环cx-1
          pop  cx               ;弹出cx
          loop LOOP1            ;第一层循环cx-1

          MOV  BX,data          ;初始化数据段
          MOV  DS,BX
    
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
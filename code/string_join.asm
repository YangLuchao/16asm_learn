;程序名称:
;功能: 请写一个可把两个字符串合并的示例程序
;=======================================
assume      cs:code,ds:data

data segment
    val1  db 'sfsdfsfadasd','$'    ;第一节字符串
    val2  db 'sdasdasdasdd','$'    ;第二节字符串
    blank db 20H                   ;空格的ASCII码
    dor   db 24H                   ;$的ASCII码
data ends
;判断val1的每一个字母，如果为$符，则替换为空格，并跳出循环
code segment
    start:
          mov ax,data           ;初始化数据段
          mov ds,ax

          MOV si,-1             ;初始化变址寄存器
          xor ax,ax             ;清空AX
          mov al,blank          ;将空格装入al
          MOV AH,dor            ;将$装入AH
    next: 
          inc si                ;si+1
          CMP AH,val1[si]       ;字节与$比较
          jnz next              ;不相等，判断下一个字符
          MOV val1[si],al       ;相等，替换为空格
          jmp print


    print:
          mov dx,offset val1    ;打印输出
          mov ah,9
          int 21H
          
          mov ax,4c00h          ;dos中断
          int 21H
code ends
    end     start
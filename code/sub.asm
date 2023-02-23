;程序名称: sub.asm
;功能:  两个64位按高高低低的原则分别存放在DATA1和DATA2两个缓冲区
;计算DATA1-DATA2；
;DATA1=2000156781234
;DATA2=1000212345678
;实现步骤：
    ;1:将两个10进制数转为两个16进制数
    ;2:转16位后，使用DW类型对数字继续保存
    ;3:dw类型有4个字节，会计算4次，所以用CX保存计数器
    ;4:重置CF标识
;======================
assume      cs:code,ds:data

data segment
    data1  dw 6ab2H,0b2a2H,01d1H,0    ;要用dw(32位)类型存储数字，并且保存形式为小端存储(高高低低原则)，该存储形式也利于计算
    data2  dw 33e4H,0e14dH,0e8H,0
    result dw ?,?,?,?                 ;result保存结果，数据宽度与参数对其
data ends

code segment
    start:
    ;
    ;设置数据段
          mov AX,data
          mov ds,ax
    ;准备
    ;ax置零
          MOV AX,0
    ;cx重置
          MOV CX,4
    ;变址寄存器置零
          MOV si,0

    ;开始循环
    next: 
          mov ax,word ptr ds:data1[si]
    ;带位减
          sbb ax,word ptr ds:data2[si]
    ;将结果保存到result中
          MOV word ptr ds:result[si],ax
    ;指针加2
          inc si
          inc si
    ;计数器减1
          DEC cx
    ;判断是否跳出循环
          jnz next

    ;退出
          MOV AH,4ch
          int 21H

code ends
    end    start
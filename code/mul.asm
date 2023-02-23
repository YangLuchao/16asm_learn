;程序名称: mul.asm
;功能:  乘法运算
;=======================================
assume      cs:code,ds:data

data        segment
val1    db  2
val2    db  4
val3    dw  0323H
val4    dw  0ba21H
val5    db  -2
val6    db  4
val7    dw  0c303H
val8    dw  0ff01H
data        ends

code        segment
start:
    ;初始数据段
    mov     AX,data
    mov     ds,ax
    ;无符号数8位乘法
    mov     al,byte ptr ds:[val1]
    mov     bl,byte ptr ds:[val2]
    mul     bl  ;8位无符号数乘法，默认用al乘mul指令的目的数，结果保存到ax中
                ;ah中的值不为0则CF置为1

    ;无符号数8位乘法
    MOV     al,byte ptr ds:[val5]
    mov     bl,byte ptr ds:[val6]
    imul    bl  ;8位有符号数乘法，默认用AL乘以imul指令的目的数，结果保存到ax中
                ;dx中的值不为0则CF置为1

    ;无符号数16位乘法
    mov     AX,word ptr ds:[val3]
    mov     bx,word ptr ds:[val4]
    mul     bx

    ;有符号数16位乘法
    mov     ax,word ptr ds:[val7]
    mov     bx,word ptr ds:[val8]
    imul    bx

    ;结束
    MOV     AH, 4ch
    int     21H
code        ends
    end     start
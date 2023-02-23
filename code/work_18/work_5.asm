;程序名称:
;功能:请编写一个可实现把操作数1和操作数2相乘之积送操作数3的宏，该宏必须通用，灵活和高效
;三个操作数
;操作数1,2可能为存储单元，可能为寄存器，共4中情况
;操作数3可能是存储单元，也可能是寄存器，共2种情况
;定义：
;op1tp=0,操作数1为地址，op1tp=1，操作数1为8位寄存器，op1tp=2操作数1为16位寄存器
;op2tp=0,操作数2为地址，op2tp=1，操作数2为8位寄存器，op2tp=2操作数2为16位寄存器
;op3tp=0,操作数3为地址，否则为两个16位寄存器AX,DX
;=======================================
MUL_MOV MACRO op1,op2,op3,op1tp,op2tp,op3tp
            xor    ax,ax
            xor    dx,dx
            xor    bx,bx
    ;处理操作数1，让如到ax中
            IF     op1tp eq 0
            mov    ax,WORD ptr ds:[op1]
            elseif op1tp eq 1
            mov    al,op1
            elseif op1tp eq 2
            mov    ax,op1
            ENDIF
    ;处理操作数2，放入到BX中
            IF     op2tp eq 0
            mov    BX,WORD ptr ds:[op2]
            elseif op2tp eq 1
            mov    bl,op1
            elseif op2tp eq 2
            mov    bx,op1
            ENDIF
    ;做乘法
            mul    bx
            IF     op3tp eq 0
            mov    WORD ptr ds:[op3],ax
            mov    WORD ptr ds:[op3+2],dx
            ENDIF
ENDM
assume      cs:code,ds:data

data segment

data ends

code segment
    start:
          mov ax,data     ;初始化数据段
          mov ds,ax

          mov ax,4c00h    ;dos中断
          int 21H
code ends
    end     start
;程序名称:
;功能:请编写一个可以实现把操作数1和操作数2相加之和送操作数1的宏。
;操作数1及操作数2可能都是存储单元，也可能都是寄存器。所以定义的宏应能区分这些情况，并分别对待。
;=======================================
assume      cs:code,ds:data
ADD_MOV_1 MACRO OPER1,OPER2,NUM
              IF    NUM EQ 0
              add   OPER1,OPER2
              ENDIF
              IF    NUM EQ 1
              mov   al,ds:[OPER1]
              add   al,ds:[OPER2]
              mov   ds:[OPER1],al
              ENDIF
ENDM
data segment
    tmp1 db 1
    tmp2 db 2
data ends

code segment
    start:
          mov       ax,data     ;初始化数据段
          mov       ds,ax
          mov       al,1
          mov       bl,1
          ADD_MOV_1 al,bl,0
          ADD_MOV_1 0,1,1
          mov       ax,4c00h    ;dos中断
          int       21H
code ends
    end     start
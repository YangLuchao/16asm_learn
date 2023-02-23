;程序名称:
;功能:请编写一个在堆栈中定义若干局部变量的宏。可通过基于BP寄存器的相对寻址访问这些局部变量。
;=======================================
assume      cs:code
BP_PARAM_1 MACRO NUM
               sub sp,NUM*2    ;预留两个参数的槽位,那么[bp],[bp-2]两个字的槽位就是预留的槽位，可以存储参数
ENDM
BP_PARAM_2 MACRO
               MOV sp,bp    ;将子程序栈顶强行指向栈底
ENDM

code segment
    start: 
           call       childP

           mov        ax,4c00h    ;dos中断
           int        21H
childP PROC  FAR
           PUSH       BP
           MOV        BP,SP       ;堆栈框架，主程序的栈顶做子程序栈底
           BP_PARAM_1 2           ;两个局部变量，可以通过[bp],[bp-2]访问

           BP_PARAM_2
           POP        BP
           RET                    ;两个参数，堆栈平衡
childP ENDP
code ends
    end     start
;程序名称:
;功能:编写一个把1位十六进制数字ASCII码转换为对应的二进制数的宏。
;=======================================
ATOBINM MACRO
            LOCAL ATOBIN1
            SUB   AL,30H
            CMP   AL,9
            JBE   ATOBIN1
            SUB   AL,7
            CMP   AL,15
            JBE   ATOBIN1
            SUB   AL,20H
    ATOBIN1:
ENDM
assume      cs:code
code segment
    start:

          xor     ax,ax
          mov     al,31h

          ATOBINM

          mov     ax,4c00h    ;dos中断
          int     21H
code ends
    end     start
;程序名称:T3-2
;功能:设X和Y均为16位无符号数，写一个求表达式16X+Y值的程序
;=======================================
assume      cs:code,ds:data
;todo ylc 待开发
data segment
    XXX  DW 1234H    ;设X为1234H
    YYY  DW 5678H    ;设Y为5678H
    ZZZ  DD ?        ;用于保存结果
data ends

code segment
    start:

code ends
    end     start
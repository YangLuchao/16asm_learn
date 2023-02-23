;程序名：T6-4,ASM
;功能：显示命令行参数
ASSUME CS:CSEG,DS:CSEG
CSEG SEGMENT
    BUFFER DB    128 DUP (?)         ;用于存放命令行参数的缓冲区
    START: 
           CLD                       ;DF置0，递减
           MOV   SI,80H
    ;mov al,[si]
           LODSB                     ;取得命令行参数长度
           MOV   CL,AL
           XOR   CH,CH               ;CX含命令行参数字节数
    ;PSP的地址挪到附加段
           PUSH  CS                  ;该程序中数据和代码在一个段中
           POP   ES
    ;缓冲区地址挪到DI中
           MOV   DI,OFFSET BUFFER
    ;暂存处理字节数
           PUSH  CX
    ;rep1:
    ;mov [di],[si]
    ;dec di
    ;dec si
    ;loop rep1
           REP   MOVSB               ;传命令行参数
    ;准备显示循环用
           POP   CX
    ;重置数据段
           PUSH  ES
           POP   DS                  ;置数据段寄存器
    ;置SI到缓冲区偏移处
           MOV   SI,OFFSET BUFFER
           MOV   AH,2
           JCXZ  OVER
    NEXT:  
    ;mov al,[si]
           LODSB                     ;显示命令行参数
           MOV   DL,AL
           INT   21H
           LOOP  NEXT
    OVER:  
           MOV   AX,4C00H            ;程序结束
           INT   21H
CSEG ENDS
END 	START
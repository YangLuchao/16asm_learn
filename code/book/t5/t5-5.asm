;程序名：T5-5.ASM
;功能：(略）
;中断处理程序常量定义
COUNT_VAL  	=  	18	;间隔“嘀答”数
DPAGE		=	0	;显示页号
ROW			=	0	;显示时钟的行号
COLUMN		=	80-BUFF_LEN ;显示时钟的开始列号
COLOR		=	07H			;显示时钟的属性值
;代码
CSEG SEGMENT
             ASSUME CS:CSEG,DS:CSEG
    ;1CH号中断处理程序使用的变量
    COUNT    DW     COUNT_VAL               ;“嘀答”计数
    HHHH     DB     ?,?,':'                 ;时
    MMMM     DB     ?,?,':'                 ;分
    SSSS     DB     ?,?                     ;秒
    BUFF_LEN =      $-OFFSET HHHH           ;BUFF_LEN为显示信息长度
    CURSOR   DW     ?                       ;原光标位置
    ;1CH号中断处理程序代码
    NEW1CH:  
             CMP    CS:COUNT,0              ;是否已到显示时候？
             JZ     NEXT                    ;是，转
             DEC    CS:COUNT                ;否
             IRET                           ;中断返回
    NEXT:    
             MOV    CS:COUNT,COUNT_VAL      ;重置间隔数初值
             STI                            ;开中断
             PUSH   DS
             PUSH   ES
             PUSH   AX
             PUSH   BX
             PUSH   CX                      ;保护现场
             PUSH   DX
             PUSH   SI
             PUSH   BP
             PUSH   CS
             POP    DS                      ;置数据段寄存器
             PUSH   DS
             POP    ES                      ;置代码段寄存器
             CALL   GET_T                   ;取时间
             MOV    BH,DPAGE
             MOV    AH,3                    ;取原光标位置
             INT    10H
             MOV    CURSOR,DX               ;保存原光标位置
             MOV    BP,OFFSET HHHH
             MOV    BH,DPAGE
             MOV    DH,ROW
             MOV    DL,COLUMN
             MOV    BL,COLOR
             MOV    CX,BUFF_LEN
             MOV    AL,0
             MOV    AH,13H                  ;显示时钟
             INT    10H
             MOV    BH,DPAGE                ;核复原光标
             MOV    DX,CURSOR
             MOV    AH,2
             INT    10H
             POP    BP
             POP    SI
             POP    DX                      ;恢复现场
             POP    CX
             POP    BX
             POP    AX
             POP    ES
             POP    DS
             IRET                           ;中断返回
    ;
    ;子程序说明信息略
GET_T PROC
             MOV    AH,2                    ;取时间信息
             INT    1AH
             MOV    AL,CH                   ;把时数转为可显示形式
             CALL   TTASC
             XCHG   AH,AL
             MOV    WORD PTR HHHH,AX        ;保存
             MOV    AL,CL                   ;把分数转为可显示形式
             CALL   TTASC
             XCHG   AH,AL
             MOV    WORD PTR MMMM,AX        ;保存
             MOV    AL,DH                   ;把秒数转为可显示形式
             CALL   TTASC
             XCHG   AH,AL
             MOV    WORD PTR SSSS,AX        ;保存
             RET
GET_T ENDP
    ;子程序名：TTASC
    ;功能：把两位压缩的BCD码转换为对应的ASCII码
    ;入口参数：AL=压缩BCD码
    ;出口参数：AH=高位BCD码所对应的ASCII码
    ; 		  AL=低位BCD码所对应的ASCII码
TTASC PROC
             MOV    AH,AL
             AND    AL,0FH
             SHR    AH,1
             SHR    AH,1
             SHR    AH,1
             SHR    AH,1
             ADD    AX,3030H
             RET
TTASC ENDP
    ;=====================
    ;初始化部分代码和变量
    OLD1CH   DD     ?                       ;原中断向量保存单元
    START:   
             PUSH   CS
             POP    DS
             MOV    AX,351CH                ;取1CH号中断向量
             INT    21H
             MOV    WORD PTR OLD1CH,BX      ;保存
             MOV    WORD PTR OLD1CH+2,ES
             MOV    DX,OFFSET NEW1CH
             MOV    AX,251CH                ;置新的1CH号中断向量
             INT    21H
    ;
    ;....
    ;....				;其它工作
    ;····
             MOV    AH,0                    ;假设其它工作是等待按键
             INT    16H
             LDS    DX,OLD1CH               ;取保存的原1CH号中断向量
             MOV    AX,251CH
             INT    21H                     ;恢复原1CH号中断向量
             MOV    AH,4CH                  ;结束
             INT    21H
CSEG ENDS
		END 	START
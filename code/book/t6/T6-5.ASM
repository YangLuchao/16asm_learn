;程序名：T6-5.ASM
;功能：显示文本文件的内容
;符号常量定义
LENOFID 	= 	128		;文件标识符最大长度
SPACE 		= 	' '
TAB			=	09H
EOF 		= 	1AH		;文件结束符的ASCII码
;数据段
DSEG SEGMENT
    FNAME DB LENOFID	DUP	(?)                   ;准备存放文件名串
    ERROR DB 'Required parameter missing',0
    ;...                                            ;同T4-6.ASM对应部分
DSEG ENDS
;代码段
CSEG SEGMENT
            ASSUME CS:CSEG,DS:DSEG
    START:  
            CLD
            MOV    SI,80H
            LODSB                      ;取命令行参数长度
            OR     AL,AL               ;是否有命令行参数
            JNZ    GETFID1             ;有
    FIDERR: 
            MOV    AX,SEG ERRORO       ;没有命令行参数处理
            MOV    DS,AX
            MOV    SI,OFFSET ERRORO
            CALL   DMESS
            JMP    OVER
    GETFID1:
            MOV    CL,AL
            XOR    CH,CH               ;CX含命令行参数长度取参数一字节
    GETFID2:
            LODSB
            CMP    AL,SPACE            ;为空格？
            JZ     GETFID3             ;是，跳过
            CMP    AL,TAB              ;为制表符？
            JNZ    GETFID4             ;不是，表示已去掉前导空格
    GETFID3:
            LOOP   GETFID2             ;跳过前导的空格和制表符
            JMP    FIDERR              ;命令行参数没有其他符号，转
    GETFID4:
            DEC    SI
            MOV    AX,SEG FNAME
            MOV    ES,AX
            MOV    DI,OFFSET FNAME     ;把剩下的命令行参数送
            REP    MOVSB               ;文件标识符区
            XOR    AL,AL               ;再补一个0.形成ASCIIZ串
            STOSB
    ;
            MOV    AX,DSEG
            MOV    DS,AX               ;置数据段寄存器
    ;
    ; ......                                 ;同T4-6.ASM对应部分
CSEG ENDS
		END 	START
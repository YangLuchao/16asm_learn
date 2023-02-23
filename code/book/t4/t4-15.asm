;程序名：T4-6.ASM
;功能：显示当前目录下的文本文件TEST.TXT内容
;符号常量定义
EOF	=	1AH		;文件结束符ASCII码
;数据段
DSEG SEGMENT
    FNAME  DB 'TEST.TXT',0             ;文件名
    ERROR1 DB 'File not foun',07H,0    ;提示信息
    ERROR2 DB 'Reading error',07H,0
    BUFFER DB ?                        ;1字节的缓冲区
DSEG ENDS
;代码段
CSEG SEGMENT
            ASSUME CS:CSEG,DS:DSEG
    START:  
            MOV    AX, DSEG
            MOV    DS,AX               ;置数据段寄存器
    ;
            MOV    DX,OFFSET FNAME
            MOV    AX,3D00H            ;为读打开指定文件
            INT    21H
            JNC    OPEN_OK             ;打开成功，转
    ;
            MOV    SI,OFFSET ERROR1
            CALL   DMESS               ;显示打开不成功提示信息
            JMP    OVER
    ;
    OPEN_OK:
            MOV    BX,AX               ;保存文件柄
    CONT:   
            CALL   READCH              ;从文件中读一个字符
            JC     READERR             ;如读出错，则转
            CMP    AL,EOF              ;读到文件结束符吗？
            JZ     TYPE_OK             ;是，转
            CALL   PUTCH               ;显示所读字符
            JMP    CONT                ;继续
    ;
    READERR:
            MOV    SI,OFFSET ERROR2
            CALL   DMESS               ;显示读出错提示信息
    ;
    TYPE_OK:
            MOV    AH,3EH              ;关闭文件
            INT    21H
    OVER:   
            MOV    AH,4CH              ;程序结束
            INT    21H
    ;子程序名：READCH
    ;功能：读取文件的一个字符
    ;入口参数：预留的缓冲区首地址
    ;出口参数：无
    ;说明：提前打开文件
    ;       cf置1，字符读取错误
READCH PROC
            MOV    CX,1                ;读字节数
            MOV    DX,OFFSET BUFFER    ;读缓冲区地址
            MOV    AH,3FH              ;功能调用号
            INT    21H                 ;读
            JC     READCH2             ;读出错，转
            CMP    AX,CX               ;判文件是否结束
            MOV    AL,1AH              ;设文件已结束，置文件结束符
            JB     READCH1             ;文件确已结束，转
            MOV    AL,BUFFER           ;文件未结束，取所读字符
    READCH1:
            CLC                        ;cf状态符清0
    READCH2:
            RET
READCH ENDP
    ;子程序名：DMESS
    ;功能：显示一个以0为结束符的字符串
    ;入口参数：SI=字符串首地址
    ;出口参数：无
DMESS PROC
    DMESS1: 
            MOV    DL,[SI]
            INC    SI
            OR     DL,DL
            JZ     DMESS2
            MOV    AH,2
            INT    21H
            JMP    DMESS1
    DMESS2: 
            RET
DMESS ENDP
    ;-----------------------------
    ;显示一个字符
    ;入口参数：al
    ;出口参数：标志输出设备
putch PROC
            PUSH   DX
            MOV    DL,AL
            MOV    AH,2
            INT    21H
            POP    DX
            RET
putch ENDP
    ;-----------------------------
CSEG ENDS
		END		START
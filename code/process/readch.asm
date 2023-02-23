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
    ;子程序名：WRITECH
    ;功能：读取文件的一个字符
    ;入口参数：al=需要写入文件的字符，dx=预留缓冲区的地址
    ;出口参数：无
    ;说明：提前打开文件，文件柄存储正常
    ;       cf置1，字符读取错误
WRITECH PROC
             MOV    BUFFER,AL             ;把要写的一字节送入缓冲区
             MOV    DX,OFFSET BUFFER      ;置缓冲区地址
             MOV    CX,1                  ;置写的字节数
             MOV    AH,40H                ;置功能号
             INT    21H                   ;写
             RET
WRITECH ENDP
;程序名称:
;功能:写一个能把键盘上输入的全部字符（直到CTRL+Z键，值1AH)存入某个文件的程序。
;把键盘上输入的字符全部存入文件TEST.TXT
;具体算法是：先建立指定文件；然后读键盘，把所读字符顺序写入文件，
;如此循环直到读到文件结束符（1AH);关闭文件。源程序如下：
;=======================================
;常量定义
EOF 	= 	1AH			;文件结束符的ASCII码
;数据段
DSEG SEGMENT
    FNAME    DB 'TEST.TXT',0                     ;文件名
    ERRMESS1 DB 'Can not create file',07H,'$'
    ERRMESS2 DB 'Writing error',07H,'$'          ;提示信息
    BUFFER   DB ?                                ;1字节缓冲区
DSEG ENDS
;代码段
CSEG SEGMENT
             ASSUME CS:CSEG,DS:DSEG
    START:   MOV    AX,DSEG
             MOV    DS,AX                 ;置数据段寄存器
    ;建立文件
             MOV    DX,OFFSET FNAME
             MOV    CX,0
             MOV    AH,3CH
             INT    21H

             JNC    CREA_OK               ;建立成功，转
             MOV    DX,OFFSET ERRMESS1    ;显示不能建立提示信息
             CALL   DISPMESS
             JMP    OVER
             
    CREA_OK: 
             MOV    BX,AX                 ;保存文件柄
    CONT:    
             CALL   GETCHAR               ;接收一个键
             PUSH   AX
             CALL   WRITECH               ;向文件写所读字符
             POP    AX
             JC     WERROR                ;写出错，转
             CMP    AL,EOF                ;读到文件结束符吗？
             JNZ    CONT                  ;不是，继续
             JMP    CLOSEF                ;遇文件结束符，转结束
    WERROR:  
             MOV    DX,OFFSET	ERRMESS2    ;显示写出错提示信息
             CALL   DISPMESS
    CLOSEF:  
             MOV    AH, 3EH               ;关闭文件
             INT    21H
    OVER:    
             MOV    AX,4C00H              ;程序结束
             INT    21H
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
    ;子程序说明信息略
GETCHAR PROC
             MOV    AH,1
             INT    21H
             RET
GETCHAR ENDP
    ;
DISPMESS PROC
    ;同T4-4.ASM中的DISPMESS
DISPMESS ENDP
CSEG ENDS
		END 	START
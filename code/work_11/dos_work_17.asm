;程序名称:
;功能:将视频中的例2改成每次向文件写若干字节。
;它通过1号功能调用读键盘，然后就把所读的字符写入文件，
;如果实际运行这个程序会发现按退格键和回车键时有特殊异常，该如果解决。
;执行步骤：:
;1:创建文件
;2:打开文件
;3:输入字符串
;4:遇到退格符(当次实现不考虑)
;4.1:文件指针-1
;4.2:下一个字符输出
;4.3:遇到换行符，输出完成
;5:关闭文件
;=======================================
;程序名称:
;功能:写一个能把键盘上输入的全部字符（直到CTRL+Z键，值1AH)存入某个文件的程序。
;把键盘上输入的字符全部存入文件TEST.TXT
;具体算法是：先建立指定文件；然后读键盘，把所读字符顺序写入文件，
;如此循环直到读到文件结束符（1AH);关闭文件。源程序如下：
;=======================================
;常量定义
EOF 	= 	1AH			;文件结束符的ASCII码
mlength = 128
;数据段
DSEG SEGMENT
    FNAME    DB 'TEST.TXT',0                     ;文件名
    ERRMESS1 DB 'Can not create file',07H,'$'
    ERRMESS2 DB 'Writing error',07H,'$'          ;提示信息
    BUFFER   db ?                                ;一个字节的缓冲
    buff1    db mlength                          ;缓冲区最大长度
             db ?                                ;字符串实际长度，出口参数之一
             db mlength dup(0)                   ;符合0AH号功能调用所需的缓冲区
DSEG ENDS
;代码段
CSEG SEGMENT
             ASSUME CS:CSEG,DS:DSEG
    START:   MOV    AX,DSEG
             MOV    DS,AX                 ;置数据段寄存器
    ;1:建立文件
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

    ;2:输入字符串
             mov    ah,0ah                ;DOS十号功能，接受一个字符串，回车键结束
             mov    dx,offset buff1       ;入口参数，缓冲区首地址，存放缓冲区最大容量
             int    21h                   ;输出提示

             MOV    si,1                  ;字符串指针
    ;
    CONT:    
             inc    si                    ;si+1
             mov    al,buff1[si]          ;将一个字符挪到al中
             CMP    AL,0dh                ;读到文件结束符吗？
             jz     CLOSEF                ;遇文件结束符，转结束
             CALL   WRITECH               ;向文件写所读字符
             JC     WERROR                ;写出错，转
             JNZ    CONT                  ;不是，继续
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
    ;
DISPMESS PROC
    ;同T4-4.ASM中的DISPMESS
DISPMESS ENDP
CSEG ENDS
		END 	START
;程序名：T4-8.ASM
;功能：写一个程序把文件2拼接到文件1上。文件1固定为当前目录下的TEST1,文件2固定为当前目录下的TEST2。
;具体算法是：为写打开文件TEST1,为读打开文件TEST2;把文件TEST1的读写指针移到尾；
;读TEST2的一块到缓冲区，写这一个块到TEST1,如此循环，直到TEST2结束；最后关闭两个文件。
;符号常量定义
BUFFLEN	=	512		;数据段
DSEG SEGMENT
    FNAME1   DB 'TEST1',0                      ;文件名1
    FNAME2   DB 'TEST2',0                      ;文件名2
    HANDLE1  DW 0                              ;存放文件1的文件柄
    HANDLE2  DW 0                              ;存放文件2的文件柄
    ERRMESS1 DB 'Can not open file',07H,'$'
    ERRMESS2 DB 'Reading error',07h,'$'
    ERRMESS3 DB 'Writing error',07H,'$'
    BUFFER   DB BUFFLEN DUP (0)                ;缓冲区
DSEG ENDS
;代码段
CSEG SEGMENT
             ASSUME CS:CSEG,DS:DSEG
    START:   
             MOV    AX,DSEG
             MOV    DS,AX                 ;置数据段寄存器
             MOV    DX,OFFSET FNAME1      ;为写打开文件1
             MOV    AX,3D01H
             INT    21H
             JNC    OPENOK1               ;成功，转
    ;
    ERR1:    
             MOV    DX,OFFSET ERRMESS1    ;显示打开文件不成功提示信息
             CALL   DISPMESS
             JMP    OVER                  ;转结束
    OPENOK1: 
             MOV    HANDLE1,AX            ;保存文件1的柄
             MOV    DX,OFFSET FNAME2      ;为读打开文件2
             MOV    AX,3D00H
             INT    21H
             JNC    OPENOK2               ;成功，转
             MOV    BX,HANDLE1            ;如文件2打开不成功
             MOV    AH,3EH                ;则关闭文件1
             INT    21H
             JMP    ERR1                  ;再显示提示信息
    OPENOK2: 
             MOV    HANDLE2,AX            ;保存文件2的柄
             MOV    BX,HANDLE1
             XOR    CX,CX
             XOR    DX,DX
             MOV    AX,4202H              ;移动文件1的指针到文件尾
             INT    21H
    CONT:    
             MOV    DX,OFFSET BUFFER      ;读文件2
             MOV    CX,BUFFLEN
             MOV    BX,HANDLE2
             MOV    AH,3FH
             INT    21H
             JC     RERR                  ;读出错，转
             OR     AX,AX                 ;文件2读完了？
             JZ     COPYOK                ;是，转结束
             MOV    CX,AX                 ;写到文件2的长度等于读出的长度
             MOV    BX,HANDLE1
             MOV    AH,40H                ;写到文件2
             INT    21H
             JNC    CONT                  ;写正确，继续
    WERR:    
             MOV    DX,OFFSET ERRMESS3
             CALL   DISPMESS              ;显示写出错提示信息
             JMP    SHORT COPYOK
    ;
    RERR:    MOV    DX,OFFSET ERRMESS2
             CALL   DISPMESS              ;显示读出错提示信息;
    COPYOK:  
             MOV    BX,HANDLE1            ;关闭文件
             MOV    AH,3EH
             INT    21H
             MOV    BX,HANDLE2
             MOV    AH,3EH
             INT    21H
    ;
    OVER:    MOV    AH,4CH                ;程序结束
             INT    21H                   ;
DISPMESS PROC
    ;同T4-4.ASM中的DISPMESS
DISPMESS ENDP
CSEG ENDS
		END 	START
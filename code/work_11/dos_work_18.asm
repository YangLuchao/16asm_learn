;程序名称:
;功能:视频中例3的文件名是固定的，请改成文件名由用户输入。并且把两个文件合并成第三个文件。
;执行步骤：
;1:创建文件3
;2:打开文件1
;2.1:输入文件1的文件名
;2.2:将文件1名的换行符换为00：算法：FNAME1[2][FNAME1[0]][1]
;2.3:保存文件柄
;3:打开文件2
;3.1:输入文件2的文件名
;3.2:将文件1名的换行符换为00：算法：FNAME2[2][FNAME2[0]][1]
;3.3:保存文件柄
;复制文件1到文件3
;复制文件2到文件3
;关闭文件1,2,3
;=======================================
;程序名：T4-8.ASM
;功能：写一个程序把文件2拼接到文件1上。文件1固定为当前目录下的TEST1,文件2固定为当前目录下的TEST2。
;具体算法是：为写打开文件TEST1,为读打开文件TEST2;把文件TEST1的读写指针移到尾；
;读TEST2的一块到缓冲区，写这一个块到TEST1,如此循环，直到TEST2结束；最后关闭两个文件。
;符号常量定义
mlength	=	128		;数据段
DSEG SEGMENT
    ;文件名1
    FNAME1   db mlength                        ;缓冲区最大长度
             db ?                              ;字符串实际长度，出口参数之一
             db mlength dup(0)                 ;符合0AH号功能调用所需的缓冲区
    ;文件名2
    FNAME2   db mlength                        ;缓冲区最大长度
             db ?                              ;字符串实际长度，出口参数之一
             db mlength dup(0)                 ;符合0AH号功能调用所需的缓冲区
    FNAME3   db 'TEST3.txt',0
    HANDLE1  DW 0                              ;存放文件1的文件柄
    HANDLE2  DW 0                              ;存放文件2的文件柄
    HANDLE3  DW 0                              ;存放文件3的文件柄
    ERRMESS1 DB 'Can not open file',07H,'$'
    ERRMESS2 DB 'Reading error',07h,'$'
    ERRMESS3 DB 'Writing error',07H,'$'
    buff     DB 512 dup(0)                     ;缓冲区
DSEG ENDS
;代码段
CSEG SEGMENT
            ASSUME CS:CSEG,DS:DSEG
    START:  
            MOV    AX,DSEG
            MOV    DS,AX                  ;置数据段寄存器
    ;1:创建文件3
            MOV    DX,OFFSET FNAME3
            MOV    CX,0
            MOV    AH,3CH
            INT    21H
            MOV    HANDLE3,AX             ;保存文件3文件柄
    ;2:打开文件1
    ;2.1:输入文件1的文件名
            mov    ah,0ah                 ;DOS十号功能，接受一个字符串，回车键结束
            mov    dx,offset FNAME1       ;入口参数，缓冲区首地址，存放缓冲区最大容量
            int    21h                    ;输出提示
    ;2.2:将文件1名的换行符换为00：算法：FNAME1[2][FNAME1[0]][1]
            xor    bx,bx
            MOV    bl,FNAME1[1]
            mov    FNAME1[bx][2],0
    ;2.3:保存文件柄
            MOV    DX,OFFSET FNAME1[2]
            MOV    AX,3D00H               ;为读打开指定文件
            INT    21H
            MOV    HANDLE1,AX             ;保存文件1文件柄
    ;3:打开文件2
            call   newline
    ;3.1:输入文件2的文件名
            mov    ah,0ah                 ;DOS十号功能，接受一个字符串，回车键结束
            mov    dx,offset FNAME2       ;入口参数，缓冲区首地址，存放缓冲区最大容量
            int    21h                    ;输出提示
    ;3.2:将文件1名的换行符换为00：算法：FNAME2[2][FNAME2[0]][1]
            xor    bx,bx
            MOV    bl,FNAME2[1]
            mov    FNAME2[bx][2],0
    ;3.3:保存文件柄
            MOV    DX,OFFSET FNAME2[2]
            MOV    AX,3D00H               ;为读打开指定文件
            INT    21H
            MOV    HANDLE2,AX             ;保存文件1文件柄
    ;复制文件1到文件3
            xor    dx,dx
    CONT1:  
            MOV    DX,OFFSET buff         ;读目标文件
            MOV    CX,512                 ;读取长度=缓冲区长度
            MOV    BX,HANDLE1             ;设置源文件文件柄
            MOV    AH,3FH                 ;读取源文件
            INT    21H
            JC     over                   ;读出错，转
            OR     AX,AX                  ;目标文件读完了？
            JZ     CONT2                  ;是，转结束
            MOV    CX,AX                  ;写到目标文件的长度等于读出的长度
            MOV    BX,HANDLE3             ;目标文件的文件柄
            MOV    AH,40H                 ;写到目标文件
            INT    21H
            JNC    CONT1                  ;写正确，继续
    ;复制文件2到文件3
            xor    dx,dx
    CONT2:  
            MOV    DX,OFFSET buff         ;读目标文件
            MOV    CX,512                 ;读取长度=缓冲区长度
            MOV    BX,HANDLE2             ;设置源文件文件柄
            MOV    AH,3FH                 ;读取源文件
            INT    21H
            JC     over                   ;读出错，转
            OR     AX,AX                  ;目标文件读完了？
            JZ     copyok                 ;是，转结束
            MOV    CX,AX                  ;写到目标文件的长度等于读出的长度
            MOV    BX,HANDLE3             ;目标文件的文件柄
            MOV    AH,40H                 ;写到目标文件
            INT    21H
            JNC    CONT2                  ;写正确，继续
    ;关闭文件1,2,3
    copyok: 
            MOV    BX,HANDLE1
            MOV    AH,3EH
            INT    21H
            MOV    BX,HANDLE2
            MOV    AH,3EH
            INT    21H
            MOV    BX,HANDLE3
            MOV    AH,3EH
            INT    21H
    OVER:   
            MOV    AH,4CH                 ;程序结束
            INT    21H                    ;
    ;----------------------------------------------
    ;子程序名：newline
    ;功能：形成回车和换行（光标移到下一行首)
    ;入口参数：无
    ;出口参数：无
    ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
            push   ax
            push   dx
            mov    dl,0dh                 ;回车符的ASCII码
            mov    ah,2
    ;显示回车符
            int    21h
            mov    dl,0ah                 ;换行符的ASCII码
            mov    ah,2
    ;显示换行符
            int    21h
            pop    dx
            pop    ax
            ret
newline endp
    ;----------------------------------------------
CSEG ENDS
		END 	START
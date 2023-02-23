;程序名称:
;功能:写一个能够复制文件的程序。源文件标识和目标文件标识由键盘输入。
;执行步骤：
;1:打开原文件，打开成功保存文件柄
;2:创建新文件，文件创建成功，保存文件柄
;3:读取源文件数据，存入到缓存区
;4:将缓冲区数据写入到新文件中
;=======================================
assume      cs:code,ds:data
data segment
    fname1  DB 'test1',0     ;源文件名
    fname2  DB 'test2',0     ;目标文件名
    hanlde1 dw 0             ;源文件文件柄
    hanlde2 dw 0             ;目标文件文件柄
    buff    db 512 dup(0)    ;缓冲区
data ends

code segment
    start:          
                    mov ax,data             ;初始化数据段
                    mov ds,ax

    ;打开源文件
                    MOV DX,OFFSET fname1
                    MOV AX,3D00H            ;为读打开指定文件
                    INT 21H
                    JNC open_source_ok      ;打开成功，转
                    JMP over                ;打开原文件失败
    ;打开原文件成功
    open_source_ok: 
                    mov hanlde1,ax          ;保存源文件文件柄
    ;创建文件
                    MOV DX,OFFSET fname2
                    MOV CX,0                ;普通文件属性
                    MOV AH,3CH
                    INT 21H
                    JC  over                ;创建失败，转
    ;打开目标文件
                    MOV DX,OFFSET fname2
                    MOV AX,3D01H            ;为写打开指定文件
                    INT 21H
                    JNC open_source_ok1     ;打开成功，转
                    JMP over                ;打开原文件失败

    open_source_ok1:
                    mov hanlde2,ax          ;保存目标文件文件柄
    ;读取源文件,并写入目标文件
    CONT:           
                    MOV DX,OFFSET buff      ;读目标文件
                    MOV CX,512              ;读取长度=缓冲区长度
                    MOV BX,hanlde1          ;设置源文件文件柄
                    MOV AH,3FH              ;读取源文件
                    INT 21H
                    JC  over                ;读出错，转
                    OR  AX,AX               ;目标文件读完了？
                    JZ  copyok              ;是，转结束
                    MOV CX,AX               ;写到目标文件的长度等于读出的长度
                    MOV BX,hanlde2          ;目标文件的文件柄
                    MOV AH,40H              ;写到目标文件
                    INT 21H
                    JNC CONT                ;写正确，继续
    copyok:         
    ;关闭文件
                    MOV BX,hanlde1
                    MOV AH,3EH
                    INT 21H
                    MOV BX,hanlde2
                    MOV AH,3EH
                    INT 21H
    ;结束
    over:           
                    mov ax,4c00h            ;dos中断
                    int 21H
code ends
    end     start
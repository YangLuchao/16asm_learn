;写一个程序计算三门课程的总分，把学号和总分依次写到文件SCORE.SUM中。
;SCORE.SUM文件的记录有两个字段，第一个字段是学号，第二个字段是总分（2字节表示）
;程序名：t7-1.asm
;实现流程：
;1.打开文件SCORE.DAT
;2.循环处理每个学生的成绩，把学号和总分依次存入预定义的缓冲区（称为总分表）中
;3.关闭文件SCORE.DAT
;4.建立文件SCORE.SUM
;5.把缓冲区中的内容写入文件SCORE.SUM
;6.关闭文件SCORE.SUM
assume cs:code,ds:data
;常量定义
count = 3                     ;设学生数为30

score struc                   ;对原始成绩的结构score的定义
    no      dw ?              ;学号
    sname   db 8 dup (' ')    ;姓名
    chn     db 0              ;语文成绩
    math    db 0              ;数学成绩
    eng     db 0              ;外语成绩
score ends
;对应学好和总分的结构item的定义
item struc
    nos     dw 0              ;学号
    sum     dw 0              ;总分
item ends
;数据段
data segment
           buffer score <>                 ;存放原始成绩的缓冲区
           stable item count dup (<>)      ;预留总分表
           fname1 db'score.dat',0          ;文件名
           fname2 db'score.sum',0
data ends
;代码段
code segment
      start:
            mov ax,data                   ;初始化代码段
            mov ds,ax

      ;第一步打开文件score.dat
            mov dx,offset fname1
            mov ax,3d00h                  ;只读方式打开
            int 21h
      ;读文件
            mov bx,ax                     ;保存文件号
            mov di,count                  ;设置循环计数器的初值
            mov si,offset stable          ;设置学号总分缓冲区指针初值
      read: 
            mov dx,offset buffer          ;读一个学生原始成绩，并存入缓冲区buffer
            mov cx,type score             ;CX=读入字节数，source是自定义类型，type source是计算一个source结构所占字节
            mov ah,3fh                    ;读取一个学生的数据
            int 21h
      ;统计总分
            mov al,buffer.chn             ;语文成绩
            xor ah,ah                     ;清空高4位
            add al,buffer.math            ;数学成绩
            adc ah,0                      ;计算进位
            add al,buffer.eng             ;英语成绩
            adc ah,0                      ;计算进位
      ;放入总分表
            mov [si].sum,ax               ;把总分保存到总分表的当前项
            mov ax,buffer.no
            mov [si].nos,ax               ;把学号保存到总分表的当前项
            add si,type item              ;调整当前总分表的当前项
            dec di
            jnz read                      ;处理下一位同学
      ;关闭文件SCORE.DAT
            mov ah,3eh
            int 21h
      ;新建文件score.sum
            mov dx,offset fname2
            mov cx,0
      ;普通文件
            mov ah,3ch
            int 21h
            mov bx,ax                     ;保存文件号
      ;写入文件score.sum
            mov dx,offset stable
            mov cx,(type item)*count
      ;写入字节数
            mov ah,40h
            int 21h
      ;关闭文件SCORE.SUM
            mov ah, 3eh
            int 21h

            mov ax,4c00h
            int 21h
code ends
end start
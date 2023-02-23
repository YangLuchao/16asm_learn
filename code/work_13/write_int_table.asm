;程序名称:
;功能:写一个程序实现如下功能：把内存区域最低端的1K字节存放到文件MEM.DAT中。
;算法：逐个读出内存单元0000:0000~1024内容到缓冲区，然后写入文件MEM.DAT中。
;注意：mem.dat文件用winhex打开查看数据，或者其他二进制编辑软件
;执行步骤：
;1:创建文件
;2:打开文件,保存文件柄
;3:重新设置段值，用附加段复制数据
;4:复制数据
;5:复制完成，关闭文件
;=======================================
assume      cs:code,ds:data
;常量定义
read_seg = 0000h;段值
read_off = 0400h;偏移
data segment
    buff   db ?              ;一个字节的缓冲区
    handle dw ?              ;文件柄
    fname  db 'mem.dat',0    ;文件名
data ends

code segment
    start:         
                   mov  ax,data            ;初始化数据段
                   mov  ds,ax

    ;1:创建文件
                   MOV  DX,OFFSET fname
                   MOV  CX,0               ;普通文件属性
                   MOV  AH,3CH
                   INT  21H
                   JC   over               ;创建失败，转

    ;2:打开文件,保存文件柄
                   MOV  DX,OFFSET fname
                   MOV  AX,3D01H           ;为写打开指定文件
                   INT  21H
                   JNC  open_source_ok     ;打开成功，转
                   JMP  over               ;打开原文件失败

    open_source_ok:
                   mov  handle,ax          ;保存目标文件文件柄
    ;3:重新设置段值，用附加段复制数据
                   mov  AX,0000h
                   mov  es,ax
    ;4:复制数据
                   mov  di,0
                   mov  cx,1024
    count:         
                   mov  al,es:[di]
                   mov  buff,al
                   call write_mem
                   jc   over
                   inc  di
                   loop count

    ;5:复制完成，关闭文件
                   MOV  BX,handle
                   MOV  AH,3EH
                   INT  21H

    over:          
                   mov  ax,4c00h           ;dos中断
                   int  21H
    ;子程序：write_mem
    ;功能：写入文件mem.dat
    ;入口参数：缓冲区buff
    ;出口参数：写入文件mem.dat
write_mem proc
                   push ax
                   push cx
                   push bx
                   push dx
                   mov  ah,40h
                   mov  dx,offset buff
                   mov  bx,handle
                   mov  cx,1
                   int  21h
                   pop  dx
                   pop  bx
                   pop  cx
                   pop  ax
                   ret
write_mem endp
code ends
    end     start
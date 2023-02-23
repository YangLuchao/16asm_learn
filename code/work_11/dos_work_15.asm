;程序名称:
;功能:写一个程序实现如下功能：
;把内存区域最低端的1K字节作为256个双字，
;依次把每个双字转换为对应的8字节十六进制ASCII码串，顺序存放到文件MEM.TXT中，
;每存放一个8字节ASCII码串，再存放回车和换行符（0DH,0AH）
;执行步骤如下：
;1:创建文件
;2:打开文件,保存文件柄
;3:重新设置段值，用附加段复制数据
;4:复制数据
;4.0:判断是否256个字节，是，转
;4.1:判断此次是第几个字节
;4.2:第9个字节，输出回车和换行
;4.3:将数据转为ascii码
;4.4:将转换的数据输出到文件中
;5:转换复制完成，关闭文件
;=======================================
assume      cs:code,ds:data

read_seg = 0000h;段值
len = 256;字节长度
new_line = 8;每行长度
data segment
    buff   db ?              ;一个字节的缓冲区
    handle dw ?              ;文件柄
    fname  db 'mem.txt',0    ;文件名
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

                   mov  di,-1
                   mov  si,-1
    ;4:复制数据
    copy:          
    ;4.0:判断此次是第几个字节
                   inc  si                 ;si+1
                   CMP  SI,8               ;是否该换行了
                   jz   newline
    ;4.1:判断是否256个字节，是，转
                   inc  di                 ;di+1
                   cmp  di,256             ;是否复制完成
                   jz   copyok             ;复制完成
                   mov  al,es:[di]         ;复制一个字节
    ;4.3:将数据转为ascii码
                   call ahtoasc            ;转ascii
    ;4.4:将转换的数据输出到文件中
                   mov  buff,ah
                   call write_mem          ;写入文件
                   MOV  buff,al
                   call write_mem
                   mov  buff,20h
                   call write_mem
                   jmp  copy

    ;4.2:第9个字节，输出回车和换行
    newline:       
                   mov  buff,0DH
                   call write_mem          ;回车
                   mov  buff,0AH
                   call write_mem          ;换行
                   MOV  si,-1              ;si置-1
                   jmp  copy
    ;5:转换复制完成，关闭文件
    copyok:        
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
    ;----------------------------------------------
    ;子程序名称:ahtoasc
    ;功能:把8位二进制数转换为2位十六进制数的ASCII
    ;入口参数:AL=欲转换的8位二进制数
    ;出口参数:AH=十六进制数高位的ASCII码,AL=十六进制数低位的ASCII码
    ;其他说明:1.近过程，2.除AX寄存器外，不影响其他寄存器3.调用了htoasc实现十六进制到ASCII码转换
    ;=======================================
ahtoasc PROC
                   mov  ah,al              ;al复制到ah
                   shr  al,1               ;AL右移4位
                   shr  al,1
                   shr  al,1
                   shr  al,1
                   call htoasc             ;调用子程序
                   xchg ah,al              ;al,ah对调
                   call htoasc             ;调用子程序
                   RET
ahtoasc ENDP
    ;子程序名称:htoasc
    ;功能:一位十六进制数转换为ASCII
    ;入口参数:al=待转换的十六进制数,ds:bx=存放转换得到的ASCII码串的缓冲区首地址
    ;出口参数:出口参数：al=转换后的ASCII
    ;其他说明:无
    ;=======================================
htoasc PROC
                   and  al,0fh             ;清空高四位
                   add  al,30h             ;+30h
                   cmp  al,39h             ;小于等于39H
                   jbe  htoascl            ;
                   add  al , 7h            ;+7H
    htoascl:       
                   ret
htoasc ENDP
code ends
    end     start
;程序名：t6-11.asm
;功能：在内存中驻留显示时钟的程序
;1CH号中断处理程序使用的常数说明与T5-5.ASM对应部分相同
;通过DOS的31H号功能调用进行驻留退出，该功能调用的主要入口参数
;是含在DX中的驻留节数（1节=16个字节）,
;驻留的内存从程序段前缀开始计算，所以计算驻留节数时，
;除了要计算驻留的代码和数据长度外，还需要加上PSP的10H节256个字节。
assume cs:code,ds:code

code segment
    ;中断处理程序常量定义
    count_val =    18                      ;间隔“滴答”数
    dpage     =    0                       ;显示页号
    row       =    0                       ;显示时钟的行号
    column    =    80-buff_len             ;显示时钟的开始列号
    color     =    07h                     ;显示时钟的属性值
    ;代码
    ;1CH号中断处理程序使用的变量
    count     dw   count_val               ;嘀搭计数
    hhhh      db   ?,?,':'                 ;时
    mmmm      db   ?,?,':'                 ;分
    ssss      db   ?,?                     ;秒
    buff_len  =    $ - offset hhhh         ;buff_len为显示信息长度
    cursor    dw   ?
    OLD1CH    DD   ?
    ;原光标位置
    ;1CH号中断处理程序代码
    new1ch:   
              cmp  cs:count,0              ;计数为0?
              jz   next                    ;为0,显示时钟
    next:     
              mov  cs:count,count_val      ;重置计数值
              sti                          ;开中断
    ;保护寄存器
              push ds
              push es
              push ax
              push bx
              push cx
              push dx
              push si
              push bp
              push cs

              pop  ds                      ;置代码段和数据段相同
              push ds
              pop  es                      ;置附加段和数据段相同
    ;置代码段寄存器
              call get_t                   ;取时间
              mov  bh,dpage
              mov  ah,3                    ;取原光标位置
              int  10h
              mov  cursor,dx               ;保存原光标位置
              mov  bp,offset hhhh
              mov  bh,dpage
              mov  dh,row
              mov  dl,column
              mov  bl,color
              mov  cx,buff_len
              mov  al,0
              mov  ah,13h                  ;显示时钟
              int  10h
              mov  bh,dpage                ;恢复原光标
              mov  dx,cursor
              mov  ah,2
              int  10h
    ;恢复寄存器
              pop  bp
              pop  si
              pop  dx
              pop  cx
              pop  bx
              pop  ax
              pop  es
              pop  ds
    ;调用老的1ch号中断
    ;执行真正的1ch号中断的业务
              jmp  dword ptr cs:OLD1CH
    ;子程序说明信息略
get_t proc
              mov  ah,2                    ;取时间信息
              int  1aH
              mov  al,ch                   ;把时数转为可显示形式
              call ttasc
              xchg ah,al
              mov  word ptr hhhh,ax
              mov  al,cl                   ;把分数转为可显示形式
              call ttasc
              xchg ah,al
              mov  word ptr mmmm,ax
    ;保存
              mov  al,dh                   ;把秒数转为可显示形式
              call ttasc
              xchg ah,al
              mov  word ptr ssss,ax        ;保存
              ret
get_t endp
    ;子程序：ttasc
    ;功能：把两位压缩的BCD码转换为对应的ASCII
    ;入口参数：AL=压缩BCD码
    ;出口参数：AH=高位BCD码所对应的ASCII码，AL=低位BCD码所对应的ASCII码
ttasc proc
              mov  ah,al
              and  al,0fh
              shr  ah,1
              shr  ah,1
              shr  ah,1
              shr  ah,1
              add  ax,3030h
              ret
ttasc endp
    ;初始化部分代码和变量
    start:    
              push cs                      ;置数据段代码段相同
              pop  ds

    ;重置1ch
              mov  ax,351ch                ;取得1c号中断向量，并将其保存到双字变量OLD1CH中
              int  21h
              mov  word ptr OLD1CH,bx
              mov  word ptr OLD1CH+2,es
              mov  dx,offset new1ch        ;DS新中断的段值，DX新中断的偏移
              mov  ax,251ch
              int  21h
              
    ;通过DOS的31H号功能调用进行驻留退出。
    ;该功能调用的主要入口参数是含在DX中的驻留节数（1节等于16字节）
    ;驻留的内容从程序段前级开始计算
    ;所以在计算驻留节数时，除了计算要驻留的数据和代码的长度外，还需要加上PSP的10H节。
              mov  dx,offset start         ;驻留内存的起始气质
              add  dx,15                   ;考虑字节数不是16的倍数的情况
              mov  cl,4                    ;dx右移4位
              shr  dx,cl                   ;转换成节数
              add  dx,10h                  ;加上PSP的长度256个字节

    ;把DOS的31H号功能调用与4CH号功能调用相比，所不同的是它在交出控制权时没有全部交出占用的内存资源，而是根据要求（由入口参数规定）保留了部分
              mov  ah,31h
              int  21h
code ends
end start
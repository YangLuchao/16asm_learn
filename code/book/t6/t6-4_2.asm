;6.2.3应用举例
;例1:设在缓冲区DATA中存放着10个组合的BCD码，求他们的和，把结果存放在缓冲区SUM中
;程序名：t6-4.asm
assume cs:code,ds:data
data segment
    num    db 23h,45h
    ;,67h,89h,32h,93h,36h,12h,66h,78h,43h,99h    ;非压缩bcd码
    result db 4 dup(0),'$'
data ends
code segment
    start: 
           mov  ax,data             ;初始化数据段
           mov  ds,ax

           mov  bx,offset num       ;参数偏移
           mov  cx,2                ;循环10次
           xor  ax,ax               ;清空累加器

    next:  
           add  al,[bx]             ;加法
           daa                      ;加法调整
           adc  ah,0                ;高位进位
           xchg ah,al               ;计算AH,只能使用AL寄存器
           daa                      ;高位加法调整
           xchg ah,al               ;复位
           inc  bx                  ;被加数+1
           loop next                ;处理下一个字节

    
           xchg ah,al               ;准备高低位地址存放，先处理高位
    ;BCD码转换为ASCII码
           call btoasc

           mov  dx,offset result    ;打印输出
           mov  ah,9H
           int  21h

           mov  ax,4c00h            ;退出
           int  21h
    ;子程序名称:btoasc，已被调整后的结果转10进制
    ;功能:把8位二进制数转换为2位十六进制数的ASCII
    ;入口参数:AX=欲转换的4位十进制数,AH存放低两位，AL存放高两位
    ;出口参数:
    ;调用：
    ;result db 4 dup(0),'$'
    ;xchg ah,al
    ;call btoasc
btoasc proc near
           xor  dx,dx               ;清空dx
           mov  si,0
    ;al 值转换并存入缓冲区
           mov  cl,4
           mov  dl,al
           shr  dl,cl
           add  dl,30h
           mov  result[si],dL
           mov  dl,al
           and  dl, 0fh
           add  dl,30h
           mov  result[si+1],dl
    ;ah 值转换并存入缓冲区
           mov  dh,ah
           shr  dh,cl
           add  dh,30h
           mov  result[si+2],dh
           mov  dh,ah
           and  dh,0fh
           add  dh,30h
           mov  result[si+3],dh
           ret
btoasc endp

code ends
end start
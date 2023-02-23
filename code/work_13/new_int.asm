;程序名称:
;功能:请写一个能够显示指定向量号的中断向量程序
;新建188号中断，打印当前时间
;25h号中断就是新建中断
;=======================================
assume      cs:code,ds:data
;常量定义
CMOS_PORT	= 70H		;CMOS端口地址
CMOS_REGA	= 0AH		;状态寄存器A地址
UPDATE_F	= 80H		;更新标志位
CMOS_SEC	= 00H		;秒单元地址
CMOS_MIN	= 02H		;分单元地址
CMOS_HOUR 	= 04H		;时单元地址
CMOS_DAY 	= 07H		;日单元地址
CMOS_MONTH 	= 08H		;月单元地址
CMOS_YEAR 	= 09H		;年单元地址

data segment
    buff db ?    ;一个字节的缓冲区
data ends

code segment
    start:   
             MOV  AX,0
             MOV  DS,AX

    ;方式1
    ;  mov  AL,188                          ;中断向量（类型）号
    ;  mov  DS,SEG now_time                 ;中断处理程序入口地址的段值
    ;  mov  DX,OFFSET now_time              ;中断处理程序入口地址的偏移
    
    ;方式2
             MOV  BX,188*4                        ;准备设置188号中断向量
             CLI                                  ;关中断
    ;关中断
             MOV  WORD PTR[BX],OFFSET now_time    ;置偏移
             MOV  WORD PTR[BX+2],SEG now_time     ;置段值
             STI                                  ;开中断
    ;调用自己定义的中断
             int  188

             mov  ax,4c00h                        ;dos中断
             int  21H

    ;-----------------------------
now_time PROC
    UIP:     
             MOV  AL,CMOS_REGA                    ;判是否可读实时钟
             OUT  CMOS_PORT,AL                    ;准备读状态寄存器A
             JMP  $+2
             IN   AL,CMOS_PORT+1                  ;读状态寄存器A
             TEST AL,UPDATE_F                     ;测更新标志
             JNZ  UIP                             ;如不可读则继续测试
    ;
             MOV  AL,CMOS_YEAR
             OUT  CMOS_PORT,AL
             JMP  $+2
             IN   Al,CMOS_PORT+1                  ;读年值
             call sout

             mov  al,'-'
             call putch

             MOV  AL,CMOS_MONTH
             OUT  CMOS_PORT,AL
             JMP  $+2
             IN   AL,CMOS_PORT+1                  ;读月值
             call sout

             mov  al,'-'
             call putch

             MOV  AL,CMOS_DAY
             OUT  CMOS_PORT,AL
             JMP  $+2
             IN   AL,CMOS_PORT+1                  ;读日值
             call sout

             mov  al,' '
             call putch

             MOV  AL,CMOS_HOUR
             OUT  CMOS_PORT,AL
             JMP  $+2
             IN   AL,CMOS_PORT+1                  ;读时值
             call sout

             mov  al,':'
             call putch

             MOV  AL,CMOS_MIN
             OUT  CMOS_PORT,AL
             JMP  $+2
             IN   AL,CMOS_PORT+1                  ;读分值
             call sout

             mov  al,':'
             call putch

             MOV  AL,CMOS_SEC
             OUT  CMOS_PORT,AL
             JMP  $+2
             IN   AL,CMOS_PORT+1                  ;读秒值
             call sout
             iret
now_time ENDP

sout PROC
             CALL ahtoasc
             mov  buff,al
             mov  al,ah
             call putch
             mov  al,buff
             call putch
             RET
sout ENDP
    ;-----------------------------
    ;显示一个字符
    ;入口参数：al
    ;出口参数：标志输出设备
putch PROC
             PUSH DX
             MOV  DL,AL
             MOV  AH,2
             INT  21H
             POP  DX
             RET
putch ENDP
    ;-----------------------------
    ;子程序名称:ahtoasc
    ;功能:把8位二进制数转换为2位十六进制数的ASCII
    ;入口参数:AL=欲转换的8位二进制数
    ;出口参数:AH=十六进制数高位的ASCII码,AL=十六进制数低位的ASCII码
    ;其他说明:1.近过程，2.除AX寄存器外，不影响其他寄存器3.调用了htoasc实现十六进制到ASCII码转换
    ;=======================================
ahtoasc PROC
             mov  ah,al                           ;al复制到ah
             shr  al,1                            ;AL右移4位
             shr  al,1
             shr  al,1
             shr  al,1
             call htoasc                          ;调用子程序
             xchg ah,al                           ;al,ah对调
             call htoasc                          ;调用子程序
             RET
ahtoasc ENDP
    ;子程序名称:htoasc
    ;功能:一位十六进制数转换为ASCII
    ;入口参数:al=待转换的十六进制数,ds:bx=存放转换得到的ASCII码串的缓冲区首地址
    ;出口参数:出口参数：al=转换后的ASCII
    ;其他说明:无
    ;=======================================
htoasc PROC
             and  al,0fh                          ;清空高四位
             add  al,30h                          ;+30h
             cmp  al,39h                          ;小于等于39H
             jbe  htoascl                         ;
             add  al , 7h                         ;+7H
    htoascl: 
             ret
htoasc ENDP
code ends
    end     start
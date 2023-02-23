;程序名称:
;功能:写一个程序在屏幕中央显示系统当前时间，当同时按下左右SHIFT键时，清屏并结束程序
;方法1
;=======================================
assume      cs:code,ds:data
;执行步骤如下：
;1:清空屏幕
;2:从cmos芯片中拿到时间
;3:在屏幕中间输出时间
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
COLUM = 80;列
line = 24;行
data segment
    buff        db ?                                              ;一个字节的缓冲区
    colum_count db -1
    line_count  db -1
    time        db 0,0,'-',0,0,'-',0,0,' ',0,0,':',0,0,':',0,0
data ends

code segment
    start:      
                MOV  AX,data
                MOV  DS,AX
         
    ;计算光标位子
    outer:      MOV  AH,2                   ;取变换键状态字节
                INT  16H
                cmp  AL,00000011B           ;同时按下左右shift键
                JZ   OVER                   ;按下，转
                MOV  AH,1
                INT  16H                    ;是否有键可读
                JZ   next                   ;没有，转
                MOV  AH,0                   ;读键
                INT  16H
    next:       
                add  line_count,1           ;行+1
                cmp  line_count,line
                jz   home1
                jmp  UIP
    iner:       
                add  colum_count,1          ;列+1
                cmp  colum_count,COLUM
                jz   home
    ;光标位子计算完成
                mov  ah,2                   ;移动光标位子
                mov  dh,line_count
                mov  dl,colum_count
                int  10h
                mov  al,0
                cmp  line_count,10
                jnz  print
                jmp  printLetter
    print:      
                mov  ah,9
                mov  bl,07h
                mov  cx,1
                int  10h
                jmp  iner
    home:       
                mov  colum_count,-1
                jmp  outer
    home1:      
                mov  line_count,-1
                jmp  outer

    printLetter:
                XOR  bx,bx
                cmp  colum_count,30
                jb   print
                cmp  colum_count,47
                ja   print
                mov  bl,colum_count
                sub  bl,27
                mov  al,byte ptr ds:[bx]
                jmp  print


    UIP:        
                MOV  AL,CMOS_REGA           ;判是否可读实时钟
                OUT  CMOS_PORT,AL           ;准备读状态寄存器A
                JMP  $+2
                IN   AL,CMOS_PORT+1         ;读状态寄存器A
                TEST AL,UPDATE_F            ;测更新标志
                JNZ  UIP                    ;如不可读则继续测试
    ;
                MOV  AL,CMOS_YEAR
                OUT  CMOS_PORT,AL
                JMP  $+2
                IN   Al,CMOS_PORT+1         ;读年值
                CALL ahtoasc
                mov  time[0],ah
                mov  time[1],al

                MOV  AL,CMOS_MONTH
                OUT  CMOS_PORT,AL
                JMP  $+2
                IN   AL,CMOS_PORT+1         ;读月值
                CALL ahtoasc
                mov  time[3],ah
                mov  time[4],al

                MOV  AL,CMOS_DAY
                OUT  CMOS_PORT,AL
                JMP  $+2
                IN   AL,CMOS_PORT+1         ;读日值
                CALL ahtoasc
                mov  time[6],ah
                mov  time[7],al

                MOV  AL,CMOS_HOUR
                OUT  CMOS_PORT,AL
                JMP  $+2
                IN   AL,CMOS_PORT+1         ;读时值
                CALL ahtoasc
                mov  time[9],ah
                mov  time[10],al

                MOV  AL,CMOS_MIN
                OUT  CMOS_PORT,AL
                JMP  $+2
                IN   AL,CMOS_PORT+1         ;读分值
                CALL ahtoasc
                mov  time[12],ah
                mov  time[13],al

                MOV  AL,CMOS_SEC
                OUT  CMOS_PORT,AL
                JMP  $+2
                IN   AL,CMOS_PORT+1         ;读秒值
                CALL ahtoasc
                mov  time[15],ah
                mov  time[16],al
                jmp  iner
    over:       
                mov  ax,4c00h               ;dos中断
                int  21H
    ;子程序名称:ahtoasc
    ;功能:把8位二进制数转换为2位十六进制数的ASCII
    ;入口参数:AL=欲转换的8位二进制数
    ;出口参数:AH=十六进制数高位的ASCII码,AL=十六进制数低位的ASCII码
    ;其他说明:1.近过程，2.除AX寄存器外，不影响其他寄存器3.调用了htoasc实现十六进制到ASCII码转换
    ;=======================================
ahtoasc PROC
                mov  ah,al                  ;al复制到ah
                shr  al,1                   ;AL右移4位
                shr  al,1
                shr  al,1
                shr  al,1
                call htoasc                 ;调用子程序
                xchg ah,al                  ;al,ah对调
                call htoasc                 ;调用子程序
                RET
ahtoasc ENDP
    ;子程序名称:htoasc
    ;功能:一位十六进制数转换为ASCII
    ;入口参数:al=待转换的十六进制数,ds:bx=存放转换得到的ASCII码串的缓冲区首地址
    ;出口参数:出口参数：al=转换后的ASCII
    ;其他说明:无
    ;=======================================
htoasc PROC
                and  al,0fh                 ;清空高四位
                add  al,30h                 ;+30h
                cmp  al,39h                 ;小于等于39H
                jbe  htoascl                ;
                add  al , 7h                ;+7H
    htoascl:    
                ret
htoasc ENDP
code ends
    end     start
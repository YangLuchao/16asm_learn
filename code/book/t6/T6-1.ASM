;程序名：T6-1.ASM
;功能：接收一个字符串，去掉其中的空格后按相反的顺序显示它符号
;常量的定义
MAXLEN	=	64	;字符串最大长度
SPACE 	= 	' '	;空格
CR 		= 	0DH	;回车符
LF 		= 	0AH	;换行符
;数据段的定义
;
DSEG SEGMENT
      BUFFER DB MAXLEN+1
             DB 0
             DB MAXLEN+1 DUP (0)
      STRING DB MAXLEN+3 DUP (0)
DSEG ENDS
;代码
CSEG SEGMENT
            ASSUME CS:CSEG,DS:DSEG,ES:DSEG
      START:
            MOV    AX,DSEG
            MOV    DS,AX
            MOV    ES,AX                        ;DS=ES

            MOV    DX,OFFSET BUFFER             ;
            MOV    AH,10
            INT    21H                          ;接收一个字符串
            XOR    CH,CH                        ;CH清空
            MOV    CL,BUFFER+1                  ;输入的字符串长度
            JCXZ   OK                           ;字符串长度为0.则结束
            CLD                                 ;DF标识置0，递增
            MOV    SI,OFFSET BUFFER+2           ;字符串1起始地址
            MOV    DI,OFFSET STRING             ;字符串2起始地址
            XOR    AL,AL                        ;清空AL
      ;将AL中的字节存入到DI所指的存储内,al=0
            STOSB                               ;将AL中的字节存入到DI所指的存储内
      ; al=' '
            MOV    AL,SPACE                     ;空格放入到AL中
      ; 设
      ; 1:
      ; 1 23
      ; 2:
      ; 0000
      ; si—>1=0
      ; di—>2=0
      PP1:  
            XCHG   SI,DI                        ;SI,DI交换，DI指向字符串1起始地址，SI指向字符串2起始地址
      ; si->2=0
      ; di->1=0
      ;REPZ:cx=0或ZF=1退出
      ;SCASB:al中的内容和di所指的内容比较，结果反映在flag中，al=空格
      ;di所指的字符比较空格，相等则退出循环 di = 2
            REPZ   SCASB                        ;去掉空格,比较字符串1,2的每一个字节
      ; si->1=2
      ; di->2=0
            XCHG   SI,DI                        ;找到一个空格，si与di交换,DI指向字符串2起始地址，SI指向字符串1起始地址
            JCXZ   PP3                          ;cx=0,如已到尾，转
      ; si-1=空格的偏移
      ; si->1=1
            DEC    SI                           ;恢复被REPZ SCASB指令扫过的字符
      ; 计数+1
      ; cx+1
            INC    CX                           ;及计数
      PP2:  
      ;判断当前si所指的字符是空格
            CMP    BYTE PTR[SI],SPACE           ;欲传字符为空格？
      ;是空格，去掉空格
      ; [si]=' ' 转
            JZ     PP1                          ;是，去掉空格
      ;mov [si],[di]
            MOVSB                               ;传一字符
      ;处理下一个字符
            LOOP   PP2                          ;下一个
      PP3:  
            MOV    AL,CR
      ;mov [di],al
            STOSB                               ;存入回车符
            MOV    AL,LF
            MOV    [DI],AL                      ;存入换行符
            STD                                 ;置方向标志,反方向递减
            MOV    SI,DI
      PP4:  
      ;mov al,[si]
            LODSB                               ;按相反顺序取字符
            OR     AL,AL
            JZ     OK                           ;结束，转
            MOV    DL,AL
            MOV    AH,2
            INT    21H                          ;显示字符
            JMP    PP4                          ;
      ;
      OK:   
            MOV    AH,4CH
            INT    21H
CSEG ENDS
		END		START
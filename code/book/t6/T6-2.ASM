;程序名：T6-2.ASM
;功能：完成两个由用户输入的10位十进制数的加法运算
;常数定义
MAXLEN 	= 	10			;最多10位数
BUFFLEN = 	MAXLEN+1	;缓冲区长度
;数据段
DSEG SEGMENT
    BUFF1  DB BUFFLEN                          ;被加数长度
           DB 0                                ;被加数字数
           DB BUFFLEN DUP (?)                  ;存放被加数
    NUM1   =  BUFF1 + 2                        ;相当于把地址buff向后偏移两个字节的内容复制个num1，num1里存放的是字符内容
    BUFF2  DB BUFFLEN                          ;加数长度
           db 0                                ;加数个数
           db BUFFLEN DUP (?)                  ;存放加数
    NUM2   =  BUFF2+2
    RESULT DB BUFFLEN DUP (?),24H              ;存放和
    ; RESULT DB 03h,03h,01h,04h,0,0,0,0,0,0,24h
    DIGITL DB '0123456789'                     ;有效的十进制数字符
    DIGLEN =  $ - DIGITL
    MESS   DB 'Invalid number!',0DH,0AH,24H
DSEG ENDS
;代码段
CSEG SEGMENT
             ASSUME CS:CSEG,DS:CSEG,ES:CSEG
    START:   
             MOV    AX,DSEG
             MOV    DS,AX                      ;置DS和ES
             MOV    ES,AX

    ;接收加数与被加数
             MOV    DX,OFFSET BUFF1
             CALL   GETNUM                     ;(1)接收被加数
             JC     OVER                       ;不合法时，处理
             
             MOV    DX,OFFSET BUFF2
             CALL   GETNUM                     ;(2)接收加数
             JC     OVER                       ;不合法时，处理

    ;si指向加数偏移
             MOV    SI,OFFSET NUM1
    ;di指向被加数偏移
             MOV    DI,OFFSET NUM2
    ;bx指向和的地址
             MOV    BX,OFFSET RESULT
    ;cx存放循环最大次数
             MOV    CX,MAXLEN
             CALL   ADDITION                   ;(3)加运算

             MOV    DX,OFFSET RESULT
             CALL   DISPNUM                    ;(4)显示结果
             JMP    SHORT OK
    OVER:    
             MOV    DX,OFFSET MESS             ;出错处理
             MOV    AH,9
             INT    21H
    OK:      
             MOV    AH,4CH
             INT    21H
    ;
    ;子程序名：GETNUM
    ;功能：接收一个十进制数字串，且扩展成10位
    ;入口参数：DX=缓冲区偏移
    ;出口参数：CF=0,表示成功
    ;		CF=1,表示不成功
GETNUM PROC
             MOV    AH,0ah                     ;接收一个字符串
             INT    21H

             CALL   NEWLINE                    ;产生回车和换行
             CALL   ISDNUM                     ;判是否为十进制数字串
             JC     GETNUM2                    ;不是，转
             MOV    SI,DX
             INC    SI
             MOV    CL,[SI]                    ;取输入的数字串长度
             XOR    CH,CH
             MOV    AX,MAXLEN
             STD
             MOV    DI,SI
             ADD    DI,AX
             ADD    SI,CX
             SUB    AX,CX
             REP    MOVSB                      ;数字串向高地址移让出低地址
             MOV    CX,AX
             JCXZ   GETNUM1
             XOR    AL,AL                      ;低地址的高位用0补足
             REP    STOSB
    GETNUM1: 
             CLD
             CLC
    GETNUM2: 
             RET
GETNUM ENDP
    ;
    ;子程序名：ADDITION
    ;功能：多位非组合BCD码数加
    ;入口参数：SI=代表被加数的非组合BCD码串开始地址偏移
    ;		DI=代表加数的非组合BCD码串开始地址偏移
    ;		CX=BCD码串长度（字节数）
    ;		BX=存放结果的缓冲区开始地址偏移
    ;出门参数：结果缓冲区含结果
    ;说明：在非组合的BCD码中，十进制数的高位在低地址
ADDITION PROC
             STD                               ;准备从在高地址的低位开始处理，倒序处理，从低位开始处理
    ;调整指针指向，都指向最低位
             ADD    BX,CX                      ;BX指向结果缓冲区最后一字节
             ADD    SI,CX                      ;指向加数的最后一个字节
             ADD    DI,CX                      ;指向被加数的最后一个字节
             DEC    SI                         ;SI指向被加数串最后一字节
             DEC    DI                         ;DI指向加数串最后一字节
    ;BX指向加数串，DI指向结果串
             XCHG   DI,BX
    ;循环前的指针预调整
             INC    BX
    ;进位符清0，为后续进位做准备
             CLC
    ADDP1:   
    ;bx-1
             DEC    BX
             LODSB                             ;取一字节被加数
             ADC    AL,[BX]                    ;加上加数（带上低位的进位）
    ;整理结果，十进制加法调整非压缩BCD码指令
             AAA                               ;调整
    ;保存结果
             STOSB                             ;保存结果
    ;处理下一位
             LOOP   ADDP1                      ;循环处理下一个
    ;处理最高位计算完成后的进位
             MOV    AL,0
             ADC    AL,0                       ;考虑最后一次进位
             AAA
             STOSB                             ;保存之
    ;DF位置0
             CLD
             RET
ADDITION ENDP
    ;
    ;子程序名：DISPNUM
    ;功能：显示结果
    ;入口参数：DX=结果缓冲区开始地址偏移
    ;出口参数：无
DISPNUM PROC
             MOV    DI,DX
             MOV    AL,0
             MOV    CX,BUFFLEN

             REPZ   SCASB                      ;跳过前导的0
             DEC    DI
             MOV    DX,DI
             MOV    SI,DI
             INC    CX
    DISPNU2: 
             LODSB                             ;把非组合BCD码串转换成ASCII码串
             ADD    AL,30H
             STOSB
             LOOP   DISPNU2

             MOV    AH,9                       ;显示结果
             INT    21H
             RET
DISPNUM ENDP
    ;
    ;子程序名：ISDNUM
    ;功能：判一个利用DOS的0AH号功能调用输入的字符串是否为数字符串
    ;人口参数：DX=缓冲区开始地址偏移
    ;出口参数：CF=0,表示是；CF=1,表示否
ISDNUM PROC
             MOV    SI,DX
             LODSB
             LODSB                             ;AL=字符串长度
             MOV    CL,AL
             XOR    CH,CH
             JCXZ   ISDNUM2                    ;空串认为非数字串
    ISDNUM1: 
             LODSB                             ;取一个字符
             CALL   ISDECM                     ;判该字符是否为数字符
             JNZ    ISDNUM2                    ;不是，转
             LOOP   ISDNUM1                    ;是，下一个
             RET
    ISDNUM2: 
             STC
             RET
ISDNUM ENDP
    ;
    ;子程序名：ISDECM
    ;功能：判一个字符是否为十进制数字符
    ;入口参数：AL=字符
    ;出口参数：ZF=1,表示是,ZF=0.表示否
ISDECM PROC
             PUSH   CX
             MOV    DI,OFFSET DIGITL
             MOV    CX,DIGLEN
             REPNZ  SCASB
             POP    CX
             RET
ISDECM ENDP
    ;----------------------------------------------
    ;子程序名：newline
    ;功能：形成回车和换行（光标移到下一行首)
    ;入口参数：无
    ;出口参数：无
    ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
             push   ax
             push   dx
             mov    dl,0dh                     ;回车符的ASCII码
             mov    ah,2
    ;显示回车符
             int    21h
             mov    dl,0ah                     ;换行符的ASCII码
             mov    ah,2
    ;显示换行符
             int    21h
             pop    dx
             pop    ax
             ret
newline endp
CSEG ENDS
			END 	START
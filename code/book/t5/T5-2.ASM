;源程序名：T5-2.ASM
;功能：(略）
;常量定义
ROW = 5			;显示信息的行号
COLUM = 10		;列号
ESCKEY = 1BH		;ESC键的ASCII码值
;数据段
DSEG SEGMENT
      MESS     DB     'HELLO'                  ;显示信息
      MESS_LEN =      $-OFFSET MESS            ;显示信息长度
      COLORB   DB     07H,17H,0FH,70H,74H      ;颜色
               COLORE LABEL BYTE
DSEG ENDS
;代码段
CSEG SEGMENT
            ASSUME CS:CSEG,DS:DSEG
      START:
            MOV    AX,DSEG
            MOV    DS,AX                   ;设置数据段段值
            MOV    DI,OFFSET COLORB-1      ;颜色指针初值
      NEXTC:
            INC    DI                      ;调整颜色指针
            CMP    DI,OFFSET COLORE        ;是否超过指定的最后一种颜色
            JNZ    NEXTE                   ;否
            MOV    DI,OFFSET COLORB        ;是，重新指定第一种颜色
      NEXTE:
            MOV    BL,[DI]                 ;取颜色
            MOV    SI,OFFSET MESS          ;取显示信息指针
            MOV    CX,MESS_LEN             ;取显示信息长度
            MOV    DH,ROW                  ;置显示开始行号
            MOV    DL,COLUM                ;置显示开始列号
            CALL   ECH                     ;显示
            MOV    AH,0
            INT    16H
            CMP    AL,ESCKEY               ;是否为ESC键
            JNZ    NEXTC                   ;不是，继续
		
            MOV    AX,4C00H                ;结束
            INT    21H
      ;
      ;子程序名：ECHO
      ;功能：直接写屏显示字符串
      ;入口参数：DS:S1=字符串首地址
      ;CX=字符串长度
      ;BL=属性,DH=显示开始行号
      ;DL=显示开始列号
      ;出口参数：无
ECH PROC
            MOV    AX,0B800H
            MOV    ES,AX                   ;设置显示段段值
            MOV    AL,80                   ;计算显示开始位置偏移
            MUL    DH                      ;偏移=(行号*80+列号）*2
            XOR    DH,DH
            ADD    AX,DX
            ADD    AX,AX
            XCHG   AX,BX
            MOV    AH,AL                   ;属性值保存到AH寄存器
            JCXZ   ECHO2                   ;显示信息长度是否为0
      ECHO1:
            MOV    AL,[SI]                 ;取一要显示字符代码
            INC    SI                      ;调整指针
            MOV    ES:[BX],AX              ;送显示存储区，即显示
            INC    BX                      ;准备显示下一个字符
            INC    BX
            LOOP   ECHO1                   ;循环显示
      ECHO2:RET                            ;返回
ECH ENDP
CSEG ENDS
		END 	START
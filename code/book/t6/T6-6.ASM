;程序名：T6-6.ASM
;功能：(略）
CR  = 	0DH 	;回车
LF	=	0AH     ;换行
ESCAPE = 1BH    ;esc
CSEG SEGMENT                            ;代码段
            ASSUME CS:CSEG,DS:CSEG
      START:
            PUSH   CS
            POP    DS                   ;置代码段=数据段
      CONT: 
            MOV    AH,8                 ;用不回显方式，接收一个字符
            INT    21H

            CMP    AL,ESCAPE            ;是否为ESC键？
            JZ     SHORT XIT            ;是，结束

            MOV    DL,AL
            MOV    AH,2                 ;否，显示所按字符
            INT    21H
          
            CMP    DL,CR                ;是否为回车键？
            JNZ    CONT                 ;否，继续
            MOV    AH,2                 ;显示
            INT    21H

            MOV    DL,LF
            MOV    AH,2                 ;是，再显示换行符（形成回车和换行）
            INT    21H
            JMP    CONT                 ;继续
      XIT:  
            MOV    AH,4CH               ;结束
            INT    21H
CSEG ENDS
	END 	START
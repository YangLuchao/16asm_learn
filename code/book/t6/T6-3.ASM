;程序名：T6-3.ASM
;功能：显示信息“HELLO”
ASSUME CS:CSEG,DS:DSEG

SSEG SEGMENT PARA STACK        ;堆栈段
         DW 256 DUP(?)
SSEG ENDS

DSEG SEGMENT                       ;数据段
    MESS DB 'HELLO',0DH,0AH,'$'
DSEG ENDS

CSEG SEGMENT                     ;代码段
          
MAIN PROC 	FAR
    START:
    ;在没有指定DS之前，ds为本程序的PSP
          PUSH DS                ;把PSP的段值压入堆栈

          XOR  AX,AX
          PUSH AX                ;把0000H(偏移）压入堆栈

          MOV  AX,DSEG
          MOV  DS,AX

          MOV  DX,OFFSET MESS
          MOV  AH,9
          INT  21H
          
    ;ret指令相当于
    ;pop cs
    ;pop ip
    ;call cs:ip
          RET                    ;转PSP的偏移0处执行
MAIN ENDP
CSEG ENDS
		END 	START
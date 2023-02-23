;程序名：T5-1.ASM
;功能：(略）
;常量定义
L_SHIFT=00000010B
R_SHIFT=00000001B
;代码段
CSEG SEGMENT
            ASSUME CS:CSEG
      START:
            MOV    AH,2              ;取变换键状态字节
            INT    16H
            cmp    AL,00000010B      ;同时按下左右shift键
            JZ     OVER              ;按下，转
            MOV    AH,1
            INT    16H               ;是否有键可读
            JZ     START             ;没有，转
            MOV    AH,0              ;读键
            INT    16H
            MOV    DL,AL             ;显示所读键
            MOV    AH,6
            INT    21H
            JMP    START             ;继续
      OVER: 
            MOV    AH,4CH
            INT    21H               ;结束
CSEG ENDS
		END 	START
;程序名：T8-4G.ASM
;功能：(略）
DSIS2 	GROUP 	DSEG1,DSEG2			;说明段组
;
DSEG1 SEGMENT PUBLIC        ;数据段1
    VAR1  DB ?
DSEG1 ENDS
;
DSEG2 SEGMENT PUBLIC        ;数据段2
    VAR2  DB ?
DSEG2 ENDS
;
CSEG SEGMENT PARA PUBLIC             ;代码段
          ASSUME CS:CSEG,DS:DSIS2    ;使DS对应组DS1S2
    START:
          MOV    AX,DSIS2
          MOV    DS,AX               ;置DS寄存器
          MOV    BL,VAR1
    ;......
          MOV    VAR2,BL
    ;......
          MOV    AH,4CH
          INT    21H
CSEG ENDS
		END 	START
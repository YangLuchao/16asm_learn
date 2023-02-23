;子程序名：HTOASC
;功能：把一位十六进制数转换为对应的ASCII码
;入口参数，AL的低4位为要转换的十六进制数
;出口参数：AL含对应的ASCII码
HTOASC2 	PROC
		AND 	AL,0FH      ;清空AL低4位
		ADD		AL,90H      ;高4位+90H
		DAA		
		ADC		AL,40H
		DAA
		RET
HTOASC2 	ENDP
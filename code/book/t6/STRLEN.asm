;子程序名：STRLEN
;功能：测字符串长度
;入口参数：ES:DI=字符串首地址的段值：偏移
;出口参数：AX=字符串长度
;说明：字符串以0结尾；字符串长度不包括结尾标志
STRLEN 	PROC
		PUSH 	CX			;保护CX
		PUSH 	DI			;保护DI
		CLD					;DF清0，正向递增
		XOR		AL,AL		;使AL含结束标志值
		MOV 	CX,0FFFFH	;取字符串长度极值
		REPNZ 	SCASB		;搜索结束标志0
		MOV 	AX,CX
		NOT		AX			;得字符串包括结束标志在内的长度
		DEC 	AX			;减结束标志1字节
		POP		DI
		POP		CX
		RET
STRLEN 	ENDP
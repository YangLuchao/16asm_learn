;子程序名：FILLB
;功能：用指定字符充填指定缓冲区
;入口参数：ES:DI=缓冲区首地址
;		CX=缓冲区长度，AL=充填字符
;出口参数：无
FILLB 	PROC
		PUSH 	AX
		PUSH 	DI
		JCXZ 	FILLB_1		;CX值为0时直接跳过（可省）
		CLD                 ;DF标识置0
		SHR 	CX,1		;字节数转成字数
		MOV 	AH,AL		;使AH与AL相同
		REP  	STOSW		;按字充填
		JNC 	FILLB_1		;如果缓冲区长度为偶数，则转
		STOSB				;补缓冲区长度为奇数时的一字节
FILLB_1:
		POP		DI
		POP		AX
		RET
FILLB 	ENDP
;子程序名：STRCAT
;功能：在字符串1末追加字符串2
;入口参数：DS:SI=字符串1起始地址的段值:偏移
;		 DS:DI=字符串2起始地址的段值:偏移
;出口参数：无
;说明：不考虑在字符串1后是否留有足够的空间
STRCAT 	PROC
		PUSH 	ES
		PUSH 	AX
		PUSH 	CX
		PUSH 	SI
		PUSH 	DI
		CLD                     ;DF置0，正向递增
		PUSH 	DS
		POP		ES				;使ES同DS
		PUSH 	DI              ;暂存DI
		MOV 	DI,SI           ;di=si
		XOR 	AL,AL           ;al清0
		MOV 	CX,0FFFFH       ;查找次数最大值
		REPNZ 	SCASB			;确定字符串1的尾地址
		LEA 	SI,[DI-1]		;SI指向字符串1的结束标志
		POP 	DI              ;DI还原
		MOV 	CX,0FFFFH
		REPNZ 	SCASB			;测字符串2的长度
		NOT 	CX				;CX为字符串2包括结束标志的长度，CX--后取反就得到循环次数的正数
		SUB		DI,CX			;DI再次指向字符串2的首
		XCHG 	SI,DI			;为拼接作准备
		TEST 	SI,1			;字符串2是否从奇地址开始？
		JZ 		STRCAT1         ;是基数地址开始的，跳
		MOVSB					;特别处理第一字节
		DEC 	CX              ;cx-1
STRCAT1:
		SHR		CX,1			;移动数据块长度除2
		REPZ 	
        MOVSW			        ;字移动
		JNC 	STRCAT2
		MOVSB					;补字移动时遗留的一字节
STRCAT2:
		POP		DI
		POP 	SI
		POP 	CX
		POP 	AX
		POP 	ES
		RET
STRCAT 	ENDP
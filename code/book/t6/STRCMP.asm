;子程序名：STRCMP
;功能：比较字符串是否相同
;入口参数：DS:SI=字符串1首地址的段值:偏移
;		 ES:DI=字符串2首地址的段值:偏移
;出口参数：AX=0表示两字符串相同，否则表示字符串不同
;说明：设字符串均以0为结束标志
STRCMP 	PROC
		CLD
		PUSH	DI
		XOR		AL,AL		;先测一个字符串的长度，AL清0
		MOV 	CX,0FFFFH	;重复次数
NEXT:
		SCASB				;将AL的内容和DI所指的内容进行比较
		JNZ 	NEXT		;计算字符串2的长度
		NOT 	CX			;至此CX含字符串2的长度（包括结束标志）
		POP		DI			;弹出DI
		REPZ	CMPSB		;SI所指的字节与DI所指的字节进行比较，两个串比较（包括结束标志在内）,cx=0或ZF=0停止比较
		MOV 	AL,[SI-1]	;比较完成，字符串1的上一个字节挪到AL中
		MOV 	BL,ES:[DI-1];比较完成，字符串2的上一个字节挪到BL中
		XOR 	AH,AH		;如两个字符串相同，则AL应等于BL
		MOV 	BH,AH
		SUB 	AX,BX		;完全相等，AX=0
		RET
STRCMP 	ENDP
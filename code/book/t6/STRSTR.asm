;子程序名：STRSTR
;功能：判字符串2是否为字符串1的子串
;入口参数：指向字符串的远指针（见调用方法）
;出口参数：DX:AX返回指向字符串2在字符串1中首次出现处的指针
;说明：调用方法如下：
;(1)压入字符串2的远指针
;(2)压入字符串1的远指针
;(3)CALL FAR PTR STRSTR
STRSTR 	PROC 	FAR
		PUSH 	BP				    ;此前的堆找如图6.3(a)所示
		MOV 	BP,SP

		PUSH 	DS
		PUSH 	ES
		PUSH 	BX				    ;保护有关寄存器
		PUSH 	CX
		PUSH 	SI
		PUSH	DI				    ;此时的堆栈如图6.3(b)所示

		LES 	BX,[BP+10]		    ;取STR2指针
		CMP 	BYTE PTR ES:[BX],0	;判STR2是否为空串
		JNZ 	STRSTR1			    ;否
		MOV 	DX,[BP+8]+STR2	    ;为空串时
		MOV 	AX,[BP+6]		    ;返回STR1指针
		JMP 	SHORT STRSTR6
STRSTR1:
		CLD                         ;清DF标识为0
		LES 	DI,[BP+6]		    ;取STR1指针
		PUSH 	ES                  ;暂存附加段段值
		MOV 	BX,DI			    ;STR1偏移送BX寄存器
		XOR 	AX,AX               ;AX清空
		MOV 	CX,0FFFFH           ;循环最大次数
		REPNZ 	SCASB			    ;测STR1长度
		NOT 	CX                  ;测得STR1的长度
		MOV 	DX,CX			    ;使DX含STR1长度（含结束标志）
		LES 	DI,[BP+10]		    ;取STR2指针
		PUSH 	ES                  ;暂存附加段的段值
		MOV 	BP,DI			    ;STR2偏移送BP寄存器
		XOR 	AX,AX               ;AX清空       
		MOV 	CX,0FFFFH           ;循环最大次数
		REPNZ 	SCASB			    ;测STR2长度
		NOT 	CX
		DEC 	CX				    ;CX为STR2长度
		POP 	DS				    ;此时，DS:BP指向STR2
		POP 	ES				    ;ES:BX指向STR1
STRSTR2: 
		MOV 	SI,BP			    ;DS:SI指向STR2
		LODSB					    ;取STR2的第一个字符
		MOV 	DI,BX
		XCHG 	CX,DX			    ;使CX含STR1长度，DX含STR2长度
		REPNZ 	SCASB			    ;在STR1中搜索STR2的第一个字符
		MOV 	BX,DI
		JNZ 	STRSTR3			    ;找到？
		CMP 	CX,DX			    ;找到，STR1剩下的字符数比STR2长？
		JNB 	STRSTR4			    ;是转
STRSTR3: 
		XOR 	BX,BX			    ;找不到处理
		MOV 	ES,BX
		MOV 	BX,1
		JMP 	SHORT STRSTR5
STRSTR4:
		XCHG	CX,DX			    ;使CX含STR2长度，DX含STR1长度
		MOV 	AX,CX
		DEC 	CX
		REPZ 	CMPSB			    ;判STR1中是否有STR2后的其它字符
		MOV 	CX,AX
		JNZ 	STRSTR2			    ;没有，转继续找
		;
STRSTR5: 
		MOV 	AX, BX			    ;找到！
		DEC 	AX				    ;准备返回值
		MOV 	DX,ES			
		;
STRSTR6:
		POP		DI
		POP 	SI
		POP 	CX
		POP		BX				    ;恢复有关寄存器
		POP		ES
		POP 	DS
		POP 	BP
		RET						    ;RETF
STRSTR 	ENDP
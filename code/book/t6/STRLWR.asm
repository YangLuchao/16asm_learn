;子程序名：STRLWR
;功能：把字符串中的大写字母转化为小写（字符串以0结尾）
;入口参数：DS:SI=字符串首地址的段值:偏移
;出口参数：无
STRLWR 	PROC
		PUSH 	SI              ;保护SI
		CLD			            ;清方向标志（以便按增值方式调整指针）
		JMP 	SHORT STRLWR2   ;跳到STRLWR2
STRLWR1:
		SUB 	AL,'A'          ;减一个A
		CMP 	AL,'Z'-'A'      ;和26比较，看是不是大写字母
		JA 		STRLWR2         ;>26跳，不是大写字母，处理下一个字符
		ADD 	AL,'a'          ;小写转大写
		MOV		[SI-1],AL		;注意指针已被调整
STRLWR2:
		LODSB					;si指向的字节移到al中，同时si++
		AND		AL,AL           ;与运算，有0为0，判断字符串是否已完结；并且不会破坏原有的值
		JNZ 	STRLWR1         ;没有完结
		POP 	SI              ;si还原
		RET
STRLWR 	ENDP
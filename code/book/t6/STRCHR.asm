;子程序名：STRCHR
;功能：判字符是否属于字符串
;人口参数：DS:SI=搜索字符串首地址的段值，偏移
;		AL=字符代码
;出口参数：CF=0表示字符在字符串中，AX=字符首次出现处的偏移,
;		CF=1表示字符不在字符串中
STRCHR 	PROC
		PUSH 	BX
		PUSH 	SI
		CLD		            ;串处理标志置0，正向递增
		MOV 	BL,AL		;字符复制到BL寄存器
		TEST 	SI,1		;判地址是否为偶，从0开始计数
		JZ 		STRCHR1		;是，转
		LODSB				;取第一个字符，放入AL中
		CMP 	AL,BL       ;比较第一个字符
		JZ 		STRCHR3     ;相等，
		AND 	AL,AL       ;不相等
		JZ 		STRCHR2     ;判断是否为字符串结尾
STRCHR1:
		LODSW				;取一个字
		CMP		AL,BL		;比较低字节
		JZ 		STRCHR4     ;低字节相等
		AND 	AL,AL       ;判断低字节是否为0
		JZ 		STRCHR2     ;字符串循环完成
		CMP 	AH,BL		;比较高字节
		JZ 		STRCHR3     ;相等，跳转到SI+1
		AND 	AH,AH       ;判断高字节是否为0
		JNZ 	STRCHR1     ;不为0，继续处理下个字
STRCHR2:
		STD
		JMP 	SHORT STRCHR5
STRCHR3:
		INC 	SI          ;
STRCHR4:
		LEA 	AX,[SI-2]   ;
STRCHR5:
		POP SI
		POP BX
		RET
STRCHR 	ENDP
;文件名：386SCD.ASM
;内容：符号常量等的定义
;------------------------------------------------
;存储段描述符/系统段描述符结构类型的定义
DESCRIPTOR 	STRUC
	LIMIT		DW	0		;段界限(0~15)
	BASEL		DW 	0		;段基地址(0~15)
	BASEM 		DB 	0 		;段基地址(16~23)
	ATTRIBUTES 	DW  0		;段属性
	BASEH 		DB 	0 		;段基地址(24~31)
DESCRIPTOR ENDS
;------------------------------------------------
;门描述符结构类型的定义
;门结构类型定义
GATE		STRUC		
	OFFSETL		DW	0		;32位偏移的低16位
	SELECTOR 	DW 	0 		;选择子
	DCOUNT 		DB 	0 		;双字计数字段
	GTYPE		DB	0		;类型
	OFFSETH		DW	0		;32位偏移的高16位
GATE		ENDS
;-----------------------------------------------
;伪描述符结构类型的定义
PDESC 		STRUC
	LIMIT		DW 	16 		;界限
	BASE		DD	0 		;基地址
PDESC		ENDS
;------------------------------------------------
;任务状态段TSS结构类型的定义
TASKSS 		STRUC
	TRLINK		DW	?,0		;链接字
	TRESP0		DD	?		;0级堆栈指针
	TRSS0		DW 	?,0
	TRESP1		DD	?		;1级堆栈指针
	TRSS1		DW 	?,0
	TRESP2		DD	?		;2级堆栈指针
	TRSS2		DW 	?,0
	TRCR3		DD 	? 		;CR3
	TREIP		DD 	? 		;EIP
	TREFLAG 	DW 	?,? 	;EFLAGS
	TREAX		DD 	? 		;EAX
	TRECX		DD 	? 		;ECX
	TREDX		DD 	? 		;EDX
	TREBX		DD 	? 		;EBX
	TRESP		DD 	? 		;ESP
	TREBP		DD 	? 		;EBP
	TRESI		DD 	? 		;ESI
	TREDI		DD 	? 		;EDI
	TRES		DW	?,0		;ES
	TRCS		DW 	?,0		;CS
	TRSS		DW 	?,0 	;SS
	TRDS		DW 	?,0 	;DS
	TRFS		DW 	?,0 	;FS
	TRGS		DW 	?,0 	;GS
	TRLDT		DW 	?,0 	;LDT
	TRFLAG		DW	0		;TSS的特别属性字
	TRIOMAP		DW	$ + 2	;指向1/0许可位图区的指针
TASKSS ENDS
;-----------------------------------------------------
;存储段描述符类型值说明
;   属性9XH，就是R0，有效存储段描述符
;   属性8XH，就是R0，有效的系统段、门描述符
ATDR 		=		90H		;存在的只读数据段类型值
ATDW		=		92H		;存在的可读写数据段类型值
                            ;0092H的二进制表示为：0000 0000 1001 0010
                            ;0 0 0 0    0000    1 00    1   0010
                            ;G D 0 AVL  LIMIT   P DPL   DT  TYPE
                            ;G=0:界限粒度为字节
                            ;P=1表示描述符对地址转换是有效
                            ;DPL表示描述符特权级
                            ;DT=1，段储存描述符
                            ;TYPE=2:读/写
                            ;所以0092H的含义是：R0可读写数据段

ATDWA		=		93H		;存在的已访问可读写数据段类型值
ATCE		=		98H		;存在的只执行代码段类型值
ATCER		=		9AH		;存在的可执行可读代码段类型值
ATCCO		=		9CH		;存在的只执行一致代码段类型值
ATCCOR 		=		9EH		;存在的可执行可读一致代码段类型值
;系统段描述符类型值说明
ATLDT		=		82H		;局部描述符表段类型值
                            ;82H的二进制表示为：1000 0010
                            ;1 00    0   0010
                            ;P DPL   DT  TYPE
                            ;P=1表示描述符对地址转换是有效
                            ;DPL表示描述符特权级
                            ;DT=0，表示系统段描述符或门描述符
                            ;TYPE=2 LDT
                            ;所以82H的含义是：LDT系统段描述符

ATTASKGAT	=		85H		;任务门类型值
							;85H的二进制表示为：1000 0101
							;1 00    0   0101
							;P DPL   DT  TYPE
							;P=1表示描述符对地址转换是有效
							;DPL表示描述符特权级
							;DT=0，表示系统段描述符或门描述符
							;TYPE=5 任务门

AT386TSS	=		89H		;386TSS类型值
							;89H的二进制表示为：1000 1001
							;0 0 0 0    0000    1 00    0   1001
							;G X 0 AVL  LIMIT   P DPL   DT  TYPE
							;G=0:界限粒度为字节
							;P=1表示描述符对地址转换是有效
							;DPL表示描述符特权级
							;DT=0，表示系统段描述符或门描述符
							;TYPE=9 可用386TSS
;门描述符类型值说明
AT386CGAT 	=		8CH		;386调用门类型值
							;8CH的二进制表示为：1000 1100
							;1 00  0  1100
							;P DPL DT TYPE 
							;P=1表示描述符对地址转换是有效
							;DPL表示描述符特权级
							;DT=0，表示系统段描述符或门描述符
							;TYPE=C 386调用门

AT386IGAT	=		8EH		;386中断门类型值
AT386TGAT	=		8FH		;386陷阱门类型值
;DPL和RPL值说明
DPL1		=		20H		;DPL=1
DPL2		=		40H		;DPL=2
DPL3		= 		60h		;DPL=3

RPL1 		= 		01H		;RPL=1
RPL2 		= 		02H 	;RPL=2
RPL3 		= 		03H 	;RPL=3

IOPL1 		= 		1000H 	;IOPL=1
IOPL2 		= 		2000H 	;IOPL=2
IOPL3	 	= 		3000H 	;IOPL=3
;其他常量值说明
D32			=		4000H	;32位代码段标志
TIL			=		04H		;TI=1(描述符表标志)
VMFL		= 		0002H 	;VMF=1
IFL			= 		0200H 	;IF=1
;------------------------------------------------
;32位偏移的段间转移宏指令
JUMP32 MACRO 	selector,offsetv
	       DB 0EAH    	;操作码,Far Jump
	       DW offsetv 	;32位偏移
	       DW 0
	       DW selector	;选择子
ENDM
;-------------------------------------------------
;32位偏移的段间调用宏指令
CALL32 MACRO 	selector, offsety
	       DB 09AH    	;操作码,CALL
	       DW offsetv 	;32位偏移
	       DW 0
	       DW selector	;选择子
ENDM
;------------------------------------------------
;16位偏移的段间转移宏指令
JUMP16 MACRO 	selector,offsetv
	       DB 0EAH    	;操作码,Far Jump
	       DW offsetv 	;16位偏移
	       DW selector	;段值/选择子
ENDM
;-----------------------------------------------
;16位偏移的段间调用宏指令
CALL16 MACRO 	selector,offsetv
	       DB 09AH    	;操作码，call
	       DW offsetv 	;16位偏移
	       DW selector	;段值/选择子
ENDM
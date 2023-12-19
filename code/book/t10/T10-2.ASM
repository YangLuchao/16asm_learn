;程序名：T10-2.ASM
;功能，演示实方式和保护方式切换
;说明，该程序使用TASM汇编
;16位偏移的段间转移指令的宏定义
JUMP16 MACRO selector,offsetv
           DB 0EAH        ;操作码，'Far Jump'指令
           DW offsetv     ;16位偏移
           DW selector    ;段值或者选择子
ENDM
;32位偏移的段间转移指令的宏定义
JUMP32 MACRO selector,offsetv
           DB 0EAH        ;操作码，'Far Jump'指令
           DW offsetv     ;32位偏移
           DW 0
           DW selector    ;选择子
ENDM
;存储段描述符结构类型的定义
DESCRIPTOR 	STRUC
		LIMITL		DW 0	;段界限(0~15)
		BASEL 		DW 0	;段基地址(0~15)
		BASEM		DB 0	;段基地址(16~23)
		ATTRIBUTES 	DW 0	;段属性
		BASEH		DB 0	;段基地址(24~31)
DESCRIPTOR 	ENDS
;GDTR伪描述符结构类型的定义
PDESC 	STRUC
		LIMIT 	DW 0	;16界限
		BASE	DD 0	;基地址
PDESC 	ENDS
;常量定义
ATDR	=	90H			;存在的只读数据段属性值
ATDW	=	92H			;存在的可读写数据段属性值
ATDWA	=	93H			;存在的已访问可读写数据段属性值
ATCE	=	98H			;存在的只执行代码段属性值
ATCE32 	=	4098H		;存在的只执行32位代码段属性值
DATALEN = 	16
;
		.386P
;----------------------------
;数据段
DSEG SEGMENT 	USE16                                                   ;16位段
               GDT    LABEL 		BYTE                                    ;全局描述符表
               DUMMY  DESCRIPTOR 	<>                                  ;空描述符
    ;0080h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示r0环GDT中index = 1的描述符
    CODE32_SEL =      08H                                             ;32位代码段描述符选择子
    ;CODE32LEN-1是32位代码段实际长度作为界限
    ;基址为0h，后面再代码中设置
    ;属性为R032位只执行代码段
               CODE32 DESCRIPTOR 	<CODE32LEN-1,,,ATCE32,>
    CODE16_SEL =      10H                                             ;16位代码段描述符选择子
    ;0FFFFH是16位代码段指定界限
    ;基址为0h，后面再代码中设置
    ;属性为R0位只执行代码段
               CODE16 DESCRIPTOR 	<0FFFFH,,,ATCE,>
    DATAS_SEL  =      18H                                             ;源数据段描述符选择子
    ;DATALEN-1是指定长度 16 - 1 = 15 个字节作为界限
    ;基址为0FFFFFh
    ;属性为只读数据段
               DATAS  DESCRIPTOR 	<DATALEN-1,0FFFOH,0FH,ATDR,0>
    DATAD_SEL  =      20H                                             ;目标数据段描述符选择子
    ;DATALEN-1是指定长度 16 * 8 - 1 = 127 个字节作为界限
    ;基址为0000 000B 80A8h
    ;属性为可读可写数据段
               DATAD  DESCRIPTOR 	<DATALEN * 8-1,80A0H,0BH,ATDW.0>
    STACKS_SEL =      28H                                             ;堆栈段描述符选择子
    ;0FFFFH字节作为界限
    ;基址为0h，后面再代码中设置
    ;属性为可写可访问数据段
               STACKS DESCRIPTOR 	<0FFFFH,,,ATDWA,>
    NORMAL_SEL =      30H                                             ;规范段描述符选择子
    ;0FFFFH字节作为界限
    ;基址为0h
    ;属性为可读可写数据段
               NORMAL DESCRIPTOR 	<0FFFFH,0,0,ATDW,0>
    GDTLEN     =      $ - GDT
    ;
               VGDTR  PDESC 		<GDTLEN - 1,>                           ;GDT伪描述符
    VARSS      DW     ?                                               ;用于保存SS的变量
DSEG ENDS
;
;--------------------------------------
;实方式下的代码段
CSEG1 SEGMENT USE16 'REAL'
           ASSUME CS:CSEG1,DS:DSEG
    START: 
           MOV    AX,DSEG
           MOV    DS,AX                        ;代码段段值挪到ds中
    ;
           MOV    BX,16                        ;设置GDT的基地址
           MUL    BX                           ;将段值转换为物理地址
           ADD    AX,OFFSET GDT                ;找到GDT的地址
           ADC    DX,0
           MOV    WORD PTR VGDTR.BASE,AX
           MOV    WORD PTR VGDTR.BASE+2,DX     ;设置GDTR的基地址
    ;
           MOV    AX,CSEG2                     ;设置32位代码段的基地址
           MUL    BX                           ;找到32位代码段的物理地址
           MOV    CODE32.BASEL,AX
           MOV    CODE32.BASEM,DL
           MOV    CODE32.BASEH,DH              ;设置32位代码段基址
    ;
           MOV    AX,CSEG3                     ;设置16位代码段的基地址
           MUL    BX                           ;找到16位代码段的物理地址
           MOV    CODE16.BASEL,AX
           MOV    CODE16.BASEM,DL
           MOV    CODE16.BASEH,DH              ;设置16位代码段的基址
    ;
           MOV    AX,SS                        ;设置堆栈段的基地址
           MUL    BX                           ;找到堆栈段的物理地址
           MOV    STACKS.BASEL,AX
           MOV    STACKS.BASEM,DL
           MOV    STACKS.BASEH,DH              ;设置堆栈段的基地址
           MOV    VARSS,SS                     ;保存实方式下的SS
    ;
           LGDT   QWORD PTR VGDTR              ;装载GDTR
    ;
           CLI                                 ;关中断
           CALL   EA20                         ;打开地址线A20
           MOV    EAX,CR0                      ;切换到保护方式
           OR     EAX,1                        ;cr0,pe位设置为1
           MOV    CR0,EAX                      ;切换到保护模式
    ;进入32位代码段
           JUMP16 CODE32_SEL,<OFFSET SPM32>    ;跳到32位代码段SPM32标号处
    TOREAL:                                    ;现在又回到实方式
           MOV    AX,DSEG
           MOV    DS,AX
           MOV    SS,VARSS                     ;恢复实方式下的SS
           CALL   DA20                         ;关闭地址线A20
           STI
           MOV    AH,4CH
    ;结束
           INT    21H
	
EA20 PROC
    ;打开地址线A20
EA20 ENDP

DA20 PROC
    ;关闭地址线A20
DA20 ENDP

CSEG1 ENDS
	
	;32位代码段
CSEG2 SEGMENT USE32 	'PM32'
              ASSUME CS:CSEG2
    SPM32:    
              MOV    AX,STACKS_SEL                ;堆栈段选择子挪到AX中
              MOV    SS,AX                        ;装载堆栈段寄存器SS，SS当前保护模式下为堆栈段选择子
              MOV    AX,DATAS_SEL
              MOV    DS,AX                        ;装载源数据段寄存器DS，DS当前保护模式下为源数据段选择子
              MOV    AX,DATAD_SEL
              MOV    ES,AX                        ;装载目标数据段寄存器ES，ES当前保护模式下为目标数据段选择子
              XOR    ESI,ESI                      ;设置指针和计数器
              XOR    EDI,EDI
              MOV    ECX,DATALEN
              CLD
    NEXT:     
              LODSB                               ;取一字节
              PUSH   AX
              CALL   TOASCII                      ;低4位转换成ASCII
              MOV    AH,7                         ;显示属性为黑底白字
              SHL    EAX,16
              POP    AX
              SHR    AL,4
              CALL   TOASCII                      ;高4位转换成ASCII
              MOV    AH,7
              STOSD                               ;显示
              MOV    AL,''
              STOSW                               ;显示空格
              LOOP   NEXT
    ;变换到16位代码段
              JUMP32 CODE16_SEL,<OFFSET SPM16>
    ;
TOASCII PROC
    ;把AL低位转换成对应ASCH码
TOASCII ENDP
    CODE32LEN =      $
CSEG2 ENDS
;---------------------------------------
;16位代码段
CSEG3 SEGMENT USE16	'PM16'
          ASSUME CS:CSEG3
    SPM16:
          XOR    SI,SI             ;设置指针和计数器
          MOV    DI,DATALEN*3*2
          MOV    AH,7
          MOV    CX,DATALEN
    AGAIN:
          LODSB                    ;把指定区域内容直接
          STOSW                    ;作为ASCII码显示
          LOOP   AGAIN
    ;
          MOV    AX,NORMAL_SEL
          MOV    DS,AX             ;把NORMAL段选择子装入DS和ES
          MOV    ES,AX
          MOV    EAX,CR0           ;切换到实方式
          AND    EAX,OFFFFFFFEH    ;将PE位设置为0，切换到实模式
          MOV    CR0,EAX
    ;切换回到实方式
          JMP    FAR PTR TOREAL
CSEG3 ENDS
		END START
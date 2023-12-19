;程序名：T10-3.ASM
;演示任务内无特权级变换的转移
;INCLUDE 386SCD.ASM
;文件386SCD.ASM含有关结构、
;宏指令和符号常量的定义
INCLUDE 386SCD.ASM
	.386P
;---------------------------------
;常量定义
ATDR	=	90H			;存在的只读数据段属性值
ATDW	=	92H			;存在的可读写数据段属性值
ATDWA	=	93H			;存在的已访问可读写数据段属性值
ATCE	=	98H			;存在的只执行代码段属性值
ATCE32 	=	4098H		;存在的只执行32位代码段属性值
DATALEN = 	16
ATLDT	=	82H			;局部描述符(系统段)表段类型值
;全局描述符表
GDTSEG SEGMENT 	PARA 	USE16 	'GDT'
               GDT     LABEL 	BYTE
               DUMMY   DESCRIPTOR	<>                        ;空描述符
    ;规范数据段描述符，刷缓冲区寄存器用
               NORMAL  DESCRIPTOR 	<0FFFFH,0,0,ATDW,0>
    ;R0环数据段index = 1 的描述符
    ;描述符内容为，段界限为FFFFH，基址为0h，属性为R0位可读写数据段
    NORMAL_SEL =       NORMAL - GDT
    ;代码段K的描述符
               CODEK   DESCRIPTOR 	<0FFFFH,,,ATCE,>
    ;R0环代码段index = 2 的描述符
    ;描述符内容为，段界限为FFFFH，基址为0h，属性为R0位只执行代码段
    CODEK_SEL  =       CODEK - GDT
    ;局部描述符表段的描述符
               LDTABLE DESCRIPTOR 	<LDTLEN - 1,,,ATLDT,>
    ;LDT段index = 3 的描述符
    ;描述符内容为，段界限为LDTLEN - 1，基址为0h，属性为LDT段地址
    LDT_SEL    =       LDTABLE - GDT
    GDTLEN     =       $
GDTSEG ENDS
;-----------------------------------
;演示任务局部描述符表
LDTSEG SEGMENT 	PARA 	USE16 	'LDT'
              LDT       LABEL 	BYTE

    ;代码段L描述符
    ;描述符内容为，段界限为CODELLEN - 1，基址为CODELSEG段，属性为R0只执行代码段
              CODEL     DESCRIPTOR 	<CODELLEN - 1,CODELSEG,,ATCE,>
    ;代码段L选择子，一个描述符的长度位8h,64位，所以CODEL - LDT = 0 * 8 = 0h + 4h = 04h
    ;04H = 0000 0000 0000 1100 = 0000000000000 1 00
    ;TI=0，为LDT描述符，该选择子含义为，在LDT中，index = 0 的描述符
    CODEL_SEL =         (CODEL - LDT) + TIL                               ;TIL=4h


    ;代码段C描述符
    ;描述符内容为，段界限为CODECLEN - 1，基址为CODECSEG段，属性为R0只执行代码段
              CODEC     DESCRIPTOR 	<CODECLEN - 1,CODECSEG,,ATCE,>
    ;代码段C选择子,一个描述符的长度位8h,64位，所以CODEL - LDT = 1 * 8 = 8h + 4h = 0Ch
    ;0C = 0000 0000 0000 1100 = 0000000000000 1 00
    ;TI=0，为LDT描述符，该选择子含义为，在LDT中，index = 1 的描述符
    CODEC_SEL =         (CODEC - LDT) + TIL


    ;显示缓冲区段描述符
    ;描述符的含义为，段界限为OFFFFH，基址为0h，属性为R0可读写数据段
              VIDEOBUFF DESCRIPTOR <OFFFFH,0,0,0F00H+ATDW,0>
    ;显示缓冲区段选择子,一个描述符的长度位8h,64位，所以VIDEOBUFF - LDT = 2 * 8 = 10h + 4h = 14h
    ;14 = 0000 0000 0001 0100 = 0000000000010 1 00
    ;TI=0，为LDT描述符，该选择子含义为：在LDT中，index = 2 的描述符
    VIDEO_SEL =         (VIDEOBUFF - LDT) + TIL


    ;演示任务LDT别名段描述符(DPL=3)
    ;描述符的含义为，段界限为LDTLEN - 1，基址为LDTSEG标号地址，属性为R3只读数据段
              TOLDT     DESCRIPTOR <LDTLEN - 1,LDTSEG,,ATDR+DPL3,>
    ;演示任务LDT别名段选择子，一个描述符的长度位8h,64位，所以TOLDT - LDT = 3 * 8 = 18h + 4h = 1Ch
    ;1C = 0000 0000 0001 1100 = 0000000000011 1 00
    ;TI=0，为LDT描述符，该选择子含义为：在LDT中，index = 3 的描述符
    TOLDT_SEL =         (TOLDT - LDT) + TIL


    ;显示信息缓冲区段描述符(DPL=3)
    ;描述符的含义为，段界限为MDATALEN - 1，基址为MDATASEG标号地址，属性为R3可读写数据段
              MDATA     DESCRIPTOR <MDATALEN - 1,MDATASEG,,ATDW+DPL3,>
    ;显示信息缓冲区段选择子，一个描述符的长度位8h,64位，所以MDATA - LDT = 4 * 8 = 20h + 4h = 24h
    ;24 = 0000 0000 0010 0100 = 0000000000100 1 00
    ;TI=0，为LDT描述符，该选择子含义为：在LDT中，index = 4 的描述符
    MDATA_SEL =         (MDATA-LDT) + TIL + RPL3


    ;堆栈段描述符
    ;描述符的含义为，段界限为TOPOFS - 1，基址为STACKSEG标号地址，属性为R0可读写数据段
              STACKS    DESCRIPTOR <TOPOFS - 1,STACKSEG,,ATDWA,>
    ;堆栈段选择子，一个描述符的长度位8h,64位，所以STACKS - LDT = 5 * 8 = 28h + 4h = 2Ch
    ;2C = 0000 0000 0010 1100 = 0000000000101 1 00
    ;TI=0，为LDT描述符，该选择子含义为：在LDT中，index = 5 的描述符
    STACK_SEL =         (STACKS - LDT) + TIL

    ;LDT含描述符个数
    LDNUM     =         ($ - LDT)/(SIZE DESCRIPTOR)
    ;LDT字节长度
    LDTLEN    =         $ - LDT
LDTSEG ENDS
;------------------------------------------
;显示信息缓冲区段
MDATASEG SEGMENT 	PARA 	USE16 	'MDATA'
    MESSAGE  DB 'Value=',0
    BUFFER   DB 80 DUP (0)
    MDATALEN =  $
MDATASEG ENDS
;--------------------------------------------
;演示任务堆栈段
STACKSEG SEGMENT 	PARA 	USE16	'STACK'
             DW 512 	DUP (0)
    TOPOFS   =  $
STACKSEG ENDS
;演示任务代码段C(含子程序D和子程序H)
CODECSEG SEGMENT 	PARA 	USE16 	'CODEC'
             ASSUME CS: CODECSEG
    ;显示信息子程序D
    ;人口参数:	 FS:SI指向要显示字符串，字符串以0结束
    ;			ES:EDI指向显示缓冲区
DISPMESS PROC 	FAR
             MOV    AH,7
    DISP1:   
             MOV    AL,FS:[SI]
             INC    SI
             OR     AL,AL
             JZ     DISP2           ;判断原始字符串是否结束，结束退出函数
             MOV    ES:[EDI],AX     ;将目标地址字符挪到缓冲区中，显示字符
             INC    EDI
             INC    EDI
             JMP    DISP1
    DISP2:   
             RET
DISPMESS ENDP
    ;
    ;子程序H,把一位十六进制数转换成对应字符的ASCII码
HTOASC PROC 	FAR
             AND    AL,0FH
             ADD    AL,90H
             DAA
             ADC    AL,40H
             DAA
             RET
HTOASC ENDP
    CODECLEN =      $

CODECSEG ENDS
;-------------------------------------
;演示任务代码段L
CODELSEG SEGMENT 	PARA 	USE16 	'CODEL'
             ASSUME CS:CODELSEG
    VIRTUAL2:
             MOV    AX,VIDEO_SEL
             MOV    ES,AX                   ;设置显示缓冲区指针
             MOV    EDI,0B8000H             ;显示缓冲区地址
    ;
             MOV    AX,MDATA_SEL
             MOV    FS,AX                   ;设置提示信息缓冲区指针
             MOV    SI,OFFSET MESSAGE
    ;
             CALL16 CODEC_SEL,DISPMESS      ;显示提示信息
    ;
             MOV    AX,TOLDT_SEL            ;把演示任务的LDT的
             MOV    GS,AX                   ;别名段的描述符选择子装入GS
    ;
             MOV    DX,GS:CODEL.LIMIT       ;取代码段L的段界限值挪到DX中
             MOV    SI,OFFSET BUFFER        ;并转成对应可显示字符串
             MOV    CX,4
    VIR:     
             ROL    DX,4
             MOV    AL,DL
             CALL16 CODEC_SEL,HTOASC        ;转换出ASCII码
             MOV    FS:[SI],AL
             INC    SI
             LOOP   VIR
             MOV    WORD PTR FS:[SI],'H'
    ;
             MOV    SI,OFFSET BUFFER
             CALL16 CODEC_SEL,DISPMESS      ;显示转换出的字符申
    ;
             JUMP16 CODEK_SEL,VIRTUAL3      ;跳转到代码段K
    CODELLEN =      $
CODELSEG ENDS
;------------------------------------------------
;演示任务代码段K
CODEKSEG SEGMENT 	PARA 	USE16 'CODEK'
             ASSUME CS:CODEKSEG
    VIRTUAL1:
             MOV    AX,LDT_SEL                  ;将LDT段的描述符选择子装入AX
             LLDT   AX                          ;装载局部描述符表寄存器LDTR
    ;
             MOV    AX,STACK_SEL                ;将LDT中的STACK_SEL选择子挪到SS中
             MOV    SS,AX                       ;建立演示任务堆栈
             MOV    SP,OFFSET TOPOFS            ;设置栈顶
    ;
             JUMP16 CODEL_SEL,VIRTUAL2          ;跳转到代码段L的VIRTUAL2偏移处
    VIRTUAL3:
             MOV    AX,NORMAL_SEL               ;准备返回实方式
             MOV    ES,AX
             MOV    FS,AX
             MOV    GS,AX
             MOV    SS,AX                       ;恢复各个段寄存器
             MOV    EAX,CR0
             AND    EAX,0FFFFFFFEH              ;将PE位置0
             MOV    CR0,EAX                     ;返回实模式
    ;返回实方式
             JUMP16 <SEG REAL>,<OFFSET REAL>
    CODEKLEN =      $
CODEKSEG ENDS
;-------------------------------------------------
;实方式数据段
RDATASEG SEGMENT 	PARA 	USE16
             VGDTR PDESC 	<GDTLEN-1,>    ;GDT伪描述符
    SPVAR    DW    ?                     ;保存实方式下堆栈指针
    SSVAR    DW    ?
RDATASEG ENDS
;-------------------------------------------------
;实方式代码段
RCODESEG SEGMENT 	PARA 	USE16
              ASSUME CS:RCODESEG
    START:    
              ASSUME DS:GDTSEG
              MOV    AX,GDTSEG                        ;GDT挪到AX中
              MOV    DS,AX                            ;GDT挪到DS中
    ;初始化全局描述符表
              MOV    BX,16
              MOV    AX,CODEKSEG
              MUL    BX                               ;找到CODEKSEG的物理地址
              MOV    CODEK.BASEL,AX                   ;设置代码段K基地址
              MOV    CODEK.BASEM,DL
              MOV    CODEK.BASEH,DH
              MOV    AX,LDTSEG                        ;LDT段挪到AX中
              MUL    BX                               ;计算LDT段的物理地址
              MOV    LDTABLE.BASEL,AX                 ;设置LDT段基址
              MOV    LDTABLE.BASEM,DL
              MOV    LDTABLE.BASEH,DH
    ;设置GDT伪描述符
              ASSUME DS:RDATASEG
              MOV    AX,RDATASEG                      ;实方式下数据段标号挪到AX中
              MOV    DS,AX                            ;实方式下数据段标号挪到DS中
              MOV    AX,GDTSEG                        ;GDT段标号挪到AX中
              MUL    BX                               ;计算GDT段的物理地址
              MOV    WORD PTR VGDTR.BASE,AX           ;设置GDTR的基地址低16位
              MOV    WORD PTR VGDTR.BASE+2,DX         ;设置GDTR的基地址高16位
    ;初始化演示任务LDT
              CLD                                     ;清空方向
              CALL   INIT_MLDT                        ;初始化LDT中各段的基址
    ;保存实方式堆栈指针
              MOV    SSVAR,SS
              MOV    SPVAR,SP
    ;装载GDTR
              LGDT   QWORD PTR VGDTR                  ;将定义的VGDTR挪到GDTR寄存器中
              CLI                                     ;关中断
    ;切换到保护方式
              MOV    EAX,CR0
              OR     EAX,1
              MOV    CR0,EAX                          ;置PE=1，切换到保护模式
    ;跳到CODEK段的VIRTUAL1标号偏移处
              JUMP16 <CODEK_SEL>,<OFFSET VIRTUAL1>
    REAL:                                             ;又回到实方式
              LSS    SP,DWORD PTR SPVAR               ;恢复实方式堆栈指针
              STI                                     ;开中断
              MOV    AX,4C00H                         ;结束
              INT    21H
    ;初始化演示任务LDT的子程序
INIT_MLDT PROC
              PUSH   DS                               ;实现无特权集转换任务内切换，push ds
              MOV    AX,LDTSEG                        ;LDTSEG标号挪到AX中
              MOV    DS,AX                            ;LDTSEG标号挪到DX中
              MOV    CX,LDNUM                         ;描述符个数挪到CX中
              MOV    SI,OFFSET LDT                    ;LDT偏移为起始地址
    INITL:    
              MOV    AX,[SI].BASEL                    ;代码段L基地址低16位挪到AX中
              MOVZX  EAX,AX                           ;代码段L基地址低16位挪到EAX中，高位补0
              SHL    EAX,4                            ;代码段L基地址低16位挪到EAX中，高位补0，并左移4位
              SHLD   EDX,EAX,16                       ;将代码段L基地址高16位挪到EDX中
              MOV    [SI].BASEL,AX                    ;初始化LDT中各段的基址
              MOV    [SI].BASEM,DL
              MOV    [SI].BASEH,DH
              ADD    SI,SIZE DESCRIPTOR
              LOOP   INITL
              POP    DS
              RET
INIT_MLDT ENDP
RCODESEG ENDS
	END START
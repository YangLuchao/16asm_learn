;程序名：T10-10.ASM
;功能：演示使用分页管理机制
;
	INCLUDE 386SCD.ASM
PL 		=	1			;存在属性位P值
RWR 	= 	0			;`R/W `属性位值，读/执行
RWW		=	2			;`R/W `属性值，读/写/执行
USU		=	0			;`U/S `属性值，系统级
USS		=	4			;`U/S `属性值，用户级
PDT_AD	=	200000H		;页目录表所在物理页的地址
PT0_AD	=	202000H		;页表0所在物理页的地址
PT1_AD	=	201000H		;页表1所在物理页的地址
;
PhVB_AD	=	0B8000H		;物理视频缓冲区地址
LoVB_AD	=	0F0000H		;程序使用的逻辑视频缓冲区地址
MPVB_AD	=	301000H		;线性地址0B8000H所映射的物理地址
PhSC_AD	=	303000H		;部分演示代码所在内存的物理地址
LoSC_AD =	402000H		;部分演示代码的逻辑地址
	.386P
;全局描述符表GDT
GDTSEG SEGMENT 	PARA 	USE16

    ;全局描述符起始地址标号
                 GDT      LABEL 	BYTE

    ;空描述符
                 DUMMY    DESCRIPTOR		<>

    ;规范描述符
                 NORMAL   DESCRIPTOR		<0FFFFH,0,0,ATDW,0>
    Normal_SEL   =        NORMAL - GDT


    ;页目录表所在段描述符(在保护方式下初始化时用)
    ;页目录表所在段描述符，内容为，段界限为0FFFH，基址为PDT_AD段，属性为R0环页目录表段
                 PDTable  DESCRIPTOR		<0FFFH,PDT_AD AND 0FFFFH,PDT_AD SHR 16,ATDW,0>
    ;PDTable为GDT第3个描述符，一个描述符结构体的长度位8h，所以PDTable - 0 = 0010h
    ;0010h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示RPL=0环GDT中index = 2的描述符
    PDT_SEL      =        PDTable - GDT


    ;页表0所在段描述符(在保护方式下初始化时用)
    ;页表0所在段描述符，内容为，段界限为0FFFH，基址为PT0_AD段，属性为R0环页表0段
                 PTable0  DESCRIPTOR 		<0FFFH,PT0_AD AND 0FFFFH ,PT0_AD SHR 16,ATDW,0>
    ;PTable0为GDT第4个描述符，一个描述符结构体的长度位8h，所以PTable0 - 0 = 0018h
    ;0018h = 0000 0000 0001 1000 = 0000000000011 0 00
    ;表示RPL=0环GDT中index = 3的描述符
    PTO_SEL      =        PTable0 - GDT

    ;页表1所在段描述符(在保护方式下初始化时用)
    ;页表1所在段描述符，内容为，段界限为0FFFH，基址为PT1_AD段，属性为R0环页表1段
                 PTable1  DESCRIPTOR 		<0FFFH,PT1_AD AND 0FFFFH,PT1_AD SHR 16,ATDW,0>
    ;PTable1为GDT第5个描述符，一个描述符结构体的长度位8h，所以PTable1 - 0 = 0020h
    ;0020h = 0000 0000 0010 0000 = 0000000000100 0 00
    ;表示RPL=0环GDT中index = 4的描述符
    PT1_SEL      =        PTable1 - GDT

    ;逻辑上的显示缓冲区所在段描述符
    ;描述符内容为，段界限为0FFFFH，基址为PhVB_AD段，属性为R0环显示缓冲区段
                 LOVIDEOB DESCRIPTOR 		<3999,LoVB_AD AND 0FFFFH,LoVB_AD SHR 16,ATDW,0>
    ;LoVideoB为GDT第6个描述符，一个描述符结构体的长度位8h，所以LoVideoB - 0 = 0028h
    ;0028h = 0000 0000 0010 1000 = 0000000000101 0 00
    ;表示RPL=0环GDT中index = 5的描述符
    LoVideoB_SEL =        LOVIDEOB - GDT

    ;逻辑上的部分演示代码所在段描述符
    ;描述符内容为，段界限为0FFFFH，基址为PhSC_AD段，属性为R0环部分演示代码段
                 LOCODE   DESCRIPTOR 		<SCodeLEN-1,LoSC_AD AND 0FFFFH,LoSC_AD SHR 16,ATCE,0>
    ;LoCode为GDT第7个描述符，一个描述符结构体的长度位8h，所以LoCode - 0 = 0030h
    ;0030h = 0000 0000 0011 0000 = 0000000000110 0 00
    ;表示RPL=0环GDT中index = 6的描述符
    LoCode_SEL   =        LOCODE - GDT

    ;预定内存区域(用于部分演示代码)所在段的描述符
    ;描述符内容为，段界限为0FFFFH，基址为PhSC_AD段，属性为R0环预定内存区域段
                 TPSCODE  DESCRIPTOR 		<SCodeLEN-1,PhSC_AD AND 0FFFFH,PhSC_AD SHR 16,ATDW,>
    ;TPSCODE为GDT第8个描述符，一个描述符结构体的长度位8h，所以TPSCODE - 0 = 0038h
    ;0038h = 0000 0000 0011 1000 = 0000000000111 0 00
    ;表示RPL=0环GDT中index = 7的描述符
    TPSCode_SEL  =        TPSCODE - GDT

    ;以下是需要额外初始化的描述符
                 EFFGDT   LABEL 	BYTE


    ;临时代码段描述符
    ;描述符内容为，段界限为0FFFFH，基址为TempCodeSEG段，属性为R0环可执行代码段
                 TEMPCODE DESCRIPTOR 		<0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第9个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 0040h
    ;0040h = 0000 0000 0100 0000 = 0000000001000 0 00
    ;表示RPL=0环GDT中index = 8的描述符
    TempCode_SEL =        TEMPCODE - GDT

    ;演示任务代码段描述符
    ;描述符内容为，段界限为DemoCodeLEN - 1，基址为DemoCodeSEG段，属性为R0环可执行代码段
                 DEMOCODE DESCRIPTOR 		<DemoCodeLEN-1,DemoCodeSEG,,ATCE,>
    ;DEMOCode为GDT第10个描述符，一个描述符结构体的长度位8h，所以DEMOCode - 0 = 0048h
    ;0048h = 0000 0000 0100 1000 = 0000000001001 0 00
    ;表示RPL=0环GDT中index = 9的描述符
    DemoCode_SEL =        DEMOCODE - GDT

    ;演示任务数据段描述符
    ;描述符内容为，段界限为DemoDataLEN - 1，基址为DemoDataSEG段，属性为R0环数据段
                 DEMODATA DESCRIPTOR 		<DemoDataLEN-1,DemoDataSEG,,ATDW,>
    ;DEMOData为GDT第11个描述符，一个描述符结构体的长度位8h，所以DEMOData - 0 = 0050h
    ;0050h = 0000 0000 0101 0000 = 0000000001010 0 00
    ;表示RPL=0环GDT中index = 10的描述符
    DemoData_SEL =        DEMODATA - GDT

    ;在初始化时要移动的代码段描述符(移动时作为数据对待)
                 SCODE    DESCRIPTOR <SCodeLEN-1,SCodeSEG,,ATDR,>
    ;SCode为GDT第12个描述符，一个描述符结构体的长度位8h，所以SCode - 0 = 0058h
    ;0058h = 0000 0000 0101 1000 = 0000000001011 0 00
    ;表示RPL=0环GDT中index = 11的描述符
    SCode_SEL    =        SCODE - GDT
    ;全局描述符数量个数
    GDNUM        =        ($ - EFFGDT)/(SIZE DESCRIPTOR)
    ;全局描述符表长度
    GDTLEN       =        $ - GDT
GDTSEG ENDS

;这部分代码在初始化时被复制到预定内存区域
;其功能是在屏幕上显示提示信息
SCodeSEG SEGMENT 	PARA 	USE16
             ASSUME CS:SCodeSEG,DS:DemoDataSEG
    SBegin:  
             MOV    AX,LoVideoB_SEL
             MOV    ES,AX
             MOV    DI,0
             MOV    AH,17H
             MOV    CX,MESSLEN
    S1:      
             LODSB                                ;显示信息
             STO    SW
             LOOP   S1
             JUMP16 DemoCode_SEL,Demo3
    MLEN     =      $ - SBegin
    SCodeLEN =      $
SCodeSEG ENDS
;演示任务数据段
DemoDataSEG SEGMENT 	PARA 	USE16
    MESS        DB ' Page is ok ! '
    MESSLEN     =  $ - MESS
    DemoDataLEN =  $
DemoDHtaSEG ENDS
    ;演示任务代码段
DemoCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:DemoCodeSEG
    DemoBegin:  
                MOV    AX,PDT_SEL                                     ;初始化页目录表
                MOV    ES,AX
                XOR    DI,DI
                MOV    CX,1024
                XOR    EAX,EAX                                        ;先把全部表项置成无效
                REP    STOSD                                          ;再置表项0和表项I
                MOV    DWORD PTR ES:[0],PT0_AD OR (USU + RWW + PL)
                MOV    DWORD PTR ES:[4],PT1_AD OR (USU + RWW + PL)
                MOV    AX,PTO_SEL
    ;初始化页表0
                MOV    ES,AX
                XOR    DI,DI
                MOV    CX,1024
                XOR    EAX,EAX
                OR     EAX,USU + RWW + PL
    Demol:      
                STOSD
                ADD    EAX,1000H                                      ;先全部置成直接对应等地址的物理页
                LOOP   Demol                                          ;再特别设置两个表项
                MOV    DI,(PhVB_AD SHR 12) * 4
                MOV    DWORD PTR ES:[DI],MPV_AD + USS + RWW + PL
                MOV    DI,(LoVB_AD SHR 12) * 4
                MOV    DWORD PTR ES:[DI],PhVB_AD + USU + RWR + PL
                MOV    AX,PT1_SEL                                     ;初始化页表1
                MOV    ES,AX
                XOR    DI,DI
                MOV    CX,1024
                MOV    EAX,400000H
    Demo2:      
                STOSD                                                 ;先把全部表项置成无效
                ADD    EAX,1000H
                LOOP   Demo2                                          ;再特别设置一项
                MOV    DI,((LoSC_AD SHR 12) AND 3FFH) * 4
                MOV    DWORD PTR ES [DI],PhSC_AD + USU + RWR + PL
    ;
                MOV    EAX,PDT_AD
                MOV    CR3,EAX
                MOV    EAX,CR0
                OR     EAX,80000000H
                MOV    CR0,EAX
    ;启用分页机制
                JMP    SHORT PageE
    PageE:      
                MOV    AX,DemoData_SEI
                MOV    DS,AX
                MOV    SI,OFFSET MESS
                JUMP16 LoCode_SEL,Sbegin
    ;转位于较大线性地址处的代码执行
    Demo3:      
                MOV    EAX,CR0
                AND    EAX,7FFFFFFFH
    ;关闭分页机制
                MOV    CR0,EAX
                JMP    SHORT PageD
    PageD:      
                MOV    AX,Normal_SEL
                JUMP16 TempCode_SEL,ToDOS
    DemoCodeLEN =      $
DemoCodeSEG ENDS
;临时代码段
TempCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:TempCodeSEG
    Virtual:    
                CLD
    ;为演示在启用分页机制后执行位于
                MOV    AX,SCode_SEL
    ;较高线性地址空间中的代码作准备
                MOV    DS,AX
                MOV    AX,TPSCode_SEL
                MOV    ES,AX
                MOV    SI,OFFSET SBegin
                MOV    DI,SI
                MOV    CX,MLEN                      ;把部分演示代码复制到预定的内存
                REP    MOVSB
                JUMP16 DemoCode_SEL,DemoBegin
    ;
    ToDOS:      
                MOV    DS,AX
    ;准备返回实方式
                MOV    ES,AX
                MOV    EAX,CR0
                AND    EAX,0FFFFFFFEH
                MOV    CR0,EAX
    ;返回实方式
                JUMP16 <SEG Real> ,<OFFSET Real>
TempCodeSEG ENDS
;实方式下的初始化代码和数据
RCodeSEG SEGMENT 	PARA 	USE16
             ASSUME CS:RCodeSEG,DS:RCodeSEG
             VGDTR  PDESC	<GDTLEN-1,>
    Start:   
             PUSH   CS
             POP    DS                                 ;将代码段推到数据段
             CLD                                       ;设置方向
             CALL   INIT_GDT                           ;初始化全局描述符表GDT
             CALL   EA20                               ;打开地址线A20
             LGDT   QWORD PTR VGDTR
             CLI                                       ;屏蔽中断
             MOV    EAX,CR0
             OR     EAX,1
             MOV    CR0,EAX                            ;切到保护模式
    ;转保护方式
             JUMP16 <TempCode_SEL>,<OFFSET Virtual>
    Real:    
    ;回到实方式
             CALL   DA20
    ;关闭地址线A20
             STI
             MOV    AX,4C00H
    ;返回DOS
             INT    21H
    ;实方式下的初始化过程
INIT_GDT PROC 	NEAR
    ;同实例四中的过程内容
INIT_GDT ENDP
EA20 PROC
    ;同实例一
EA20 ENDP
DA20 PROC
    ;同实例一
DA20 ENDP
RCodeSEG ENDS
	END Start
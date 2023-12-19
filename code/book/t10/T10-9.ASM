;程序名：T10-9.ASM
;功能：演示`I/O`保护及I/Q敏感指令的作用
	INCLUDE	386SCD.ASM;参见实例三说明
	.386P
;------------------------------
;全局描述符表GDT
GDTSEG SEGMENT 	PARA 	USE16

    ;全局描述符起始地址标号
                   GDT        LABEL 	BYTE

    ;空描述符
                   DUMMY      DESCRIPTOR		<>

    ;规范数据段描述符，刷缓冲区寄存器用
                   NORMAL     DESCRIPTOR		<OFFFFH,0,0,ATDW,0>
    Normal_SEL     =          NORMAL - GDT

    ;全局描述符表任务定义描述符起始标识
                   EFFGDT     LABEL 	BYTE

    ;显示缓冲区段描述符(任何特权级可写)
    ;描述符内容为，段界限为80*25*2-1，基址为 0B800H ,属性为R3环显示缓冲区段
                   VIDEOBUFF  DESCRIPTOR 	<80*25*2-1,0B800H,,ATDW+DPL3,>
    ;VIDEOBUFF为GDT第3个描述符，一个描述符结构体的长度位8h，所以VIDEOBUFF - 0 = 0010h
    ;0010h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示0环GDT中index = 2的描述符
    VideoBuff_SEL  =          VIDEOBUFF - GDT

    ;演示任务TSS段描述符
    ;描述符内容为，段界限为DemoTSSLEN - 1，基址为DemoTSSSEG段，属性为R0环386TSS类型值
                   DEMOTSS    DESCRIPTOR 	<DemoTSSLEN-1 , DemoTSSSEG , , AT386TSS ,>
    ;DEMOSEL为GDT第4个描述符，一个描述符结构体的长度位8h，所以DEMOSEL - 0 = 0018h
    ;0018h = 0000 0000 0001 1000 = 0000000000011 0 00
    ;表示RPL=0环GDT中index = 3的描述符
    DemoTSS_SEL    =          DEMOTSS - GDT

    ;演示任务堆栈段描述符
    ;描述符内容为，段界限为DemoStackLEN - 1，基址为DemoStackSEG段，属性为R0环32位堆栈段
                   DEMOSTACK  DESCRIPTOR 	<DemoStackLEN-1,DemoStackSEG,,ATDW+D32,>
    ;DEMOSTACK为GDT第5个描述符，一个描述符结构体的长度位8h，所以DEMOSTACK - 0 = 0020h
    ;0020h = 0000 0000 0010 0000 = 000000000100 0 00
    ;表示RPL=0环GDT中index = 4的描述符
    DemoStack_SEL  =          DEMOSTACK - GDT

    ;演示任务代码段描述符
    ;描述符内容为，段界限为DemoCodeLEN - 1，基址为DemoCodeSEG段，属性为R0环32位代码段
                   DEMOCODE   DESCRIPTOR 	<DemoCodeLEN-1,DemoCodeSEG,,ATCE+D32,>
    ;DEMOCode为GDT第6个描述符，一个描述符结构体的长度位8h，所以DEMOCode - 0 = 0028h
    ;0028h = 0000 0000 0010 1000 = 000000000101 0 00
    ;表示RPL=0环GDT中index = 5的描述符
    DemoCode_SEL   =          DEMOCODE - GDT

    ;属于演示任务的临时代码段描述符
    ;描述符内容为，段界限为0FFFFH，基址为TempCodeSEG段，属性为R0环可执行代码段
                   TEMPCODE   DESCRIPTOR 	<0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第7个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 0030h
    ;0030h = 0000 0000 0011 0000 = 000000000110 0 00
    ;表示RPL=0环GDT中index = 6的描述符
    TempCode_SEL   =          TEMPCODE - GDT

    ;指向GDT的存储段描述符
    ;描述符内容为，段界限为GDTLEN - 1，基址为GDT段，属性为R0环可读写数据段
                   TOGDT      DESCRIPTOR 	<GDTLEN-1,GDTSEG,,ATDW,>
    ;TOGDT为GDT第8个描述符，一个描述符结构体的长度位8h，所以TOGDT - 0 = 0038h
    ;0038h = 0000 0000 0011 1000 = 000000000111 0 00
    ;表示RPL=0环GDT中index = 7的描述符
    ToGDT_SEL      =          TOGDT - GDT
    
    ;指向通用保护故障处理任务TSS的存储段描述符
    ;描述符内容为，段界限为GPTSSLEN - 1，基址为GPTSSSEG段，属性为R0环可读写数据段
                   TOGPTSS    DESCRIPTOR 	<GPTSSLEN-1,GPTSSSEG,,ATDW,>
    ;TOGPTSS为GDT第9个描述符，一个描述符结构体的长度位8h，所以TOGPTSS - 0 = 0040h
    ;0040h = 0000 0000 0100 0000 = 000000001000 0 00
    ;表示RPL=0环GDT中index = 8的描述符
    TOGPTSS_SEL    =          TOGPTSS - GDT

    ;指向测试任务TSS的存储段描述符
    ;描述符内容为，段界限为TestTSSLEN - 1，基址为TestTSSSEG段，属性为R0环可读写数据段
                   TOTESTTSS  DESCRIPTOR 	<TestTSSLEN-1, TestTSSSEG , , ATDW ,>
    ;TOTESTTSS为GDT第10个描述符，一个描述符结构体的长度位8h，所以TOTESTTSS - 0 = 0048h
    ;0048h = 0000 0000 0100 1000 = 000000001001 0 00
    ;表示RPL=0环GDT中index = 9的描述符
    ToTestTSSSEL   =          TOTESTTSS - GDT

    ;测试任务TSS段描述符
    ;描述符内容为，段界限为TestTSSLEN - 1，基址为TestTSSSEG段，属性为R0环386TSS类型值
                   TESTTSS    DESCRIPTOR 	<TestTSSLEN-1 , TestTSSSEG , , AT386TSS ,>
    ;TESTTSS为GDT第11个描述符，一个描述符结构体的长度位8h，所以TESTTSS - 0 = 0050h
    ;0050h = 0000 0000 0101 0000 = 000000001010 0 00
    ;表示RPL=0环GDT中index = 10的描述符
    TestTSS_SEL    =          TESTTSS - GDT

    ;测试任务1堆栈段描述符(DPL=1)
    ;描述符内容为，段界限为TestStackLEN - 1，基址为TestStackSEG段，属性为R1环32位可读写数据段
                   TESTISTACK DESCRIPTOR 	<TestStackLEN-1 , TestStackSEG,,ATDW+D32+DPL1,>
    ;TESTISTACK为GDT第12个描述符，一个描述符结构体的长度位8h，所以TESTISTACK - 0 = 0058h
    ;0058h = 0000 0000 0101 1000 = 000000001011 0 01
    ;表示RPL=1环GDT中index = 11的描述符
    Test1Stack_SEL =          (TESTISTACK - GDT) + RPL1

    ;测试任务1代码段描述符(DPL=1)
    ;描述符内容为，段界限为TestCodeLEN - 1，基址为TestCodeSEG段，属性为R1环32位可执行代码段
                   TESTICODE  DESCRIPTOR 	<TestCodeLEN-1,TestCodeSEG,,ATCE+D32+DPL1,>
    ;TESTICODE为GDT第13个描述符，一个描述符结构体的长度位8h，所以TESTICODE - 0 = 0060h
    ;0060h = 0000 0000 0110 0000 = 000000001100 0 01
    ;表示RPL=1环GDT中index = 12的描述符
    Test1Code_SEL  =          (TESTICODE - GDT) + RPL1

    ;测试任务2堆栈段描述符(DPL=2)
    ;描述符内容为，段界限为TestStackLEN - 1，基址为TestStackSEG段，属性为R2环32位可读写数据段
                   TEST2STACK DESCRIPTOR 	<TestStackLEN-1,TestStackSEG,,ATDW+D32+DPL2,>
    ;TEST2STACK为GDT第14个描述符，一个描述符结构体的长度位8h，所以TEST2STACK - 0 = 0068h
    ;0068h = 0000 0000 0110 1000 = 000000001101 0 10
    ;表示RPL=2环GDT中index = 13的描述符
    Test2Stack_SEL =          (TEST2STACK - GDT) + RPL2

    ;测试任务2代码段描述符(DPL=2)
    ;描述符内容为，段界限为TestCodeLEN - 1，基址为TestCodeSEG段，属性为R2环32位可执行代码段
                   TEST2CODE  DESCRIPTOR 	<TestCodeLEN-1,TestCodeSEG,,ATCE+D32+DPL2,>
    ;TEST2CODE为GDT第15个描述符，一个描述符结构体的长度位8h，所以TEST2CODE - 0 = 0070h
    ;0070h = 0000 0000 0111 0000 = 000000001110 0 10
    ;表示RPL=2环GDT中index = 14的描述符
    Test2Code_SEL  =          (TEST2CODE - GDT) + RPL2

    ;测试任务3堆栈段描述符(DPL=3)
    ;描述符内容为，段界限为TestStackLEN - 1，基址为TestStackSEG段，属性为R3环32位可读写数据段
                   TEST3STACK DESCRIPTOR 	<TestStackLEN-1,TestStackSEG,,ATDW+D32+DPL3,>
    ;TEST3STACK为GDT第16个描述符，一个描述符结构体的长度位8h，所以TEST3STACK - 0 = 0078h
    ;0078h = 0000 0000 0111 1000 = 000000001111 0 11
    ;表示RPL=3环GDT中index = 15的描述符
    Test3Stack_SEL =          (TEST3STACK - GDT) + RPL3

    ;测试任务3代码段描述符(DPL=3)
    ;描述符内容为，段界限为TestCodeLEN - 1，基址为TestCodeSEG段，属性为R3环32位可执行代码段
                   TEST3CODE  DESCRIPTOR 	<TestCodeLEN-1,TestCodeSEG,,ATCE+D32+DPL3,>
    ;TEST3CODE为GDT第17个描述符，一个描述符结构体的长度位8h，所以TEST3CODE - 0 = 0080h
    ;0080h = 0000 0000 1000 0000 = 000000010000 0 11
    ;表示RPL=3环GDT中index = 16的描述符
    Test3Code_SEL  =          (TEST3CODE - GDT) + RPL3

    ;通用保护故障处理任务的TSS段描述符
    ;描述符内容为，段界限为GPTSSLEN - 1，基址为GPTSSSEG段，属性为R0环386TSS类型值
                   GPTSS      DESCRIPTOR 	<GPTSSLEN-1,GPTSSSEG,,AT386TSS,>
    ;GPTSS为GDT第18个描述符，一个描述符结构体的长度位8h，所以GPTSS - 0 = 0088h
    ;0088h = 0000 0000 1000 1000 = 000000010001 0 00
    ;表示RPL=0环GDT中index = 17的描述符
    GPTSS_SEL      =          GPTSS - GDT

    ;通用保护故障处理任务的堆栈段描述符
    ;描述符内容为，段界限为GPStackL - 1，基址为GPStackSEG段，属性为R0环32位可读写数据段
                   GPSTACK    DESCRIPTOR 	<GPStackL,EN-1,GPStackSEG.,ATDW+D32,>
    ;GPSTACK为GDT第19个描述符，一个描述符结构体的长度位8h，所以GPSTACK - 0 = 0090h
    ;0090h = 0000 0000 1001 0000 = 000000010010 0 00
    ;表示RPL=0环GDT中index = 18的描述符
    GPStack_SEL    =          GPSTACK - GDT

    ;通用保护故障处理任务的代码段描述符
    ;描述符内容为，段界限为GPCodeLEN - 1，基址为GPCodeSEG段，属性为R0环32位可执行代码段
                   GPCODE     DESCRIPTOR 	<GPCodeLEN-1,GPCodeSEG,,ATCE+D32,>
    ;GPCode为GDT第20个描述符，一个描述符结构体的长度位8h，所以GPCode - 0 = 0098h
    ;0098h = 0000 0000 1001 1000 = 000000010011 0 00
    ;表示RPL=0环GDT中index = 19的描述符
    GPCode_SEL     =          GPCODE - GDT

    ;其他中断/异常处理程序代码段描述符(一致可读代码段)
    ;描述符内容为，段界限为ERRCodeLEN - 1，基址为ERRCodeSEG段，属性为R0环32位可读代码段
                   ERRCODE    DESCRIPTOR <ERRCodeLEN-1,ERRCodeSEG,,ATCCOR+D32,>
    ;ERRCODE为GDT第21个描述符，一个描述符结构体的长度位8h，所以ERRCODE - 0 = 00A0h
    ;00A0h = 0000 0000 1010 0000 = 000000010100 0 00
    ;表示RPL=0环GDT中index = 20的描述符
    ERRCode_SEL    =          ERRCODE - GDT

    ;任务用全局描述符个数
    GDNUM          =          ($ - EFFGDT)/(SIZE DESCRIPTOR)

    ;指向测试任务的任务门
    ;描述符内容为，段界限为TestTSSLEN - 1，指向TestTSS_SEL选择子，属性为R0环386任务门类型
                   TESTTASK   GATE 		<,TestTSS_SEL,0,ATTASKGAT,>
    ;TESTTASK为GDT第22个描述符，一个描述符结构体的长度位8h，所以TESTTASK - 0 = 00A8h
    ;00A8h = 0000 0000 1010 1000 = 000000010101 0 00
    ;表示RPL=0环GDT中index = 21的描述符
    Test_SEL       =          TESTTASK - GDT

    ;GDT长度
    GDTLEN         =          $ - GDT
GDTSEG ENDS
;中断描述符表IDT
IDTSEG SEGMENT 	PARA 	USE16
    ;IDT表起始地址标号
           IDT   LABEL BYTE

    ;0H~DH定义为陷阱门
           REPT  13
           GATE  <ERRBegin,ERRCode_SEL,0,AT386TGAT,0>
ENDM
    ;通用故障处理门描述符
           INTOD GATE <,GPTSS_SEL,O,ATTASKGAT,
    ;后240个陷阱门定义
           REPT  254 - 14
           GATE  <ERRBegin,ERRCode_SEL,0,AT386TGAT,0>
ENDM
    IDTLEN =     $ - IDT
IDTSEG ENDS
;-----------------------------------------------------
;其他中断/异常处理程序代码段(一致的可读代码段)
ERRCodeSEG SEGMENT 	PARA 	USE32
    ERRMESS    DB     'Error......................'
    ERRMESSLEN =      $ - ERRMESS
               ASSUME CS:ERRCodeSEG
    ERRBegin:  
               CLD
               MOV    AX,ERRCode_SEL
               MOV    DS,AX                            ;可读代码段
               LEA    ESI,ERRMESS
               MOV    AX,VideoBuff_SEL
               MOV    ES,AX
               XOR    EDI,EDI
               MOV    ECX,ERRMESSLEN
               MOV    AH,17H
    ERR1:      
               LODSB                                   ;显示提示信息
               STOSW
               LOOP   ERR1
               JMP    $                                ;循环等待
    ERRCodeLEN =      $
ERRCodeSEG ENDS
;通用保护故障处理任务的TSS段
GPTSSSEG SEGMENT 	PARA 	USE16
             GPTaskSS LABEL	BYTE
             DD       0                  ;任务钱套时的链接指针
             DD       ?                  ;0级堆栈指针
             DW       ?,?
             DD       ?                  ;1级堆栈指针
             DW       ?,?
             DD       ?                  ;2级堆栈指针
             DW       ?,?
             DD       0                  ;CR3
             DW       GPBegin,0          ;EIP
             DD       0                  ;EFLAGS
             DD       0                  ;EAX
             DD       0                  ;ECX
             DD       0                  ;EDX
             DD       0                  ;EBX
             DW       GPStackLEN,0       ;ESP
             DD       0                  ;EBP
             DD       0                  ;ESI
             DD       0                  ;EDI
             DW       VideoBuff_SEL,0    ;ES
             DW       GPCode_SEL,0       ;CS
             DW       GPStack_SEL,0
             DW       ToTestTSS_SEL,0    ;DS
             DW       ToGPTSS_SEL.0      ;FS
             DW       0,0                ;GS
             DW       0,0                ;LDT
             DW       0
             DW       $+2                ;指向`I/O`许可位图区的指针
             DB       0FFH               ;`I/O`许可位图结束标志
    GPTSSLEN =        $
GPTSSSEG ENDS
;通用保护故障处理任务的堆栈段
GPStackSEG SEGMENT 	PARA 	USE32
    GPStackLEN =  512
               DB GPStackLEN DUP (0)
GPStackSEG ENDS
;通用保护故障处理任务的代码段
GPCodeSEG SEGMENT 	PARA 	USE32
              ASSUME  CS:GPCodeSEG
    GPStart:                                      ;在屏幕左上角显示故障点
              XOR     EDI,EDI
              MOV     EBX.OFFSET TestTaskSS
              MOV     EDX,DWORD PTR [EBX].TRCS
              CALL    EchoEDX
              MOV     AX,(17H SHL 8) + ':'
              STOSW
              MOV     EDX,[EBX].TREIP
              CALL    EchoEDX                     ;延时以便看清故障点
              MOV     ECX,1234567H
              LOOP    $                           ;调整任务链接指针，终止故障任务
              MOV     EBX,OFFSET GPTaskSS
              MOV     AX,DemoTSS_SEL
              MOV     FS,[EBX].TRLINK,AX
              IRETD
              GPBegin                             ;通用故障处理任务开始点
              JMP     GPStart
    ;显示EDX内容的子程序
EchoEDX PROC
              MOV     AH,17H
              MOV     ECX,8
    EchoEDX1: 
              ROL     EDX.4
              MOV     AL,DL
              CALL    HTOASC
              STOSW
              LOOP    EchoEDX1
              RET
EchoEDX ENDP
    ;把4位二进制数转换成对应ASCII码
HTOASC PROC
    ;内容略
HTOASC ENDP
    GPCodeLEN =       $
GPCodeSEG ENDS
;测试任务的TSS段
TestTSSSEG SEGMENT 	PARA 	USE16
               TestTaskSS TASKSS 	<>
    ;TSS的固定格式部分
               IOMAP      LABEL 	BYTE    ;`I/O`许可位图
               DB         8 	DUP (0)     ;端口0000H~003FH
               DB         1100 0100B     ;端口0040H~0047H
               DB         0011 1011B     ;端口0048H~004FH
               DB         0,0            ;端口0050H~005FH
               DB         1111 0010B     ;端口0060H~0067H
               DB         0              ;端口0068H~006FH
               DB         OFFH           ;`I/O`许可位图结束标志
    TestTSSLEN =          $
TestTSSSEG ENDS
;
;测试任务的堆栈段
TestStackSEG SEGMENT 	PARA 	USE32
    TestStackLEN =  1024
                 DB TestStackLEN 	DUP(0)
TestStackSEG ENDS
;测试任务的代码段
TestCodeSEG SEGMENT 	PARA 	USE32
                ASSUME CS:TestCodeSEG
    Test3Begin: 
                CLI                      ;`I/O`敏感指令
                CLTS                     ;特权指令
                IRETD
    TestBegin:  
                MOV    AL,0B6H           ;使扬声器发出一长声
                OUT    43H,AL
                MOV    AL,2
                OUT    42H,AI.
                MOV    AL,34H
                OUT    42H,AL
                IN     AL,61H
                MOV    AH,AL
                OR     AL,3
                OUT    61H,AL
                MOV    ECX,1234567H
                LOOP   $                 ;延时
                MOV    AL,AH
                OUT    61H,AL
                IRETD
    TestCodeLEN =      $
TestCodeSEG ENDS
;演示任务的TSS段
DemoTSSSEG SEGMENT 	PARA 	USE16
               DemoTaskSS TASKSS	<>
               DB         0FFH
    DemoTSSLEN =          $
DemoTSSSEG ENDS
;演示任务的堆栈段
DemoStackSEG SEGMENT 	PARA 	USE32
    DemoStackLEN =  1024
                 DB DemoStackLEN DUP (0)
DemoStackSEG ENDS
;演示任务的代码段
DemoCodeSEG SEGMENT 	PARA 	USE32
                 ASSUME CS:DemoCodeSEG
    ;CPL=0
    DemoBegin:   
                 MOV    AX,ToTestTSS_SEL
                 MOV    DS,AX
                 MOV    EBX,OFFSET TestTaskSS
    ;把测试任务1的入口点、堆栈指针和标志值(含IOPL)填入测试任务TSS
                 MOV    WORD PTR [EBX].TRSS,Test1Stack.SEL
                 MOV    DWORD PTR [EBX].TRESP,TestStackLEN
                 MOV    WORD PTR [EBX].TRCS,Test1Code_SEL
                 MOV    DWORD PTR [EBX].TREIP,OFFSET TestBegin
                 MOV    DWORD PTR [EBX].TREFLAG,IOPL1
    ;通过任务门调用测试任务
                 CALL32 Test_SEL,0
    ;
    ;把测试任务2的入口点、堆栈指针和标志值(含IOPL)填入测试任务TSS
                 MOV    WORD PTR [EBX].TRSS,Test2Stack_SEL
                 MOV    DWORD PTR [EBX].TRESP,TestStackLEN
                 MOV    WORD PTR [EBX].TRCS,Test2Code_SEL
                 MOV    DWORD PTR [EBX].TREIP,OFFSET TestBegin
                 MOV    DWORD PTR [EBX].TREFLAG,IOPL1
    ;通过任务门调用测试任务
                 CALL32 Test_SEL,0
    ;把测试任务TSS描述符内的属性置为“可用”
                 MOV    AX,ToGDT_SEL
                 MOV    FS,AX
                 MOV    FS:TESTTSS.ATTRIBUTES,AT386TSS
    ;把测试任务3的入口点、堆栈指针和标志值(含IOPL)填入测试任务TSS
                 MOV    WORD PTR [EBX].TRSS, Test3Stack_SEL
                 MOV    DWORD PTR [EBX].TRESP, TestStackLEN
                 MOV    WORD PTR [EBX].TRCS,Test3Code_SEL
                 MOV    DWORD PTR [EBX].TREIP,OFFSET Test3Begin
                 MOV    DWORD PTR [EBX].TREFLAG,IOPL2
    ;通过任务门调用测试任务
                 CALL32 Test_SEL,0
    ;把测试任务TSS描述符内的属性置为“可用”
                 MOV    AX,ToGDT.SEL
                 MOV    FS,AX
                 MOV    FS:TESTTSS.ATTRIBUTES,AT386TSS
    ;把测试任务4的入口点、堆栈指针和标志值(含IOPL)填入测试任务TSS
                 MOV    WORD PTR [EBX].TRSS,Test3Stack_SEL
                 MOV    DWORD PTR [EBX].TRESP,TestStackLEN
                 MOV    WORD PTR [EBX]. TRCS, Test3Code_SEL
                 MOV    DWORD PTR [EBX].TREIP,OFFSET Test3Begin
                 MOV    DWORD PTR [EBX].TREFLAG,IOPL3
    ;通过任务门调用测试任务
                 CALL32 Test_SEL,0
    OVER:        
                 JUMP32 TempCode_SEL,<OFFSET ToDOs>
    DetnoCodeLEN =      $
DemoCodeSEG ENDS
;演示任务的临时代码段
TempCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:TempCodeSEG
    Virtual:    
    ;置数据段寄存器为空
                MOV    AX,0
                MOV    DS,AX
                MOV    ES,AX
                MOV    FS,AX
                MOV    GS,AX                      ;置堆栈指针
                MOV    AX,DemoStack_SEL
                MOV    SS,AX
                MOV    ESP,DemoStackLEN           ;置任务寄存器TR
                MOV    AX,DemoTSS_SEL
                LTR    AX
                JUMP16 DemoCode_SEL,DemoBegin     ;转演示代码段
    ToDOS:      
                CLTS                              ;清任务切换标志TS
                MOV    AX,Normal_SEL
                MOV    DS,AX                      ;把规范数据段描述符装入段寄存器
                MOV    ES,AX
                MOV    FS,AX
                MOV    GS,AX
                MOV    SS,AX
                MOV    EAX,CR0
                AND    EAX,0FFFFFFFEH
                MOV    CR0,EAX                    ;切换到实方式
                JUMP16 <SEG Real , OFFSET Real
TempCodeSEG ENDS
;实方式数据段
RDataSEG SEGMENT 	PARA 	USE16
             VGDTR    PDESC		<GDTLEN-1,>
             VIDTR    PDESC		<IDTLEN-1,>
             NORVIDTR PDESC 		<3FFH,0>
    SPVAR    DW       ?
    SSVAR    DW       ?
RDataSEG ENDS
;实方式代码段
RCodeSEG SEGMENT 	PARA 	USE16
             ASSUME CS:RCodeSEG,DS:RDataSEG
    Start:   
             MOV    AX,RDataSEG                        ;实模式数据段
             MOV    DS,AX
             CLD                                       ;清空方向
             CALL   INIT_GDT                           ;初始化GDT
             CALL   INIT_IDT                           ;初始化IDT
             LGDT   QWORD PTR VGDTR                    ;将VGDTR装载到GDTR中
             MOV    SSVAR,SS                           ;保存实方式堆栈指针
             MOV    SPVAR,SP
             SIDT   NORVIDTR                           ;保存IDTR装载到NORVIDTR中
             CLI                                       ;关中断
             LIDT   QWORD PTR VIDTR                    ;将VIDTR装载到IDT中
             MOV    EAX,CR0
             OR     EAX,1
             MOV    CR0,EAX                            ;切换到保护方式
             JUMP16 <TempCode_SEL>,<OFFSET Virtual>
    Real:                                              ;实方式
             MOV    AX,RDataSEG
             MOV    DS,AX
             LSS    SP,DWORD PTR SPVAR
             LIDT   NORVIDTR                           ;恢复IDTR
             STI
             MOV    AX,4C00H                           ;返回DOS
             INT    21H
    ;初始化全局描述符表的子程序
    ;(1)把定义时预置的段值转换成32位段基地址并置入描述符内相应字段
    ;(2)初始化为GDTR准备的伪描述符
INIT_GDT PROC 	NEAR
             PUSH   DS
             MOV    AX,GDTSEG                          ;定义的GDT段段值挪到AX中
             MOV    DS,AX                              ;定义的GDT段段值挪到DS中
             MOV    CX,GDNUM                           ;GDNUM是初始化的描述符个数
             MOV    SI,OFFSET EFFGDT                   ;EFFGDT是开始偏移
    ;将描述符中的基址扩展到32位
    INITG:   
             MOV    AX,[SI].BASEL                      ;取出预置的段值
             MOVZX  EAX,AX                             ;将初始化进去的16位段值扩展到32位
             SHL    EAX,4                              ;段值左移4位
             SHLD   EDX,EAX,16                         ;将 EAX 左移 16 位，然后将结果和目标操作数 EDX 的低位相结合，进位被放置到目标操作数的最高位
             MOV    [SI].BASEL,AX
             MOV    [SI].BASEM,DL                      ;置入描述符相应字段
             MOV    [SI].BASEH,DH
             ADD    SI,SIZE DESCRIPTOR                 ;调整到下一描述符
             LOOP   INITG                              ;所有描述符处理完后，退出循环
    ;描述符中的基址扩展完成
             POP    DS
    ;初始化为GDTR准备的伪描述符
             MOV    BX,16
             MOV    AX,GDTSEG
             MUL    BX
             MOV    WORD PTR VGDTR.BASE,AX
             MOV    WORD PTR VGDTR.BASE+2,DX
    ;VGDTR初始化完成
             RET
INIT_GDT ENDP
    ;初始化IDTR伪描述符子程序
INIT_IDT PROC
             MOV    BX,16
             MOV    AX,IDTSEG
             MUL    BX
             MOV    WORD PTR VIDTR.BASE,AX
             MOV    WORD PTR VIDTR.BASE+2,DX
             RET
INIT_IDT ENDP
RCodeSEG ENDS
END Start
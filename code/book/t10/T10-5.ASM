;程序名：T10-5.ASM
;功能：演示任务切换和任务内特权级变换
;
INCLUDE 386SCD.ASM;参见实例三
.386P
;全局描述符表
GDTSEG SEGMENT 	PARA 	USE16
    ;全局描述符表标号
                 GDT       LABEL 	BYTE
                 
    ;空描述符
                 DUMMY     DESCRIPTOR 		<>

    ;规范描述符
    ;描述符的含义为，段界限为0FFFFH，基址为0h，属性为R0可读写数据段
                 NORMAL    DESCRIPTOR 		<0FFFFH,0,0,ATDW,0>
    ;NORMAL为GDT第二个描述符，一个描述符结构体的长度位8h，所以NORMAL - 0 = 0008h
    ;0008h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示0环GDT中index = 1的描述符
    Normal_SEL   =         NORMAL - GDT

    ;全局描述符表任务定义描述符起始表示
                 EFFGDT    LABEL 	BYTE


    ;演示任务的任务状态段描述符
    ;描述符内容为，段界限为DemoTSSLEN - 1，基址为DemoTSSSEG段，属性为R0环386TSS类型值
                 DEMOTSS   DESCRIPTOR 		<DemoTSSLEN - 1,DemoTSSSEG,,AT386Tss,>
    ;DEMOTSS为GDT第三个描述符，一个描述符结构体的长度位8h，所以DEMOTSS - 0 = 0010h
    ;0010h = 0000 0000 0001 0000 = 0000000000010 0 00
    ;表示RPL=0环GDT中index = 2的描述符
    DemoTSS_SEL  =         DEMOTSS - GDT


    ;演示任务的局部描述符表段描述符
    ;描述符内容为，段界限为DemoLDTLEN - 1，基址为DemoLDTSEG段,属性为R0环局部描述符表段类型值
                 DEMOLDTAB DESCRIPTOR 		<DemoLDTLEN - 1,DemoLDTSEG,,ATLDT,>
    ;DEMOLDTAB为GDT第四个描述符，一个描述符结构体的长度位8h，所以DEMOLDTAB - 0 = 0018h
    ;0018h = 0000 0000 0001 1000 = 0000000000011 0 00
    ;表示RPL=0环GDT中index = 3的描述符
    DemoLDT_SEL  =         DEMOLDTAB - GDT


    ;临时任务的任务状态段描述符
    ;描述符内容为，段界限为TempTSSLEN - 1，基址为TempTSSSEG段，属性为R2环386TSS类型值
                 TEMPTSS   DESCRIPTOR 		<TempTSSLEN - 1,TempTSSSEG,,AT386TSS+DPL2,>
    ;TEMPTSS为GDT第五个描述符，一个描述符结构体的长度位8h，所以TEMPTSS - 0 = 0020h
    ;0020h = 0000 0000 0010 0000 = 0000000000100 0 00
    ;表示RPL=0环GDT中index = 4的描述符
    TempTSS_SEL  =         TEMPTSS - GDT


    ;临时任务代码段
    ;描述符内容为，段界限为0FFFFH，基址为TempCodeSEG段，属性为R0环可执行代码段
                 TEMPCODE  DESCRIPTOR 		<0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第六个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 0028h
    ;0028h = 0000 0000 0010 1000 = 0000000000101 0 00
    ;表示RPL=0环GDT中index = 5的描述符
    TempCode_SEL =         TEMPCODE - GDT


    ;子程序代码段描述符
    ;描述符内容为，段界限为SUBRLEN - 1，基址为SUBRSEG段，属性为R0环子程序代码段
                 SUBR      DESCRIPTOR 		<SUBRLEN - 1,SUBRSEG,,ATCE+D32,>
    ;SUBR为GDT第七个描述符，一个描述符结构体的长度位8h，所以SUBR - 0 = 0030h + 3h = 0033h
    ;0033h = 0000 0000 0011 0000 = 0000000000110 0 11
    ;表示RPL=3环GDT中index = 6的描述符
    SUBR_SEL     =         SUBR_GDT + RPL3


    ;显示缓冲区段描述符
    ;描述符内容为，段界限为0FFFFH，基址为0H，属性为R3环显示缓冲区段
                 VIDEOBUFF DESCRIPTOR 		<0FFFFH,0,0,0F00H+ATDW+DPL3,0>
    ;VIDEOBUFF为GDT第八个描述符，一个描述符结构体的长度位8h，所以VIDEOBUFF - 0 = 0038h
    ;0038h = 0000 0000 0011 1000 = 0000000000111 0 00
    ;表示RPL=0环GDT中index = 7的描述符
    Video_SEL    =         VIDEOBUFF - GDT

    ;可用的全局描述符个数
    GDNUM        =         ($ - EFFGDT)/(SIZE DESCRIPTOR)

    ;GDT长度
    GDTLEN       =         $	-	GDT
GDTSEG ENDS
;演示任务的任务状态段
DemoTSSSEG SEGMENT 	PARA 	USE16
               DD 0                   ;链接字
               DD DemoStack0LEN       ;0级堆栈指针
               DW DemoStack0_SEL,0
               DD 0                   ;1级堆栈指针(实例不使用)
               DW ?,0
               DD DemoStack2LEN       ;2级堆栈指针
               DW DemoStack2_SEL,0
               DD 0                   ;CR3
               DW DemoBegin,0         ;EIP
               DD 0                   ;EFLAGS
               DD 0                   ;EAX
               DD 0                   ;ECX
               DD 0                   ;EDX
               DD 0                   ;EBX
               DD DemoStack2LEN       ;ESP
               DD 0                   ;EBP
               DD 0                   ;ESI
               DD 0B8000H             ;EDI
               DW Video_SEL,0         ;ES
               DW DemoCode_SEL,0      ;CS
               DW DemoStack2_SEL,0    ;SS
               DW DemoData_SEL,0      ;DS
               DW ToDLDT_SEL,0        ;FS
               DW ToTTSS_SEL,0        ;GS
               DW DemoLDT_SEL,0       ;LDTR
               DW 0
               DW $ + 2               ;`I/O`许可位图指针
               DB 0FFH                ;`I/O`许可位图结束字节
    DemoTSSLEN =  $
DemoTSSSEG ENDS
;演示任务的局部描述符表LDT
DemoLDTSEG SEGMENT 	PARA 	USE16
    ;局部描述符表标号
                   DemoLDT    LABEL 	BYTE


    ;0级堆栈段描述符(32位段)
    ;描述符内容为，段界限为DemoStack0LEN - 1，基址为DemoStack0SEG段，属性为R0环32位可读写数据段
                   DEMOSTACKO DESCRIPTOR 		<DemoStack0LEN,,DemoStack0SEG,ATDW + D32,>
    ;DEMOSTACK0为LDT第一个描述符，一个描述符结构体的长度位8h，所以0 * 8 - 0 = 0h + 4h = 04h
    ;04h = 0000 0000 0000 0100 = 0000000000000 1 00
    ;表示RPL=0环LDT中index = 0的描述符
    DemoStackO_SEL =          (DEMOSTACK0 - DemoLDT) + TIL


    ;1级堆栈段描述符(32位段，DPL=2)
    ;描述符内容为，段界限为DemoStack1LEN - 1，基址为DemoStack1SEG段，属性为R2环32位可读写数据段
                   DEMOSTACK2 DESCRIPTOR 		<DemoStack2LEN - 1,DemoStack2SEG,ATDW+D32+DPL2,>
    ;DEMOSTACK1为LDT第二个描述符，一个描述符结构体的长度位8h，所以1*8 - 0 = 0008h + 4h = 0ch + 0001h = 0Dh
    ;0Dh = 0000 0000 0000 1101 = 0000000000001 1 01
    ;表示RPL=1环LDT中index = 1的描述符
    DemoStack2_SEL =          (DEMOSTACK2 - DemoLDT) + TIL + RPL2


    ;演示代码段描述符(32位段，DPL=2)
    ;描述符内容为，段界限为DemoCodeLEN - 1，基址为DemoCodeSEG段，属性为R2环32位可读写数据段
                   DEMOCODE   DESCRIPTOR 		<DemoCodeLEN - 1,DemoCodeSEG,,ATCE+D32+DPL2,>
    ;DEMOCODE为LDT第三个描述符，一个描述符结构体的长度位8h，所以2*8 - 0 = 0010h + 4h = 14h + 0001h = 15h
    ;15h = 0000 0000 0001 0101 = 0000000000010 1 01
    ;表示RPL=1环LDT中index = 2的描述符
    DemoCode_SEL   =          (DEMOCODE - DemoLDT) + TIL + RPL2


    ;演示数据段描述符(32位段，DPL=3)
    ;描述符内容为，段界限为DemoDataLEN - 1，基址为DemoDataSEG段，属性为R3环32位可读写数据段
                   DEMODATA   DESCRIPTOR 		<DemoDataLEN - 1,DemoDataSEG,,ATDW+D32+DPL3,>
    ;DEMODATA为LDT第四个描述符，一个描述符结构体的长度位8h，所以3*8 - 0 = 0018h + 4h = 1Ch
    ;1Ch = 0000 0000 0001 1100 = 0000000000011 1 00
    ;表示RPL=0环LDT中index = 3的描述符
    DemoData_SEL   =          (DEMODATA - DemoLDT) + TIL


    ;把LDT作为普通数据段描述的描述符(DPL=2)
    ;描述符内容为，段界限为DemoLDTLEN - 1，基址为DemoLDTSEG段，属性为R2环32位可读写数据段
                   TODLDT     DESCRIPTOR 		<DemoLDTLEN - 1,DemoLDTSEG,,ATDW+DPL2,>
    ;TODLDT为LDT第五个描述符，一个描述符结构体的长度位8h，所以4*8 - 0 = 0020h + 4h = 24h
    ;24h = 0000 0000 0010 0100 = 0000000000100 1 00
    ;表示RPL=0环LDT中index = 4的描述符
    ToDLDT_SEL     =          (TODLDT - DemoLDT) + TIL


    ;把TSS作为普通数据段描述的描述符(DPL=2)
    ;描述符内容为，段界限为TempTSSLEN - 1，基址为TempTSSSEG段，属性为R2环386TSS类型值
                   TOTTSS     DESCRIPTOR 		<TempTSSLEN - 1,TempTSSSEG,,ATDW+DPL2,>
    ;TOTTSS为LDT第六个描述符，一个描述符结构体的长度位8h，所以5*8 - 0 = 0028h + 4h = 2Ch
    ;2Ch = 0000 0000 0010 1100 = 0000000000101 1 00
    ;表示RPL=0环LDT中index = 5的描述符
    ToTTSS_SEL     =          (TOTTSS - DemoLDT)	+	TIL

    ;演示任务的LDT描述符个数
    DemoLDNUM      =          ($	-	DemoLDT)/(SIZE DESCRIPTOR)


    ;指向子程序SUBRB的调用门(DPL=3)
    ;TOSUBR为门描述符，含义为，SUBRB为偏移低16位，SUBR_SEL为目标选择子，0为参数计数器，AT386CGAT+DPL3为3环386调用门类型值，0为偏移高16位
                   TOSUBR     GATE 			<SUBRB,SUBR_SEL,0,AT386CGAT+DPL3,0>
    ;TOSUBR为LDT第七个描述符，一个描述符结构体的长度位8h，所以6 * 8 - 0 = 0030h + 4h = 34h
    ;34h = 0000 0000 0011 0100 = 0000000000110 1 10
    ;表示RPL=2环LDT中index = 6的描述符
    TOSUBR_SEL     =          (TOSUBR - DemoLDT) + TIL + RPL2


    ;指向临时任务Temp的任务门(DPL=3)
    ;TOTEMPT为门描述符，含义为，0为偏移低16位，TempTSS_SEL为目标选择子，0为参数计数器，AT386CGAT+DPL3为3环386调用门类型值，0为偏移高16位
                   TOTEMPT    GATE 			<0,TempTSS_SEL,0,ATTASKGAT+DPL3,0>
    ;TOTEMPT为LDT第八个描述符，一个描述符结构体的长度位8h，所以7 * 8 - 0 = 0038h + 4h = 38h
    ;38h = 0000 0000 0011 1000 = 0000000000111 1 00
    ;表示RPL=0环LDT中index = 7的描述符
    ToTempT_SEL    =          (TOTEMPT - DemoLDT) + TIL

    ;演示任务的LDT长度
    DemoLDTLEN     =          $ 	- 	DemoLDT
DemoLDTSEG ENDS
;演示任务的0级堆栈(32位段)
DemoStackOSEG SEGMENT 	PARA 	USE32
    DemoStackOLEN =  1024
                  DB DemoStack0LEN 	DUP (0)
DemoStackOSEG ENDS
;演示任务的2级堆栈(32位段)
DemoStack2SEG SEGMENT 	PARA 	USE32
    DemoStack2LEN =  512
                  DB DemoStack2LEN 	DUP (0)
DemoStack2SEG ENDS
;演示任务的数据段(32位段)
DemoDataSEG SEGMENT 	PARA 	USE32
    Message     DB 'Value=',0
    DemoDataLEN =  $
DemoDataSEG ENDS
;子程序段(32位段)
;CPL=0
;使用0级堆栈
SUBRSEG SEGMENT 	PARA 	USE32
            ASSUME     CS:SUBRSEG
SUBRB PROC 	FAR
            PUSH       EBP
            MOV        EBP,ESP
            PUSHAD                     ;保护现场
    ;从堆栈(0级)中取提示信息串偏移
    ;为什么是+12？
    ;+4是外层EIP
    ;+8是外层CS
    ;+12是第2个参数，Message起始地址
            MOV        EAX,[EBP+12]
            MOV        ESI,EAX
            MOV        AH,7
            JMP        SHORT SUBR2
    SUBR1:                             ;输出message信息与TempTask.TREIP
            STOSW
    SUBR2:  
            LODSB
            OR         AL,AL
            JNZ        SUBR1           ;从堆栈(0级)中取显示值
            MOV        EDX.[EBP+16]
            MOV        ECX,8
    SUBR3:  
            ROL        EDX,
            MOV        AL,DL
            CALL       HTOASC
            STOSW
            LOOP       SUBR3
            POPAD                      ;恢复现场
            POP        EBP
            RET        8               ;ret 8 堆栈平衡
SUBRB ENDP
HTOASC PROC
            AND        AL,0FH
            ADD        AL,90H
            DAA
            ADC        AL,40H
            DAA
            RET
            HTOASCENDP
    SUBRLEN =          $
SUBRSEG ENDS
;演示任务的代码段(32位段)
;从R0切换过来，CPL=2
DemoCodeSEG SEGMENT 	PARA 	USE32
                ASSUME CS:DemoCodeSEG
    DemoBegin:  
    ;表示在特权级向内层变换时，需从外层堆栈依次复制2个双字参数到内层堆栈
                MOV    FS:ToSUBR.DCOUNT,2
    ;向堆栈(2级)中压入参数
    ;TempTask 是临时任务TSS，当前要通过调用们进行特权集切换，现将返回地址压入对账
    ;将提示信息前缀压入堆栈
                PUSH   DWORD PTR GS:TempTask.TREIP
                PUSH   OFFSET Message
    ;通过调用门调用子程序 SUBRB
    ;选择子 TOSUBR_SEL RPL=2
    ;选择子 TOSUBR_SEL 指向的 TOSUBR 调用门 DPL=3 可以调用
    ;执行调用门 TOSUBR
    ;调用门指向 SUBR_SEL 选择子，RPL=0，且偏移为 SUBRB
    ;SUBR_SEL 选择子 RPL=3 指向的段为 SUBRSEG DPL=0
    ;特权集进行切换，堆栈也进行了切换
                CALL32 ToSUBR_SEL,0
    ;SUBRB的返回，`CPL=0`变换为`CPL=2`，堆栈也回到2级堆栈
    ;把指向规范数据段描述符的选择子填入临时任务TSS
                ASSUME DS:TempTSSSEG
                PUSH   GS
                POP    DS
                MOV    AX,Normal.SEL
                MOV    TempTask.TRDS,AX
                MOV    TempTask.TRES.AX
                MOV    TempTask.TRFS,AX
                MOV    TempTask.TRGS,AX
                MOV    TempTask.TRSS,AX
    ;通过任务切换到临时任务
    ;CPL=2
    ;ToTempT_SEL RPL=0
    ;ToTempT_SEL 指向的 TempTSS_SEL DPL=3，偏移为0
    ;TempTSS_SEL RPL=0 指向 TempTSSSEG DPL=2
    ;跳转TSS.CS TSS.EIP
    ;跳转CS:TempCodeSEG，EIP:ToReal
                JUMP32 ToTempT_SEL,0
    DemoCodeLEN =      $
DemoCodeSEG ENDS
;临时任务的任务状态段
TempTSSSEG SEGMENT 	PARA 	USE16
               TempTask TASKSS	<>
               DB       0FFH
    TempTSSLEN =        $
TempTSSSEG ENDS
;临时任务的代码段
TempCodeSEG SEGMENT 	PARA 	USE16
                 ASSUME CS:TempCodeSEC
    Virtual:     
    ;将 TempTSS 装载到 TR
    ;TempTSS_SEL 的 RPl=0
    ;TempTSS_SEL 指向的 TEMPTSS 的 DPL=2
                 MOV    BX,TempTSS_SEL
                 LTR    BX                          ;要把临时任务的现场保存到临时任务的`TSS`，这就要求`TR`指向临时任务的`TSS`
    ;CPL=0
    ;DemoTSS_SEL 的 RPL= 0
    ;DemoTSS_SEL 指向 DemoTSSSEG 的 DPL=0
    ;DemoTSSSEG 为定义的TSS段，预定义的CS=DemoCode_SEL,EIP=DemoBegin
    ;DemoCode_SEL 为指向 DemoCodeSEG 的选择子，RPL=2，DPL=2
    ;采用段间转移指令`JMP`，直接指向演示任务的`TSS`，切换到演示任务，切换动作包括
    ;1：把临时任务的执行现场保存到临时任务的`TSS`中
    ;2：从演示任务的`TSS`中恢复演示任务的现场
    ;3：把演示任务的`LDT`描述符选择子装载到`LDTR`等
                 JUMP16 DemoTSS_SEL,0               ;直接切换到演示任务
    ;TSS中的CS:TempCodeSEG，EIP:ToReal
    ToReal:                                         ;准备返回实方式
                 CLTS                               ;清空TS
    ;清任务切换标志
                 MOV    EAX,CR0
                 AND    EAX,0FFFFFFFEH
                 MOV    CR0,EAX                     ;PE位置0，返回实模式
    ;返回实方式
                 JUMP16 <SEG Real>,<OFFSET Real>
    TempCodel_EN =      $
TempCodeSEG ENDS
;实方式数据段
RDataSEG SEGMENT 	PARA 	USE16
             VGDTR PDESC <GDTLEN-1,>
    SPVAR    DW    ?
    SSVAR    DW    ?
RDataSEG ENDS
;实方式代码段
RCodeSEG SEGMENT 	PARA 	USE16
             ASSUME CS:RCodeSEG,DS:RDataSEG,ES:RDataSEG
    Start:   
             MOV    AX,RDataSEG
             MOV    DS,AX                                  ;装载实模式数据段
             CLD                                           ;设置方向标志
             CALL   INIT_GDT                               ;初始化GDT
             MOV    AX,DemoLDTSEG
             MOV    FS,AX
             MOV    CX,DemoLDNUM
             MOV    SI,OFFSET DemoLDT
             CALL   INIT_LDT                               ;初始化演示任务LDT
  
             MOV    SSVAR,SS
             MOV    SPVAR,SP                               ;保存实方式下的堆栈指针


             LGDT   QWORD PTR VGDTR                        ;装载GDTR
             CLI                                           ;关中断
             MOV    EAX,CR0
             OR     EAX,1
             MOV    CR0,EAX                                ;CR0的PE位置为1，切换到保护模式
    ;切换到保护方式
    ;CPL=0 TempCode_SEL(RPL=0) 可以调用
    ;TempCode_SEL 指向的 TempCodeSEG DPL=0，可以跳转
             JUMP16 <TempCode_SEL>,<OFFSET Virtual>
    Real:    
    ;又回到实方式
             MOV    AX,RDataSEG
             MOV    DS,AX
             LSS    SP,DWORD PTR SPVAR                     ;将源操作数加载到目标操作数中，并且 TR 寄存器的内容更新为源操作数
             STI                                           ;开中断
             MOV    AX,4C00H
             INT    21H
    ;初始化全局描述符表的子程序
    ;(1)把定义时预置的段值转换成32位段基地址并置入描述符内相应字段
    ;(2)初始化为GDTR准备的伪描述符
INIT_GDT PROC 	NEAR
             PUSH   DS
             MOV    AX,GDTSEG                              ;定义的GDT段段值挪到AX中
             MOV    DS,AX                                  ;定义的GDT段段值挪到DS中
             MOV    CX,GDNUM                               ;GDNUM是初始化的描述符个数
             MOV    SI,OFFSET EFFGDT                       ;EFFGDT是开始偏移
    ;将描述符中的基址扩展到32位
    INITG:   
             MOV    AX,[SI].BASEL                          ;取出预置的段值
             MOVZX  EAX,AX                                 ;将初始化进去的16位段值扩展到32位
             SHL    EAX,4                                  ;段值左移4位
             SHLD   EDX,EAX,16                             ;分解到2个16位寄存器
             MOV    [SI].BASEL,AX
             MOV    [SI].BASEM,DL                          ;置入描述符相应字段
             MOV    [SI].BASEH,DH
             ADD    SI,SIZE DESCRIPTOR                     ;调整到下一描述符
             LOOP   INITG                                  ;所有描述符处理完后，退出循环
    ;描述符中的基址扩展完成
             POP    DS
    ;初始化为GDTR准备的伪描述符
             MOV    BX,16
             MOV    AX,GDTSEG
             MUL    BX
             MOV    WORD PTR VGDTR.BASE,AX
             MOV    WORD PTR VGDTR.BASE+2,DX               ;VGDTR初始化完成
             RET
INIT_GDT ENDP
    ;初始化演示任务局部描述符表的子程序
    ;把定义时预置的段值转换成32位段基地址并置入描述符内相应字段
    ;入口参数：FS:SI=第一个要初始化的描述符
    ;CX=要初始化的描述符个数
INIT_LDT PROC
    ;将初始化进去的16位段值扩展到32位
    ILDT:    
             MOV    AX,FS:[SI].BASEL
             MOVZX  EAX,AX
             SHL    EAX,4
             SHLD   EDX,EAX.16
             MOV    FS:[SI].BASEL,AX
             MOV    FS:[SI].BASEM,DL
             MOV    FS:[SI].BASEH,DH
             ADD    SI,SIZE DESCRIPTOR
             LOOP   ILDT
    ;将初始化进去的16位段值扩展到32位结束
             RET
INIT_LDT ENDP
RCodeSEG ENDS
	END Start
;程序名：T10-11.ASM
;功能：演示进入和离开V86方式
	INCLUDE	386SCD.ASM
	.386P
;全局描述符表GDT
GDTSEG SEGMENT 	PARA 	USE16

    ;全局描述符起始地址标号
                  GDT       LABEL 	BYTE

    ;空描述符
                  DUMMY     DESCRIPTOR 			<>

    ;规范描述符
                  NORMAL    DESCRIPTOR			<0FFFFH,0,0,ATDW,0>
    Normal_SEL    =         NORMAL - GDT

    ;以下是需要额外初始化的全局描述符
                  EFFGDT    LABEL BYTE

    ;V86任务TSS段描述符
    ;描述符内容为，段界限为V86TSSLEN - 1，基址为V86TSS段，属性为R0环V86任务TSS段
                  V86TSS    DESCRIPTOR 			<V86TSSLEN-1,V86TSSSEG,,AT386TSS,>
    ;V86TSS为GDT第3个描述符，一个描述符结构体的长度位8h，所以 V86TSS - 0 = 0010h
    ;0010h = 0000 0000 0001 0000 = 0000000000010 0 00
    ;表示RPL=0环GDT中index = 2的描述符
    V86TSS_SEL    =         V86TSS - GDT

    ;V86任务局部描述符表的描述符
    ;描述符内容为，段界限为V86LDTLEN - 1，基址为V86LDT段，属性为R0环V86任务局部描述符表
                  V86LDT    DESCRIPTOR 			<V86LDTLEN-1,V86LDTSEG,,ATLDT,>
    ;V86LDT为GDT第4个描述符，一个描述符结构体的长度位8h，所以 V86LDT - 0 = 0018h
    ;0018h = 0000 0000 0001 1000 = 0000000000011 0 00
    ;表示RPL=0环GDT中index = 3的描述符
    V86LDT_SEL    =         V86LDT - GDT

    ;INTFF任务TSS段描述符
    ;描述符内容为，段界限为INTFFTSSLEN - 1，基址为INTFFTSS段，属性为R0环386TSS类型值
                  INTFFTSS  DESCRIPTOR 			<INTFFTSSLEN-1,INTFFTSSSEG,,AT386TSS,>
    ;INTFFTSS为GDT第5个描述符，一个描述符结构体的长度位8h，所以INTFFTSS - 0 = 0020h
    ;0020h = 0000 0000 0010 0000 = 0000000000100 0 00
    ;表示RPL=0环GDT中index = 4的描述符
    INTFFTSS_SEL  =         INTFFTSS - GDT

    ;INTFF任务局部描述符表的描述符
    ;描述符内容为，段界限为INTFFLDTLEN - 1，基址为INTFFLDT段，属性为R0环386LDT类型值
                  INTFFLDT  DESCRIPTOR 			<INTFFLDTLEN-1,INTFFLDTSEG,,ATLDT,>
    ;INTFFLDT为GDT第6个描述符，一个描述符结构体的长度位8h，所以INTFFLDT - 0 = 0028h
    ;0028h = 0000 0000 0010 1000 = 0000000000101 0 00
    ;表示RPL=0环GDT中index = 5的描述符
    INTFFLDT_SEL  =         INTFFLDT - GDT

    ;临时任务TSS段描述符
    ;描述符内容为，段界限为TempTSSLEN - 1，基址为TempTSSSEG段，属性为R0环386TSS类型值
                  TEMPTSS   DESCRIPTOR 			<TempTSSLEN-1,TempTSSSEG,,AT386TSS,>
    ;TEMPTSS为GDT第7个描述符，一个描述符结构体的长度位8h，所以TEMPTSS - 0 = 0030h
    ;0030h = 0000 0000 0011 0000 = 0000000000110 0 00
    ;表示RPL=0环GDT中index = 6的描述符
    TempTSS_SEL   =         TEMPTSS - GDT

    ;临时任务代码段描述符
    ;描述符内容为，段界限为0FFFFH，基址为TempCodeSEG段，属性为R0环可执行代码段
                  TEMPCODE  DESCRIPTOR 			<0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第8个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 0038h
    ;0038h = 0000 0000 0011 1000 = 0000000000111 0 00
    ;表示RPL=0环GDT中index = 7的描述符
    TempCode_SEL  =         TEMPCODE - GDT
    
    ;显示缓冲区描述符
    ;描述符内容为，段界限为80*25*2-1，基址为 0B800H ,属性为R3环显示缓冲区段
                  VIDEOBUFF DESCRIPTOR 			<80*25*2-1,0B800H,,ATDW,>
    ;VIDEOBUFF为GDT第9个描述符，一个描述符结构体的长度位8h，所以VIDEOBUFF - 0 = 0040h
    ;0040h = 0000 0000 0100 0000 = 0000000001000 0 00
    ;表示RPL=0环GDT中index = 8的描述符
    VideoBuff_SEL =         VIDEOBUFF - GDT

    ;全局描述符数
    GDNUM         =         ($ - EFFGDT)/(SIZE DESCRIPTOR)

    ;全局描述符表长度
    GDTLEN        =         $ - GDT
GDTSEG ENDS

;V86任务使用的中断描述符表IDT
IDTSEG SEGMENT 	PARA 	USE16

    ;IDT表起始地址标号
           IDT  LABEL 	BYTE
    ;对应0~12号中断/异常的中断门描述符
           REPT 13
           GATE <?,TPCode_SEL.0,AT386IGAT+DPL3.0>
ENDM

    ;对应一般保护异常的陷阱门描述符
           GATE <GPBegin,GPCode_SEL,0,AT386TGAT+DPL3,0>

    ;对应15-254号中断/异常的中断门描述符
           REPT 256 - 1 - 14
           GATE <?,TPCode-SEL,0.AT386IGAT+DPL3,0>
ENDM

    ;对应255(0FFH)号中断的任务门描述符
           GATE <?,INTFF.TSS_SEL,0,ATTASKGAT+DPL3.?>

    ;中断描述符表长度
    IDTLEN =    $ - IDT
IDTSEG ENDS

;INTFF任务的TSS段
INTFFTSSSEG SEGMENT 	PARA 	USE16
                DD 0                    ;链接字
                DD ?                    ;0级堆栈指针
                DW ?,?
                DD ?                    ;1级堆栈指针
                DW ?,?                  ;特权级不会变换，无需初始化
                DD ?                    ;2级堆栈指针
                DW ?,?
                DD 0                    ;CR3
                DW INTFFBegin,0         ;EIP
                DW 0,0                  ;EFLAGS
                DD 0                    ;EAX
                DD 0                    ;ECX
                DD 0                    ;EDX
                DD 0                    ;EBX
                DW INTFFStack0LEN,0     ;ESP
                DD 0                    ;EBP
                DD 0                    ;ESI
                DD 0                    ;EDI
                DW Normal_SEL,0         ;ES(段寄存器已初始化妥)
                DW INTFFCode SEL,0      ;CS
                DW INTFFStack0_SEL,0    ;SS
                DW Normal_SEL,0         ;DS
                DW Normal_SEL,0         ;FS
                DW Normal_SEL,0         ;GS
                DW INTFFLDT_SEL,0       ;LDT
                DW 0
                DW $ + 2                ;指向`I/O`许可位图区的指针
                DB 0FFH                 ;`I/O`许可位图结束字节
    INTFFTSSLEN =  $
INTFFTSSSEG ENDS
;
;INTFF社务的LDT段
INTFFLDTSEG SEGMENT 	PARA 	USE16

    ;LDT表起始地址标号
                    FLDT        LABEL 	BYTE

    ;0级堆钱段描述符
    ;描述符内容为，段界限为 INTFFStack0LEN - 1，基址为 INTFFStack0SEG 段，属性为R0环已访问读写段
                    INTFFSTACK0 DESCRIPTOR 		<INTFFStack0LEN-1,INTFFStack0SEG,,ATDWA,>
    ;INTFFSTACK0 为LDT第1个描述符，一个描述符结构体的长度位8h，所以0*8 - 0 = 0000h + 4h = 4h
    ;04h = 0000 0000 0000 0100 = 0000000000000 1 00
    ;表示RPL=0环LDT中index = 0的描述符
    INTFFStack0_SEL =           (INTFFSTACK0 - FLDT) + TIL

    ;代码段描述符
    ;描述符内容为，段界限为 INTFFCodeLEN - 1，基址为 INTFFCodeSEG 段，属性为R0环可读可执行代码段
                    INTFFCODE   DESCRIPTOR 		<INTFFCodeLEN-1,INTFFCodeSEG,,,ATCER,>
    ;INTFFCODE 为LDT第2个描述符，一个描述符结构体的长度位8h，所以1*8 - 0 = 0008h + 4h = 0ch
    ;0CH = 0000 0000 0000 1100 = 000000000001 1 00
    ;表示RPL=0环LDT中index = 1的描述符
    INTFFCode_SEL   =           (INTFFCODE - FLDT) + TIL
    
    ;LDT中描述符个数
    INTFFLDNUM      =           ($ - FLDT)/(SIZE DESCRIPTOR)

    ;LDT段长度
    INTFFLDTLEN     =           $
INTFFLDTSEG ENDS

    ;------------------
    ;INTFF任务的0级堆栈
INTFFStack0SEG SEGMENT 	PARA 	USE16
    INTFFStack0LEN =  512
                   DB INTFFStack0LEN DUP (0)
INTFFStack0SEG ENDS

;INTFF任务的代码段
INTFFCodeSEG SEGMENT 	PARA 	USE16
                 ASSUME CS:INTFFCodeSEG
    INTFFMESS    DB     'Return to real mode.'
    INTFFMESSLEN =      $ - INTFFMESS
    INTFFBegin:  
                 MOV    SI,OFFSET GPERRMESS
                 MOV    AX,VideoBuff.sel
                 MOV    ES,AX                     ;置显示缓冲区选择子
                 MOV    DI,0                      ;从屏幕左上角开始显示
                 MOV    AH,17H                    ;置显示属性
                 MOV    CX,INTFFMESSLEN           ;置提示信息长度
                 CLD
    INEXT:       
                 MOV    AL,CS:[SI]                ;从代码段取显示信息
                 INC    SI
                 STOSW                            ;显示返回实方式的提示信息
                 LOOP   INEXT
                 JUMP16 TempTSS_SEL,0             ;切换到临时任务
    INTFFCodeLEN =      $
INTFFCodeSEG ENDS

;V86任务的TSS段
V86TSSSEG SEGMENT 	PARA 	USE16
              DD 0                  ;链接字
              DD V86Stack0LEN       ;0级堆栈指针
              DW V86Stack0_SEL,?
              DD ?                  ;1级堆栈指针
              DW ?,?
              DD ?                  ;2级堆栈指针
              DW ?,?
              DD 0                  ;CR3
              DW V86Begin,0         ;EIP
              DW IOPL3,VMFL         ;EFLAGS(IO特权级为3,VM=1)
              DD 0                  ;EAX
              DD 0                  ;ECX
              DD 0                  ;EDX
              DD 0                  ;EBX
              DW V86Stack3LEN,0     ;ESP
              DD 0                  ;EBP
              DD 0                  ;ESI
              DD 0                  ;EDI
              DW V86CodeSEG,0       ;ES(V86方式下的段值)
              DW V86CodeSEG,0       ;CS
              DW V86Stack3SEG,0     ;SS
              DW V86CodeSEG,0       ;DS
              DW V86CodeSEG,0
              DW V86CodeSEG,0       ;GS
              DW V86LDT_SEL.0       ;V86任务的局部描述符表选择子
              DW 0
              DW $ + 2              ;指向`I/O`许可位图区的指针
              DB 4000H/8 DUP (0)    ;`I/O`许可位图
              DB 0FFH               ;`I/O`许可位图结束字节
    V86TSSLEN =  $
V86TSSSEG ENDS

;V86任务的LDT段
V86LDTSEG SEGMENT 	PARA 	USE16

    ;V86任务LDT起始标号
                  VLDT      LABEL 	BYTE

    ;V86任务线性地址空间中最低端1M字节段的描述符
    ;描述符内容为，段界限为0FFFFH，基址为0H，属性为R0环已访问可读写段
                  VALLMEM   DESCRIPTOR 			<0FFFFH,0,,8F00H+ATDWA,>
    ;VALLMEM 为LDT第1个描述符，一个描述符结构体的长度位8h，所以0*8 - 0 = 0000h + 4h = 4h
    ;04h = 0000 0000 0000 0100 = 0000000000000 1 00
    ;表示RPL=0环LDT中index = 0的描述符
    VAIIMEM_SEL   =         (VALLMEM - VLDT) + TIL

    ;V86任务0级堆找段描述符
    ;描述符内容为，段界限为 V86StackOLEN-1, 基址为V86Stack0SEGH，属性为R0环已访问可读写段
                  V86STACK0 DESCRIPTOR 			<V86StackOLEN-1,V86Stack0SEG,,ATDWA,>
    ;V86STACK0 为LDT第2个描述符，一个描述符结构体的长度位8h，所以1*8 - 0 = 0008h + 4h = 0ch
    ;0CH = 0000 0000 0000 1100 = 000000000001 1 00
    ;表示RPL=0环LDT中index = 1的描述符
    V86Stack0_SEL =         (V86STACK0 - VLDT) + TIL

    ;V86任务数据段描述符
    ;描述符内容为，段界限为 V86DataLEN-1, 基址为V86DataSEG，属性为R0环只读数据段
                  V86DATA   DESCRIPTOR 			<V86DataLEN-1,V86DataSEG,,ATDR,>
    ;V86DATA 为LDT第3个描述符，一个描述符结构体的长度位8h，所以2*8 - 0 = 0010h + 4h = 14h
    ;14h = 0000 0000 0001 0100 = 000000000010 1 00
    ;表示RPL=0环LDT中index = 2的描述符
    V86Data_SEL   =         (V86DATA - VLDT) + TIL

    ;V86任务中断/异常处理程序代码段描述符
    ;描述符内容为，段界限为 V86CodeLEN-1, 基址为V86CodeSEG，属性为R0环可读可执行代码段
                  TPCODE    DESCRIPTOR 			<TPCodeLEN-1,TPCodeSEG,,ATCE,>
    ;TPCode 为LDT第4个描述符，一个描述符结构体的长度位8h，所以3*8 - 0 = 0018h + 4h = 1ch
    ;1CH = 0000 0000 0001 1100 = 000000000011 1 00
    ;表示RPL=0环LDT中index = 3的描述符
    TPCode_SEL    =         (TPCODE - VLDT) + TIL

    ;V86任务通用保护异常处理程序代码段描述符
    ;描述符内容为，段界限为 GPCodeLEN-1, 基址为GPCodeSEG，属性为R0环可读可执行代码段
                  GPCODE    DESCRIPTOR 			<GPCodeLEN-1,GPCodeSEG,,ATCE,>
    ;GPCode 为LDT第5个描述符，一个描述符结构体的长度位8h，所以4*8 - 0 = 0020h + 4h = 24h
    ;24h = 0000 0000 0010 0100 = 000000000100 1 00
    ;表示RPL=0环LDT中index = 4的描述符
    GPCode_SEL    =         (GPCODE - VLDT) + TIL

    ;LDT中描述符个数
    V86LDNUM      =         ($ - VLDT)/(SIZE DESCRIPTOR)
    
    ;LDT段长度
    V861DTLEN     =         $ - VLDT
V86LDTSEG ENDS

;V86任务的0级堆栈
V86StackOSEG SEGMENT 	PARA 	USE16
    V86StackOLEN =  512
                 DB V86StackOLEN DUP (0)
V86StackOSEG ENDS

;V86任务的3级堆栈
V86Stack3SEG SEGMENT 	PARA 	USE16
    V86Stack3LEN =  1024
                 DB V86Stack3LEN DUP(0)
V86Stack3SEG ENDS

;V86数据段
VB6DataSEG SEGMENT 	PARA 	USE16
    GPERRMESS    DB  '......General Protection Error.....'
    GPERRMESSLEN =   $	-	GPERRMESS
    V86DatalEN   =   $
V86DataSEG ENDS

    ;定义部分代表堆栈单元的符号(参见图10.33)
    Perr         EQU WORD PTR [BP+0]
    Pip          EQU WORD PTR [BP+4]
    Pcs          EQU WORD PTR [BP+8]
    Pflag        EQU WORD PTR [BP+12]
    Psp          EQU WORD PTR [BP+16]
    Pss          EQU WORD PTR [BP+20]
    Pes          EQU WORD PTR [BP+24]
    Pds          EQU WORD PTR [BP+28]
    Pfs          EQU WORD PTR [BP+32]
    Pgs          EQU WORD PTR [BP+36]

    ;V86任务下的中断/异常处理程序代码段
TPCodeSEG SEGMENT 	PARA 	USE16
              ASSUME CS:TPCodeSEG
    TPBegin:  
    COUNT     =      0
              REPT   256                ;对应256个入口
              IF     COUNT 	EQ 		21H
              ENT21H LABEL 	BYTE        ;在第21H项处定义标号ENT21H
              ENDIF
              PUSH   BP
              MOV    BP,COUNT           ;置中断向量号到BP
              JMP    PROCESS            ;都转统一的处理程序
    COUNT     =      COUNT + 1
ENDM
    PROCESS:  
              PUSH   BP                 ;保存BP
              MOV    BP,SP              ;堆栈指针送BP
              PUSH   EAX
              PUSH   EBX                ;保存EAX,EBX
    ;1在V86堆栈顶形成返回点的现场
              MOV    AX,VAIIMEM_SEL     ;装载描述最低1M字节线性地址空间
              MOV    DS,AX              ;的描述符选择子
              XOR    EAX,EAX
              MOV    AX,Psp             ;修改在V86任务0级堆栈中保存的
              SUB    AX,3*2             ;3级堆栈指针，减3个字
              MOV    Psp,AX             ;即在V86方式下的堆栈顶空出3个字
              XOR    EBX,EBX
              MOV    BX,Pss             ;使EBX指向V86堆栈顶
              SHL    EBX,4
              ADD    EBX,EAX
              MOV    AX,Pip             ;把保存在0级堆栈中的返回地址的
              MOV    [EBX],AX           ;偏移部分送V86堆栈
              MOV    AX,Pcs
              MOV    [EBX+2],AX         ;段值部分送V86堆栈
              MOV    [AX],Pflag
              MOV    [EBX+4],AX         ;标志值送V86堆找
    ;2用对应的中断向量值代替返回地址
              MOV    BX,[BP]            ;取中断号
              SHL    BX,2               ;乘4
              MOV    AX,[BX]            ;取实方式下对应中断向量的偏移
              MOV    Pip,AX             ;代替0级堆栈中的EIP
              MOV    AX,[BX+2]          ;取实方式下对应中断向量的段值
              MOV    Pcs,AX             ;代替0级堆栈中的CS
              POP    EBX                ;恢复EBX、EAX等
              POP    EAX
              POP    BP
              POP    BP
    ;3从保护方式返回V86方式
    ;先转入对应中断处理程序，再返回中断发生处
              IRETD
    TPCodeLEN =      $
TPCodeSEG ENDS

;V86任务下的通用保护异常处理程序代码段
GPCodeSEG SEGMENT 	PARA 	USE16
              ASSUME CS:GPCodeSEG
    GPBegin:  
              MOV    AX,V86Data_SEL
              MOV    DS,AX                  ;装载V86任务的数据段
              MOV    SI,OFFSET GPERRMESS
              MOV    AX,VideoBuff_sel
              MOV    ES,AX
              MOV    DI,0
              MOV    AH,17H                 ;显示属性值
              MOV    CX,GPERRMESSLEN
              CLD
    GNEXT:    
              LODSB
              STOSW                         ;显示发生通用保护异常的提示信息
              LOOP   GNEXT                  ;利用DOS的21H功能调用终止引起该异常的程序
              ADD    ESP,4                  ;废除堆栈中的出错代码
              MOV    AX,4C01H
              JUMP16 TPCode_SEL,ENT21H      ;转21H号中断处理程序
    GPCodeLEN =      $
GPCodeSEG ENDS
;V86方式执行的8086程序段
V86CodeSEG SEGMENT 	PARA 	USE16
               ASSUME CS:V86CODESEG,DS:V86CODESEG
    Message    DB     'V86 is OK.',0DH.0AH,24H
    V86Begin:  
    ;处于V86方式
               MOV    AH,9                           ;显示进入V86方式的提示信息
               MOV    DX,OFFSET Message
               INT    21H                            ;驻留内存方式返回到DOS
               MOV    AX,RCodeSEG
               SUB    AX,GDTSEG                      ;计算驻留的长度
               MOV    DX,OFFSET TSRLINE +16
               SHR    DX,4                           ;以“节”为单位
               ADD    DX,AX
               ADD    DX,10H                         ;含PSP的节数
               MOV    AX,3100H
               INT    21H
V86CodeSEG ENDS

;临时任务的TSS段
TempTSSSEG SEGMENT 	PARA 	USE16
               DD 0                 ;链接字
               DD ?                 ;0级堆栈指针
               DW ?,?               ;总是特权级0,无堆栈切换
               DD ?                 ;1级堆栈指针
               DW ?,?
               DD ?                 ;2级堆栈指针
               DW ?,?
               DD 0                 ;CR3
               DW ?,0               ;EIP
               DD 0                 ;EFLAGS
               DD 0                 ;EAX
               DD 0                 ;ECX
               DD 0                 ;EDX
               DD 0                 ;EBX
               DW ?,0               ;ESP
               DD 0                 ;EBP
               DD 0                 ;ESI
               DD 0                 ;EDI
               DW ?,0               ;ES
               DW TempCode_SEL,0    ;CS
               DW ?,0               ;SS
               DW ?,0               ;DS
               DW ?,0               ;FS
               DW ?,0               ;GS
               DW 0,0               ;LDT(临时任务不使用LDT)
               DW 0                 ;指向`I/O`许可位图区的指针
               DW $ + 2
               DB 0FFH              ;`I/O`许可位图结束字节
    TempTSSLEN =  $
TempTSSSEG ENDS

;临时任务的代码段
TempCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:TempCodeSEG
    Virtual:                                       ;进入保护方式后的入口点
                MOV    AX,TempTSS_SEL
                LTR    AX                          ;加载TR指向临时任务的TSS
                MOV    AX,Normal.SEL               ;准备切换到V86任务
                MOV    DS,AX                       ;给各段寄存器赋适当的选择子
                MOV    ES,AX
                MOV    FS,AX
                MOV    GS,AX
                MOV    SS,AX
                JUMP16 V86TSS_SEL,0
    ;转移到V86任务(V86方式)
    ;从INTFF任务回到临时任务的入口点
    ToReal:     
                CLTS
                MOV    EAX,CR0
                AND    EAX,0FFFFFFFEH
                MOV    CR0,EAX .                   ;返回实方式
                JUMP16 <SEG Real>,<OFFSET Real>
TempCodeSEG ENDS

;实方式下的初始化代码和数据
RCodeSEG SEGMENT 	PARA 	USE16
             VGDTR     PDESC		<GDTLEN-1,>                 ;伪GDTR
             VIDTR     PDESC 		<IDTLEN-1,>                ;伪IDTR
             NORVIDTR  PDESC		<3FFH,0>                    ;保存实方式下的IDTR
    SPVAR    DW        ?                                  ;保存实方式下的堆栈指针
    SSVAR    DW        ?
             ASSUME    CS:RCodeSEG,DS:RCodeSEG
    Start:   
             MOV       AX,RCodeSEG
             MOV       DS,AX
             CLD
             CALL      INIT_GDT                           ;初始化GDT
             CALL      INIT_IDT                           ;初始化IDT
             MOV       AX,V86LDTSEG
             MOV       FS,AX
             MOV       CX,V86LDNUM
             MOV       SI,OFFSET VLDT
             CALL      INIT_LDT                           ;初始化V86任务的LDT
             MOV       AX,INTFFLDTSEG
             MOV       FS,AX
             MOV       CX,INTFFLDNUM
             MOV       SI,OFFSET FLDT
             CALL      INIT_LDT                           ;初始化INTFF任务的LDT
             MOV       SSVAR,SS                           ;保存实方式下的堆栈指针
             MOV       SPVAR,SP
             LGDT      QWORD PTR VGDTR                    ;装载GDTR
             SIDT      NORVIDTR                           ;保存IDTR
             CLI
             LIDT      QWORD PTR VIDTR                    ;装载IDTR
             MOV       EAX,CR0
             OR        EAX,1
             MOV       CR0,EAX                            ;转保护方式下的临时任务
             JUMP16    <TempCode_SEL>,<OFFSET Virtual>
    Real:                                                 ;从保护方式回到实方式时的入口点
             MOV       AX,CS
             MOV       DS,AX
             LIDT      NORVIDTR                           ;恢复IDTR
             LSS       SP,DWORD PTR SPVAR
             STI
             MOV       AX,4C00H                           ;结束发出INTFF指令的DOS程序
             INT       21H
             TSRLINE   LABEL 	BYTE
    ;实方式下的初始化过程
INIT_GDT PROC	NEAR
    ;同实例四
INIT_GDT ENDP
    ;初始化局部描述符表的过程
INIT_LDT PROC
    ;同实例四
INIT_LDT ENDP
    ;初始化IDT表及伪IDTR的过程
INIT_IDT PROC
             PUSH      DS
             MOV       AX,IDTSEG
             MOV       DS,AX
             MOV       CX,256-1                           ;对FFH号特殊处理
             MOV       SI,OFFSET IDT
             MOV       AX,OFFSET TPBegin
    IIDT1:   
             CMP       CX,256-1-13
             JZ        IIDT2                              ;对13号特殊处理
             MOV       [SI],AX
    IIDT2:   
             ADD       SI,8                               ;每个门描述符8字节
             ADD       AX.7                               ;处理程序开始部分长7字节
             LOOP      IIDT
             POP       DS
    ;
             MOV       BX,16
             MOV       AX,IDTSEG
             MUL       BX                                 ;设置伪IDTR
             MOV       WORD PTR VIDTR.BASE,AX
             MOV       WORD PTR VIDTR.BASE+2,DX
             RET
             INIT_IDTE NDP
RCodeSEG ENDS
	END Start
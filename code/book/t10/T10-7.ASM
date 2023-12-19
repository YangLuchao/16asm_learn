;程序名：T10-7.ASM
;功能：模拟异常和演示异常处理
;
	INCLUDE	386SCD.ASM
;参见实例三
	.386P
;全局描述符表GDT
GDTSEG SEGMENT PARA 	USE16
    ;全局描述符表标号
                  GDT       LABEL 	BYTE

    ;空描述符
                  DUMMY     DESCRIPTOR		<>

    ;规范描述符
    ;描述符内容为，段界限为0FFFFH，基址为0h，属性为可读可写数据段
                  NORMAL    DESCRIPTOR 		<0FFFFH,0,0,ATDW,0>
    Normal_SEL    =         NORMAL - GDT

    ;全局描述符表任务定义描述符起始标识
                  EFFGDT    LABEL BYTE

    ;临时代码段描述符
    ;描述符内容为，段界限为0FFFFH，基址为 TempCodeSEG 段，属性为R0环可执行代码段
                  TEMPCODE  DESCRIPTOR 	<0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第三个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 2 * 8h = 0010h
    ;0010h = 0000 0000 0001 0000 = 0000000000010 0 00
    ;表示RPL=0环GDT中index = 2的描述符
    TempCode_SEL  =         TEMPCODE - GDT

    ;演示任务代码段描述符
    ;描述符内容为，段界限为DemoCodeLEN - 1，基址为 DemoCodeSEG 段，属性为R0环可执行代码段
                  DEMOCODE  DESCRIPTOR 	<DemoCodeLEN-1,DemoCodeSEG,,ATCE,>
    ;DEMOCode为GDT第四个描述符，一个描述符结构体的长度位8h，所以DEMOCode - 0 = 3 * 8h = 0018h
    ;0018h = 0000 0000 0001 1000 = 0000000000011 0 00
    ;表示RPL=0环GDT中index = 3的描述符
    DemoCode_SEL  =         DEMOCODE - GDT

    ;演示任务局部描述符表段描述符
    ;描述符内容为，段界限为DemoLDTLEN - 1，基址为 DemoLDTSEG 段，属性为R0环LDT
                  DEMOLDT   DESCRIPTOR 	<DemoLDTLEN-1,DemoLDTSEG,,ATLDT,>
    ;DEMOCode为GDT第五个描述符，一个描述符结构体的长度位8h，所以DEMOCode - 0 = 4 * 8h = 0020h
    ;0020h = 0000 0000 0010 0000 = 0000000000100 0 00
    ;表示RPL=0环GDT中index = 4的描述符
    DemoLDT_SEL   =         DEMOLDT - GDT

    ;演示任务TSS段描述符
    ;描述符内容为，段界限为DemoTSSLEN - 1，基址为 DemoTSSSEG 段，属性为R0环TSS
                  DEMOTSS   DESCRIPTOR 	<DemoTSSLEN-1,DemoTSSSEG,,AT386Tss,>
    ;DEMOCode为GDT第六个描述符，一个描述符结构体的长度位8h，所以DEMOCode - 0 = 5 * 8h = 0028h
    ;0028h = 0000 0000 0010 1000 = 0000000000101 0 00
    ;表示RPL=0环GDT中index = 5的描述符
    DemoTSS_SEL   =         DEMOTSS - GDT

    ;缓冲数据段描述符
    ;描述符内容为，段界限为BufferLEN - 1，基址为 BufferSEG 段，属性为R0环可读写数据段
                  XBUFFER   DESCRIPTOR 	<BufferLEN-1,BufferSEG,,ATDW,>
    ;XBUFFER为GDT第七个描述符，一个描述符结构体的长度位8h，所以XBUFFER - 0 = 6 * 8h = 0030h
    ;0030h = 0000 0000 0011 0000 = 0000000000110 0 00
    ;表示RPL=0环GDT中index = 6的描述符
    XBuffer_SEL   =         XBUFFER - GDT

    ;读键盘任务局部描述符表段描述符
    ;描述符内容为，段界限为GKeyLDTLEN - 1，基址为 GKeyLDTSEG 段，属性为R0环LDT
                  GKEYLDT   DESCRIPTOR 	<GKeyLDTLEN-1,GKeyLDTSEG,,ATLDT,>
    ;GKeyLDT为GDT第八个描述符，一个描述符结构体的长度位8h，所以GKeyLDT - 0 = 7 * 8h = 0038h
    ;0038h = 0000 0000 0011 1000 = 0000000000111 0 00
    ;表示RPL=0环GDT中index = 7的描述符
    GKeyLDT_SEL   =         GKEYLDT - GDT
    
    ;读键盘任务TSS段描述符
    ;描述符内容为，段界限为GKeyTSSLEN - 1，基址为 GKeyTSSSEG 段，属性为R0环TSS
                  GKEYTSS   DESCRIPTOR 	<GKeyTSSLEN-1,GKeyTSSSEG,,AT386TSS,>
    ;GKeyTSS为GDT第九个描述符，一个描述符结构体的长度位8h，所以GKeyTSS - 0 = 8 * 8h = 0040h
    ;0040h = 0000 0000 0100 0000 = 0000000001000 0 00
    ;表示RPL=0环GDT中index = 8的描述符
    GKeyTSS_SEL   =         GKEYTSS - GDT

    ;视频缓冲区段描述符(B8000H)
    ;描述符内容为，段界限为80*25*2-1，基址为0B800H，属性为R0环已访问可读写数据段
                  VIDEOBUFF DESCRIPTOR 	<80*25*2-1,0B800H,,ATDW,>
    ;VIDEOBUFF为GDT第十个描述符，一个描述符结构体的长度位8h，所以VIDEOBUFF - 0 = 9 * 8h = 0048h
    ;0048h = 0000 0000 0100 1000 = 000000001001 0 00
    ;表示RPL=0环GDT中index = 9的描述符
    VideoBuff_SEL =         VIDEOBUFF - GDT

    ;显示陷阱处理程序代码段描述符
    ;描述符内容为，段界限为EchoCodeLEN - 1，基址为 EchoCodeSEG 段，属性为R0环可执行代码段
                  ECHOCODE  DESCRIPTOR 	<EchoCodeLEN-1,EchoCodeSEG,,ATCE,>
    ;ECHOCODE为GDT第十一个描述符，一个描述符结构体的长度位8h，所以ECHOCODE - 0 = 10 * 8h = 0050h
    ;0050h = 0000 0000 0101 0000 = 000000001010 0 00
    ;表示RPL=0环GDT中index = 10的描述符
    EchoCode_SEL  =         ECHOCODE - GDT

    ;显示出错码过程代码段描述符
    ;描述符内容为，段界限为SUBCodeLEN - 1，基址为 SUBCodeSEG 段，属性为R0环可执行代码段
                  SUBCODE   DESCRIPTOR 	<SUBCodeLEN-1,SUBCodeSEG,,ATCE,>
    ;SUBCODE为GDT第十二个描述符，一个描述符结构体的长度位8h，所以SUBCODE - 0 = 11 * 8h = 0058h
    ;0058h = 0000 0000 0110 1000 = 000000001011 0 00
    ;表示RPL=0环GDT中index = 11的描述符
    SUBCode_SEL   =         SUBCODE - GDT

    ;其他中断或异常处理程序代码段描述符
    ;描述符内容为，段界限为OtherCodeLEN - 1，基址为OtherCodeSEG段，属性为R0环可执行代码段
                  OTHER     DESCRIPTOR	<OTHERCodeLEN-1,OTHERCodeSEG,,ATCE,>
    ;OTHER为GDT第十三个描述符，一个描述符结构体的长度位8h，所以OTHER - 0 = 12 * 8h = 0060h
    ;0060h = 0000 0000 0111 0000 = 000000001100 0 00
    ;表示RPL=0环GDT中index = 12的描述符
    OTHER_SEL     =         OTHER - GDT

    ;GDT中需要初始化基地址的描述符个数
    GDNUM         =         ($ - EFFGDT)/(SIZE DESCRIPTOR)

    ;GDT的长度
    GDTLEN        =         $ - GDT
GDTSEG ENDS

;中断描述符表IDT
IDTSEG SEGMENT 	PARA 	USE16

    ;IDT起始地址标识
           IDT   LABEL 	BYTE

    ;00H号陷耕门描述符(对应除法出错故障)
           INT00 GATE 	<DIVBegin ,Divide_SEL,0,AT386TGAT,0>

    ;从01~03的3个陷饼门描述符
           REPT  3
           GATE  <OtherBegin,OTHER_SEL,0,AT386TGAT,0>
ENDM

    ;04H号陷阱门描述符(对应溢出陷阱)
           INT04 GATE 	<OFBegin,OF_SEL,0,AT386TGAT,0>

    ;从05~0AH的6个陷阱门描述符
           REPT  6
           GATE  <OtherBegin,OTHER_SEL,0,AT386TGAT,0>
ENDM

    ;0BH号陷阱门描述符(对应段不存在故障)
           INT0B GATE 	<SNPBegin,SNP_SEL,0,AT386TGAT,0>

    ;OCH号陷阱门描述符(对应堆栈段故障)
           INT0C GATE 	<SSEBegin,SSE_SEL,0,AT386TGAT,0>

    ;0DH号陷阱门描述符(对应通用保护故障)
           INT0D GATE 	<GPBegin,GP_SEL,0,AT386TGAT,0>

    ;从OE~EDH的240个陷阱门描述符
           REPT  254 - 14
           GATE  <OtherBegin,OTHER_SEL,0,AT386TGAT,0>
ENDM

    ;O0EH号陷阱门描述符(对应显示中断处理程序)
           INTFE GATE 	<EchoBegin,EchoCode_SEL,0,AT386TGAT,>

    ;0FFH号任务门描述符(对应读键盘中断处理任务)
           INTFF GATE 	<,GKeyTSS_SEL,0,ATTASKGAT,>

    ;IDT长度
    IDTLEN =     $	-	IDT
IDTSEG ENDS

;---------------------------------
;读键盘任务局部描述符表段
GKeyLDTSEG SEGMENT 	PARA 	USE16
    ;读键盘任务LDT起始地址标识
                  GLDT      LABEL 	BYTE

    ;代码段描述符
    ;描述符内容为，段界限为 0FFFFH，基址为 GKeyCodeSEG 段，属性为R0环可执行代码段
                  GKEYCODE  DESCRIPTOR 	<0FFFFH,GKeyCodeSEG,,ATCE,>
    ;GKeyCode为GLDT第一个描述符，一个描述符结构体的长度位8h，所以GKeyCode - 0 = 0 * 8h = 0000h +4H = 4H
    ;04h = 0000 0000 0000 0100 = 0000000000000 1 00
    ;表示RPL=0环GLDT中index = 0的描述符
    GKeyCode_SEL  =         (GKEYCODE - GLDT) + TIL
    
    ;堆栈段描述符
    ;描述符内容为，段界限为 GKeyStackLEN - 1，基址为 GKeyStackSEG 段，属性为R0环已访问可读写段
                  GKEYSTACK DESCRIPTOR 	<GKeyStackLEN-1,GKeyStackSEG,,ATDWA,>
    ;GKeyStack 为GLDT第二个描述符，一个描述符结构体的长度位8h，所以GKeyStack - 0 = 1 * 8h = 0008h + 4H = 0CH
    ;0CH = 0000 0000 0000 1100 = 000000000001 1 00
    ;表示RPL=0环GLDT中index = 1的描述符
    GKeyStack_SEL =         (GKEYSTACK - GLDT) + TIL

    ;该LDT中需要初始化基地址的描述符个数
    GKeyLDNUM     =         ($ - GLDT)/(SIZE DESCRIPTOR)

    ;LDT长度
    GKeyLDTLEN    =         $
GKeyLDTSEG ENDS

;读键盘任务TSS段
GKeyTSSSEG SEGMENT 	PARA 	USE16
               DD 0                  ;链接字
               DD ?                  ;0级堆栈指针
               DW ?,?
               DD ?                  ;1级堆栈指针
               DW ?,?
               DD ?                  ;2级堆栈指针
               DW ?,?
               DD 0                  ;CR3
               DW GKeyBegin , 0      ;EIP
               DD 0                  ;EFLAGS
               DD 0                  ;EAX
               DD 0                  ;ECX
               DD 0                  ;EDX
               DD 0                  ;EBX
               DW GKeyStackLEN,0     ;ESP
               DD 0                  ;EBP
               DD 0                  ;ESI
               DD 0                  ;EDI
               DW Normal_SEL,0       ;ES
               DW GKeyCode_SEL,0     ;CS
               DW GKeyStack_SEL,0    ;SS
               DW Normal_SEL,0       ;DS
               DW Normal_SEL,0       ;FS
               DW Normal_SEL,0       ;GS
               DW GKeyLDT_SEL,0      ;LDT
               DW 0                  ;TSS的特别属性字
               DW $+2                ;指向`I/O`许可位图区的指针
               DB OFFH               ;`I/O`许可位图结束字节
    GKeyTSSLEN =  $
GKeyTSSSEG ENDS

;读键盘任务堆栈段
GKeyStackSEG SEGMENT 	PARA 	USE16
    GKeyStackLEN =  1024
                 DB GKeyStackLEN 	DUP 	(0)
GKeyStackSEG ENDS

;读键盘任务代码段
;当前保护模式
GKeyCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:GKeyCodeSEG,DS:RDataSEG,ES:BufferSEG
    GKeyBegin:  
                PUSH   DS
                PUSH   ES
                PUSH   FS
                PUSH   GS
                MOV    AX,Normal_SEL
                MOV    SS,AX                                      ;准备转实方式
                MOV    EAX,CR0
                AND    EAX,0FFFFFFFEH
                MOV    CR0,EAX                                    ;PE位置0，转实模式
                JUMP16 <SEG GetKey>,<OFFSET GetKey>
    GetKey:     
                MOV    AX,RDataSEG                                ;实模式数据段
                MOV    DS,AX
                MOV    EBP,ESP                                    ;恢复实方式部分现场
                LSS    SP,DWORD PTR SPVAR                         ;将 SPVAR 加载到 SP 中，并且 TR 寄存器的内容更新为 SPVAR
                LIDT   NORVIDTR                                   ;恢复IDTR的值
                STI                                               ;开中断
                MOV    DX,OFFSET MESS                             ;Strike a key [0,4,B,C,D]:$
                MOV    AH,9
                INT    21H                                        ;显示提示信息
    GetKey1:    
                MOV    AH,0
                INT    16H                                        ;读键盘
                CMP    AL,'0'
                JZ     GetKey2                                    ;输入等于0
                CMP    AL,'4'                                     ;只有[0,4,B,C,D]有效
                JZ     GetKey2
                AND    AL,11011111B                               ;小写转大写
                CMP    AL,'B'
                JB     GetKey1                                    ;小于B，跳
                CMP    AL,'D'
                JA     GetKey1                                    ;大于D，跳
    GetKey2:    
                MOV    DL,AL
                MOV    AH,2
                INT    21H                                        ;显示所按字符
                MOV    AX,BufferSEG
                MOV    ES,AX
                MOV    ES:KeyASCII,DL                             ;保存到缓冲数据段
                CLI                                               ;准备返回保护方式
                LIDT   QWORD PTR VIDTR
                MOV    EAX,CR0
                OR     EAX,1                                      ;PE位置为1
                MOV    CR0,EAX                                    ;返回保护方式
                JUMP16 <GKeyCode_SEL>,<OFFSET GetKeyV >
    GetKeyV:                                                      ;又进保护方式
                MOV    AX,GKeyStack_SEL                           ;设置堆栈段
                MOV    SS,AX
                MOV    ESP,EBP
                POP    GS
                POP    FS
                POP    ES
                POP    DS
                IRETD                                             ;中断返回，弹出cs/eip/EFLAGS
                JMP    GKeyBegin
    GKeyCodeLEN =      $
GKeyCodeSEG ENDS

;其他中断或异常处理程序代码段
OtherCodeSEG SEGMENT 	PARA 	USE16
                 ASSUME CS:OtherCodeSEG
    OtherBegin:  
                 MOV    SI,OFFSET MESSOTHER
                 INT    0FEH                   ;显示提示信息
                 JMP    $                      ;进入无限循环
    OtherCodeLEN =      $
OtherCodeSEG ENDS

;除法出错故障处理程序代码段
;触发除零错误，打印出提示信息
DIVCodeSEG SEGMENT 	PARA 	USE16
               ASSUME CS:DIVCodeSEG
    DIVBegin:  
               MOV    SI,OFFSET MESS0
               MOV    DI,0
               INT    OFEH               ;显示提示信息
               SHR    AX,1               ;处理模拟的除法错误，右移一位
               IRETD                     ;中断返回，依次弹出EIP,CS,EFLAGS
    ;返回
    DIVCodeLEN =      $
DIVCodeSEG ENDS

;溢出陷阱处理程序代码段
;模拟溢出陷阱，打印出提示信息
OFCodeSEG SEGMENT 	PARA 	USE16
              ASSUME CS:OFCodeSEG
    OFBegin:  
              MOV    SI,OFFSET MESS4
              MOV    DI,0
              INT    0FEH               ;显示提示信息
              IRETD                     ;返回
    OFCodeLEN =      $
OFCodeSEG ENDS

;段不存在故障处理程序代码段
SNPCodeSEG SEGMENT 	PARA 	USE16
               ASSUME CS:SNPCodeSEG
    SNPBegin:  
               MOV    SI,OFFSET MESSB
               MOV    DI,0
               INT    0FEH                    ;显示提示信息
    ;
               POP    EAX                     ;弹出出错代码
               CALL16 SUBCode_SEL,SUBBegin    ;显示出错代码
    ;
               POP    EAX
               ADD    EAX,2                   ;按模拟的引起段不存在指令
               PUSH   EAX                     ;调整返回地址
               IRETD
    SNPCodeLEN =      $
SNPCodeSEG ENDS

;推找段故障处理程序代码段
SSECodeSEG SEGMENT 	PARA 	USE16
               ASSUME CS:SSECodeSEG
    SSEBegin:  
               MOV    SI,OFFSET MESSC
               MOV    DI,0
               INT    0FEH                    ;显示提示信息
               POP    EAX                     ;弹出出错代码
               CALL16 SUBCode_SEL,SUBBegin    ;显示出错代码
               POP    EAX
               ADD    EAX,4                   ;按模拟的引起堆栈段错误指令
               PUSH   EAX                     ;调整返回地址
               IRETD
    SSECodeLEN =      $
SSECodeSEG ENDS

;通用保护故障处理程序代码段
GPCodeSEG SEGMENT 	PARA 	USE16
              ASSUME CS:GPCodeSEG
    GPBegin:  
              PUSH   EBP
              MOV    EBP,ESP
              PUSH   EAX
              PUSH   ESI                     ;保护现场
              PUSH   EDI
              MOV    SI,OFFSET MESSD
              MOV    DI,0
              INT    0FEH                    ;显示提示信息
              MOV    EAX,[BP+4]              ;从堆栈中取出错代码
              CALL16 SUBCode_SEL,SUBBegin    ;显示出错代码
              POP    EDI
              POP    ESI                     ;恢复部分现场
              POP    EAX
              ADD    DWORD PTR[EBP+8],2      ;按模拟的故障指令调整返回地址
              POP    EBP
              ADD    SP,4                    ;废除堆栈中的出错代码
              IRETD
    GPCodeLEN =      $
GPCodeSEG ENDS

;显示出错码过程代码段
SUBCodeSEG SEGMENT 	PARA 	USE16
               ASSUME CS:SUBCodeSEG
    SUBBegin:  
               PUSH   AX                   ;AX含出错代码
               PUSH   CX
               PUSH   DX                   ;保护现场
               PUSH   SI
               PUSH   DI
               MOV    SI,OFFSET ERRCODE
               MOV    DX.AX
               MOV    CX,4
    SUBR1:     
               ROL    DX,4                 ;把16位出错代码
               MOV    AL,DI                ;转成4位十六进制数的ASCII码
               AND    AL,0FH               ;并保存
               ADD    AL,30H
               CMP    AL,'9'
               JBE    SUBR2
               ADD    AL.
    SUBR2:     
               MOV    [SI],AL
               INC    SI
               LOOP   SUBR1
    ;
               MOV    SI,OFFSET ERRMESS
               MOV    DI,80 * 2            ;在第二行首开始
               INT    0FEH                 ;显示出错代码
               POP    DI
               POP    SI
               POP    DX                   ;恢复部分现场
               POP    CX
               POP
               RETF
    SUBCodeLEN =      $
SUBCodeSEG ENDS

;实现显示的陷阱处理程序代码段
EchoCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:EchoCodeSEG
    EchoBegin:                           ;DS:SI指向显示信息串，ES:DI指向显示缓冲区
                PUSHAD                   ;保护现场
                CLD
                MOV    AH,7
                MOV    AL,20H
                MOV    CX,80
                PUSH   DI
                REP    STOSW             ;清所在显示行
                POP    DI
    Echol:      
                LODSB
                OR     AL,AL
                JZ     Echo2
                STOSW                    ;显示指定信息串
                JMP    Echol
    Echo2:      
                POPAD                    ;核复现场
                IRETD
    EchoCodeLEN =      $
EchoCodeSEG ENDS

;缓冲区数据段
BufferSEG SEGMENT 	PARA 	USE16
    KeyASCII  DB ?
    Buffer    DB 128 DUP (?)
    BufferLEN =  $
BufferSEG ENDS

;演示任务局部描述符表段
DemoLDTSEG SEGMENT 	PARA 	USE16

    ;局部描述符开始地址标号
                  DLDT      LABEL 	BYTE

    ;演示任务TSS段描述符
    ;描述符内容为，段界限为 DemoTSSLEN - 1，基址为 DemoTSSSEG 段，属性为R0环可读写段
                  TODEMOTSS DESCRIPTOR 	<DemoTSSLEN-1,DemoTSSSEG,,ATDW,>
    ;TODEMOTSS 为 LDT 第一个描述符，一个描述符结构体的长度位8h，所以 TODEMOTSS - 0 = 0 * 8h = 0000h + 4h = 04h
    ;0004h = 0000 0000 0000 0100 = 000000000000 1 00
    ;表示RPL=0环LDT中index = 0的描述符
    ToDemoTSS_SEL =         (TODEMOTSS - DLDT) + TIL

    ;演示任务堆栈段描述符
    ;描述符内容为，段界限为 DemoStackLEN - 1，基址为 DemoStackSEG 段，属性为R0环已访问可读写段
                  DEMOSTACK DESCRIPTOR 	<DemoStackLEN-1,DemoStackSEG,,ATDWA>
    ;DEMOSTACK 为 LDT 第二个描述符，一个描述符结构体的长度位8h，所以 DEMOSTACK - 0 = 1 * 8h = 0008h + 4h = 0ch
    ;000ch = 0000 0000 0000 1100 = 000000000001 1 00
    ;表示RPL=0环LDT中index = 1的描述符
    DemoStack_SEL =         (DEMOSTACK - DLDT) + TIL

    ;演示任务数据段描述符
    ;描述符内容为，段界限为 DemoDataLEN - 1，基址为 DemoDataSEG 段，属性为R0环可读写段
                  DEMODATA  DESCRIPTOR 	<DemoDataLEN-1,DemoDataSEG,,ATDW,>
    ;DEMODATA 为 LDT 第三个描述符，一个描述符结构体的长度位8h，所以 DEMODATA - 0 = 2 * 8h = 0010h + 4h = 14h
    ;0014h = 0000 0000 0001 0100 = 000000000010 1 00
    ;表示RPL=0环LDT中index = 2的描述符
    DemoData_SEL  =         (DEMODATA  - DLDT) + TIL

    ;除法出错故障处理程序代码段描述符
    ;描述符内容为，段界限为 DIVCodeLEN - 1，基址为 DIVCodeSEG 段，属性为R0环可执行代码段
                  DIVIDE    DESCRIPTOR 	<DIVCodeLEN-1,DIVCodeSEG,,ATCE,>
    ;DIVIDE 为 LDT 第四个描述符，一个描述符结构体的长度位8h，所以 DIVIDE - 0 = 3 * 8h = 0018h + 4h = 1ch
    ;001ch = 0000 0000 0001 1100 = 000000000011 1 00
    ;表示RPL=0环LDT中index = 3的描述符
    Divide_SEL    =         (DIVIDE - DLDT) + TII

    ;溢出陷阱处理程序代码段描述符
    ;描述符内容为，段界限为 OFCodeLEN - 1，基址为 OFCodeSEG 段，属性为R0环可执行代码段
                  OVERFLOW  DESCRIPTOR <OFCodeLEN-1,OFCodeSEG,,ATCE,>
    ;OVERFLOW 为 LDT 第五个描述符，一个描述符结构体的长度位8h，所以 OVERFLOW - 0 = 4 * 8h = 0020h + 4h = 24h
    ;0024h = 0000 0000 0010 0100 = 000000000100 1 00
    ;表示RPL=0环LDT中index = 4的描述符
    OF_SEL        =         (OVERFLOW - DLDT) + TIL

    ;段不存在故障处理程序代码段描述符
    ;描述符内容为，段界限为 SNPCodeLEN - 1，基址为 SNPCodeSEG 段，属性为R0环可执行代码段
                  SNPCODE   DESCRIPTOR 	<SNPCodeLEN-1,SNPCodeSEG,,ATCE,>
    ;SNPCODE 为 LDT 第六个描述符，一个描述符结构体的长度位8h，所以 SNPCODE - 0 = 5 * 8h = 0028h + 4h = 2ch
    ;002ch = 0000 0000 0010 1100 = 000000000101 1 00
    ;表示RPL=0环LDT中index = 5的描述符
    SNP_SEL       =         (SNPCODE - DLDT) + TIL

    ;准栈段出错故障处理程序代码段描述符
    ;描述符内容为，段界限为 SSECodeLEN - 1，基址为 SSECodeSEG 段，属性为R0环可执行代码段
                  SSECODE   DESCRIPTOR	<SSECodeLEN-1,SSECodeSEG,,ATCE,>
    ;SSECODE 为 LDT 第七个描述符，一个描述符结构体的长度位8h，所以 SSECODE - 0 = 6 * 8h = 0030h + 4h = 34h
    ;0034h = 0000 0000 0011 0100 = 000000000110 1 00
    ;表示RPL=0环LDT中index = 6的描述符
    SSE_SEL       =         (SSECODE - DLDT) + TIL

    ;通用保护故障处理程序代码段描述符
    ;描述符内容为，段界限为 GPCodeLEN - 1，基址为 GPCodeSEG 段，属性为R0环可执行代码段
                  GPCODE    DESCRIPTOR	<GPCodeLEN-1,GPCodeSEG,,ATCE,>
    ;GPCODE 为 LDT 第八个描述符，一个描述符结构体的长度位8h，所以 GPCODE - 0 = 7 * 8h = 0038h + 4h = 3ch
    ;003ch = 0000 0000 0011 1100 = 000000000111 1 00
    ;表示RPL=0环LDT中index = 7的描述符
    GP_SEL        =         (GPCODE - DLDT) + TIL

    ;为模拟段不存在故障而安排的数据段描述符
    ;描述符内容为，段界限为 TestNPSLEN - 1，基址为 TestNPSSEG 段，属性为R0环可读写段
    ;该选择子索引的描述符中的存在位`P`被故意置为0表示对应段不在内存
                  TESTNPS   DESCRIPTOR	<0FFFFH,0,,ATDW-80H,>
    ;TESTNPS 为 LDT 第九个描述符，一个描述符结构体的长度位8h，所以 GPCODE - 0 = 8 * 8h = 0040h + 4h = 44h
    ;0044h = 0000 0000 0100 0100 = 000000001000 1 00
    ;表示RPL=0环LDT中index = 8的描述符
    TestNPS_SEL   =         (TESTNPS - DLDT) + TIL

    ;该LDT中需要初始化基地址的描述符个数
    DemoLDNUM     =         ($ - DLDT)/(SIZE DESCRIPTOR)

    ;LDT长度
    DemoLDTLEN    =         $
DemoI_DTSEG ENDS

    ;演示任务TSS段
DemoTSSSEG SEGMENT 	PARA 	USE16
               DemoTaskSS TASKSS	<>
               DB         0FFH
    DemoTSSLEN =          $
DemoTSSSEG ENDS

;演示任务堆栈段
DemoStackSEG SEGMENT 	PARA 	USE16
                 DemoStackLEN 1024
                 DB           1024 DUP (0)
DemoStackSEG ENDS

;演示任务数据段
DemoDataSEG SEGMENT 	PARA 	USE16
    MESS0       DB 'Divide Error (Exception 0)',0
    MESS4       DB 'Overflow (Exception 4)',0
    MESSB       DB 'Segment Not Present (Exception 11)',0
    MESSC       DB ''*Stack Segment (Exception 12)',0
    MESSI       DB 'General Protection (Exception 13)',0
    MESSOTHER   DB 'Other Execption',0
    ERRMESS     DB 'Error Code ='
    ERRCODE     DB 4 DUP (0),'H',0
    DemoDataLEN =  $
DemoDataSEG ENDS

;演示任务代码段
;CPL=0
DemoCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:DemoCodeSEG
    DemoBegin:  
                MOV    AX,DemoLDT_SEL
                LLDT   AX                                 ;装载LDTR
                MOV    AX,DemoStack_SEL
                MOV    SS,AX                              ;置堆栈指针
                MOV    ESP,DemoStackLEN
                MOV    AX,ToDemoTSS_SEL
                MOV    GS,AX                              ;把演示任务LDT选择子填入TSS
                MOV    GS:DemoTaskSS.TRLDT,DemoLDT_SEL    ;装载TR
                MOV    AX,DemoTSS_SEL
                LTR    AX                                 ;装载其他数据段寄存器
                MOV    AX,DemoData_SEL
                MOV    DS,AX
                MOV    AX,VideoBuff_SEL
                MOV    ES,AX
                MOV    AX,XBuffer_SEL
                MOV    FS,AX
                MOV    AX,XBuffer_SEL
                MOV    GS,AX                              ;接收要模拟的异常类型号
    ;按接收的字符模拟异常
    ;直接调用0FF中断，通过任务门访问演示任务TSS
    ;通过预定义的TSS，跳转到 GKeyCode_SEL 选择子 GKeyBegin 偏移处
    ;GKeyCode_SEL 指向 GKeyCodeSEG 段
                INT    0FFH
                MOV    AL,FS:KeyASCII
                CMP    AL,'0'
                JNZ    Demo4                              ;输入的字符不等于为0，跳
    Exceptiono: 
                MOV    AX,1000                            ;输入的字符为0
                MOV    CL,2
                DIV    CL                                 ;模拟除法出错故障，依次压入EFLAGS,CS,EIP，转入除0陷阱
                JMP    OVER
    Demo4:      
                CMP    AL,'4'
                JNZ    Demo11                             ;输入的字符不等于4，跳
    Exception4: 
                MOV    AL,100
                ADD    AL,50
                INTO                                      ;检查溢出标志（OF）并在发生溢出时触发软中断，如果OF=1，转入溢出陷阱
                JMP    OVER
    Demo11:     
                CMP    AL,'B'
                JNZ    Demo12
    Exception11:
                MOV    AX,TestNPS_SEL                     ;模拟段不存在故障
                MOV    GS,AX                              ;该指令长2字节
                JMP    OVER
    Demo12:     
                CMP    AL,'C'
                JNZ    Demo13
    Exception12:
                MOV    EBP,ESP                            ;模拟堆栈出错故障
                MOV    AL,[EBP]                           ;该指令长4字节
                JMP    OVER
    Demo13:     
    Exception13:
                MOV    AX,DemoTSS_SEL                     ;模拟通用保护故障
                MOV    GS,AX                              ;该指令长2字节
                JMP    OVER                               ;转临时代码段
    OVER:       
                JUMP16 TempCode_SEL,<OFFSET ToDOS>
    DemoCodeLEN =      $
DemoCodeSEG ENDS

;临时代码段
;CPL=0
TempCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:TempCodeSEG
    Virtual:                                       ;转演示代码段
                JUMP16 DemoCode_SEL,0
    ToDOS:                                         ;演示结束后准备返回实方式
                MOV    AX,Normal_SEL
                MOV    DS,AX
                MOV    ES,AX
                MOV    FS,AX
                MOV    GS,AX
                MOV    SS,AX
                MOV    EAX,CR0
                AND    EAX,0FFFFFFFEH
                MOV    CR0,EAX
    ;返回实方式
                JUMP16 <SEG Real>,<OFFSET Real>
TempCodeSEG ENDS

;实方式下的数据段
RDataSEG SEGMENT 	PARA 	USE16
             VGDTR    PDESC <GDTLEN-1,>               ;GDT伪描述符
             VIDTR    PDESC <IDTLEN-1,>               ;IDT伪描述符
             NORVIDTR PDESC <3FFH,0>                  ;保存IDTR原值
    SPVAR    DW       ?                               ;保存原堆栈指针
    SSVAR    DW       ?
    MESS     DB       "Strike a key [0,4,B,C,D]:$"    ;提示信息
RDataSEG ENDS

;实方式下的代码段
;CPL=0
RCodeSEG SEGMENT 	PARA 	USE16
             ASSUME CS:RCodeSEG,DS:RDataSEG
    Start:   
             MOV    AX,RDataSEG
             MOV    DS,AX
             CLD
             CALL   INIT_GDT                            ;初始化GDT
             CALL   INIT_IDT                            ;初始化IDT
             MOV    AX,GKeyLDTSEG                       ;读键盘任务局部描述符表段挪到AX中
             MOV    FS,AX                               ;FS作为读键盘任务局部描述符表段基址
             MOV    CX,GKeyLDNUM                        ;读键盘任务局部描述符个数挪到cx中
             MOV    SI,OFFSET GLDT                      ;初始化读键盘任务LDT
             CALL   INIT_LDT
             MOV    AX,DemoLDTSEG                       ;演示任务局部描述符表段挪到AX中
             MOV    FS,AX
             MOV    CX,DemoLDNUM                        ;演示任务局部描述符个数挪到CX中
             MOV    SI,OFFSET DLDT
             CALL   INIT_LDT                            ;初始化演示任务LDT
             MOV    SSVAR,SS
             MOV    SPVAR,SP                            ;保存实模式栈顶和堆栈基址
             LGDT   QWORD PTR VGDTR                     ;将VGDTR加载到GDTR
             SIDT   NORVIDTR                            ;将IDTR原值保存
             CLI                                        ;清方向
             LIDT   QWORD PTR VIDTR                     ;将VIDTR加载到IDTR
             MOV    EAX,CR0
             OR     EAX,1
             MOV    CR0,EAX                             ;PE位置1，进入保护模式
             JUMP16 <TempCode_SEL>,<OFFSET Virtual >
    Real:    
             MOV    AX,RDataSEG
             MOV    DS,AX
             LSS    SP,DWORD PTR SPVAR
             LIDT   NORVIDTR
             STI
             MOV    AX,4C00H
             INT    21H
    ;初始化全局描述符表的子程序
    ;(1)把定义时预置的段值转换成32位段基地址并置入描述符内相应字段
    ;(2)初始化为GDTR准备的伪描述符
INIT_GDT PROC 	NEAR
             PUSH   DS
             MOV    AX,GDTSEG                           ;定义的GDT段段值挪到AX中
             MOV    DS,AX                               ;定义的GDT段段值挪到DS中
             MOV    CX,GDNUM                            ;GDNUM是初始化的描述符个数
             MOV    SI,OFFSET EFFGDT                    ;EFFGDT是开始偏移
    ;将描述符中的基址扩展到32位
    INITG:   
             MOV    AX,[SI].BASEL                       ;取出预置的段值
             MOVZX  EAX,AX                              ;将初始化进去的16位段值扩展到32位
             SHL    EAX,4                               ;段值左移4位
             SHLD   EDX,EAX,16                          ;将 EAX 左移 16 位，然后将结果和目标操作数 EDX 的低位相结合，进位被放置到目标操作数的最高位
             MOV    [SI].BASEL,AX
             MOV    [SI].BASEM,DL                       ;置入描述符相应字段
             MOV    [SI].BASEH,DH
             ADD    SI,SIZE DESCRIPTOR                  ;调整到下一描述符
             LOOP   INITG                               ;所有描述符处理完后，退出循环
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

    ;
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
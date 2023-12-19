;程序名：T10-6.ASM
;功能：演示中断处理的实现
;
INCLUDE 386SCD.ASM
;参见实例三
	.386P
;部分常量定义
EOICOM 	= 	20H		;外部中断处理结束命令
ICREGP	=	20H		;中断控制寄存器端口地址
IMREGP 	= 	21H		;中断屏蔽寄存器端口地址
;全局描述符表GDT
GDTSEG SEGMENT 	PARA 	USE16

    ;全局描述符表标号
                  GDT       LABEL 	BYTE

    ;空描述符
                  DUMMY     DESCRIPTOR 	<>

    ;规范描述符
                  NORMAL    DESCRIPTOR 	<0FFFFH,0,0,ATDW,0>
    Normal_SEL    =         NORMAL - GDT

    ;全局描述符表任务定义描述符起始标识
                  EFFGDT    LABEL 	BYTE


    ;临时代码段描述符
    ;描述符内容为，段界限为0FFFFH，基址为TempCodeSEG段，属性为R0环可执行代码段
                  TEMPCODE  DESCRIPTOR 	<0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第三个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 3 * 8h = 0010h
    ;0010h = 0000 0000 0001 0000 = 0000000000010 0 00
    ;表示RPL=0环GDT中index = 2的描述符
    TempCode_SEL  =         TEMPCODE - GDT


    ;演示任务代码段描述符
    ;描述符内容为，段界限为DemoCodeLEN - 1，基址为DemoCodeSEG段，属性为R0环可执行代码段
                  DEMOCODE  DESCRIPTOR 	<DemoCodeLEN-1,DemoCodeSEG,,ATCE,>
    ;DEMOCode为GDT第四个描述符，一个描述符结构体的长度位8h，所以DEMOCode - 0 = 3 * 8h = 0018h
    ;0018h = 0000 0000 0001 1000 = 000000000011 0 00
    ;表示RPL=0环GDT中index = 3的描述符
    DemoCode_SEL  =         DEMOCODE - GDT


    ;演示任务数据段描述符
    ;描述符内容为，段界限为DemoDataLEN - 1，基址为DemoDataSEG段，属性为R0环可读写数据段
                  DEMODATA  DESCRIPTOR 	<DemoDataLEN-1,DemoDataSEG,,ATDW,>
    ;DEMODATA为GDT第五个描述符，一个描述符结构体的长度位8h，所以DEMODATA - 0 = 4 * 8h = 0020h
    ;0020h = 0000 0000 0010 0000 = 000000000100 0 00
    ;表示RPL=0环GDT中index = 4的描述符
    DemoData_SEL  =         DEMODATA - GDT


    ;演示任务堆栈段描述符
    ;描述符内容为，段界限为DemoStackLEN - 1，基址为DemoStackSEG段，属性为R0环已访问可读写数据段
                  DEMOSTACK DESCRIPTOR 	<DemoStackLEN-1,DemoStackSEG,,ATDWA,>
    ;DEMOSTACK为GDT第六个描述符，一个描述符结构体的长度位8h，所以DEMOSTACK - 0 = 5 * 8h = 0028h
    ;0028h = 0000 0000 0010 1000 = 000000000101 0 00
    ;表示RPL=0环GDT中index = 5的描述符
    DemoStack_SEL =         DEMOSTACK - GDT


    ;FEH号中断处理程序(显示程序)代码段描述符
    ;描述符内容为，段界限为EchoCodeLEN - 1，基址为EchoCodeSEG段，属性为R0环可执行代码段
                  ECHOCODE  DESCRIPTOR 	<EchoCodeLEN-1,EchoCodeSEG,,ATCE,>
    ;ECHOCODE为GDT第七个描述符，一个描述符结构体的长度位8h，所以ECHOCODE - 0 = 6 * 8h = 0030h
    ;0030h = 0000 0000 0011 0000 = 000000000110 0 00
    ;表示RPL=0环GDT中index = 6的描述符
    EchoCode_SEL  =         ECHOCODE - GDT


    ;FEH号中断处理程序(显示程序)数据段描述符
    ;描述符内容为，段界限为EchoDataLEN - 1，基址为EchoDataSEG段，属性为R0环可读写数据段
                  ECHODATA  DESCRIPTOR 	<EchoDataLEN-1,EchoDataSEG,,ATDW,>
    ;ECHODATA为GDT第八个描述符，一个描述符结构体的长度位8h，所以ECHODATA - 0 = 7 * 8h = 0038h
    ;0038h = 0000 0000 0011 1000 = 000000000111 0 00
    ;表示RPL=0环GDT中index = 7的描述符
    EchoData_SEL  =         ECHODATA - GDT


    ;视频缓冲区描述符(B8000H)
    ;描述符内容为，段界限为80*25*2-1，基址为0B800H，属性为R0环已访问可读写数据段
                  VIDEOBUFF DESCRIPTOR 	<80*25*2-1,0B800H,,ATDW,>
    ;VIDEOBUFF为GDT第九个描述符，一个描述符结构体的长度位8h，所以VIDEOBUFF - 0 = 8 * 8h = 0040h
    ;0040h = 0000 0000 0100 0000 = 000000001000 0 00
    ;表示RPL=0环GDT中index = 8的描述符
    VideoBuff_SEL =         VIDEOBUFF - GDT


    ;8H号中断处理程序代码段描述符
    ;描述符内容为，段界限为TICodeLEN - 1，基址为TICodeSEG段，属性为R0环可执行代码段
                  TICODE    DESCRIPTOR 	<TICodeLEN-1,TICodeSEG,,ATCE>
    ;TICODE为GDT第十个描述符，一个描述符结构体的长度位8h，所以TICODE - 0 = 9 * 8h = 0048h
    ;0048h = 0000 0000 0100 1000 = 000000001001 0 00
    ;表示RPL=0环GDT中index = 9的描述符
    TI_SEL        =         TICODE - GDT


    ;8H号中断处理程序数据段描述符
    ;描述符内容为，段界限为TiDataLEN - 1，基址为TiDataSEG段，属性为R0环可读写数据段
                  TIDATA    DESCRIPTOR 	<TiDataLEN-1,TiDataSEG,,ATDW,>
    ;TIDATA为GDT第十一个描述符，一个描述符结构体的长度位8h，所以TIDATA - 0 = 10 * 8h = 0050h
    ;0050h = 0000 0000 0101 0000 = 000000001010 0 00
    ;表示RPL=0环GDT中index = 10的描述符
    TIData_SEL    =         TIDATA - GDT


    ;其他中断或异常处理程序代码段描述符
    ;描述符内容为，段界限为OtherCodeLEN - 1，基址为OtherCodeSEG段，属性为R0环可执行代码段
                  OTHER     DESCRIPTOR 	<OTHERCodeLEN-1,OTHERCodeSEG,,ATCE,>
    ;OTHER为GDT第十二个描述符，一个描述符结构体的长度位8h，所以OTHER - 0 = 11 * 8h = 0058h
    ;0058h = 0000 0000 0101 1000 = 000000001011 0 00
    ;表示RPL=0环GDT中index = 11的描述符
    OTHER_SEL     =         OTHER - GDT


    ;GDT中的需要进行基地址初始化的描述符个数
    GDNUM         =         ($ - EFFGDT)/(SIZE DESCRIPTOR)

    ;GDT的长度
    GDTLEN        =         $ - GDT
GDTSEG ENDS
;中断描述符表IDT
IDTSEG SEGMENT 	PARA 	USE16

    ;IDT中的需要进行基地址初始化的描述符个数
           IDT   LABEL 	BYTE


    ;从00~07的8个陷阱门描述符
    ;00~007号陷阱门
    ;描述内容：偏移为OtherBegin，选择子为OTHER_SEL，陷阱门
           REPT  8
           GATE  <OtherBegin,OTHER_SEL,0,AT386TGAT,0>
ENDM


    ;对应8H号(时钟)中断处理程序的中断门描述符
    ;描述内容为：偏移为TIBegin，选择子为TL_SEL，中断门
    ;时钟中断使用的8H号中断向量号就与双重故障异常使用的中断向量号发生冲突，所以每次时钟中断就会触发0FEH的陷阱门
           INT08 GATE 	<TIBegin,TI_SEL,0,AT386IGAT,0>
    ;从09~FDH的245个陷阱门描述符
    ;描述内容为：偏移为OtherBegin，选择子为OTHER_SEL，陷阱门
           REPT  254 - 9
           GATE  <OtherBegin,OTHER_SEL,0,AT386TGAT,0>
ENDM


    ;对应0FEH号中断处理程序的陷阱门描述符
    ;描述内容为：偏移为EchoBegin，选择子为EchoCode_SEL，陷阱门
           INTFE GATE	<EchoBegin,EchoCode_SEL,0,AT386TGAT,>
    ;对应0FFH号中断处理程序的陷阱门描述符
    ;描述内容为：偏移为OtherBegin，选择子为OTHER_SEL，陷阱门
           GATE  <OtherBegin,OTHER_SEL,0,AT386TGAT.0>

    ;IDT长度
    IDTLEN =     $ - IDT
IDTSEG ENDS
;其他中断或异常处理程序的代码段
OtherCodeSEG SEGMENT 	PARA 	USE16
                 ASSUME CS:OtherCodeSEG
    OtherBegin:  
                 MOV    AX,VideoBuff_SEL
                 MOV    ES,AX
                 MOV    AH,17H
                 MOV    AL,'! '
                 MOV    ES:[0].AX           ;在屏幕左上角显示兰底白色符号“！”
                 JMP    $                   ;无限循环
    OtherCodeLEN =      $
OtherCodeSEG ENDS
;8H号(时钟)中断处理程序的数据段
TIDataSEG SEGMENT 	PARA 	USE16
    COUNT     DB 0    ;中断发生的计数器
    TIDataLEN =  $
TIDataSEG ENDS
;8H号(时钟)中断处理程序的代码段
;每次时钟中断都会调用0FEH陷阱
TICodeSEG SEGMENT 	PARA 	USE16
              ASSUME CS:TICodeSEG,DS:TIDataSEG
    TIBegin:  
              PUSH   EAX
              PUSH   DS
              PUSH   FS
              PUSH   GS                           ;保护现场
              MOV    AX,TIData_SEL
              MOV    DS,AX                        ;置中断处理程序数据段
              MOV    AX,EchoData_SEL
              MOV    FS,AX                        ;置显示过程数据段
              MOV    AX,DemoData_SEL
              MOV    GS,AX                        ;置演示程序数据段
              CMP    COUNT,0
              JNZ    TI2                          ;计数非0表示未到一秒
              MOV    COUNT,18                     ;每秒约18次
              INT    0FEH                         ;调用OFEH号中断处理程序显示
              CMP    FS:MESS,'0'
              JNZ    T11
              MOV    GS:FLAG,1                    ;显示符号0时置标记
    T11:      
              DEC    FS:MESS                      ;调整显示符号
    TI2:      
              DEC    COUNT                        ;调整计数
              POP    GS
              POP    FS                           ;恢复现场
              POP    DS
              MOV    AL,EOICOM
              OUT    ICREGP,AL                    ;通知中断控制器中断处理结束
              POP    EAX
              IRETD                               ;中断返回
    TICodeLEN =      $
TICodeSEG ENDS
;0FEH号中断处理程序的数据段
EchoDataSEG SEGMENT 	PARA 	USE16
    MESS        DB '8',07H
    EchoDataLEN =  $
EchoDataSEG ENDS
;OFEH号中断处理程序(显示程序)的代码段
;CPL=0
;每次由时钟中断引起的陷阱，都会在屏幕上输出一个8
EchoCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:EchoCodeSEG,DS:EchoDataSEG
    EchoBegin:  
                PUSH   AX
                PUSH   DS                               ;保护现场
                PUSH   ES
                MOV    AX,EchoData_SEL
                MOV    DS,AX                            ;置显示过程数据段
                MOV    AX,VideoBuff_SEL
                MOV    ES,AX                            ;置视频数据段
                MOV    AX,WORD PTR MESS
                MOV    ES:[0],AX                        ;显示符号
                POP    ES
                POP    DS                               ;恢复现场
                POP    AX
                IRETD                                   ;中断返回
    EchoCodeLEN =      $
EchoCodeSEG ENDS
;演示任务的堆栈段
DemoStackSEG SEGMENT 	PARA 	USE16
    DemoStackLEN =  1024
                 DB DemoStackLEN DUP (0)
DemoStackSEG ENDS
;演示任务的数据段
DemoDataSEG SEGMENT 	PARA 	USE16
    FLAG        DB 0
    DemoDataLEN =  $
DemoDataSEG ENDS
;演示任务的代码段
;CPL=0
DemoCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:DemoCodeSEG,DS:DemoDataSEG
    DemoBegin:  
                MOV    AX,DemoStack_SEL
                MOV    SS,AX                            ;置堆栈
                MOV    SP,DemoStackLEN
                MOV    AX,DemoData_SEL
                MOV    DS,AX                            ;置数据段,DS=DemoData_SEL
                MOV    ES,AX                            ;置数据段,ES=DemoData_SEL
                MOV    FS,AX                            ;置数据段,FS=DemoData_SEL
                MOV    GS,AX                            ;置数据段,GS=DemoData_SEL
    ;
                MOV    AL,0FEH                          ;置中断屏蔽寄存器
                OUT    IMREGP,AL                        ;仅开放时钟中断，0FEH为自定义的时钟中断中断号
                STI                                     ;开中断
    DemoConti:  
                CMP    FLAG,0                           ;判标志，FLAG标志初始化为0
                JZ     DemoConti                        ;为0继续
                CLI                                     ;关中断
    ;转回临时代码段，准备回实方式
    OVER:       
                JUMP16 TempCode_SEL,<OFFSET ToDOS>
    DemoCodeLEN =      $
DemoCodeSEG ENDS
;临时代码段
;CPL=0
TempCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:TempCodeSEG
    Virtual:                                       ;转演示程序
                JUMP16 DemoCode_SEL,DemoBegin
    ToDOS:                                         ;准备返回实方式
                MOV    AX,Normal.SEL
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
              VGDTR    PDESC 	<GDTLEN-1,>    ;GDT伪描述符
              VIDTR    PDESC 	<IDTLEN-1,>    ;IDT伪描述符
              NORVIDTR PDESC	<3FFH,0>        ;用于保存原IDTR值
    SPVAR     DW       ?                     ;用于保存原堆栈指针
    SSVAR     DW       ?
    IMASKREGV DB       ?                     ;用于保存原中断屏蔽寄存器值
RDataSEG ENDS
;实方式下的代码段
RCodeSEG SEGMENT 	PARA 	USE16
             ASSUME CS:RCodeSEG,DS:RDataSEG
    Start:   
             MOV    AX,RDataSEG
             MOV    DS,AX
             CLD
             CALL   INIT_GDT                           ;初始化GDT
             CALL   INIT_IDT                           ;初始化IDT
             MOV    SSVAR,SS                           ;保存堆栈指针
             MOV    SPVAR,SP
             SIDT   NORVIDTR                           ;保存IDTR值保存到NORVIDTR
             IN     AL,IMREGP
             MOV    IMASKREGV,AL                       ;保存中断屏蔽字节
             LGDT   QWORD PTR VGDTR                    ;置GDTR
             CLI                                       ;关中断
             LIDT   QWORD PTR VIDTR                    ;置IDTR
             MOV    EAX,CR0
             OR     EAX,1
             MOV    CR0,EAX                            ;转保护模式
             JUMP16 <TempCode_SEL>,<OFFSET Virtual>    ;跳临时代码
    Real:                                              ;又回到实方式
             MOV    AX,RDataSEG
             MOV    DS,AX                              ;理实方式数据段
             LSS    SP,DWORD PTR SPVAR                 ;恢复堆栈指针
             LIDT   NORVIDTR                           ;恢复IDTR
             MOV    AL,IMASKREGV                       ;恢复中断屏蔽字节
             OUT    IMREGP,AL
             STI                                       ;开中断
             MOV    AX,4C00H                           ;返回DOS
             INT    21H                                ;初始化过程
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
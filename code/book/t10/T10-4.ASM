;程序名：T10-4.ASM
;演示在任务内如何进行特权级变换
;
INCLUDE 386SCD.ASM
;
;参见实例三
	.386P

;全局描述符表GDT
GDTSEG SEGMENT 	PARA 	USE16
                 GDT       LABEL 	BYTE

    ;空描述符
                 DUMMY     DESCRIPTOR 	<>

    ;规范数据段描述符
    ;描述符的含义为，段界限为OFFFFH，基址为0h，属性为R0可读写数据段
                 NORMAL    DESCRIPTOR 	<0FFFFH,0,0,ATDW,0>
    ;NORMAL为GDT第二个描述符，一个描述符结构体的长度位8h，所以NORMAL - 0 = 0008h
    ;0008h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示0环GDT中index = 1的描述符
    NORMAL_SEL   =         NORMAL - GDT


                 EFFGDT    LABEL 	BYTE


    ;演示任务状态段TSS描述符
    ;描述符内容为，段界限为DemoTSSLEN - 1，基址为DemoTSSSEG段，属性为R0环386TSS类型值
                 DEMOTSS   DESCRIPTOR <DemoTSSLEN-1,DemoTSSSEG,,AT386TSS,>
    ;DEMOTSS为GDT第三个描述符，一个描述符结构体的长度位8h，所以DEMOTSS - 0 = 0010h
    ;0010h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示0环GDT中index = 2的描述符
    DemoTSS_SEL  =         DEMOTSS - GDT


    ;演示任务LDT段描述符
    ;描述符内容为，段界限为DemoLDTLEN - 1，基址为DemoLDTSEG段,属性为R0环局部描述符表段类型值
                 DEMOLDTD  DESCRIPTOR <DemoLDTLEN-1,DemoLDTSEG,,ATLDT,>
    ;DEMOLDTD为GDT第四个描述符，一个描述符结构体的长度位8h，所以DEMOLDTD - 0 = 0018h
    ;0018h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示0环GDT中index = 3的描述符
    DemoLDT_SEL  =         DEMOLDTD - GDT


    ;临时代码段描述符
    ;描述符内容为，段界限为0FFFFH，基址为TempCodeSEG段，属性为R0环可执行代码段
                 TEMPCODE  DESCRIPTOR <0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第五个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 0020h
    ;0020h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示0环GDT中index = 4的描述符
    TempCode_SEL =         TEMPCODE - GDT


    ;视频缓冲区段描述符(DPL=3)
    ;描述符内容为，段界限为0FFFFH，基址为0F00H+VideoSEG段，属性为R3环视频缓冲区段
                 VIDEOBUFF DESCRIPTOR 	<0FFFFH,0,0,0F00H+ATDW+DPL3,0>
    ;VIDEOBUFF为GDT第六个描述符，一个描述符结构体的长度位8h，所以VIDEOBUFF - 0 = 0028h
    ;0028h = 0000 0000 0000 1000 = 0000000000101 0 00
    ;表示0环GDT中index = 5的描述符
    Video_SEL    =         VIDEOBUFF - GDT

    ;可用的全局描述符个数
    GDNUM        =         ($ - EFFGDT)/(SIZE DESCRIPTOR)
    ;GDT长度
    GDTLEN       =         $ - GDT
GDTSEG ENDS

;演示任务局部描述符表LDT
DemoLDTSEG SEGMENT 	PARA 	USE16
    ;LDT起始位置标号
                   DemoLDT    LABEL 		BYTE

    ;0级堆栈段描述符(32位段)
    ;描述符内容为，段界限为DemoStack0LEN - 1，基址为DemoStack0SEG段，属性为R0环32位可读写数据段
                   DEMOSTACK0 DESCRIPTOR 	<DemoStack0LEN-1,DemoStack0SEG,,ATDW+D32,>
    ;DEMOSTACK0为LDT第一个描述符，一个描述符结构体的长度位8h，所以0 * 8 - 0 = 0h + 4h = 04h
    ;04h = 0000 0000 0000 0100 = 0000000000000 1 00
    ;表示0环LDT中index = 0的描述符
    DemoStack0_SEL =          (DemoStack0 - DEMOLDT) + TIL


    ;1级堆栈段描述符(DPL=1)
    ;描述符内容为，段界限为DemoStack1LEN - 1，基址为DemoStack1SEG段，属性为R1环32位可读写数据段
                   DEMOSTACK1 DESCRIPTOR 	<DemoStack1LEN-1,DemoStack1SEG,,ATDW+D32+DPL1,>
    ;DEMOSTACK1为LDT第二个描述符，一个描述符结构体的长度位8h，所以1*8 - 0 = 0008h + 4h = 0ch + 0001h = 0Dh
    ;0Dh = 0000 0000 0000 1101 = 0000000000001 1 01
    ;表示1环LDT中index = 1的描述符
    DemoStack1_SEL =          (DemoStack1 - DEMOLDT) + TIL + RPL1


    ;3级堆栈段描述符(DPL=3)
    ;描述符内容为，段界限为DemoStack3LEN - 1，基址为DemoStack3SEG段，属性为R3环32位可读写数据段
                   DEMOSTACK3 DESCRIPTOR 	<DemoStack3LEN-1,DemoStack3SEG,,ATDW+DPL3,>
    ;DEMOSTACK3为LDT第三个描述符，一个描述符结构体的长度位8h，所以3*8 - 0 = 0018h + 4h = 001ch + 0001h = 001dh
    ;001dh = 0000 0000 0001 1101 = 0000000000011 1 01
    ;表示3环LDT中index = 3的描述符
    DemoStack3_SEL =          (DemoStack3 - DEMOLDT) + TIL + RPL3


    ;演示代码段描述符(32位段，DPL=3)
    ;描述符内容为，段界限为DemoCodeLEN - 1，基址为DemoCodeSEG段，属性为R3环32位可执行代码段
                   DEMOCODE   DESCRIPTOR 	<DemoCodeLEN-1,DemoCodeSEG,,ATCE+D32+DPL3>
    ;DEMOCode为LDT第四个描述符，一个描述符结构体的长度位8h，所以4 * 8 - 0 = 0020h + 4h = 0024h + 0001h = 0025h
    ;0025h = 0000 0000 0010 0101 = 0000000000100 1 01
    ;表示3环LDT中index = 4的描述符
    DemoCode_SEL   =          (DEMOCODE - DEMOLDT) + TIL + RPL3


    ;过渡代码段描述符(32位段)
    ;描述符内容为，段界限为T32CodeLEN - 1，基址为T32CodeSEG段，属性为R0环32位可执行代码段
                   T32CODE    DESCRIPTOR 	<T32CodeLEN-1,T32CodeSEG,,ATCE+D32,>
    ;T32Code为LDT第五个描述符，一个描述符结构体的长度位8h，所以5 * 8 - 0 = 0028h + 4h = 002ch
    ;002ch = 0000 0000 0010 1100 = 0000000000101 1 00
    ;表示0环LDT中index = 5的描述符
    T32Code_SEL    =          (T32CODE - DEMOLDT) + TIL


    ;显示子程序代码段描述符(32位段，DPL=1)
    ;描述符内容为，段界限为EchoSUBRLEN - 1，基址为EchoSUBRSEG段，属性为R1环32位可执行代码段
                   ECHOSUBR   DESCRIPTOR 	<EchoSUBRLEN-1,EchoSUBRSEG,,ATCER+D32+DPL1,>
    ;EchoSUBR为LDT第六个描述符，一个描述符结构体的长度位8h，所以6 * 8 - 0 = 0030h + 4h = 0034h + 0001h = 0035h
    ;0035h = 0000 0000 0011 0101 = 0000000000110 1 01
    ;表示1环LDT中index = 6的描述符
    Echo_SEL1      =          (ECHOSUBR - DEMOLDT) + TIL + RPL1
    ;EchoSUBR为LDT第六个描述符，一个描述符结构体的长度位8h，所以6 * 8 - 0 = 0030h + 4h = 0034h + 0003h = 0037h
    ;0037h = 0000 0000 0011 0111 = 0000000000110 1 11
    ;表示3环LDT中index = 6的描述符
    Echo_SEL3      =          (ECHOSUBR - DEMOLDT) + TIL + RPL3

    ;描述符个数
    DemoLDNUM      =          ($ - DEMOLDT)/(SIZE DESCRIPTOR)


    ;指向过渡代码段内T32Begin点的调用门(DPL=0)
    ;TOT32GATEA为门描述符，含义为，T32Begin为偏移低16位，T32Code_SEL为目标选择子，0为参数计数器，AT386CGAT为0环386调用门类型值，0为偏移高16位
                   TOT32GATEA GATE 	<T32Begin,T32Code_SEL,0,AT386CGAT,0>
    ;T32Begin为LDT第七个描述符，一个描述符结构体的长度位8h，所以7 * 8 - 0 = 0038h + 4h = 003ch
    ;003ch = 0000 0000 0011 1100 = 0000000000111 1 00
    ;表示0环LDT中index = 7的描述符
    TOT32A_SEL     =          (TOT32GATEA - DemoLDT) + TIL


    ;指向过渡代码段内T32End点的调用门(DPL=3)
    ;TOT32GATEB为门描述符，含义为，T32End为偏移低16位，T32Code_SEL为目标选择子，0为参数计数器，AT386CGAT+DPL3为3环386调用门类型值，0为偏移高16位
                   TOT32GATEB GATE 	<T32End,T32Code_SEL,0,AT386CGAT+DPL3,0>
    ;T32End为LDT第八个描述符，一个描述符结构体的长度位8h，所以8 * 8 - 0 = 0040h + 4h = 0044h
    ;0044h = 0000 0000 0100 0100 = 0000000001000 1 00
    ;表示0环LDT中index = 8的描述符
    ToT32B_SEL     =          (TOT32GATEB - DemoLDT) + TIL


    ;指向显示子程序的调用门(DPL=3)
    ;TOECHOGATE为门描述符，含义为，EchoSUB为偏移低16位，ToEcho_SEL为目标选择子，0为参数计数器，AT386CGAT+DPL3为3环386调用门类型值，0为偏移高16位
                   TOECHOGATE GATE 	<EchoSUB,Echo_SEL3,0,AT386CGAT+DPL3,0>
    ;EchoSUB为LDT第九个描述符，一个描述符结构体的长度位8h，所以9 * 8 - 0 = 0048h + 4h = 004ch
    ;004ch = 0000 0000 0100 1100 = 0000000001001 1 00
    ;表示0环LDT中index = 9的描述符
    ToEcho_SEL     =          (TOECHOGATE - DemoLDT) + TIL

    ;LDT长度
    DemoLDTLEN     =          $ - DemoLDT
DemoLDTSEG ENDS
    ;----
    ;演示任务的TSS段
DemoTSSSEG SEGMENT PARA USE 16
               DD 0                   ;BACK
               DW DemoStack0LEN,0     ;0级堆栈指针
               DW DemoStack0_SEL,0    ;初始化
               DW DemoStack1LEN,0     ;1级堆栈指针
               DW DemoStack1_SEL,0    ;初始化
               DD ?                   ;2级堆栈指针
               DW ?,0                 ;未初始化
               DD 0                   ;CR3
               DD ?                   ;EIP
               DD ?                   ;EFLAGS
               DD ?                   ;EAX
               DD ?                   ;ECX
               DD ?                   ;EDX
               DD ?                   ;EBX
               DD ?                   ;ESP
               DD ?                   ;EBP
               DD ?                   ;ESI
               DD ?                   ;EDI
               DW ?,0                 ;ES
               DW ?,0                 ;CS
               DW ?,0                 ;SS
               DW ?,0                 ;DS
               DW ?,0                 ;FS
               DW ?,0                 ;GS
               DW DemoLDT_SEL,0       ;LDT
               DW 0
               DW $+2                 ;指向`I/O`许可位图
               DB OFFH                ;`I/O`许可位图结束标志
    DemoTSSLEN =  $
DemoTSSSEG ENDS
;演示任务0级堆栈段(32位段)
DemoStack0SEG SEGMENT 	PARA 	USE32
    DemoStack0LEN =  512
                  DB DemoStack0LEN 	DUP(0)
DemoStack0SEG ENDS
;演示任务1级堆栈段(16位段)
DemoStack1SEG SEGMENT 	PARA 	USE32
    DemoStack1LEN =  512
                  DB DemoStack1LEN DUP(0)
DemoStack1SEG ENDS
;演示任务3级堆栈段(16位段)
DemoStack3SEG SEGMENT 	PARA 	USE16
    DemoStack3LEN =  512
                  DB DemoStack3LEN DUP (0)
DemoStack3SEG ENDS
;演示任务显示子程序代码段(32位段，1级)
EchoSUBRSEG SEGMENT 	PARA 	USE32
    MESSAGE     DB     'CPL=',0
                ASSUME CS:EchoSUBRSEG
    ;显示调用程序的执行特权级
EchoSUB PROC 	FAR
                CLD                          ;清空方向
                PUSH   EBP
                MOV    EBP,ESP               ;当前ESP为R1栈栈顶，重新定义栈底
                MOV    AX,Echo_SEL1          ;子程序代码段是可读段
                MOV    DS,AX                 ;采用RPL=1的选择子
                MOV    AX,Video_SEL
                MOV    ES,AX                 ;视频缓冲区段基地址00000000H
                MOV    EDI,0B8000H           ;视频缓冲区段B8000H开始
                MOV    ESI,OFFSET MESSAGE
                MOV    AH,17H                ;显示属性
    EchoSUB1:   
                LODSB
                OR     AL,AL
                JZ     EchoSUB2
                STOSW                        ;显示字符串
                JMP    EchoSUB1
    EchoSUB2:   
                MOV    EAX,[EBP+8]           ;从堆栈中取调用程序的选择子
                AND    AL,3                  ;调用程序的CPL在CS的RPL字段
                ADD    AL,'0'
                MOV    AH,17H
                STOSW                        ;显示之
                POP    EBP
                RETF                         ;返回
EchoSUB ENDP
    EchoSUBRLEN =      $
EchoSUBRSEG ENDS
;----------------
;演示任务的演示代码段(32位段，3级)
DemoCodeSEG SEGMENT 	PARA 	USE32
                ASSUME CS:DemoCodeSEG
    DemoBegin:  
    ;CPL=3，只能调用DPL=3的门，TOECHOGATE 的属性中DPL=3
    ;TOECHOGATE 门中选择子为 Echo_SEL3，RPL=3，可以指向DPL=0/1/2/3段
    ;Echo_SEL3 指向的段 ECHOSUBR 的DPL=1，所有条件符合，进行跳转，跳到 EchoSUBRSEG 的代码段
    ;CALL 指令，将SS/SP/参数/CS/EIP压入R1堆栈
    ;特权集变换到1级
                CALL32 ToEcho_SEL,0
    ;上一个CALL32 RET后，CPL又回退到3级
    ;转到过渡代码段(变换到0级)
    ;CPL=3，只能调用DPL=3的门，TOT32GATEB 的属性中DPL=3
    ;TOT32GATEB 门中选择子为 T32Code_SEL，RPL=0，可以指向DPL=0段 偏移为t32End
    ;T32Code_SEL 指向的段 T32CODE 的DPL=0，所有条件符合，进行跳转，跳到 T32CodeSEG 的代码段 T32End 偏移处
    ;特权集转换到R0
                CALL32 ToT32B_SEL,0
    DemoCodeLEN =      $
DemoCodeSEG ENDS
;演示任务的过渡代码段(32位段，0级)
;`RET`指令，从特权级0变换到特权级3
T32CODESEG SEGMENT 	PARA 	USE32
               ASSUME CS:T32CODESEG
    T32Begin:  
    ;建立0级堆栈
               MOV    AX,DemoStack0_SEL               ;设置0级栈ss段段值
               MOV    SS,AX
               MOV    ESP,DemoStack0LEN               ;设置0级栈栈顶，方向向下
    ;构建正常CALL跨权限级调用
    ;当前CPL=0，通过调用门调用内层程序，要设法使`CPL>0`,所以要压入3级堆栈指针
               PUSH   DWORD PTR DemoStack3_SEL        ;R3堆栈段选择子(SS)入R0栈
               PUSH   DWORD PTR DemoStack3LEN         ;R3堆栈段栈顶(SP)入R0栈，没有参数，不用压入
    ;压入入口点
               PUSH   DWORD PTR DemoCode_SEL          ;R3代码段选择子(CS)如R0栈，返回地址选择子(CS)的RPL决定返回后的CPL，DemoCode_SEL 选择子对应R3环
               PUSH   OFFSET DemoBegin                ;R3指令指针(EIP)入R0栈
    ;利用RET实现转3级的演示代码段
    ;转移到 DemoCode_SEL 段 DemoBegin 偏移处
               RETF
    T32End:                                           ;转临时代码段，ToReal偏移处
               JUMP32 TempCode_SEL,<OFFSET ToReal>
    T32CadeLEN =      $
T32CODESEG ENDS
	;临时代码段(16位段，0级)
TempCodeSEG SEGMENT		PARA 	USE16
                ASSUME CS:TempCodeSEG
    Virtual:    
    ;装载TR
                MOV    AX,DemoTSS_SEL
                LTR    AX                          ;TR中加载跳转前的TSS
    ;装载LDTR
                MOV    BX,DemoLDT_SEL
                LLDT   BX                          ;LDT中加载跳转前的LDT
    ;通过调用门转过渡段
    ;通过 TOT32A_SEL 选择子找到 TOT32GATEA 门描述符
    ;通过 TOT32GATEA 调用门找到 T32Code_SEL 目标存储段选择子和 T32Begin 在目标存储段中的偏移
    ;通过 T32Code_SEL 目标存储段选择子找到 T32Code_SEG 目标存储段
    ;通过 T32Code_SEG 目标存储段找到 T32Begin 偏移
    ;执行跳转
                JUMP16 ToT32A_SEL,0
    ToReal:                                        ;准备切换回实方式
                MOV    AX,Normal_SEL
                MOV    DS,AX
                MOV    ES,AX                       ;把规范段描述符
                MOV    FS,AX                       ;装入各数据段寄存器
                MOV    GS,AX
                MOV    SS,AX
                MOV    EAX,CR0                     ;PE置为0，切换到实模式
                AND    AX,OFFFEH
                MOV    CR0,EAX                     ;返回实方式
                JUMP16 <SEG REAL>,<OFFSET REAL>
    TempCodeLEN =      $
TempCodeSEG ENDS
;实方式下的数据段
RDataSEG SEGMENT 	PARA 	USE16
             VGDTR PDESC 	<GDTLEN - 1,>
    SPVAR    DW    ?
    SSVAR    DW    ?
RDataSEG ENDS
;实方式下的代码段
RCodeSEG SEGMENT 	PARA 	USE16
             ASSUME CS:RCodeSEG,DS:RDataSEG
    Start:   
             MOV    AX,RDataSEG
             MOV    DS,AX                            ;装载是模式下数据段
             CLD                                     ;设置方向标志
             CALL   INIT_GDT                         ;初始化GDT
    ;
             MOV    AX,DemoLDTSEG                    ;LDT段值挪到FS中
             MOV    FS,AX
             MOV    SI,OFFSET DemoLDT                ;设置起始偏移
             MOV    CX,DemoLDNUM                     ;设置LDT中描述符的个数
             CALL   INIT_LDT                         ;初始化LDT
    ;设置切换前的栈基址和栈顶位置
             MOV    SSVAR,SS
             MOV    SPVAR,SP
    ;装载GDTR和切换到保护方式
             LGDT   QWORD PTR VGDTR
             CLI                                     ;关中断
             MOV    EAX,CR0
             OR     AX,1
             MOV    CR0,EAX                          ;切换到保护模式
             JUMP16 TempCode_SEL,<OFFSET Virtual>    ;跳转，跳转以后，系统会自动刷新TSS和LDT，TSS和LDT会保存未跳转前的任务的信息
    Real:    
             MOV    AX,RDATASEG
             MOV    DS,AX
             LSS    SP,DWORD PTR SPVAR               ;恢复实方式堆栈指针
             STI                                     ;关中断
             MOV    AX,4C00H
             INT    21H                              ;完成，退出
    ;初始化全局描述符表的子程序
    ;(1)把定义时预置的段值转换成32位段基地址并置入描述符内相应字段
    ;(2)初始化为GDTR准备的伪描述符
INIT_GDT PROC 	NEAR
             PUSH   DS
             MOV    AX,GDTSEG                        ;定义的GDT段段值挪到AX中
             MOV    DS,AX                            ;定义的GDT段段值挪到DS中
             MOV    CX,GDNUM                         ;GDNUM是初始化的描述符个数
             MOV    SI,OFFSET EFFGDT                 ;EFFGDT是开始偏移
    ;将描述符中的基址扩展到32位
    INITG:   
             MOV    AX,[SI].BASEL                    ;取出预置的段值
             MOVZX  EAX,AX                           ;将初始化进去的16位段值扩展到32位
             SHL    EAX,4                            ;段值左移4位
             SHLD   EDX,EAX,16                       ;将 EAX 左移 16 位，然后将结果和目标操作数 EDX 的低位相结合，进位被放置到目标操作数的最高位
             MOV    [SI].BASEL,AX
             MOV    [SI].BASEM,DL                    ;置入描述符相应字段
             MOV    [SI].BASEH,DH
             ADD    SI,SIZE DESCRIPTOR               ;调整到下一描述符
             LOOP   INITG                            ;所有描述符处理完后，退出循环
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
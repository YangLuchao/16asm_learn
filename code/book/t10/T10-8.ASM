;程序名：T10-8.ASM
;功能：显示关键寄存器内容兼说明操作系统类指令的使用
INCLUDE	386SCD.ASM
;参见实例三
	.386P
;全局描述符表GDT
GDTSEG SEGMENT 	PARA 	USE16
    ;全局描述符起始地址标号
                 GDT      LABEL 	BYTE

    ;空描述符
                 DUMMY    DESCRIPTOR		<>

    ;规范描述符
                 NORMAL   DESCRIPTOR 		<0FFFFH,0,0,ATDW,0>
    Normal_SEL   =        NORMAL - GDT

    ;全局描述符表任务定义描述符起始标识
                 EFFGDT   LABEL 	BYTE

    ;临时代码段描述符
    ;描述符内容为，段界限为0FFFFH，基址为TempCodeSEG段，属性为R0环可执行代码段
                 TEMPCODE DESCRIPTOR 		<0FFFFH,TempCodeSEG,,ATCE,>
    ;TEMPCODE为GDT第三个描述符，一个描述符结构体的长度位8h，所以TEMPCODE - 0 = 0010h
    ;0010h = 0000 0000 0001 0000 = 0000000000010 0 00
    ;表示RPL=0环GDT中index = 2的描述符
    TempCade_SEL =        TEMPCODE GDT


    ;缓冲区段描述符
    ;描述符内容为，段界限为BufferLEN - 1，基址为BufferSEG段,属性为R0环缓冲区段类型值
                 BUFFER   DESCRIPTOR 		<BufferLEN-1,BufferSEG,,ATDW,>
    ;BUFFER为GDT第四个描述符，一个描述符结构体的长度位8h，所以BUFFER - 0 = 0018h
    ;0018h = 0000 0000 0001 1000 = 0000000000011 0 00
    ;表示RPL=0环GDT中index = 3的描述符
    Buffer_SEL   =        BUFFER - GDT


    ;测试描述符1
                 TEST1    DESCRIPTOR		 <1111H,0,,8792H,>
    ;TEST1为GDT五个描述符，一个描述符结构体的长度位8h，所以TEST1 - 0 = 0020h
    ;0020h = 0000 0000 0010 0000 = 0000000000100 0 00
    ;表示RPL=0环GDT中index = 4的描述符
    TestL_SEL    =        TEST1 - GDT
    ;TESTL为GDT第五个描述符，一个描述符结构体的长度位8h，所以TESTL - 0 = 0020h
    ;0020h = 0000 0000 0010 0000 = 0000000000100 0 00
    ;表示RPL=3环GDT中index = 4的描述符
    TestR_SEL    =        TEST1 - GDT + RPL3


    ;测试描述符2
                 TEST2    DESCRIPTOR	 	<2222H,0,,1782H,>
    ;TEST2为GDT第六个描述符，一个描述符结构体的长度位8h，所以TEST2 - 0 = 0028h
    ;0028h = 0000 0000 0011 0000 = 0000000000110 0 00
    ;表示RPL=0环GDT中index = 5的描述符
    Test2_SEL    =        TEST2 - GDT

    ;全局描述符表任务用描述符个数
    GDNUM        =        ($ - EFFGDT)/(SIZE DESCRIPTOR)

    ;全局描述符表长度
    GDTLEN       =        $ - GDT
GDTSEG ENDS

;缓冲区段
BufferSEG SEGMENT 	PARA 	USE16
              GDTR_V PDESC		<>    ;存放GDTR
              IDTR_V PDESC		<>    ;存放IDTR
    MSW_V     DW     ?            ;存放机器状态字
    LDTR_V    DW     ?            ;存放LDTR选择子
    TR_V      DW     ?            ;存放TR选择子
    CRO_V     DD     ?            ;存放控制寄存器CR0
    CR3_V     DD     ?            ;存放控制寄存器CR3
    DR7_V     DD     ?            ;存放调试寄存器DR7
    TEST_RPL  DW     ?            ;存放测试描述符的RPL
    ;
    TEST1_SLD DD     ?            ;演示用变量
    TEST1_ARD DD     ?
    TEST1_SIW DW     ?
    TESTI_ARW DW     ?
    TESTI_RF  DW     ?
    TESTI_WF  DW     ?
    ;
    TEST2_SLD DD     ?            ;演示用变量
    TEST2_ARD DD     ?
    TEST2_SLW DW     ?
    TEST2_ARW DW     ?
    TEST2_RF  DW     ?
    TEST2_WF  DW     ?
    BufferLEN =      $
BufferSEG ENDS

;临时代码段
TempCodeSEG SEGMENT 	PARA 	USE16
                ASSUME CS:TempCodeSEG,DS:BufferSEG
    Virtual:    
                MOV    AX,Buffer_SEL
                MOV    DS,AX                          ;设缓冲段为数据段
                MOV    EAX,CR0                        ;存储CR0
                MOV    CR0_V,EAX
                MOV    EAX,CR3                        ;存储CR3
                MOV    CR3_V,EAX
                MOV    EAX,DR7                        ;存储DR7
                MOV    DR7_V,EAX
                STR    TR_V                           ;存储TR
                SLDT   LDTR_V                         ;存储LDTR
    ;
                MOV    TEST_RPL,TestL_SEL             ;TestL_SEL 的 RPL = 0
                MOV    AX,TestR_SEL                   ;TestR_SEL 的 RPL = 1
                ARPL   TEST_RPL,AX                    ;置TEST_RPL的RPL = TestR_SEL的RPL，切置ZF=1
    ;
                MOV    BX,0
                MOV    AX,TESTL_SEL
    LAB1:       
                MOV    EDX,0
                MOV    CX,0
                LSL    EDX,EAX                        ;说明装载段界限指令
                LSL    CX,AX
                MOV    TEST1_SLD[BX],EDX
                MOV    TEST1_SLW[BX],CX
                MOV    EDX,0
                MOV    CX,0
                LAR    EDX,EAX                        ;说明装载存取权指令
                LAR    CX,AX
                MOV    TEST1_ARD[BX],EDX
                MOV    TEST1_ARW[BX],CX
                MOV    TEST1_RF[BX],0
                VERR   AX                             ;说明读检验指令
                JNZ    LAB2
                MOV    TEST1_RF[BX],1
    LAB2:       
                MOV    TEST1_WF[BX],0
                VERW   AX                             ;说明写检验拾令
                JNZ    LAB3
                MOV    TEST1_WF[BX],1
    LAB3:       
                ADD    BX,16
                MOV    AX,TEST2_SEL
                CMP    BX,32
                JB
                LAB1
    Over:       
    ;准备返回实方式
                MOV    AX,Normal_SEL
                MOV    DS.AX
                MOV    EAX,CR0
                AND    EAX,0FFFFFFFEH
                MOV    CR0,EAX                        ;返回实方式
                JUMP16 <SEG Real>,<OFFSET Real>
TempCodeSEG ENDS

;实方式下的数据段和代码段
RCodeSEG SEGMENT 	PARA 	USE16
             VGDTR  PDESC 	<GDTLEN-1,>
             ASSUME CS:RCodeSEG,DS:BufferSEG
    Start:   
    ;实方式
             MOV    AX,BufferSEG
             MOV    DS,AX
             SGDT   GDTR_V                             ;存储GDTR
             SIDT   IDTR_V                             ;存储IDTR
             SMSW   MSW_V                              ;存储机器状态字
    ;准备转入保护方式
             PUSH   CS
             POP    DS
             CLD                                       ;清理方向
             CALL   INIT_GDT
             MOV    BX,OFFSET VGDTR
             LGDT   [BX]
             CLI                                       ;关中断
             MOV    EAX,CR0
             OR     EAX,1                              ;转入保护方式
             MOV    CR0,EAX
             JUMP16 <TempCode_SEL>,<OFFSET Virtual>
    Real:                                              ;回到实方式
             STI
    ;(略去显示相关变量内容的部分代码)
             MOV    AX,4C00H
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
RCodeSEG ENDS
	END Start
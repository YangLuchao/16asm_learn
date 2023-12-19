;程序名：T10-1.ASM
;功能：演示实方式和保护方式切换
;16位偏移的段间直接转移指令的宏定义
;该宏编译后为：jump selector:offsetv
JUMP MACRO selector,offsetv
         DB 0EAH        ;操作码，'Far Jump'指令
         DW offsetv     ;16位偏移
         DW selector    ;段值或者选择子
ENDM
;字符显示宏指令的定义
;该宏为执行AH=2的INT21H指令显示一个字符
ECHOCH MACRO ascii
           MOV AH,2
           MOV DL,ascii
           INT 21H
ENDM
;存储段描述符结构类型的定义
;共64位
DESCRIPTOR 	STRUC
	LIMITL 			DW 	0	;段界限(0~15)
	BASEL			DW 	0	;段基地址(0~15)
	BASEM			DB	0	;段基地址(16~23)
	ATTRIBUTES 		DW 	0	;段属性
	BASEH			DB 	0	;段基地址(24~31)
DESCRIPTOR 	ENDS
;GDTR伪描述符结构类型的定义
PDESC	STRUC
	LIMIT 	DW 0	;16界限
	BASE	DD 0	;基地址
PDESC	ENDS
;常量定义
;AT为存储段描述符40~55位
ATDW = 0092H	;存在的可读写数据段属性值
                ;0092H的二进制表示为：0000 0000 1001 0010
                ;0 0 0 0    0000    1 00    1   0010
                ;G D 0 AVL  LIMIT   P DPL   DT  TYPE
                ;G=0:界限粒度为字节
                ;P=1表示描述符对地址转换是有效
                ;DPL表示描述符特权级
                ;DT=1，段储存描述符
                ;TYPE，位3=0，位2=0，位1=1，位0=1
                ;位1=1，W=1表示可写
                ;位3=0，数据段
                ;所以0092H的含义是：R0可读写数据段

ATCE = 0098H	;存在的只执行代码段属性值
                ;0098H的二进制表示为：0000 0000 1001 1000
                ;0 0 0 0    0000    1 00    1   1000
                ;G D 0 AVL  LIMIT   P DPL   DT  TYPE
                ;G=0:界限粒度为字节
                ;P=1表示描述符对地址转换是有效
                ;DPL表示描述符特权级
                ;DT=1，段储存描述符
                ;TYPE，位3=1，位2=0，位1=0，位0=0
                ;位1=0，不可写，只能读
                ;位3=1，可执行，代码段
                ;所以0098H的含义是：R0只执行代码段
.386P
;数据段
DSEG SEGMENT 	USE16                                       ;16位段
              GDT   LABEL 		BYTE                          ;全局描述符表GDT，标号标识
              DUMMY DESCRIPTOR 	<>                        ;空描述符，占8个字节64位
              CODE  DESCRIPTOR 	<0FFFFH,,,ATCE,>          ;含义为：界限为0FFFFH，基地址为0,属性为R0只执行代码段
    ;CODE为GDT第二个描述符，一个描述符结构体的长度位8h，所以CODE - 0 = 0008h
    ;0008h = 0000 0000 0000 1000 = 0000000000001 0 00
    ;表示0环GDT中index = 1的描述符
    CODE_SEL  =     CODE - GDT                            ;代码段描述的选择子
              DATAS DESCRIPTOR 	<0FFFFH,0H,11H,ATDW,0>    ;含义为：界限为0FFFFH，基地址为0011 0000H,属性为R0可读写数据段
    ;DATAS位GDT中第三个描述符，一个描述符结构体的长度位8h，所以DATAS - 0 = 0010h
    ;0010h = 0000 0000 0001 0000 = 0000000000010 0 00
    ;表示0环GDT中index = 2的描述符
    DATAS_SEL =     DATAS - GDT                           ;源数据段描述符的选择子
              DATAD DESCRIPTOR 	<0FFFFH,,,ATDW,>          ;含义为：界限为0FFFFH，基地址为0000 0000H,属性为R0可读写数据段
    ;DATAD位GDT中第四个描述符，一个描述符结构体的长度位8h，所以DATAS - 0 = 0018h
    ;0018h = 0000 0000 0001 1000 = 0000000000011 0 00
    ;表示0环GDT中index = 3的描述符
    DATAD_SEL =     DATAD - GDT                           ;目标数据段描述符的选择子
    GDTLEN    =     $ - GDT
              VGDTR PDESC 		<GDTLEN - 1,>                 ;VGDTR为GDT的伪描述符，GDTLEN - 1为GDT界限，就是所有描述符的长度
    BUFFERLEN =     256                                   ;缓冲区字节长度
    BUFFER    DB    BUFFERLEN DUP (0)                     ;缓冲区，被定义为真正的数据段
DSEG ENDS
;代码段
;在保护模式或长模式下（32 位或 64 位），不再需要显式地指定
CSEG SEGMENT 	USE16                                ;指示编译器在生成目标代码时使用 16 位模式
             ASSUME CS:CSEG,DS:DSEG                ;假设，代码段为自定义代码段，数据段为自定义数据段
    START:   
             MOV    AX,DSEG                        ;数据段标号挪到AX中
             MOV    DS,AX                          ;设置DS数据段段值
    ;准备要加载到GDTR的伪描述符
             MOV    BX,16                          ;将段标号转为段地址，在x86架构中，段地址是由段标号左移4位得到的
             MUL    BX                             ;乘以16相当于将段标号乘以16，将结果存储在AX寄存器中，作为段地址的一部分
             ADD    AX,OFFSET GDT                  ;界限已在定义时设置妥当
    ;在x86的实模式中，内存寻址是通过物理地址进行的，物理地址由段基址（由左移4位的段标号计算而来）和偏移地址组成
             ADC    DX,0                           ;ADC DX的意思是看 ADD AX,OFFSET GDT 有没有进位
             MOV    WORD PTR VGDTR.BASE,AX         ;设置GDTR的基址
             MOV    WORD PTR VGDTR.BASE+2,DX       ;设置基址进位
    ;设置代码段描述符
             MOV    AX,CS                          ;将代码段标号挪到AX中
             MUL    BX                             ;乘以16 将标号转换为物理地址
             MOV    CODE.BASEL,AX                  ;代码段描述符基址，低16位
             MOV    CODE.BASEM,DL                  ;代码段描述符基址，中8位
             MOV    CODE.BASEH,DH                  ;代码段描述符基址，高8位
             MOV    AX,DS                          ;将数据段标号挪到AX中
             MUL    BX                             ;乘以16 将标号转换为物理地址
             ADD    AX,OFFSET BUFFER               ;缓冲区地址挪到AX中
             ADC    DX,0                           ;如果有进位，将进位挪到DX中
             MOV    DATAD.BASEL,AX                 ;设置定义的真正的数据段基址
             MOV    DATAD.BASEM,DL
             MOV    DATAD.BASEH,DH
    ;加载GDTR
             LGDT   QWORD PTR VGDTR                ;将定义的VGDTR挪到GDTR寄存器中
             CLI                                   ;关中断
             CALL   ENABLEA20                      ;打开地址线A20
    ;切换到保护方式
             MOV    EAX,CR0                        ;控制寄存器cr0挪到EAX中
             OR     EAX,1                          ;将PE位置1，切换到保护模式
             MOV    CR0,EAX                        ;挪回到CR0
    ;清指令预取队列，并真正进入保护方式
    ;当前在保护模式下运行，CODE_SEL为段选择子，virtual为偏移
    ;配合jump指令，意思是在GDT中寻找偏移为CODE_SEL的段描述符
    ;拿到CODE_SEL段描述符后，找到段的基地址，加上偏移，得到真正的偏移地址
             JUMP   <CODE_SEL>,<OFFSET VIRTUAL>
    VIRTUAL:                                       ;现在开始在保护方式下
             MOV    AX,DATAS_SEL
             MOV    DS,AX                          ;加载源数据段描述符
             MOV    AX.DATAD_SEL
             MOV    ES,AX                          ;加载目标数据段描述符
             CLD                                   ;设置方向为正向
             XOR    SI,SI                          ;SI,DI清空
             XOR    DI,DI
             MOV    CX,BUFFERLEN/4                 ;设置4字节为单位的缓冲区长度
             REPZ   MOVSD                          ;传送
    ;切换回实方式
             MOV    EAX,CR0
             AND    EAX,OFFFFFFFEH                 ;将PE位设置为0，切换到实模式
             MOV    CR0,EAX
    ;清指令预取队列，进入实模式
    ;实模式下，JUMP 段值:偏移
             JUMP   <SEG REAL>,<OFFSET REAL>
    REAL:                                          ;现在又回到实方式
	
             CALL   DISABLEA20                     ;关闭地址线A20
             STI                                   ;开中断
    ;
    ;重置数据段寄存器
             MOV    AX,DSEG                        ;设置数据段到AX中
             MOV    DS,AX                          ;设置数据段段值
             MOV    SI,OFFSET BUFFER               ;设置源寄存器地址
             CLD                                   ;显示缓冲区内容
             MOV    BP,BUFFERLEN/16                ;计算打印行数
    NEXTLINE:
             MOV    CX,16                          ;设置每行打印16个字符
    NEXTCH:  
             LODSB                                 ;挪2个字节到AX中，SI+16
             PUSH   AX
             SHR    AL,4
             CALL   TOASCII
             ECHOCH AL
             POP    AX
             CALL   TOASCII
             ECHOCH AL
             ECHOCH ''
             LOOP   NEXTCH
             ECHOCH 0DH                            ;输出换行符
             ECHOCH 0AH
             DEC    BP
             JNZ    NEXTLINE
    ;
             MOV    AX,4C00H                       ;结束
             INT    21H
TOASCII PROC
    ;把AL低4位的十六进制数转换成对应的ASCII,保存在AL
TOASCII ENDP
    ;打开地址线A20
EA20 PROC
             PUSH   AX
             IN     AL,92H
             OR     AL,2
             OUT    92H,AL
             POP    AX
             RET
EA20 ENDP
    ;关闭地址线A20
DA20 PROC
             PUSH   AX
             IN     AL,92H
             AND    AL,0FDH                        ;0FDH = NOT 20H
             OUT    92H,AL
             POP    AX
             RET
DA20 ENDP
CSEG ENDS
	END START
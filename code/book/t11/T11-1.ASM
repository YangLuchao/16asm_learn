;程序名：T11-1.ASM
;功能：演示片上高速缓存的作用
;说明：仅在80486实方式下运行(用TASM汇编，用TLINK连接)
CDBIT	=	30		;CR0种的CD位位置
COUNT 	= 	100
	.486P
;识别486指令集
CSEG SEGMENT 	PARA 	USE16
    CacheD   DB     'Cache Disable: $'
    CacheE   DB     'Cache Enable: $'
             ASSUME CS:CSEG
    BEGIN:   
             PUSH   CS
             POP    DS                    ;使数据段同代码段
    Step1:                                ;在禁止片上超高速缓存的情况下调用测试子程序
             CLI                          ;屏蔽中断
             MOV    EAX,CR0
             BTS    EAX,CDBIT             ;把被测试位的值送标志CF，并且把被测试位置位，也即置1
             MOV    CR0,EAX               ;置CD位，禁止片上超高速缓存
             INVD                         ;清洗片上超高速缓存
             CALL   Acceas                ;调用测试子程序
             STI                          ;开中断
             MOV    ESI,EDX               ;保存所耗时间参数
    Step2:                                ;在允许片上超高速缓存的情况下调用测试子程序
             CLI                          ;关中断
             MOV    EAX,CR0
             BTR    EAX,CDBIT             ;把被测试位的值送标志CF，并且把被测试位复位，也即清0
             MOV    CR0,EAX               ;清CD位，允许片上超高速缓存
             INVD                         ;清洗片上超高速缓存
             CALL   Access                ;调用测试子程序
             STI
             MOV    EDI,EDX               ;保存所耗时间参数
    Step3:   
    ;显示两种情况下的所耗时间表示值
             MOV    DX,OFFSET CacheD
             MOV    ECX,ESI
             CALL   DMESS
             MOV    DX,OFFSET CacheE
             MOV    ECX,EDI
             CALL   DMESS
    Over:                                 ;结束
             MOV    AH,4CH
             INT    21H
    ;过程名称：Access
    ;功能：测试允许和禁止片上超高速缓存效率
    ;人口参数：无
    ;出口参数：EDX含所耗时间参数
    ;高16位是开始时间表示值，低16位是结束时间表示值
Access PROC
             MOV    CX,COUNT
             MOV    EBX,16
             CALL   GetCount              ;取时间表示值
             SHL    EDX,16                ;保存到EDX高16位
    ACC1:    
             MOV    EAX,[EBX]
             MOV    EAX,[EBX*2]
             MOV    EAX,[EBX+EBX*2]
             LOOP   ACC1                  ;再取时间表示值，保存在DX中
             CALL   GetCount
             RET
Access ENDP
    ;过程名称：GetCount
    ;功能：读系统定时计数器0,取得时间表示值
    ;入口参数：无
    ;出口参数：DX=时间表示值
GetCount PROC
             MOV    AL,0
             OUT    43H,AL                ;选定系统定时器0
             CALL   DELAY
             IN     AL,40H                ;读计数值低8位
             MOV    DL,AL
             CALL   DELAY
             IN     AL,40H                ;读计数值高8位
             MOV    DH,AL
    DELAY:   
             RET
GetCount ENDP
    ;过程名称：DMESS
    ;功能：显示说明信息和所用时间表示值
    ;入口参数：DX=提示信息开始地址偏移
    ;ECX=含时间表示值(高16位是开始表示值，低16位是结束表示值)
    ;出口参数：无
DMESS PROC
             MOV    AH,9
             INT    21H                   ;显示提示信息
             SHLD   EDX,ECX,16
             SUB    DX,CX                 ;得所耗时间表示值
    DMESS1:  
             MOV    AX,DX
             CALL   DHEX                  ;以16进制数形式显示
             CALL   NEWLINE               ;回车换行
             RET
DMESS ENDP
    ;略去按十六进制数形式显示DX之内容的过程DHEX
    ;略去形成回车换行的过程NEWLINE
CSEG ENDS
	END BEGIN
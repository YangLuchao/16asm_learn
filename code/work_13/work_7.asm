;程序名称:
;功能:通过调整BIOS中的键盘I/O程序(int 16h)，
;可使到所按的大写字母全部变换为对应的小写字母。
;写一个测试程序验证上述方法。
;=======================================
assume      cs:code,ds:data

data segment
data ends

code segment
    start:  
            mov   ax,0                          ;初始化数据段
            mov   ds,ax

    ;关中断
            CLI                                 ;关中断
            MOV   BX,16H*4                      ;准备设置9号中断向量
            MOV   si,WORD PTR[BX]               ;置偏移暂存SI
            MOV   di,WORD PTR[BX+2]             ;置段值暂存di
    ;将16号中断挪到188号中断
            MOV   bx,188*4
            MOV   WORD PTR[BX],si               ;置偏移
            MOV   WORD PTR[BX+2],di             ;置段值
    ;将16号中断设置为自己的逻辑
            MOV   BX,16H*4
            MOV   WORD PTR[BX],OFFSET new16h    ;置偏移
            MOV   WORD PTR[BX+2],SEG new16h     ;置段值
            STI                                 ;关中断

    START1: 
            MOV   AH,1
            INT   16H                           ;是否有键可读
            JZ    START1                        ;没有，转
            MOV   AH,0                          ;读键
            INT   16H
            MOV   DL,AL                         ;显示所读键
            MOV   AH,6
            INT   21H
            JMP   START1                        ;继续
            
    over:   
            mov   ax,4c00h                      ;dos中断
            int   21H
new16h PROC
            pushf
    ;先执行原16号中断
            int   188
            
            CMP   AL,'A'                        ;小于'A'不是大写英文字符
            JB    new16h1
            CMP   AL,'Z'                        ;大于'Z'不是大写英文字符
            ja    new16h1                       ;
            add   al,20h
    new16h1:
            popf
            iret
new16h ENDP
code ends
    end     start
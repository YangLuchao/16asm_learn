;程序名称:
;功能:通过调整BIOS中的显示I/O程序(int 10h)，可使到所按的大写字母全部变换为对应的小写字母。
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
            MOV   BX,10H*4                      ;准备设置9号中断向量
            MOV   si,WORD PTR[BX]               ;置偏移暂存SI
            MOV   di,WORD PTR[BX+2]             ;置段值暂存di
    ;将16号中断挪到188号中断
            MOV   bx,188*4
            MOV   WORD PTR[BX],si               ;置偏移
            MOV   WORD PTR[BX+2],di             ;置段值
    ;将16号中断设置为自己的逻辑
            MOV   BX,10H*4
            MOV   WORD PTR[BX],OFFSET new10h    ;置偏移
            MOV   WORD PTR[BX+2],SEG new10h     ;置段值
            STI                                 ;关中断

    START1: 
            MOV   AH,1
            INT   16H                           ;是否有键可读
            JZ    START1                        ;没有，转
            MOV   AH,0                          ;读键
            INT   16H
            MOV   AH,9
            MOV   CX,1
            mov   bl,07
            INT   10h
            JMP   START1                        ;继续
            
    over:   
            mov   ax,4c00h                      ;dos中断
            int   21H
new10h PROC
            pushf
            cmp   ah,9
            jnz   new10h1                       ;不是9号显示功能，直接执行原10h号功能
            CMP   AL,'A'                        ;小于'A'不是大写英文字符
            JB    new10h1
            CMP   AL,'Z'                        ;大于'Z'不是大写英文字符
            ja    new10h1                       ;
            add   al,20h
    new10h1:
            int   188
            popf
            iret
new10h ENDP
code ends
    end     start
;程序名：t6-12.asm
;功能：简单热键激活TSR程序，热键CTRL+F8
assume cs:code
;常量说明
buff_head   = 1ah       ;键盘缓冲区头指针保存单元偏移
buff_tail   = 1ch       ;键盘缓冲区尾指针保存单元偏移
buff start  = 1eh       ;键盘缓冲区开始偏移
buff end    = 3eh       ;键盘缓冲区结束偏移
ctrl_f8     = 6500h     ;激活键扫描码
row         = 10        ;行号
column      = 0         ;列号
pagen       = 0         ;显示页号
;代码
code segment
    
    old9h   dd    ?                       ;原9号中断向量保存单元
    mess    db    'Hello!'                ;显示信息
    messlen equ   $ - mess
    ;新建中断
    newgh:  
            pushf                         ;保存标识符
            call  cs:old9h                ;调用原中断处理程序
            sti                           ;开中断
            push  ds                      ;保存寄存器
            push  ax
            push  bx
            
            mov   ax,40h                  ;设置键盘缓冲区段值
            mov   ds,ax
    ;键盘缓冲区偏移
            mov   bx,ds:[buff_head]
            cmp   bx.ds:[buff_tail]
            jz    iover                   ;是，结束
            mov   ax,ds:[bx]              ;键盘缓冲区的值放入到ax中
            cmp   ax,ctrl_f8              ;取所按键的代码
            jz    yes                     ;是否为激活键？
    ;结束
    iover:  
            pop   bx
            pop   ax
            pop   ds
            iret
    ;是
    yes:    
            inc   bx
            inc   bx                      ;调整键盘缓冲区头指针（取走激活键）
            cmp   bx,buff_end             ;指针到缓冲区末尾？
            jnz   yes1
            mov   bx,buff_start           ;是，指向头
    yes1:   
            mov   ds:[buff_head],bx       ;保存
            push  cx
            push  dx
            push  bp I
            push  es

            mov   ax,cs
            mov   es,ax
            
            mov   bp,offset mess
            
            mov   cx,messlen
            mov   dh,row
            mov   dl,column
            mov   bh,pagen
            mov   bl,07h
            mov   al,0                    ;显示后不移动光标，串中不含属性
            mov   ah,13h
            int   10h
            pop   es
            pop   bp
            pop   dx
            pop   cx
            jmp   iover
    ;初始化代码
    init:   
            
            push  cs
            pop   ds
            mov   ax,3509h
    ;取9H号中断向量
            int   21h
            mov   word ptr old9h.bx
            mov   word ptlr old9h+2,es
            mov   dx,offset new9h         ;设置新的9号中断向量
            mov   ax,2509h
            int   21h
            mov   ah , 0
            int   16h
            mov   dx,offset init+25
            mov   cl,4                    ;计算驻留节数
            shr   dx,cl
            add   dx,10h                  ;加上PSP的节数
            mov   al, 0
            mov   ah,31h                  ;驻留退出
            int   21h
            
code ends
end init
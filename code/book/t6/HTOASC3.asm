;程序名称:
;功能:
;=======================================
assume      cs:code,ds:data

data segment

data ends

code segment
    start: 
           mov  ax,data     ;初始化数据段
           mov  ds,ax

           mov  al,0Dh
           call HTOASC

           mov  ax,4c00h    ;dos中断
           int  21H
    ;子程序名：HTOASC
    ;功能：把一位十六进制数转换为对应的ASCII码
    ;入口参数，AL的低4位为要转换的十六进制数
    ;出口参数：AL含对应的ASCII码
HTOASC PROC
           AND  AL,0FH      ;清空AL高4位
           ADD  AL,90H      ;高4位+90H
           DAA              ;十进制加法整理
           ADC  AL,40H      ;
           DAA              ;十进制加法整理
           RET
HTOASC ENDP
code ends
    end     start
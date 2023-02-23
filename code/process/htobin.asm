    ;----------------------------------------------
    ;16进制数转2进制的值
    ;入口参数：dx=要转换值的首地址
    ;入口参数：ax=已转换好的值
htobin PROC
    ;保护寄存器
             PUSH CX
             PUSH DX
             PUSH SI
    ;
             MOV  SI,DX                   ;置指针为入口参数
             XOR  DX,DX                   ;DX值清0
             MOV  CH,4                    ;置循环计数初值，循环4次
             MOV  CL,4                    ;置移位位数，每次位移4位
    HTOBINI: MOV  AL,[SI]                 ;取一位十六进制数
             INC  SI                      ;si+1
             CMP  AL,CR                   ;是否是回车符
             JZ   HTOBIN2                 ;是，转返回
             CALL atobin                  ;十六进制数码符转换成值
             SHL  DX,CL                   ;X*16+Y
             OR   DL,AL
             DEC  CH                      ;循环控制
             JNZ  HTOBIN1
    HTOBIN2: MOV  AX,DX                   ;置出口参数
    ;
    ;恢复寄存器
             POP  SI
             POP  DX
             POP  CX
             RET
htobin ENDP
    ;----------------------------------------------
    ;----------------------------------------------
    ;ascii转2进制的值
    ;入口参数：al=需要转二进制值的ascii码
    ;出口参数：al=已转好的2进制值
atobin PROC
             SUB  AL,30H
             CMP  AL,9
             JBE  ATOBIN1
             SUB  AL,7
             CMP  AL,15
             JBE  ATOBIN1
             SUB  AL,20H
    ATOBIN1: RET
atobin ENDP
    ;----------------------------------------------
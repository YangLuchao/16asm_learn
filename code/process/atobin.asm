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
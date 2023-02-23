    ;----------------------------------------------
    ;设欲转换的十六进制数码在AL的低4位
    ;转换得到的ASCII码在AL中
HTOASC PROC NEAR
             AND  AL,0FH        ;清空高4位
             ADD  AL,30H        ;+30H
             CMP  AL,39H        ;比较39h
             JBE  HTOASC1
             ADD  AL,7H
    TOASC1:  RET
HTOASC ENDP
    ;----------------------------------------------
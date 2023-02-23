    ;----------------------------------------------
    ;判断是不是16进制数
    ;入口参数：AL
    ;出口参数：CF标，CF置1不是16进制数，CF置0位是16进制数
ishex PROC
             CMP  AL,'0'
             JB   ISHEX2
             CMP  AL,'9'+1
             JB   ISHEX1
             CMP  AL,'A'
             JB   ISHEX2
             CMP  AL,'F'+1
             JB   ISHEX1
             CMP  AL,'a'
             JB   ISHEX2
             CMP  AL,'f'+1
    ISHEX1:  CMC
    ISHEX2:  RET
ishex ENDP
    ;----------------------------------------------
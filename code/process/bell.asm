    ;-----------------------------
    ;响铃
    ;入口参数:无
    ;出口参数:标志输出设备
bell PROC
             MOV  AL,BELLCH
             CALL PUTCH
             RET
bell ENDP
    ;-----------------------------
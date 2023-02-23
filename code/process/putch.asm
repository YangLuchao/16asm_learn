    ;-----------------------------
    ;显示一个字符
    ;入口参数：al
    ;出口参数：标志输出设备
putch PROC
             PUSH DX
             MOV  DL,AL
             MOV  AH,2
             INT  21H
             POP  DX
             RET
putch ENDP
    ;-----------------------------
   ;-----------------------------
    ;子程序：接收一个最大长度为4的16进制数串
getstr proc
             mov  di,offset buffer        ;置缓冲区首地址
             mov  bx,0                    ;请接收字符数计数器
    getstrl: 
             call getch                   ;得一个字符
             cmp  al,cr                   ;是否回车符
             jz   getstr5                 ;是，转
             cmp  al,backspace            ;否，是否退格键
             jnz  getstr4
             cmp  bx,0
    ;判断是否有字符可擦除
             jz   getstr2                 ;响铃符
             dec  bx
    ;有字符可擦除
             call putch                   ;光标回移
             mov  al,20h                  ;空格
             call putch                   ;显示空格擦除原字符
             mov  al,backspace
             call putch                   ;光标再回移
             jmp  getstrl
    getstr2: 
             call bell
             jmp  getstr1
    getstr4: 
             cmp  bx,4
    ;一般键处理
             jz   getstr2                 ;如果已接收4个字符，响铃
             call ishex                   ;判断是否为十六进制数码符
             jc   getstr2                 ;cf=1,响铃
             mov  [bx][di],al             ;保存
             inc  bx
             call putch                   ;显示
             jmp  getstr1                 ;继续接收
    getstr5: 
             mov  [bx][di],al             ;保存回车符
             ret
getstr endp
    ;-----------------------------
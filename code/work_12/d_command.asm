;程序名称:
;功能:d命令
;输入段值，偏移，展示出段值偏移的从偏移起的128个字符
;不做跨段展示
;命令:
;d 段值:偏移
;=======================================
;执行步骤：
;1:提醒输入段值，可以为空，默认段值为数据段
;2:提醒输入偏移，可以为空，默认偏移为0000
;3:输入的段值转二进制，存入变量
;4:输入的偏移转二进制，存入变量
;5:进入循环
;循环次数计算规则：
;ffff-偏移<128的，输出实际字符个数
;ffff-偏移>128的，输出128个字符
;5->打印规则,cx记循环次数
;1:外层循环，输出换行，输出段值:偏移，输出空格，cx+1
;2:内层循环，输出字符
;2.1:偏移最小值>0,输出(偏移最小值*2)个空格
;2.2:正常输出16进制字符，每个字符用空格分隔
;2.3:输出字符的同时，将字符翻译存入到ascii变量中
;2.4:内循环完成后一次性输出
;3:ascii变量清空还原为空格符
;4:cx=打印的字符数，退出内循环循环
assume      cs:code,ds:data
;常量定义
blank = 20H;空格符
cr = 0dh;回车
data segment
    inputErr   db 'input err: 0~f $'    ;输入格式错误提示
    inputCs    db 'input cs: $'         ;段值输入提示
    inputIp    db 'input ip: $'         ;偏移输入提示
    csSegAsc   db ?,?,?,?               ;段值ascii码输入暂存变量
    ipSegAsc   db ?,?,?,?               ;偏移ascii码输入暂存变量
    minIp      db ?                     ;16进制最小位偏移
    csBit      dw ?                     ;段值
    ipBit      dw ?                     ;偏移
    loopCount  db 127                   ;循环次数,默认128
    ascii      db 16 dup(20H)           ;ascii码变量
               db '$'
    csAscBuff  db 4 dup(0),24h          ;给转换成的十进制数预留槽位
    ipAscBuff  db 4 dup(0),24h          ;给转换成的十进制数预留槽位
    bitBuff    db ?,?                   ;内存内容转ASCII码的预留槽
    memBit     db 0
    blankCount dw 0
data ends

code segment
    start:       
                 mov  ax,data                ;初始化数据段
                 mov  ds,ax

    ;执行步骤：
    ;1:提醒输入段值，可以为空，默认段值为数据段
                 MOV  DX,OFFSET inputCs
                 CALL DISPMESS
    ;1.1:段值最长4位，不足4位，前面补零
                 mov  si,-1
    csLoop:      
                 inc  si
                 cmp  si,4
                 jz   csInputOver
                 call getch                  ;从键盘上获取一个值
                 CMP  AL,cr                  ;是否输入回车
                 jz   csInputOver            ;是回车，段值处理完成，不足4位，补零
                 call ishex                  ;判断是否为16进制数
                 jc   soutInputErr           ;不是16进制数，输出错误信息
                 mov  csSegAsc[si],al        ;将输入数据挪入变量
                 call putch                  ;将该字符输出到屏幕
                 jmp  csLoop
    csInputOver: 
                 call newline                ;换行
                 MOV  DX,OFFSET inputIp
                 CALL DISPMESS
                 mov  si,-1
                 
    ;2:提醒输入偏移，可以为空，默认偏移为0000
    ipLoop:      
                 inc  si
                 cmp  si,4
                 jz   ipInputOver
                 call getch                  ;从键盘上获取一个值
                 CMP  AL,cr                  ;是否输入回车
                 jz   ipInputOver            ;是回车，段值处理完成，不足4位，补零
                 call ishex                  ;判断是否为16进制数
                 jc   soutInputErr           ;不是16进制数，输出错误信息
                 mov  ipSegAsc[si],al        ;将输入数据挪入变量
                 call putch                  ;将该字符输出到屏幕
                 jmp  ipLoop
    ipInputOver: 
    ;3:输入的段值转二进制，存入变量
                 mov  si,-1
                 XOR  bx,bx
    movCs:       
                 inc  si
                 cmp  si,4
                 jz   movCsOver              ;段值转换完成
                 mov  al,csSegAsc[si]        ;需要转二进制的ascii码数挪到AL中
                 CMP  AL,0                   ;比较0值，为0，转换完成
                 jz   movCsOver
                 call atobin                 ;将AL中的ASCII码转为二进制数据，存在AL的低4位中
    ;将转换好的二进制数挪到bx中
                 mov  cx,4
                 shl  al,cl                  ;将AL的低4位挪到高4位
    ;重复4次，将al高4位挪到di低4位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 jmp  movCs                  ;处理下一位ASCII码
    movCsOver:   
                 MOV  csBit,bx               ;将bx的值挪到变量中
                 mov  si,-1
                 XOR  bx,bx
                 XOR  ax,ax
    ;4:输入的偏移转二进制，存入变量
    movIp:       
                 inc  si
                 cmp  si,4
                 jz   movIpOver              ;段值转换完成
                 mov  al,ipSegAsc[si]        ;需要转二进制的ascii码数挪到AL中
                 CMP  AL,0                   ;比较0值，为0，转换完成
                 jz   movIpOver
                 call atobin                 ;将AL中的ASCII码转为二进制数据，存在AL的低4位中
                 mov  ah,al                  ;将al的值挪到ah中做备份
    ;将转换好的二进制数挪到bx中
                 mov  cx,4
                 shl  al,cl                  ;将AL的低4位挪到高4位
    ;重复4次，将al高4位挪到di低4位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 rcl  al,1                   ;左移1位到cf中
                 rcl  bx,1                   ;将cf的1位挪到bx的最后1位
                 jmp  movIp                  ;处理下一位ASCII码
    movIpOver:   
                 mov  minIp,ah               ;将ah的值挪到变量中
                 MOV  ipBit,bx               ;将bx的值挪到变量中

                 MOV  ax,csBit               ;设置需要输出的段值
                 mov  es,ax
    ;5:进入循环
    ;循环次数计算规则：
    ;ffff-偏移<128的，输出实际字符个数
    ;ffff-偏移>=128的，输出128个字符
                 mov  cx,-1                  ;初始化cx
                 mov  al,minIp               ;al+偏移的低4位
                 add  loopCount,al           ;循环次数挪到变量中
                 cmp  al,0
                 jz   outLoop
                 xor  ax,ax
                 mov  al,16                  ;计算空格循环个数
                 sub  al,minIp
                 mov  blankCount,ax
                 and  ipBit,0fff0h           ;清空si低4位
                 
    ;外循环
    outLoop:     
    ;1:外层循环，输出换行，输出段值:偏移，输出空格，cx+1
    ;输出 段值:偏移
    ;输出段值
                 mov  dx,cx
                 add  dx,1
                 cmp  loopCount,dl           ;判断循环次数
                 call newline
                 MOV  AX,csBit               ;转低8位
                 call ahtoasc
                 mov  csAscBuff[2],ah
                 mov  csAscBuff[3],al
                 MOV  AX,csBit
                 mov  al,ah
                 call ahtoasc
                 mov  csAscBuff[0],ah
                 mov  csAscBuff[1],al
                 push dx
                 MOV  dx,offset csAscBuff
                 mov  ah,9
                 int  21H
                 pop  dx
    ;输出:
                 xor  ax,ax
                 MOV  al,':'
                 call putch
    ;输出偏移
                 MOV  AX,ipBit               ;转低8位
                 add  ax,dx
                 call ahtoasc
                 mov  ipAscBuff[2],ah
                 mov  ipAscBuff[3],al
                 MOV  AX,ipBit
                 mov  al,ah
                 call ahtoasc
                 mov  ipAscBuff[0],ah
                 mov  ipAscBuff[1],al
                 MOV  dx,offset ipAscBuff
                 mov  ah,9
                 int  21H                    ;偏移输出完成
                 call putBlank               ;输出空格
                 MOV  di,-1
    ;5->打印规则,cx记循环次数
    ;2:内层循环，输出字符
    inLoop:      
                 inc  di                     ;内层计数器+1
                 mov  memBit,0               ;内存字节变量，初始化为0
                 cmp  di,16                  ;当次内存循环是否完成
                 jz   printAsc               ;内层循环完成，打印ASCII码
                 cmp  loopCount,cl           ;判断循环次数
                 jz   printAsc               ;打印asc码
                 mov  dl,cl
                 inc  dl
                 cmp  dl,minIp               ;对比偏移最小位
                 jb   print2Blank            ;输出空格
                 jmp  printBin               ;正常输出二进制数
    ;2.2:正常输出16进制字符，每个字符用空格分隔
    printBin:    
    ;2.3:输出字符的同时，将字符翻译存入到ascii变量中
    ;地址处的字节放入到AL中
                 inc  cx                     ;外层计数器+1
                 mov  si,cx                  ;cx为外层循环计数器，可做为偏移的增量指针
                 mov  bx,ipBit
                 MOV  al,es:[bx][si]
                 mov  memBit,al
    ;打印输出字符
                 call ahtoasc
                 mov  bitBuff[0],ah
                 mov  bitBuff[1],al
                 mov  al,bitBuff[0]
                 call putch
                 mov  al,bitBuff[1]
                 call putch
    ;判断是否为可见字符，否则用'.'代替
                 mov  al,memBit
                 call isVisible
                 jnc  bitOver                ;是可见字符，直接输入到变量中
                 MOV  al,'.'                 ;不是可见字符，用.号代替
    bitOver:     
                 MOV  ascii[di],al
                 jmp  printBlank             ;输出一个空格
    ;2.1:偏移最小值>0,输出(偏移最小值*2)个空格
    print2Blank: 
                 inc  cx                     ;外层计数器+1
                 call putBlank               ;输出一个空格
                 call putBlank               ;输出一个空格
    printBlank:  
                 call putBlank               ;输出一个空格
                 jmp  inLoop
   
    ;2.4:内循环完成后一次性输出
    printAsc:    
                 call putBlank               ;输出一个空格
    ;输出ascii码
                 cmp  loopCount,cl           ;判断循环次数
                 jz   outBlank
    printAsc1:   
                 MOV  dx,offset ascii
                 mov  ah,9
                 int  21H
                 cmp  loopCount,cl           ;判断循环次数
                 jz   over
    ;ascii变量清空还原为空格符
                 mov  ascii[0],20h
                 mov  ascii[1],20h
                 mov  ascii[2],20h
                 mov  ascii[3],20h
                 mov  ascii[4],20h
                 mov  ascii[5],20h
                 mov  ascii[6],20h
                 mov  ascii[7],20h
                 mov  ascii[8],20h
                 mov  ascii[9],20h
                 mov  ascii[10],20h
                 mov  ascii[11],20h
                 mov  ascii[12],20h
                 mov  ascii[13],20h
                 mov  ascii[14],20h
                 mov  ascii[15],20h
                 jmp  outLoop                ;调回到外层循环
    ;4:cx=打印的字符数，退出内循环循环
    soutInputErr:
                 call newline
                 MOV  DX,OFFSET inputErr
                 CALL DISPMESS
                 jmp  over
    outBlank:    
                 mov  ax,blankCount
                 cmp  al,0
                 mov  si,0
                 jnz  outBlank1
                 jmp  printAsc1
    outBlank1:   
                 call putBlank               ;输出一个空格
                 call putBlank               ;输出一个空格
                 call putBlank               ;输出一个空格
    outBlank2:   
                 inc  si
                 cmp  si,blankCount
                 jz   printAsc1
                 call putBlank               ;输出一个空格
                 call putBlank               ;输出一个空格
                 call putBlank               ;输出一个空格
                 jmp  outBlank2
                 
    over:        
                 mov  ax,4c00h               ;dos中断
                 int  21H
    ;显示由DX所指的提示信息，其他子程序说明信息略
DISPMESS PROC
                 MOV  AH,9
                 INT  21H
                 RET
DISPMESS ENDP
    ;接受一个字符但不显示，存到al中
    ;入口参数：标志输入设备
    ;出口参数：al
getch PROC
                 MOV  AH,8                   ;接受一个字符但不显示,
                 INT  21H
                 RET
getch ENDP
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
    ISHEX1:      CMC
    ISHEX2:      RET
ishex ENDP
    ;----------------------------------------------
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
    ;-----------------------------
    ;显示一个字符
    ;入口参数：al
    ;出口参数：标志输出设备
dbg PROC
                 PUSH DX
                 call newline
                 MOV  DL,'d'
                 MOV  AH,2
                 INT  21H
                 POP  DX
                 RET
dbg ENDP
    ;-----------------------------
    ;-----------------------------
    ;显示一个字符
    ;入口参数：al
    ;出口参数：标志输出设备
putBlank PROC
                 PUSH DX
                 MOV  DL,20H
                 MOV  AH,2
                 INT  21H
                 POP  DX
                 RET
putBlank ENDP
    ;-----------------------------
    ;----------------------------------------------
    ;子程序名：newline
    ;功能：形成回车和换行（光标移到下一行首)
    ;入口参数：无
    ;出口参数：无
    ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
                 push ax
                 push dx
                 mov  dl,0dh                 ;回车符的ASCII码
                 mov  ah,2
    ;显示回车符
                 int  21h
                 mov  dl,0ah                 ;换行符的ASCII码
                 mov  ah,2
    ;显示换行符
                 int  21h
                 pop  dx
                 pop  ax
                 ret
newline endp
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
    ATOBIN1:     RET
atobin ENDP
    ;----------------------------------------------
    ;子程序名：isVisible
    ;功能：判断字符是否可见
    ;入口参数：al=需要判断的字符
    ;出口参数：无
    ;说明：CF标，CF置1不是可见字符，CF置0位是可见字符
isVisible proc
                 CMP  AL,' '
                 JB   isVisible2
                 CMP  AL,'~'+1
    isVisible1:  CMC
    isVisible2:  RET
isVisible endp
    ;----------------------------------------------
    ;子程序名称:ahtoasc
    ;功能:把8位二进制数转换为2位十六进制数的ASCII
    ;入口参数:AL=欲转换的8位二进制数
    ;出口参数:AH=十六进制数高位的ASCII码,AL=十六进制数低位的ASCII码
    ;其他说明:1.近过程，2.除AX寄存器外，不影响其他寄存器3.调用了htoasc实现十六进制到ASCII码转换
    ;=======================================
ahtoasc PROC
                 mov  ah,al                  ;al复制到ah
                 shr  al,1                   ;AL右移4位
                 shr  al,1
                 shr  al,1
                 shr  al,1
                 call htoasc                 ;调用子程序
                 xchg ah,al                  ;al,ah对调
                 call htoasc                 ;调用子程序
                 RET
ahtoasc ENDP
    ;子程序名称:htoasc
    ;功能:一位十六进制数转换为ASCII
    ;入口参数:al=待转换的十六进制数,ds:bx=存放转换得到的ASCII码串的缓冲区首地址
    ;出口参数:出口参数：al=转换后的ASCII
    ;其他说明:无
    ;=======================================
htoasc PROC
                 and  al,0fh                 ;清空高四位
                 add  al,30h                 ;+30h
                 cmp  al,39h                 ;小于等于39H
                 jbe  htoascl                ;
                 add  al,7h                  ;+7H
    htoascl:     
                 ret
htoasc ENDP
code ends
    end     start
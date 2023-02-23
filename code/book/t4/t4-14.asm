;程序名称:
;例3:写一个指定内存单元内容的程序；
;允许用户按十六进制数的形式输入指定内存单元的段值和偏移
;十六进制显示指定字节单元的内容
;分析：
;第一步:接收段值和偏移
;第二步:把指定单元内容转换为2位十六进制的ASCCI码，边转换边显示
;设子程序getadr接收用户输入的十六进制数串，并转换为进制数，派生2个子程序getstr和htobin
;getstr接收长度为4的十六进制字符串，htobin负责转换为二进制数
;功能：用十六进制数的形式显示指定内存字节单元的内容
;=======================================
assume      cs:code,ds:data
;常量定义
cr          = 0dh   ;回车符
lf          = 0ah   ;换行符
backspace   = 08h   ;退格符
bellch      = 07h   ;响铃符
blank       = 20h   ;空格
data segment
    segoff dd ?                  ;存放指定单元的段值和偏移
    mess1  db ' segment : $ '    ;段值提示
    mess2  db ' offset : $ '     ;偏移提示
    buffer db 5 dup(0)           ;缓冲区
data ends

code segment
    start:   
             mov  ax,data                 ;初始化数据段
             mov  ds,ax

    ;接收段值
             mov  dx,offset mess1         ;准备入口参数
             call dispmess                ;显示提示信息
             call getadr                  ;接收段值
             mov  word ptr segoff+2,ax    ;输入的段值，保存段值在高位

    ;接收偏移
             mov  dx,offset mess2         ;准备入口参数
             call dispmess                ;显示提示信息
             call getadr                  ;接收偏移
             mov  word ptr segoff,ax      ;保存偏移在低位
             Les  di,segoff               ;把段值和偏移送入寄存器di
             mov  al,es:[di]              ;取字节值
             call showal                  ;转换并显示
    
             mov  ax,4c00h                ;dos中断
             int  21H
    ;-----------------------------
    ;子程序转换并显示
showal proc
    ;保护寄存器
             push ax
    ;
             mov  cl,4                    ;右移准备
             rol  al,cl                   ;带位右移4位，准备入口参数，先输出高4位
             call htoasc
             call putch
    ;弹出寄存器
             pop  ax                      ;再输出低4位
             call htoasc
             call putch
             ret
showal endp
    ;-----------------------------
    ;-----------------------------
    ;显示由DX所指的提示信息，其他子程序说明信息略
    ;9号子程序功能，在屏幕显示一个字符串
    ;入口参数：dx：输出字符串的首地址，字符串需要以’$‘结尾
dispmess proc
             mov  ah,9
             int  21h
             ret
dispmess endp
    ;-----------------------------
    ;-----------------------------
getadr proc
    getadr1: 
             call getstr                  ;获取字符串
    ;接收一个字符串
             cmp  buffer,cr               ;字符串是否空
             jnz  getadr2
             call bell
             jmp  getadr1                 ;重新接收
    getadr2: 
             mov  dx,offset buffer
             call htobin                  ;转换出段值
             call newline                 ;另起一行
             ret
getadr endp
    ;-----------------------------
    ;-----------------------------
    ;子程序：接收一个最大长度为4的16进制数串
getstr proc
             mov  di,offset buffer        ;置缓冲区首地址
             mov  bx,0                    ;接收字符数计数器
    getstr1: 
             call getch                   ;得一个字符，存到al中
             cmp  al,cr                   ;是否回车符，对比一下是不是回车符
             jz   getstr5                 ;是回车符，转，保存回车符
             cmp  al,backspace            ;不是回车符否，是否退格键
             jnz  getstr4                 ;不是退格符，转处理本次输入的字符
             cmp  bx,0                    ;是退格符，判断还有没有字符可以退
    ;判断是否有字符可擦除
             jz   getstr2                 ;没有字符可以退了，输出响铃符
             dec  bx                      ;有字符可以退，接受字符计数器-1
    ;有字符可擦除
    ;------------------擦除一个字符
             call putch                   ;当前输入的是退格符，先将退格符输出到屏幕，将光标回移
             mov  al,20h                  ;空格符准备输出
             call putch                   ;将当前光标上的字符替换为空格
             mov  al,backspace            ;退格符准备
             call putch                   ;光标再回移
    ;------------------擦除一个字符
             jmp  getstr1
    getstr2: 
             call bell                    ;输出个响铃，警告
             jmp  getstr1
    getstr4: 
             cmp  bx,4                    ;看接收几个字符了
    ;一般键处理
             jz   getstr2                 ;如果已接收4个字符，响铃
             call ishex                   ;判断是否为十六进制数码符
             jc   getstr2                 ;cf=1,响铃
             mov  [bx][di],al             ;cf=0,是16进制数码符，保存
             inc  bx                      ;输入字符计数器+1
             call putch                   ;显示
             jmp  getstr1                 ;继续接收
    getstr5: 
             mov  [bx][di],al             ;保存回车符
             ret
getstr endp
    ;-----------------------------
    ;-----------------------------
    ;接受一个字符但不显示，存到al中
    ;入口参数：标志输入设备
    ;出口参数：al
getch PROC
             MOV  AH,8                    ;接受一个字符但不显示,
             INT  21H
             RET
getch ENDP
    ;-----------------------------
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
    ;响铃
    ;入口参数:无
    ;出口参数:标志输出设备
bell PROC
             MOV  AL,BELLCH
             CALL PUTCH
             RET
bell ENDP
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
             mov  dl,0dh                  ;回车符的ASCII码
             mov  ah,2
    ;显示回车符
             int  21h
             mov  dl,0ah                  ;换行符的ASCII码
             mov  ah,2
    ;显示换行符
             int  21h
             pop  dx
             pop  ax
             ret
newline endp
    ;----------------------------------------------
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
             MOV  CH,4                    ;置循环计数初值，4个字符循环4次
             MOV  CL,4                    ;置移位位数，每次位移4位
    HTOBIN1: MOV  AL,[SI]                 ;取一位十六进制数
             INC  SI                      ;si+1
             CMP  AL,CR                   ;是否是回车符
             JZ   HTOBIN2                 ;是，转返回
             CALL atobin                  ;十六进制数码符转换成值
             SHL  DX,CL                   ;X*16+Y，16进制转二进制的算法
             OR   DL,AL                   ;左移4位后，DL全为0，OR AL = ADD AL
             DEC  CH                      ;循环控制，CH-1，为0时，ZF值置1
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
    ;----------------------------------------------
    ;判断是不是16进制数
    ;入口参数：AL
    ;出口参数：CF标，CF置1不是16进制数，CF置0位是16进制数
    ;CMP指令，配合JB指令，执行跳转CF置1
ishex PROC
             CMP  AL,'0'                  ;和'0'对比
             JB   ISHEX2                  ;小于0不是ascii码，CF=1
             CMP  AL,'9'+1                ;在'0'~'9'之间，是ascii,cf=0
             JB   ISHEX1
             CMP  AL,'A'                  ;小于''A'不是ascii码，CF=1
             JB   ISHEX2
             CMP  AL,'F'+1                ;在''A'~'F'之间是ascii,cf=0
             JB   ISHEX1
             CMP  AL,'a'                  ;小于''a'不是ascii码，CF=1
             JB   ISHEX2
             CMP  AL,'f'+1                ;在''a'~'f'之间是ascii,cf=0
    ISHEX1:  CMC                          ;cf取反
    ISHEX2:  RET
ishex ENDP
    ;----------------------------------------------
    ;----------------------------------------------
    ;设欲转换的十六进制数码在AL的低4位
    ;转换得到的ASCII码在AL中
HTOASC PROC NEAR
             AND  AL,0FH
             ADD  AL,30H
             CMP  AL,39H
             JBE  TOASC1
             ADD  AL,7H
    TOASC1:  RET
HTOASC ENDP
    ;----------------------------------------------
code ends
    end     start
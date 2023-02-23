;程序名：t6-2.asm
;功能：比较两个字符串是否相同
;子程序strcmp
;REPZ和CMPZ指令配合使用
assume cs:code,ds:data1,es:data2
data1 segment
    str1  db 'Please get up !',0
    str2  db 'Please get up !',0
    mess1 db 'YES!$ '
    mess2 db 'NO!$'                 ;变量名不可以和标号名相同
data1 ends
data2 segment
data2 ends
code segment
    start: 
           mov    ax,data1
           mov    ds,ax
           mov    si,offset str1
           mov    ax,data2
           mov    es,ax

           mov    di,offset str2
           call   far ptr strcmp
           cmp    ax,0
           jz     mess

           mov    dx,offset mess2
           mov    ah,9
           int    21h
           jmp    over
    mess:  
           mov    dx , offset mess1
           mov    ah , 9
           int    21h
    over:  
           mov    ax , 4c00h
           int    21h
    ;子程序名：strcmp
    ;功能：比较两个字符串是否相同
    ;入口参数DS:SI=字符串1首地址
    ;ES:DI=字符串2首地址
    ;出口参数：AX=0表示两字符串相同，否则表示字符串不同
    ;说明：字符串均以0结尾
strcmp proc far
           push   bp                   ;保存主程序栈基址
           MOV    bp,sp                ;将当前栈顶作为栈底，建立堆栈框架
    ;保护寄存器
           push   ds
           push   es
           push   si
           push   di
           push   cx
           push   bx
    ;==================子程序代码开始==============
           mov    ds,[bp+12]           ;要转换的数据地址
           mov    si,[bp+10]
           mov    es,[bp+8]            ;预留槽位的位置
           mov    di,[bp+6]

           cld
           push   di
           xor    al,al                ;测量字符串2的长度，用0与字符串2比较，扫描到结尾符0时结束
           mov    cx, 0ffffh           ;假设长度为FFFF
    next:  
           scasb
    ;扫描字符串2
           Loopnz next                 ;zf不等于0,未到结尾0时，继续扫描
           not    cx                   ;zf=0时， CX值取反，即得到字符串2的长度
           pop    di
           repz   cmpsb                ;两个串比较（包括结束符在内）,CX=0或zf=0时，(即字符不相等时）
           mov    al,[si-1]
           mov    bl,es:[di-1]
           xor    ah,ah                ;如果两个字符串相同，则ax=0
           mov    bh,ah
           sub    ax,bx

           pop    bx
           pop    cx
           pop    si
           pop    es
           pop    ds
           pop    BP
           RET    8                    ;堆栈平衡由子程序完成
strcmp endp
code ends
end start
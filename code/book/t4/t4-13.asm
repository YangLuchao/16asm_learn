;程序名称:
;功能:写一个程序，它接受一个字符串，然后显示其中数字的个数，英文字母的个数和字符串的长度
;分析：利用0AH号功能调用接受一个字符串，然后分别统计个数，
;最后用十进制形式显示
;字符串的长度可以从0AH号功能调用的出口参数中取得。
;=======================================
assume      cs:code,ds:data
mlength = 128;缓冲区最大长度
data segment
    buff  db mlength               ;缓冲区最大长度
          db ?                     ;字符串实际长度，出口参数之一
          db mlength dup(0)        ;符合0AH号功能调用所需的缓冲区

    mess0 db 'Please input : $'    ;提示
    mess1 db 'Length = $'          ;字符串实际长度
    mess2 db 'x = $'               ;字母个数
    mess3 db 'y = $'               ;数字个数
data ends

code segment
    start:   
             mov  ax,data             ;初始化数据段
             mov  ds,ax

    ;输入字符串
             mov  dx,offset mess0     ;打印提示信息
             call dispmess
             
             mov  ah,0ah              ;DOS十号功能，接受一个字符串，回车键结束
             mov  dx,offset buff      ;入口参数，缓冲区首地址，存放缓冲区最大容量
             int  21h                 ;输出提示

             call newline             ;新换一行

             mov  bh,0                ;bh保存数字个数
             mov  bl,0                ;bl保存字符个数
             mov  cl,buff+1           ;取字符串长度，缓冲区的第二字节存放实际读入的字符串长度
             mov  ch,0                ;ch置零

             jcxz cok                 ;若字符串长度等于0,不统计

             mov  si,offset buff+2    ;指向字符串首，缓冲区的第三字节存放实际读入的字符串

    agin:    
             mov  al,[si]             ;取一个字符
             inc  si                  ;si+1
             cmp  al,'0'              ;判断是否数字符
             jb   next                ;<'0'，处理下一个字符
             cmp  al,'9'
             ja   nodec               ;>'9'只能是字符，跳到字符处理
             inc  bh                  ;数字+1
    ;数字符加1
             jmp  short next          ;处理下一个字符
    nodec:   
             or   al,20h              ;转小写，大小写只差20H
             cmp  al,'a'              ;判断是否字母符
             jb   next                ;<'a',处理下一个字符
             cmp  al,'z'
             ja   next                ;>'z',处理下一个字符
             inc  bl                  ;字符+1
    ;字母符加1
    next:    
             Loop agin                ;cx-1

    cok:                              ;显示字符串长度
             mov  dx,offset mess1
             call dispmess
             mov  al,buff+1
             xor  ah,ah
             call dispal
             call newline
    ;显示数字符个数
             mov  dx,offset mess2
             call dispmess
             mov  al,bh
             xor  ah,ah
             call dispal
             call newline
    ;显示字母符个数
             mov  dx,offset mess3
             call dispmess
             mov  al,bl
             xor  ah,ah
             call dispal
             call newline

             mov  ax,4c00h            ;dos中断
             int  21H
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
    ;----------------------------------------------
    ;子程序名：newline
    ;功能：形成回车和换行（光标移到下一行首)
    ;入口参数：无
    ;出口参数：无
    ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
             push ax
             push dx
             mov  dl,0dh              ;回车符的ASCII码
             mov  ah,2
    ;显示回车符
             int  21h
             mov  dl,0ah              ;换行符的ASCII码
             mov  ah,2
    ;显示换行符
             int  21h
             pop  dx
             pop  ax
             ret
newline endp
    ;----------------------------------------------
    ;----------------------------------------------
    ;显示DL中的字符，其他子程序说明信息略
    ;2号子程序功能：显示输出
echoch proc
             mov  ah,2
             int  21h
             ret
echoch endp
    ;----------------------------------------------
    ;----------------------------------------------
    ;子程序名：dispal
    ;功能：用十进制数的形式显示8位二进制数
    ;入口参数：AL=8位二进制数
    ;出口参数：无
dispal proc
             mov  cx,3                ;8位二进制数最多转换为3位十进制数
             mov  dl,10
    disp1:   
             div  dl
             xchg ah,al               ;使AL=余数，AH=商
             add  al,'0'              ;得ASCII码
             push ax
             xchg ah,al
             mov  ah,0
             Loop disp1
             mov  cx,3
    disp2:   
             pop  dx                  ;弹出一位
             call echoch              ;显示之
             Loop disp2               ;继续
             ret
dispal endp
    ;----------------------------------------------

             
code ends
    end     start
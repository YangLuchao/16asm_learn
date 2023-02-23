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
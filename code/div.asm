;程序名称:  div.asm
;功能:  除法指令测试
;=======================================
assume      cs:code,ds:data

data segment
    val1 db 4
    val2 db 2
    val3 dw 1234H
    val4 dw 0e12H
    val5 db -14
    val6 db 11
    val7 dw 0ef23H
    val8 dw 4cfH
data ends

code segment
    start:
    ;初始化代码段
          mov  ax,data
          mov  ds,ax
        

    ;8位无符号数除法
          mov  al,val1
          mov  bl,val2
          xor  ah,ah      ;执行除法前，扩展AH
          div  bl         ;除法的商存入AL中，余数存入AH中

    ;16位无符号数除法
          MOV  ax,val3
          mov  bx,val4
          xor  dx,dx      ;执行除法前，扩展DX
          div  BX         ;除法的商存入AX中，余数存入DX中

    ;8位有符号数除法
          mov  AL,val5
          mov  bl,val6
          cbw             ;执行除法前，扩展AH
          idiv bl         ;除法的商存入AH，余数存入AL

    ;16位有符号数除法
          mov  AX,val7
          mov  bx,val8
          cwd             ;执行除法前，扩展DX
          idiv bx         ;除法的商存入AX中，余数存入DX中

    ;结束
          mov  AH,4ch
          int  21h
code ends
    end     start
;程序名称:
;功能:请编写一个用2位十六进制数显示AL的内容的宏。该宏调用已定义的宏HTOASC和宏ECHO。
;宏HTOASC把1位十六进制数转换为对应的ASCII码，宏ECHO显示字符。
;=======================================
assume      cs:code
HTOASC MACRO
           AND AL,0FH    ;清空AL低4位
           ADD AL,90H    ;高4位+90H
           DAA
           ADC AL,40H
           DAA
ENDM
RCHO MACRO
         MOV DL,AL
         MOV AH,2
         INT 21H
ENDM
PUTCH MACRO
          mov    ah,al
          mov    cx,4
          shr    al,cl
          HTOASC
          RCHO
          mov    al,ah
          HTOASC
          RCHO
ENDM

code segment
    start:
          mov   al,12H
          PUTCH
          mov   ax,4c00h    ;dos中断
          int   21H
code ends
    end     start
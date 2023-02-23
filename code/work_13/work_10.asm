;程序名称:
;功能:写一个程序在屏幕中央显示系统当前时间，当同时按下左右SHIFT键时，清屏并结束程序
;方法2
;=======================================
assume      cs:code,ds:data
;执行步骤如下：
;1:清空屏幕
;2:从int 1ah中拿到时间
;3:在屏幕中间输出时间
COLUM = 80;列
line = 24;行
data segment
    HHHH        DB ?,?,':'    ;时
    MMMM        DB ?,?,':'    ;分
    SSSS        DB ?,?,24h    ;秒
    colum_count db -1
    line_count  db -1
data ends

code segment
    start:      
                mov  ax,data                ;初始化数据段
                mov  ds,ax

    ;计算光标位子
    outer:      
                MOV  AH,2                   ;取变换键状态字节
                INT  16H
                cmp  AL,00000011B           ;同时按下左右shift键
                JZ   OVER                   ;按下，转
                MOV  AH,1
                INT  16H                    ;是否有键可读
                JZ   next                   ;没有，转
                MOV  AH,0                   ;读键
                INT  16H
    next:       
                add  line_count,1           ;行+1
                cmp  line_count,line
                jz   home1
                call GET_T
    iner:       
                add  colum_count,1          ;列+1
                cmp  colum_count,COLUM
                jz   home
    ;光标位子计算完成
                mov  ah,2                   ;移动光标位子
                mov  dh,line_count
                mov  dl,colum_count
                int  10h
                mov  al,0
                cmp  line_count,10
                jnz  print
                jmp  printLetter
    print:      
                mov  ah,9
                mov  bl,07h
                mov  cx,1
                int  10h
                jmp  iner
    home:       
                mov  colum_count,-1
                jmp  outer
    home1:      
                mov  line_count,-1
                jmp  outer

    printLetter:
                XOR  bx,bx
                cmp  colum_count,28
                jb   print
                cmp  colum_count,38
                ja   print
                mov  bl,colum_count
                sub  bl,31
                mov  al,byte ptr ds:[bx]
                jmp  print
    over:       
                mov  ax,4c00h               ;dos中断
                int  21H
    ;子程序说明信息略
    ;子程序名称:GET_T
    ;功能:获取系统时间
    ;入口参数:HHHH DB ?,?,':'    ;时
    ;        MMMM DB ?,?,':'    ;分
    ;        SSSS DB ?,?        ;秒
    ;出口参数:变量中存好了时分秒
    ;其他说明:1.近过程，2.除AX寄存器外，不影响其他寄存器3.调用了htoasc实现十六进制到ASCII码转换
    ;=======================================
GET_T PROC
                MOV  AH,2                   ;取时间信息
                INT  1AH
                MOV  AL,CH                  ;把时数转为可显示形式
                CALL TTASC
                XCHG AH,AL
                MOV  WORD PTR HHHH,AX       ;保存
                MOV  AL,CL                  ;把分数转为可显示形式
                CALL TTASC
                XCHG AH,AL
                MOV  WORD PTR MMMM,AX       ;保存
                MOV  AL,DH                  ;把秒数转为可显示形式
                CALL TTASC
                XCHG AH,AL
                MOV  WORD PTR SSSS,AX       ;保存
                RET
GET_T ENDP
    ;子程序名：TTASC
    ;功能：把两位压缩的BCD码转换为对应的ASCII码
    ;入口参数：AL=压缩BCD码
    ;出口参数：AH=高位BCD码所对应的ASCII码
    ; 		  AL=低位BCD码所对应的ASCII码
TTASC PROC
                MOV  AH,AL
                AND  AL,0FH
                SHR  AH,1
                SHR  AH,1
                SHR  AH,1
                SHR  AH,1
                ADD  AX,3030H
                RET
TTASC ENDP
    ;=====================
code ends
    end     start
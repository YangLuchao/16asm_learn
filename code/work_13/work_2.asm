;程序名称:
;功能:写一个程序在屏幕上循环显示26个大写字母，
;每行显示10个，逐行变化显示颜色，当按下ALT+F1键时终止程序。
;注：macos系统没得alt键，按任意键终止
;=======================================
assume      cs:code,ds:data
count = 26
count1 = 4000
line_count = 10
data segment
        COLORB        DB 0FH,70H,74H,07H,17H,0FH,70H,74H,70H        ;颜色
        letter_count  db -1
        newline_count db -1
data ends

code segment
        start:  
                MOV  AX,data
                MOV  DS,AX

        next:   
                mov  ah,1                           ;1号功能，判断键盘有没有输入
                int  16h                            ;执行16号中断
                jc   over                           ;有输入，执行完成
                add  newline_count,1
                cmp  newline_count,11
                jz   next2
                add  letter_count,1
                CMP  letter_count,26
                jz   next3
        next1:  
                mov  ah,2                           ;2号功能，移动光标
                mov  dl,newline_count               ;列
                mov  dh,24                          ;行
                int  10h                            ;执行10号中断
                mov  ah,9                           ;9号功能，输出字符
                add  letter_count,41H               ;转大写
                MOV  AL,letter_count                ;放入al
                mov  cx,1                           ;重复打印1ci
                mov  si,offset newline_count
                mov  bl,byte ptr ds:[si]            ;选个颜色
                int  10h                            ;执行10号中断
                sub  letter_count,41h               ;减41h
                jmp  next
        next2:  
                call newline
                mov  newline_count,-1
                jmp  next
        next3:  
                mov  letter_count,0
                jmp  next1
            
        over:   
                mov  ax,4c00h                       ;dos中断
                int  21H
        ;----------------------------------------------
        ;子程序名：newline
        ;功能：形成回车和换行（光标移到下一行首)
        ;入口参数：无
        ;出口参数：无
        ;说明：通过显示回车符形成回车，通过显示换行符形成换行
newline proc
                push ax
                push dx
                mov  dl,0dh                         ;回车符的ASCII码
                mov  ah,2
        ;显示回车符
                int  21h
                mov  dl,0ah                         ;换行符的ASCII码
                mov  ah,2
        ;显示换行符
                int  21h
                pop  dx
                pop  ax
                ret
newline endp
        ;----------------------------------------------
code ends
    end     start
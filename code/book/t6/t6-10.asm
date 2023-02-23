;程序名：t6-10.asm
;功能：在屏幕上显示用户所按字符，直到用户按ESC键为止
assume cs:code
;常量定义
cr=0dh
lf=0ah
escape=1bh
;ESC
code segment
    start:
          push cs           ;psp压入栈
          pop  ds
    cont: 
          mov  ah,8         ;8号功能调用，不带回显，接收一个字符
          int  21h
          cmp  al,escape    ;判断是否为ESC键
          jz   short xit
          
          mov  dl,al        ;否，显示按键字符
          mov  ah,2         ;显示字符
          int  21h
          cmp  dl,cr        ;是否回车键
          jnz  cont         ;否，继续输入

          mov  ah,2         ;是，显示回车换行键
          int  21h
          mov  dl,lf
          mov  ah,2
          int  21h
          jmp  cont
          
    xit:  
          mov  ax,4c00h
          int  21h
code ends
end start
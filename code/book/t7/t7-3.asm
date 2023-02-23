;程序名：t7-3.asm
;功能：在当前光标位置循环显示各种不同背景的显示效果，按一次键，则换一种颜色。
assume cs : code , ds : data
;预定义说明记录类型
color record blank:1,back:3,intense:1,fore:3
data segment
    char db   'A'
         attr color <0,0,1,7>    ;定义记录变量
data ends

;代码段
code segment
    start:
          mov ax,data
          mov ds,ax
          mov bp,1 shl width back    ;置循环计数器bp=8

    next: 
          mov ah,9                   ;当前光标位置显示字符A
          mov bh,0
          mov al,char
          mov bl,attr
          mov cx,1
          int 10h

          mov al,attr                ;取显示属性（记录变量）al=0fh
          mov ah,al

          and al,not mask back       ;析出除背景的其他位al=0fh
          mov cl,back                ;记录到最右端的移动位数cl=4
          shr ah,cl                  ;把背景字段移至右端ah=0
          inc ah                     ;调整背景色ah=1
   
          shl ah,cl                  ;再向左移到原位ah=10h
          and ah,mask back           ;屏蔽除背景位的其他位ah=10h
          or  ah,al                  ;和其他位原值合并ah=1fh
    
          mov attr,ah                ;保存属性
    
          mov ah,0                   ;接收键盘输入
          int 16h
          dec bp
          jnz next

          mov ax,4c00h               ;退出到dos
          int 21h
code ends
end start
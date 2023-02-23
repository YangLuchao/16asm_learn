;程序名称: 16汇编hello world
;功能: 打印出一条字符串hello world
;======================
assume cs:code,ds:data ;自定义代码段，数据段，堆栈段可忽略由系统自动分配

data segment
    string db 'hello world asm 16!','$'    ;string是标号，db是数据类型，后面是值，’$‘是结尾标识符
data ends

code segment                       ;代码段定义
    start:                         ;代码段开始
    ;
          mov bx,data              ;asm16固定写法，将data首地址赋值给BX
          mov ds,bx                ;将BX的值赋值给数据段
    ;
          mov si,0                 ;si是变址寄存器，存放偏移地址
          mov ax,[si]              ;数据段偏移地址si处存储的值，送入ax
          mov dx, offset string    ;操作系统预定义子程序，必须使用对象
    ;offset 编译器感知，指向string的首地址，string的偏移地址：0
    ;offset好处在于让编译器计算偏移地址
          mov AH,9                 ;9号功能：显示一个字符串，必须以’$‘结尾
          int 21H                  ;dos的中断（过程、中断子程序、内核函数）
    ;
    ; mov ax,4c00h,下面拆开写
          mov al,0                 ;入口参数为0，表示程序结束了
          MOV AH,4ch               ;4ch号功能
          int 21h                  ;dos中断
code ends                          ;代码段结束
end start           ;程序入口
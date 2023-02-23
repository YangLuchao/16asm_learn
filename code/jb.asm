;程序名称: jb指令测试
;功能:  基于jb输出不同的字符串
;======================
assume cs:code,ds:data ;假设代码段标号为code，数据段标号为data

data segment                                  ;定义数据段
      string db 'hello world asm 1!','$'      ;定义string标号，db(字节类型)，以’$‘结尾的字符串
      number db 1,2,3,4,5,6                   ;定义number标号，db(字节)类型，分配6个字节的空间，初始化为1,2,3,4,5,6
data ends                                     ;数据段定义完成

code segment                             ;定义代码段
      start:                             ;开始
            mov ax,data                  ;规定写法
            mov ds,ax                    ;规定写法
        
            mov si,offset number         ;number地址放到变址寄存器中
            mov al,byte ptr ds:[si]      ;byte ptr ds:[si]
                                         ;寻址的标准写法
      ;byte类型的指针 数据段:[变址寄存器中存储的偏移]
      ;SI值当前为0
      ;byte ptr ds:[si] = 1
      ;mov al,1
            cmp al,[si+1]                ;cmp al,2
      ;jb     无符号数 小于转移
            jb  over                     ;jb 小于，跳转，不打印
      ;
            mov dx,offset string
            mov ah,9
            int 21H
      ;
      over: mov ax,4c00h
            int 21H
code ends
end start
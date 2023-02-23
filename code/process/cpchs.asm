       ;----------------------------------------------
       ;子程序名：cpChs
       ;功能：复制字符串
       ;入口参数：[bp-6]=源字符串的首地址，[bp-4]=目标地址的首地址
       ;出口参数：无
       ;说明：遇到回车符结束
cpChs proc
                  push bp                    ;构建堆栈框架
                  mov  bp,sp
       ;
                  push ax                    ;保护寄存器
                  push si
                  push bx
       ;准备
                  mov  si,-1

       ;开始处理
       cpNext:    
                  inc  si                    ;si+1
                  MOV  bx,[bp+6]             ;源字符串首地址放到bx中
                  MOV  al,[bx][si+2]         ;字符串实际是从第三个字节开始的
                  MOV  bx,[bp+4]             ;目标地址首地址放入bx中
                  xchg al,[bx][si]           ;复制入
                  cmp  al,0dh                ;遇到回车符子程序结束
                  jz   cpOver
                  jmp  cpNext

                  pop  bx                    ;弹出寄存器
                  pop  si
                  pop  ax
       ;销毁堆栈架构
                  pop  bp
       cpOver:    
                  ret  4                     ;子程序完成堆栈平衡
cpChs endp
       ;----------------------------------------------
;程序名称:32_bit_ complement.asm
;功能:编写一个求32位补码的程序。通过寄存器传递出入口参数
;=======================================
assume      cs:code,ds:data

data segment
    val1 dw 1234H    ;低16位，放入AX
    val2 dw 0045H    ;高16位，放入dx
data ends

code segment
    start:     
               mov  ax,data       ;初始化数据段
               mov  ds,ax
    ;val1放入AX，val2放入dx
    ;分别对ax,dx取反
    ;分别对AX,dx加1
               mov  ax,val1
               mov  dx,val2
               call COMPLEMENT

               mov  ax,4c00h      ;dos中断
               int  21H
    ;子程序名称:求32位补码的程序
    ;功能:求32位补码
    ;入口参数:AX寄存器放低16位，DX寄存器放高16位
    ;出口参数:AX寄存器放低16位结果，DX寄存器放高16位结果
    ;其他说明:无
    ;=======================================
COMPLEMENT PROC
               push bp            ;保存主程序栈基址
               MOV  bp,sp         ;将当前栈顶作为栈底，建立堆栈框架
    ;用bp寄存器作为堆栈的基址
    ;bp+2获取返回地址IP
    ;bp+4获取返回地址段值(CS)
    ;bp+6获取入口参数
    ;==================子程序代码开始==============
               not  ax            ;低16位的反码
               not  dx            ;高16位的反码
               add  ax,1h         ;低位正常加1
               adc  dx,0          ;高位，带位加1
    ;==================子程序代码结束==============
               MOV  sp,bp         ;释放定义的局部变量的空间(SUB sp,4)
               pop  BP
               RET
COMPLEMENT ENDP

code ends
    end     start
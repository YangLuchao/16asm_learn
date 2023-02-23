;程序名称:
;功能:设A1=0,A2=1,当n>=3时，An=A_{n-1}+3*A_{n-2}
;=======================================
assume      cs:code,ds:data

data segment
    N       dw 6    ;n=10
    N_val   dw 1    ;n的值,初始化为1
    N_1_val dw 0    ;n-1的值，初始化为0
data ends

code segment
    start:    
              mov  ax,data            ;初始化数据段
              mov  ds,ax

              mov  cx,2
              mov  bx,offset N_val    ;bx传参

              call algorithm

              mov  ax,4c00h           ;dos中断
              int  21H
    ;子程序名称:
    ;功能:
    ;入口参数:bx传参
    ;出口参数:变量传参
    ;其他说明:算法如下：
    ;n=1:A1=0
    ;n=2:A2=1
    ;n=3:A3=1+3*0=1
    ;n=4:A4=1+3*1=4
    ;n=5:A5=4+3*1=7
    ;n=6:A6=7+3*4=19
    ;=======================================
algorithm PROC
    ;保护寄存器
              push CX
              push ax
              push dx

              cmp  cx,[bx-2]
              jz   done               ;完成退出递归
    ;An=A_{n-1}+3*A_{n-2}
              inc  cx                 ;处理n+1
              call algorithm
              MOV  ax,[bx+2]          ;n-2的值放入ax中
              mov  dx,3               ;乘数3放到dx中
              mul  dx                 ;乘积放入ax中
              add  ax,[bx]            ;n-1的值+乘积,ax中保存的是n的值，
    ;结果存入变量中
              xchg [bx],ax
              xchg [bx+2],ax
    done:     
    ;弹出寄存器
              pop  dx
              pop  ax
              POP  cx
              RET
algorithm ENDP
code ends
    end     start
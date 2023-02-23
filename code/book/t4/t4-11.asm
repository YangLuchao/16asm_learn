;程序名：t4-11.asm
;递归：n!
;计算9!
;算法：递归
assume cs:code
code segment
    start:
          mov  ax,9
    ;入口参数
          call fact
          mov  ax,4c00h
          int  21h
    ;递归堆栈结构如下
    ;|IP    |ffff
    ;|DX    |
    ;|IP    |
    ;|DX    |
    ;|IP    |
    ;|DX    |
    ;|      |
    ;|...   |0000
fact proc
          push dx
          mov  dx,ax
          cmp  ax,0
    ;n为0?
          jz   done
          dec  ax
          call fact        ;求（n-1)!
          mul  dx
          pop  dx
          ret
    done: 
          mov  ax,1
    ;0!=1
          pop  dx
          ret
fact endp
code ends
end start
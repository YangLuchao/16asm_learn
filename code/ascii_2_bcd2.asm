;程序名称:
;功能:请写一个可把某个十进制数ASCII码串转换为BCD码对应的二进制数的示例程序
;=======================================
assume      cs:code,ds:data

data segment
    target       db '12'          ;需要转换的ASCII码
    len          =  $-target      ;计数器
    non_compress db len dup(0)    ;非压缩，预留变量槽位
data ends
;16进制数对应的ASCII码相差30H
;1的ASCII码 0011 0001 ，转为bcd码：31H-30H = 1H
;非压缩: 1 = 0000 0001 2 = 0000 0002 3 = 0000 0003 4 = 0000 0004
code segment
    start:
          mov  ax,data                ;初始化数据段
          mov  ds,ax

          mov  si,-1                  ;变址寄存器置0
          mov  cx,len                 ;初始化计数器
    ;非压缩处理，比较简单，取出字符后-30H放入对应变量即可
    next: 
          inc  si                     ;变址寄存器+1
          XOR  AX,ax                  ;ax清零
          mov  al,target[si]          ;值挪到al中
          sub  al,30H                 ;减30H转bcd码
          mov  non_compress[si],al    ;保存到变量中
          loop next                   ;处理下一个字符

          mov  ax,4c00h               ;dos中断
          int  21H
code ends
    end     start
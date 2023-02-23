;程序名称:
;功能: 请写一个可把某个十进制数ASCII码串转换为对应的非压缩BCD和压缩BCD的示例程序
;=======================================
assume      cs:code,ds:data

data segment
      target       db '12'                 ;需要转换的ASCII码
      len          =  $-target             ;计数器
      non_compress db len dup(0)           ;非压缩，预留变量槽位
      compress     db len/2 +1 dup(0)      ;压缩，预留变量槽位
data ends
;16进制数对应的ASCII码相差30H
;1的ASCII码 0011 0001 ，转为bcd码：31H-30H = 1H
;非压缩: 1 = 0000 0001 2 = 0000 0002 3 = 0000 0003 4 = 0000 0004
;压缩:  12 = 0001 0002 34 = 0003 0004
code segment
      start:
            mov  ax,data                  ;初始化数据段
            mov  ds,ax

            mov  si,-1                    ;变址寄存器置0
            mov  cx,len                   ;初始化计数器
      ;非压缩处理，比较简单，取出字符后-30H放入对应变量即可
      next: 
            inc  si                       ;变址寄存器+1
            XOR  AX,ax                    ;ax清零
            mov  al,target[si]            ;值挪到al中
            sub  al,30H                   ;减30H转bcd码
            mov  non_compress[si],al      ;保存到变量中
            loop next                     ;处理下一个字符


      ;压缩处理
      ;判断SI奇偶
      ;SI为偶数，取出一个数值，放到al中，al-30H,再al左移4位
      ;si为奇数，取出一个数值，放到AL中，al-30h,将al挪到对应变量中，al清零
            mov  si,-1                    ;初始化变址寄存器
            mov  cx,len                   ;初始化计数器
            xor  ax,ax                    ;ax清零
      next1:
            inc  si                       ;si+1
            mov  bx,si                    ;si放入BX中，判断si奇偶
            and  bx,01H                   ;保留最后一位
            SUB  BX,1                     ;减1
            jz   odd                      ;等于0，为奇数
            jmp  even1                    ;不等于0，为偶数
      next2:
            cmp  si,len-1                 ;判断是否为最后一个字段
            jz   over
            loop next1                    ;处理下一个字符

      ;si为奇数
      odd:  
            add  al,target[si]            ;上一个bcd码已经挪到了高4位，取出一个字符add到低4位中
            sub  al,30H                   ;转bcd码
            push ax                       ;暂存计算出的bcd码
            MOV  ax,si                    ;对变量寻址，公式为：((si+1)/2)-1
            add  ax,1
            cwd                           ;除法指令，进行扩展
            xor  bx,bx                    ;bx清空
            mov  bx,2
            div  bx                       ;除以2
            sub  ax,1                     ;再减1
            mov  di,ax                    ;将计算出的地址挪到dx中
            pop  ax                       ;弹出计算出的bcd码
            mov  compress[di],al          ;挪到对应变量中
            xor  ax,AX                    ;al清0
            jmp  next2                    ;跳到next2处，继续循环，处理下一个字段

      ;si为偶数
      even1:
            mov  al,target[si]            ;取出一个字符放到AL中
            sub  al,30H                   ;转bcd码
            push cx                       ;暂存cx的值
            mov  cl,4                     ;准备左移位数
            shl  AX,cl                    ;左移4位，挪到高4位去
            pop  cx
            jmp  next2                    ;跳到next2处，继续循环，处理下一个字段

      over: 
            mov  ax,4c00h                 ;dos中断
            int  21H
code ends
    end     start
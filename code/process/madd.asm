    ;子程序名：madd
    ;功能：32位数相加
    ;入口参数：datal和data2缓冲区存放要相加的32位数
    ;出口参数：data3缓冲区存放结果
    ;说明：1.32位数据的存放依次采用'高高低低'的原则；2.可能产生进位存放在data3开始的第5字节中
madd proc
          push ax                       ;保护寄存器
          push CX                       ;保护寄存器
          push si                       ;保护si
          mov  cx,2                     ;两次循环
          xor  si,si
    ;cf=0
    maddl:
          mov  ax,word ptr data1[si]    ;拿第一个数的16位
          adc  ax,word ptr data2[si]    ;和第二个数的16位相加
          mov  word ptr data3[si],ax    ;计算结果放到预留槽位中
          inc  si                       ;指针+2
          inc  si
          loop maddl                    ;第二次高16位相加
          mov  al,0                     ;al置零
    ;进位处理
          adc  al,
          mov  byte ptr data3+4,AL
          pop  si
          pop  cx
          pop  ax
          ret
madd endp
;程序名称:
;功能:编写一个去掉字符串前导空格的近过程。
;定义：原字符串
;步骤：
;1:计算有多少空格，没有空格，退出
;2:计算原字符串长度
;3：清除空格
;4：清空结尾处字符
;=======================================
assume      cs:code,ds:data
blank = ' ';空格常量
data segment
    str1     db '       0123456789qwertyuiopasdfghjklzxcvbnm',0,'$'
    blankLen dw 0
    str1Len  dw 0
data ends

code segment
    start:
          mov   ax,data           ;初始化数据段
          mov   ds,ax

          mov   ax,data
          mov   es,ax

          mov   si,-1
          mov   al,blank
    ;计算空格个数，没有空格则退出
    next: 
          inc   si
          cmp   al,ds:[si]
          jz    next
          cmp   si,-1
          jz    over
          mov   cx,si
          mov   blankLen,cx

    ;计算字符串1的长度
          mov   di,offset str1
          CLD                     ;DF清0，正向递增
          XOR   AL,AL             ;使AL含结束标志值
          MOV   CX,0FFFFH         ;取字符串长度极值
          REPNE SCASB             ;搜索结束标志0
          NOT   CX                ;得字符串包括结束标志在内的长度
          sub   cx,blankLen
          mov   str1Len,cx
  
          mov   di,offset str1
          mov   si,offset str1
          add   si,blankLen
          rep   movsb

          mov   al,0
          mov   si,str1Len
          mov   cx,blankLen
          rep   STOSB

          mov   dx,offset str1    ;打印
          mov   ah,9H
          int   21H

    over: 
          mov   ax,4c00h          ;dos中断
          int   21H
code ends
    end     start
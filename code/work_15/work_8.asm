;程序名称:
;功能:编写一个截取字符串某子串的近过程
;定义：原字符串str1，开始截取偏移，子串长度
;步骤：
;1:计算原字符串长度
;2:字符串长度小于偏移,退出
;3:偏移+子串长度<原字符串长度，截取到原字符串尾
;4：截取
;=======================================
assume      cs:code,ds:data

data segment
       str1    db '0123456789qwertyuiopasdfghjklzxcvbnm',0
       str2    db 40 dup(0)
               db '$'
       sta     dw 10
       sz      dw 10
       str1Len dw 0
data ends

code segment
       start: 
              mov   ax,data              ;初始化数据段
              mov   ds,ax

              mov   ax,data              ;初始化数据段
              mov   es,ax
              mov   di,offset str1

       ;计算字符串1的长度
              CLD                        ;DF清0，正向递增
              XOR   AL,AL                ;使AL含结束标志值
              MOV   CX,0FFFFH            ;取字符串长度极值
              REPNE SCASB                ;搜索结束标志0
              MOV   AX,CX
              NOT   CX                   ;得字符串包括结束标志在内的长度
              cmp   cx,sz                ;原字符串长度小于子串长度，退出
              jb    over
              mov   str1Len,cx

              sub   cx,sz
              sub   cx,sta
              cmp   cx,0
              jae   len_ok
              mov   cx,str1Len
              sub   cx,sta
              mov   sz,cx
       len_ok:
              mov   cx,sz
              MOV   si,offset str1
              add   si,sta
              mov   di,offset str2
              rep   movsb

              mov   dx,offset str2       ;打印
              mov   ah,9H
              int   21H
        
       over:  
              mov   ax,4c00h             ;dos中断
              int   21H
code ends
    end     start
;程序名称:
;功能:编写一个把字符串2插入字符串1指定位置的远过程
;定义：
;字符串1，字符串2，预留缓冲区字符串3，插入位子
;步骤：
;1：计算字符串1长度
;1.1:字符串1长度小于插入位子，退出
;2:计算字符串2长度
;3:挪字符串1插入位置前的数据到缓冲区
;4：挪字符串2插入缓冲区
;5：将字符串1剩下的字符挪到缓冲区
;=======================================
assume      cs:code,ds:data

data segment
      str1    db '0123456789qwertyuiopasdfghjklzxcvbnm',0      ;字符串1
      str2    db 'aaaaaa',0                                    ;字符串2
      str3    db 50 dup(0)
              db '$'

      insert  dw 2
      str1Len dw 0
      str2Len dw 0
data ends

code segment
      start:
            mov   ax,data             ;初始化数据段
            mov   ds,ax

            mov   ax,data             ;初始化数据段
            mov   es,ax
            mov   di,offset str1

      ;计算字符串1的长度
            CLD                       ;DF清0，正向递增
            XOR   AL,AL               ;使AL含结束标志值
            MOV   CX,0FFFFH           ;取字符串长度极值
            REPNE SCASB               ;搜索结束标志0
            MOV   AX,CX
            NOT   CX                  ;得字符串包括结束标志在内的长度
            cmp   cx,insert           ;字符串1的长度小于指定的位子，直接结束
            jb    over
            mov   str1Len,cx

      ;计算字符串2的长度
            mov   di,offset str2
            XOR   AL,AL               ;使AL含结束标志值
            MOV   CX,0FFFFH           ;取字符串长度极值
            REPNE SCASB               ;搜索结束标志0
            MOV   AX,CX
            NOT   CX
            dec   cx                  ;得字符串包括结束标志在内的长度
            mov   str2Len,cx

            mov   cx,insert
            mov   di,offset str3
            mov   si,offset str1
            rep   movsb

            mov   cx,str2Len
            mov   di,offset str3
            ADD   di,insert
            mov   si,offset str2
            rep   movsb

            mov   cx,str1Len
            sub   cx,insert
            mov   di,offset str3
            ADD   di,insert
            ADD   di,str2Len
            mov   si,offset str1
            add   si,insert
            rep   movsb
          
            mov   dx,offset str3      ;打印
            mov   ah,9H
            int   21H
      over: 
            mov   ax,4c00h            ;dos中断
            int   21H
code ends
    end     start
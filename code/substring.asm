;程序名称:
;功能:设字符串1在数据段1中，字符串2在数据段2中，写一个程序判别字符串2是否是字符串1的;
;子字符串，如果是，则把数据段2中的flag单元置1，否置0
;=======================================
assume      cs:code,ds:data
;手推过程
;'123225',0
;'22'
;child_len
;si = 0 di = 0 [si] = 1 != [di] = 2
;si = 1 di = 0 [si] = 2 == [di] = 2 
;di++
;si = 2 di = 1 [si] = 2 != [di] = 3 
;di = 0
;si = 3 di = 0 [si] = 2 == [di] = 2
;di++
;si = 4 di = 1 [si] = 2 == [di] = 2
;di++
;di == child_len
;flag = 1
data segment
    string    db '123225',0       ;字符串
    child     db '22'             ;子串
    child_len =  $ - child - 1    ;子串长度，要与指针对比，所以减1
    flag      db 0                ;默认为不存在标识
data ends

code segment
    start:     
               mov ax,data          ;初始化数据段
               mov ds,ax
    ;准备
               MOV si,-1            ;si指向字符串
               mov di,-1            ;di指向子串
    
    loop1:     
               inc si               ;si+1
               inc di               ;di+1
               cmp string[si],0     ;判断字符串是否遍历完成
               jz  over             ;字符串遍历完成，退出
               mov ah,string[si]    ;分别放入AL，AH中
               mov al,child[di]
               cmp ah,al            ;比较
               jnz no               ;不相等，跳
               cmp di,child_len     ;相等，di与子串长度对比
               jz  child_over       ;相等子串已匹配到
               jmp loop1            ;子串还没有匹配完成
    no:        
               mov di,-1            ;di初始化为-1，下次循环加上去
               jmp loop1            ;跳到循环开始
    child_over:
               mov al,1             ;相等子串已匹配到
               mov flag,al          ;将标匹配识置为1
    over:      
               mov ax,4c00h         ;dos中断
               int 21H
code ends
    end     start
;程序名称:
;功能:设从地址F000:000H开始的1K字节内存区域是缓冲区。请写一个可收集该区域所有子串‘OK'开始地址的程序
;=======================================
assume      cs:code,ds:data
;指定起始地址开始，循环1024次，指针每次移动1字节，每次获取两字节数据
;获取的数据-'OK'
;不等于0指针加1，继续执行
;等于0，统计个数+1
data segment

      vals  db 'gOKdfgdfhgsOKsdghdfgsOkas'            ;准备缓冲区
            db 'vknskvnsOKlnlvkdsvklsnvjd '
            db 'vjkzknvklNLKNOKVNLSvnlsdknvl',0H
      count dw 0                                      ;ok个数计数
      addrs dw 10 dup(0)                              ;1k字节内存区域内，极端情况下，可能有512个OK,数据定义太长，假设定义短一点

data ends

code segment
      start:  
              mov  ax,data                   ;初始化数据段
              mov  ds,ax

              mov  cx,1024                   ;初始化循环计数器
              mov  si,-1                     ;初始化变址寄存器
              MOV  DX,-1                     ;初始化地址寄存器

      loop1:  
              inc  si                        ;si+1
              xor  ax,ax
              cmp  ax,word ptr vals[si]      ;对比单字节
              jz   over                      ;为0结束
              mov  ax,word ptr vals[si]      ;拿两个个字节
              cmp  ax,'KO'                   ;与ok比较，小端存储，所以字符倒序
              jz   address                   ;等于0跳转
              loop loop1                     ;不等于0，处理下一个字段

      address:
              inc  dx                        ;bx+1
              lea  ax,vals[si]               ;将ok的起始地址挪到ax中
              add  dx,dx                     ;si每次自增1，但是2个字节，所以bx*2
              mov  bx,dx
              MOV  addrs[bx],ax
              loop loop1                     ;处理下一个字段

      over:   
              mov  ax,4c00h                  ;dos中断
              int  21H
code ends
    end     start
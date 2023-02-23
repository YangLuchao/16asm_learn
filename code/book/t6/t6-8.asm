;例1:写一个显示命令行参数的程序
;程序名：t6-8.asm
;先从PSP中把命令行参数传到程序定义的缓冲区，然后再显示。
assume cs:code,ds:code
code segment
       buffer db    128 dup(?)             ;存放命令行参数的缓冲区
       start: 
              cld
              mov   si,80h                 ;从psp区，80h偏移处开始加载命令行参数
              lodsb
       
              mov   cl,al                  ;取得命令行参数的长度，字节数
              xor   ch,ch
              push  cs                     ;该程序数据和代码在同一个段中
              pop   es                     ;附加段和代码段相同
              mov   di,offset buffer
              push  cx
              rep   movsb                  ;传命令行参数，将命令行参数复制到buffer中
              pop   cx
              push  es
              pop   ds                     ;置数据段寄存器
              mov   si,offset buffer
              mov   ah,2
              jcxz  over
       next:  
              lodsb
              mov   dl,al                  ;显示命令行参数
              int   21h
              loop  next
       over:  
              mov   ax,4c00h
              int   21h
code ends
end start
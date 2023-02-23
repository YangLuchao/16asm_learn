;程序名称:
;功能:反编译，看REP
;=======================================
assume      cs:code,ds:data

data segment

data ends

code segment
    start:
          mov  ax,data     ;初始化数据段
          mov  ds,ax

          CLD              ;如果已清方向标志，则这条指令可省
          MOV  CX,50

          REP  MOVSW

          REPZ CMPSB
          
          mov  ax,4c00h    ;dos中断
          int  21H
code ends
    end     start
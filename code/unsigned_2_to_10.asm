;程序名称:
;功能:无符号数二进制码转10进制ASCII码
;=======================================
assume      cs:code,ds:data
;二进制转十进制，用位权法如下：
;1011 0101B=1*2^7+1*2^5+1*2^4+1*2^2+1*2^0=128+32+16+4+1=181D
;其中二进制的位权值建表，快速查出，地址为位数
;计算过程用2进制计算，计算完成后转化为10进制
;定义10进制加法运算，逢10进1
;先判断2进制有多少位，就循环多少次
;每次循环做10进制加法
;定义10进制加法表：一个二维数组，结果所在位置代表两数相加，结果高四位代表进位,地址计算规则为：两数相加的结果就是两个四位组成的8位地址所索引的值
;寄存器只做数据运算，所有用到的数据均需创建变量存储
data segment
    bit_ptr             db          00000000B                                  ;当前处理的位数
    byte_count          db          ?                                          ;字节循环计数器
    bit_count           db          ?                                          ;位循环计数器
    two_scale_data      db          '67'                                       ;需要转10进制的二进制数据，6 = 0110 7 = 0111，转10进制后为0103
                        data_length =$-two_scale_data                          ;准备的数据的长度(字节)
    data_reverse        db          data_length  dup(0)                        ;给需要处理的字节倒序存储预留槽位
    wait_process_bit    db          00000000B                                  ;等待缓存的位
    carry_bit           db          0H                                         ;进位标识
    print               db          ?,?,?,?,'$'                                ;sum转ascii码
    add_result          dw          0H                                         ;临时缓存
    sum                 dw          0H                                         ;sum
    bit_weight          dw          0000H                                      ;计算出的位权值
    two_position_weight dw          0001H                                      ;2^0
                        dw          0002H                                      ;2^1
                        dw          0004H                                      ;2^2
                        dw          0008H                                      ;2^3
                        dw          0016H                                      ;2^4
                        dw          0032H                                      ;2^5
                        dw          0064H                                      ;2^6
                        dw          0064H                                      ;2^7
                        dw          0128H                                      ;2^8
                        dw          0256H                                      ;2^9
                        dw          0512H                                      ;2^10
                        dw          1024H                                      ;2^11
                        dw          2048H                                      ;2^12
                        dw          4086H                                      ;2^13

    ten_scale_add       dw          00H,01H,02H,03H,04H,05H,06H,07H,08H,09H    ;0+0~9
                        dw          01H,02H,03H,04H,05H,06H,07H,08H,08H,10H    ;1+0~9
                        dw          02H,03H,04H,05H,06H,07H,08H,09H,10H,11H    ;2+0~9
                        dw          03H,04H,05H,06H,07H,08H,09H,10H,11H,12H    ;3+0~9
                        dw          04H,05H,06H,07H,08H,09H,10H,11H,12H,13H    ;4+0~9
                        dw          05H,06H,07H,08H,09H,10H,11H,12H,13H,14H    ;5+0~9
                        dw          06H,07H,08H,09H,10H,11H,12H,13H,14H,15H    ;6+0~9
                        dw          07H,08H,09H,10H,11H,12H,13H,14H,15H,16H    ;7+0~9
                        dw          08H,09H,10H,11H,12H,13H,14H,15H,16H,17H    ;8+0~9
                        dw          09H,10H,11H,12H,13H,14H,15H,16H,17H,18H    ;9+0~9
data ends

code segment
    start:      
                mov  ax,data                           ;初始化数据段
                mov  ds,ax
            
                XOR  ax,ax                             ;清空ax
                xor  bx,bx                             ;清空BX
                XOR  cx,cx                             ;清空cx
                XOR  dx,dx                             ;清空dx
                MOV  cx,data_length                    ;2进制数据占槽位数(多少个字节，每个字节8位)
                mov  di,-1

    reverse:    
                mov  ax,cx                             ;cx表示有多少个字节
                sub  ax,1                              ;ax-1,索引最后一个字节
                mov  si,ax                             ;将AX放到si中
                mov  al,byte ptr two_scale_data[si]    ;将最后一个字节挪到al中
                inc  di                                ;另一个变址寄存器+1
                mov  data_reverse[di],al               ;将ax中的数据挪到预留的槽内
                loop reverse                           ;继续处理下一个字节
    ;数据倒序处理完成
    ;准备
                xor  ax,ax                             ;清空ax
                mov  bl,-1                             ;初始化bl,bl存处的位数
                mov  bit_ptr,bl                        ;当前的位数存入bit_ptr中
                XOR  bx,bx                             ;清空BX
                MOV  SI,-1                             ;初始化si
                mov  di,0                              ;di置0
                mov  cx,data_length                    ;需要处理的字节数

    LOOP1:                                             ;循环处理每一个字节
                inc  si                                ;si+1
                MOV  al,data_reverse[si]               ;将最后一个字节放入到Al中，待处理
                mov  byte_count,cl                     ;暂存cx
                mov  cx,8                              ;每个字节有8位，处理每一位，循环处理8次
            
    process_bit:
                mov  bl,bit_ptr                        ;将变量中的值挪到bl中
                inc  bl                                ;bl+1记录,记录处理当前位的位数，每次进入bl循环，bl+1
                mov  bit_ptr,bl                        ;bl中的值挪到变量中
                mov  bit_count,cl                      ;暂存cx的值
                ror  al,1                              ;右移一位，移到CF中
                jb   one                               ;cf值为1，跳到one，计算值
                loop process_bit                       ;cf值为0，处理下一个位
                mov  cl,byte_count                     ;当前al的8位全部处理完成，将字节数计数器弹出
                loop LOOP1                             ;继续处理下一个字节

    one:        
                MOV  carry_bit,bh                      ;清空进位符
                MOV  wait_process_bit,al               ;当前al中存的是待处理的位，暂存到变量中
                xor  di,di                             ;di清空
                xor  dx,dx                             ;清空dx
                add  dl,bit_ptr                        ;将当前的位加到dl中
                mov  di,dx                             ;位权值地址表寻址地址
                MOV  dx,two_position_weight[di]        ;位权值存放到dx中
                mov  bit_weight,dx                     ;将找到的位权值挪到变量中
                xor  cx,cx                             ;清空cx

    ;处理1~4位
                MOV  ax,sum                            ;sum中存的是累加的值，挪到ax中
                and  ax,0fH                            ;清空高12位，保留低4位
                AND  dx,0fH                            ;清空高12位，保留低4位
                add  ax,dx                             ;组装位地址
                MOV  di,ax                             ;地址挪到变址寄存器
                mov  dx,ten_scale_add[di]              ;将计算结果暂存到dx中
                mov  add_result,dx                     ;将加运算结果临时存到变量中
                AND  dx,0fH                            ;清空dx高12位，保留低4位
                mov  ax,sum                            ;将sum挪到ax中
                and  ax,0fff0H                         ;清空低4位
                add  ax,dx                             ;将sum的低4位换成新值
                MOV  sum,ax                            ;计算结果保存起来
                MOV  cl,4                              ;右移4位准备
                ror  dl,cl                             ;右移4位，将高4位挪到低4位
                MOV  carry_bit,dl                      ;将进位标识挪到变量中保存

    ;处理5~8位
                MOV  ax,sum                            ;sum中存的是累加的值，挪到ax中
                and  ax,0f0H                           ;保留al高4位
                mov  dx,bit_weight                     ;从变量中把位权值挪到dx中
                AND  dx,0f0H                           ;保留dl高4位
                mov  cl,4                              ;右移4位做准备
                shr  ax,cl                             ;右移4位
                shr  dx,cl                             ;dx右移4位
                add  dx,ax                             ;组装位地址
                MOV  di,dx                             ;计算好的地址挪挪到di中
                mov  dx,ten_scale_add[di]              ;将计算结果挪到dx中
                mov  add_result,dx                     ;将计算结果暂存到变量中
                and  dx,0f0H                           ;保留dl高4位
                mov  cx,4                              ;右移4位做准备
                shr  dx,cl                             ;将dl高4位挪到低4位，为加进位做准备
                add  dl,carry_bit                      ;加进位
                MOV  carry_bit,dh                      ;将进位标志置0
                MOV  cl,4                              ;左移4位做准备
                shl  dx,cl                             ;将dl低4位挪到高4位
                MOV  ax,sum                            ;将sum挪到ax中
                and  ax,0ff0fH                         ;清空al高4位
                add  ax,dx                             ;将al高4位换成新值
                mov  sum,ax                            ;将加法结果放入到sum中
                MOV  dx,add_result                     ;将计算结果挪到dx中
                mov  cl,5                              ;右移5位做准备
                shr  dx,cl                             ;dx右移5位
                MOV  carry_bit,dl                      ;进位标识挪到变量中

    ;处理9~12位
                xor  ax,ax                             ;清空ax
                mov  ax,sum                            ;将sum挪到AX中，准备计算
                AND  ax,0f00H                          ;保留ah低4位
                MOV  dx,bit_weight                     ;将变量中的位权值挪到dx中
                and  dx,0f00H                          ;保留dh低4位
                add  dx,ax                             ;组装位地址
                mov  cl,8                              ;右移8位准备
                shr  dx,cl                             ;dx右移8位
                MOV  di,dx                             ;将组装好的地址挪到变址寄存器中
                mov  dx,ten_scale_add[di]              ;将计算结果挪到dx中
                MOV  add_result,dx                     ;将计算结果挪到变量中暂存
                and  dx,0f00H                          ;保留dh低4位
                MOV  CX,8                              ;右移8位做准备
                shr  dx,cl                             ;右移8位
                add  dl,carry_bit                      ;加进位
                MOV  carry_bit,dh                      ;将进位置0
                mov  cl,8                              ;左移8位做准备
                shl  dx,cl                             ;dx左移8位
                MOV  AX,sum                            ;将sum挪到ax中
                and  ax,0f0ffH                         ;清空ah低4位
                add  ax,dx                             ;将ah的低4位换成新值
                MOV  sum,ax                            ;将加法结果放入到sum中
                MOV  dx,add_result                     ;将计算结果挪到dx中
                MOV  Cl,9                              ;右移9位准备
                shr  dx,cl                             ;右移9位
                MOV  carry_bit,dl                      ;将进位标识挪到变量中

    ;处理13~16位
                xor  ax,ax                             ;清空ax
                mov  ax,sum                            ;将sum挪到ax中，准备计算
                AND  ax,0f000H                         ;保留ah高4位
                mov  dl,bit_ptr                        ;将变量中的位权值挪到dx中
                AND  dx,0f000H                         ;保留dh高4位
                mov  cl,4                              ;右移4位准备
                shr  dx,cl                             ;dx右移4位
                shr  ax,cl                             ;ax右移4位
                add  dx,ax                             ;组装位地址
                mov  cl,8                              ;右移8位准备
                shr  dx,cl                             ;dx右移8位
                MOV  di,dx                             ;将组装好的地址放入到di中
                MOV  dx,ten_scale_add[di]              ;将计算结果挪到dx中
                MOV  add_result,dx                     ;将计算结果保存到变量中
                and  dx,0f000H                         ;保存dh的高4位
                mov  cl,12                             ;右移12位准备
                shr  dx,cl                             ;右移12位
                add  dl,carry_bit                      ;加进位
                MOV  carry_bit,dh                      ;将进位置为0
                mov  cl,12                             ;左移12位准备
                shl  dx,cl                             ;左移12位
                MOV  AX,sum                            ;将sum挪到ax中
                AND  ax,0fffH                          ;清空ah的高4位
                add  ax,dx                             ;将ah高4位换为新值
                mov  sum,ax                            ;将结果保存到sum中，后面不用再处理进位

    ;10进制加法处理完成，继续处理下一位
                mov  cl,bit_count                      ;弹出CX
                loop process_bit                       ;继续处理下一位
                mov  cl,byte_count                     ;当前al的8位全部处理完成，将字节数计数器弹出
                loop LOOP1                             ;继续处理下一个字节

    ;全部字节处理完成，结果存在sum中，转ascii码
                mov  ax,sum                            ;将sum挪到ax中
                AND  Ah,0f0H                           ;清空低4位
                add  ah,30H                            ;转ascii码
                mov  print[0],ah                       ;挪到预定义的槽位中
                MOV  ax,sum
                and  ah,0fH                            ;清空高4位
                mov  cl,4                              ;右4位准备
                shr  ah,cl                             ;将高4位挪到低4位
                add  ah,30H                            ;装ascii码
                mov  print[1],ah                       ;挪到预定义槽位
                mov  ax,sum
                and  al,0f0H                           ;清空低4位
                add  al,30H                            ;转ASCII码
                MOV  print[2],al                       ;挪到预定的槽位
                mov  ax,sum
                and  AL,0fH                            ;清空高4位
                MOV  cl,4                              ;右移4位做准备
                shr  al,cl                             ;右移4位
                add  al,30H                            ;转ascii码
                mov  print[3],al                       ;挪到预定一点额槽位

                mov  dx,offset print                   ;打印输出
                xor  AX,ax
                mov  ah,9
                int  21H

                mov  ax,4c00h                          ;dos中断
                int  21H
code ends
    end     start
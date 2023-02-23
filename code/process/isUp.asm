       ;-----------------------------
       ;子程序名称:isUp
       ;功能:判断大写还是小写
       ;入口参数:AL=字符ASCII码
       ;出口参数:CF标，CF置1不是大写，CF置0位是大写
       ;其他说明:无
              ; call isUp
              ; jnc  iner                 ;是大写，处理下一个字符
       ;=======================================
isUp proc
                    CMP   AL,'A'               ;小于'a'不是大写，CF=1
                    JB    isUp2
                    CMP   AL,'Z'+1             ;在'a'~'z'之间是大写,cf=0
                    JB    isUp1
       isUp1:       CMC                        ;cf取反
       isUp2:       RET
isUp endp
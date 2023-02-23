      ;-----------------------------
      ;判断是不是英文字符
      ;入口参数：al
      ;出口参数：CF标，CF置1是小写，CF置0位是大写
islow proc
                 CMP   AL,'a'          ;小于'a'不是小写，CF=1
                 JB    islow2
      islow1:    CMC                   ;cf取反
      islow2:    RET
islow endp
      ;-----------------------------
      ;-----------------------------
      ;判断是不是英文字符
      ;入口参数：al
      ;出口参数：CF标，CF置1不是英文字符，CF置0位是英文字符
            ; CALL isEnglesh
            ; jnc  engAdd              ;是英文字符，转
isEnglesh PROC
                 CMP   AL,'A'          ;小于'A'不是英文字符，CF=1
                 JB    isEnglesh2
                 CMP   AL,'Z'+1        ;在'A'~'F'之间是英文,cf=0
                 JB    isEnglesh1
                 CMP   AL,'a'          ;小于'a'不是英文字符，CF=1
                 JB    isEnglesh2
                 CMP   AL,'z'+1        ;在'a'~'z'之间是英文字符,cf=0
      isEnglesh1:CMC                   ;cf取反
      isEnglesh2:RET
isEnglesh endp
      ;-----------------------------
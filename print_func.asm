global print

;Func:print
;    rbx -> str address
;    rdi point to src string
;    rsi point to dest string
;    
;    The Run time stack status is as follow
;    -----------
;    |  Para 1 |
;    -----------
;         :
;    -----------
;    |  Para N |
;    -----------
;    | ParaNum |
;    -----------
;    | Address |
;    -----------   
;    |   ip    |
;    -----------
;    |   rbp   |
;    -----------
print:    
          push      rbp
          mov       rbp, rsp

          ; save register
          push      rbx
          push      rdi
          push      rsi
          push      rax
          push      rcx
          push      rdx

          xor       r10, r10                ; set r10 -> 0
          xor       rdi, rdi                ; set rdi -> 0
          xor       rsi, rsi                ; set rsi -> 0

          mov        r9, [rbp + 24]         ; get para number
          shl        r9, 3
          add        r9, 24
          
print_begin:
          mov       rbx, [rbp + 16]         ; get src string address
          mov byte   al, [rbx + rdi]          ; al -> message[rdi]

          cmp        al, 0
          jz         print_sys_call

          cmp        al, '%'
          jnz        movech

          mov byte   al, [rbx + rdi + 1]
          cmp        al, 'd'
          jnz        movech

replace_digit:
          ; convert int -> string
          push      rbx
          mov       rbx, r9
          sub        r9, 8
          mov       rax, [rbp + rbx]
          pop       rbx
          inc       r10
          push      rbx
          mov       ebx, 10
          xor       rcx, rcx       ; rcx -> 0

divideLoop:
          mov       edx, 0
          div       ebx

          push      rdx
          inc       rcx
          cmp       eax, 0
          jnz       divideLoop

popLoop:
          pop       rax
          add       al, '0'
          mov byte  [print_buffer+rsi], al
          inc       rsi
          loop      popLoop
          add       rdi, 2
          pop       rbx
          jmp       print_begin

movech:
          mov byte   al, [rbx+rdi]
          mov      [print_buffer+rsi], al
          inc       rdi
          inc       rsi
          jmp       print_begin

print_sys_call:
          mov byte [print_buffer+rsi], 0
          mov       rax, 1         ; system call for write
          mov       rdi, 1         ; file handle 1 is stdout
          mov       rdx, rsi
          inc       rdx            ; number of bytes
          mov       rsi, print_buffer   ; address of string to output
          syscall

          ; restore registers
          pop       rdx
          pop       rcx
          pop       rax
          pop       rsi
          pop       rdi
          pop       rbx
          pop       rbp

          ret


          section   .data
print_buffer: times 256 db 0
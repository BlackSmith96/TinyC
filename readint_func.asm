global readint

;Func: readint
;	read a integer & write to [rsp]
          section   .text
readint:
		  push 		rbx
		  push		rcx
		  push 		rax
		  push      rdi
		  push 		rsi
		  push		rdx

		  xor 		rbx, rbx				; rbx = 0

readch:   mov 		rax, SYS_read
          mov 		rdi, STDIN
          mov		rsi, read_buffer		; msg address
          mov 		rdx, 1					; read count
          syscall

          mov		al, byte [read_buffer]
          cmp		al, LF
          je		readDone
calc:

		  mov		rcx, rax
		  mov		rax, rbx
		  mov		rdx, 10
		  mul 		rdx
		  add 		rax, rcx
		  sub 		rax, '0'
		  mov		rbx, rax
		  jmp		readch

readDone:
		; Put integer in [rsp]
		  mov		[rsp+56], rbx
		  pop 		rdx
		  pop 		rsi
		  pop 		rdi
		  pop		rax
		  pop		rcx
		  pop 		rbx

		  ret

          section   .data
LF			equ		10		; line feed
NULL		equ		0		; end of string
STDIN 		equ 	0
SYS_read	equ		0
read_buffer db		0
INT10		dw		10
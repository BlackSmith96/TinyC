%include"macro.inc"
global _start
   section     .text
_start:
	call main
	exit rax
factor:
	push rbp
	mov  rbp, rsp
_beg_if_1:
	push qword [rbp+16]
	push qword 2
	cmplt
	jz _else_1
	push qword 1
	pop  rax
	mov  rsp, rbp
	pop  rbp
	ret
	jmp _end_if_1
_else_1:
_end_if_1:
	push qword [rbp+16]
	push qword [rbp+16]
	push qword 1
	sub
	call factor
	add  rsp, 8
	push  rax
	mul
	pop  rax
	mov  rsp, rbp
	pop  rbp
	ret
main:
	push rbp
	mov  rbp, rsp
	sub  rsp, 8
	push qword 0
	pop  [rbp-8]
_beg_while_1:
	push qword [rbp-8]
	push qword 10
	cmplt
	jz _end_while_1
	push qword [rbp-8]
	push qword 1
	add
	pop  [rbp-8]
_beg_if_2:
	push qword [rbp-8]
	push qword 3
	cmpeq
	push qword [rbp-8]
	push qword 5
	cmpeq
	or
	jz _else_2
	jmp _beg_while_1	; Continue
	jmp _end_if_2
_else_2:
_end_if_2:
_beg_if_3:
	push qword [rbp-8]
	push qword 8
	cmpeq
	jz _else_3
	jmp _end_while_1	; Break
	jmp _end_if_3
_else_3:
_end_if_3:
	push qword [rbp-8]
	push qword [rbp-8]
	call factor
	add  rsp, 8
	push  rax
	push qword 2
	push _print_message_1
	call print
	add  rsp,32
	jmp _beg_while_1
_end_while_1:
	push qword 0
	pop  rax
	mov  rsp, rbp
	pop  rbp
	ret
   section     .data
_print_message_1 db "%d! = %d" , 10, 0

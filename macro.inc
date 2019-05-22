%MACRO add 0
    POP	rax
    ADD qword [rsp], rax
%ENDMACRO

%MACRO sub 0
    POP	rax
    SUB	qword [rsp], rax
%ENDMACRO

%MACRO mul 0
    POP	rax
    MUL	qword [rsp]
    MOV [rsp], rax
%ENDMACRO

%MACRO div 0
	XOR rdx, rdx
	MOV rax, [rsp + 8]
	DIV qword [rsp]
	ADD rsp, 8
	MOV [rsp], rax
%ENDMACRO

%MACRO mod 0
	XOR rdx, rdx
	MOV rax, [rsp + 8]
	DIV qword [rsp]
	ADD rsp, 8
	MOV [rsp], rdx
%ENDMACRO

%MACRO cmpeq 0
	MOV rax, [rsp + 8]
	CMP rax, [rsp]
	PUSHF
	POP rax
	SHR rax, 6
	AND rax, 0x1
	ADD rsp, 8
	MOV [rsp], rax
%ENDMACRO


%MACRO cmpne 0
	MOV rax, [rsp + 8]
	CMP rax, [rsp]
	PUSHF
	POP rax
	SHR rax, 6
	AND rax, 0x1
	XOR rax, 0x1
	ADD rsp, 8
	MOV [rsp], rax
%ENDMACRO

%MACRO cmpge 0
	MOV rax, [rsp + 8]
	SUB rax, [rsp]
	PUSHF
	POP rax
	AND rax, 10000000b
	CMP rax, 0
	PUSHF
	POP rax
	SHR rax, 6
	AND rax, 1
	ADD rsp, 8
	MOV [rsp], rax
%ENDMACRO

%MACRO cmple 0
	MOV rax, [rsp + 8]
	SUB rax, [rsp]
	PUSHF
	POP rax
	AND rax, 11000000b
	MOV rbx, rax
	AND rbx, 10000000b
	AND rax, 01000000b
	SHR rax, 6
	SHR rbx, 7
	OR  rax, rbx
	ADD rsp, 8
	MOV [rsp], rax
%ENDMACRO

%MACRO cmplt 0
	MOV rax, [rsp + 8]
	SUB rax, [rsp]
	PUSHF
	POP rax
	AND rax, 11000000b	;10的情况下
	CMP rax, 10000000b
	PUSHF
	POP rax
	SHR rax, 6
	AND rax, 1
	ADD rsp, 8
	MOV [rsp], rax
%ENDMACRO

%MACRO cmpgt 0
	MOV rax, [rsp + 8]
	SUB rax, [rsp]
	PUSHF
	POP rax
	AND rax, 11000000b	;00的情况下gt
	CMP rax, 00000000b
	PUSHF
	POP rax
	SHR rax, 6
	AND rax, 1
	ADD rsp, 8
	MOV [rsp], rax
%ENDMACRO

%MACRO and 0
	MOV rax, [rsp + 8]
	AND [rsp], rax
	ADD rsp, 8
%ENDMACRO

%MACRO or 0
	MOV rax, [rsp]
	OR  [rsp+8], rax
	ADD rsp, 8
%ENDMACRO

%MACRO not 0
	MOV rax, [rsp]
	OR  rax, rax
	PUSHF
	POP rax
	SHR rax, 6
	AND rax, 1
	MOV [rsp], rax
%ENDMACRO

%MACRO neg 0
	XOR rax, rax
	SUB rax, [rsp]
	MOV [rsp], rax
%ENDMACRO

%MACRO jz 1
	POP rax
	OR  rax, rax
	JZ  %1
%ENDMACRO

%MACRO jmp 1
	JMP %1
%ENDMACRO

%MACRO push 1
	PUSH qword %1
%ENDMACRO

%MACRO pop 0-1
	%IFIDN %0, 0
		ADD rsp, 8
	%ELSE
		POP qword %1
	%ENDIF
%ENDMACRO

%MACRO exit 1
	MOV rdi, %1
	MOV rax, 60                 
    syscall
%ENDMACRO

;---------------------
%MACRO FUNC 1
	%1
	PUSH rbp
	MOV	 rbp, rsp
%ENDMACRO


extern print
extern readint
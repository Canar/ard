	.file	"main.c"
	.comm	error_value,4,4
	.section	.rodata
	.align 8
.LC0:
	.string	"Require at least 1 argument. User entered %i."
.LC1:
	.string	"Failed to open %s."
.LC2:
	.string	"Failed to stat %s: %m"
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$176, %rsp
	movl	%edi, -164(%rbp)
	movq	%rsi, -176(%rbp)
	movl	$0, error_value(%rip)
	cmpl	$0, -164(%rbp)
	jle	.L2
	movl	-164(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf
	movl	error_value(%rip), %eax
	addl	$1, %eax
	movl	%eax, error_value(%rip)
	movl	error_value(%rip), %eax
	jmp	.L6
.L2:
	movq	-176(%rbp), %rax
	movq	(%rax), %rax
	movl	$526594, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	open
	movl	%eax, -4(%rbp)
	cmpl	$0, -4(%rbp)
	js	.L4
	movq	-176(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, %rsi
	movl	$.LC1, %edi
	movl	$0, %eax
	call	printf
	movl	$2, %eax
	jmp	.L6
.L4:
	leaq	-160(%rbp), %rdx
	movl	-4(%rbp), %eax
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	fstat
	testl	%eax, %eax
	js	.L5
	movq	-176(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, %rsi
	movl	$.LC2, %edi
	movl	$0, %eax
	call	printf
	movl	error_value(%rip), %eax
	addl	$1, %eax
	movl	%eax, error_value(%rip)
	movl	error_value(%rip), %eax
	jmp	.L6
.L5:
	movl	$0, %eax
.L6:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (Debian 4.9.2-18) 4.9.2"
	.section	.note.GNU-stack,"",@progbits

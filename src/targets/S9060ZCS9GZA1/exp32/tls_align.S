/* Force the merged .tdata section (and thus PT_TLS p_align) to 32 bytes.
 * Bionic's loader rejects an ARM executable whose TLS segment alignment is
 * below 32 ("executable's TLS segment is underaligned ... for ARM Bionic").
 * The static bionic libc only contributes an 8-byte, 8-aligned .tdata, so
 * without this anchor the exp32 stage aborts at execve with SIGABRT. */
	.section .tdata,"awT",%progbits
	.p2align 5
	.global exp32_tls_align_anchor
exp32_tls_align_anchor:
	.word 0

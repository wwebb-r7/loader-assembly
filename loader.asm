; loader.asm

BITS 64

sys_open  equ 2
sys_fstat equ 5
sys_mmap  equ 9
SHT_SYMTAB equ 2

global _start


section .text

_start:
  ;long testfile, testelf;
  ;struct stat *statbuf;
  ;unsigned char *testbuf, *t;
  ;void (*e_entry)(long *, long *);

  ;long got, rela, relasz, rel, relsz;

  ;long stack[9] = {0};
  ;long *dynv;
  
  ; setup some stack space and handle arguments here
  xor  eax, eax

  ; mmap statbuf
	xor  rdi, rdi
  mov  rsi, 90h       ; sizeof(struct stat)
  mov  rdx, 0x03      ; PROT_WRITE (0x02) | PROT_READ (0x01)
  mov  r10, 0x0801    ; MAP_SHARED (0x01) | MAP_ANON (0x0800)
  xor  r8, r8
  xor  r9, r9
  mov  rax, sys_mmap  ; mmap
  syscall
  ; save result (statbuf) somewhere

  ; open argv[1]
  mov  rdi, argv1
  xor  rsi, rsi       ; O_RDONLY
  mov  rax, sys_open
  syscall
  ; save result (testfile) somewhere

  ; open argv[2]
  mov  rdi, argv2
  xor  rsi, rsi        ; O_RDONLY
  mov  rax, sys_open
  syscall
  ; save result (testelf) somewhere

  ; fstat(testfile, statbuf)
  mov  rdi, testfile
  mov  rsi, statbuf
  mov  rax, sys_fstat
  syscall

  ; testbuf = mmap(0, statbuf->st_size, PROT_EXEC | PROT_WRITE | PROT_READ, MAP_PRIVATE, testfile, 0);
  xor  rdi, rdi
  mov  rsi, statbuf->st_size
  mov  rdx, 0x07        ; PROT_EXEC (0x04) | PROT_WRITE (0x02) | PROT_READ (0x01)
  mov  rcx, 0x02        ; MAP_PRIVATE
  mov  r8, testfile
  xor  r9, r9
  mov  rax, sys_mmap
  syscall
  ; save result (testbuf) somewhere

  ; fstat(testelf, statbuf)
  mov  rdi, testelf
  mov  rsi, statbuf
  mov  rax, sys_fstat
  syscall

  ; t = mmap(0, statbuf->st_size, PROT_EXEC | PROT_WRITE | PROT_READ, MAP_PRIVATE, testelf, 0);
  xor  rdi, rdi
  mov  rsi, statbuf->st_size
  mov  rdx, 0x07        ; PROT_EXEC (0x04) | PROT_WRITE (0x02) | PROT_READ (0x01)
  mov  rcx, 0x02        ; MAP_PRIVATE
  mov  r8, testelf
  xor  r9, r9
  mov  rax, sys_mmap
  syscall
  ; save result (t) somewhere

  ; at this point we will need strcmp-like functionality
  ; since the string we're comparing for is small, we may be able to
  ; keep this relatively small
  ; like
  ; mov  rax, 0xbabababaabababab
  ; lea  rdi, [rsi]
  ; scasq
  ; jz match_found
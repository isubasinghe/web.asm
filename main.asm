  global _start
  section .text

  struc sockaddr_in
    .sin_family resw 1
    .sin_port resw 1
    .sin_address resd 1
    .sin_zero resq 1
  endstruc

  ;; rdi = address, rsi=length, rdx=val
  ;; We process this from rsi to 0
  ;; this is register allocation efficient
  ;; since we do not need a counter.
_memset:
  push rbx
loop:
  neg rsi                       ; could it get more hacky, convert rsi to negative number to be used in lea
  lea rax, [rsp + rsi]          ; load memory value to rax register
  mov [rax], rdx                ; set value at memory location to value in rdx
  neg rsi                       ; negate it back

  dec rsi                       ; decrement by 1
  jz end                        ; skip the jmp to the loop head and enter the function epilogue
  jmp loop                      ; continue loop
end:
  pop rbx
  ret

_read_int:
  push rbx                      ; prologue
  mov rdx, 0                    ; holds zero value used in memeset
  mov rdi, [rsp]                ; address held in rsp
  mov rsi, 20                   ; 20 bytes
  call _memset                  ; set to zero
  pop rbx                       ; epilogue
  ret

_exit_error:


_set_up_tcp:
  push rbx                      ; prologue
  mov rax, 41                   ; call sys_socket
  mov rdi, 0x02                 ; socket family
  mov rsi, 0x01                 ; socket type
  xor rdx, rdx                  ; clear rdx with 0x00
  syscall

  push rax                      ; store fd in stack
  mov rax, 49                   ; sys_bind
  pop rdi                       ; fd
  mov rbx, rdi                  ; rbx is saved across all calls
  mov rsi, sockaddr
  mov rdx, 16                   ; size of sin_address



  pop rbx                       ; epilogue
  ret

_start:
  push rbx
  mov rax, 1
  mov rdi, 1
  mov rsi, message
  mov rdx, 20
  syscall
  call _set_up_tcp
  mov rax, 60
  xor rdi, rdi
  syscall

  section .data
message:  db "Starting Web Server", 10
sockaddr:
  istruc sockaddr_in
  ;; AF_INET
  at sockaddr_in.sin_family, dw 2
  ;; 3030 in network order
  at sockaddr_in.sin_port, dw 0xD60B
  ;; INADDR_ANY
  at sockaddr_in.sin_address, dd 0
  ;; PADDING
  at sockaddr_in.sin_zero, dq 0
  iend

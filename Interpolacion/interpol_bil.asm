section .data
    input_file db "quadrant.img", 0
    output_file db "interpolated_image.img", 0

section .bss
    buffer resb 97*97
    output_buffer resb 385*385

section .text
    global _start

_start:
    ; Abrir imagen
    mov rax, 2
    mov rdi, input_file
    mov rsi, 0
    syscall
    mov rdi, rax

    ; Leer buffer
    mov rax, 0
    mov rsi, buffer
    mov rdx, 97*97
    syscall

    xor rcx, rcx
.loop_y:
    cmp rcx, 96
    jge .end
    xor rdx, rdx
.loop_x:
    cmp rdx, 96
    jge .next_row

    ; Índices base
    mov r8, rcx
    imul r8, 97
    add r8, rdx
    movzx r9,  byte [buffer + r8]         ; P1
    movzx r10, byte [buffer + r8 + 1]     ; P2
    movzx r11, byte [buffer + r8 + 97]    ; P3
    movzx r12, byte [buffer + r8 + 98]    ; P4

    ; Coordenadas base en imagen 385x385
    mov r13, rcx
    imul r13, 4
    mov r14, rdx
    imul r14, 4
    mov r15, r13
    imul r15, 385
    add r15, r14

    ; --- Primera fila ---
    mov [output_buffer + r15], r9b                    ; P1
    mov rax, r9
    imul rax, 3
    add rax, r10
    shr rax, 2
    mov [output_buffer + r15 + 1], al                 ; a
    mov rax, r10
    imul rax, 3
    add rax, r9
    shr rax, 2
    mov [output_buffer + r15 + 2], al                 ; b
    mov [output_buffer + r15 + 3], r10b               ; P2

    ; --- Segunda fila ---
    mov rbx, r13
    add rbx, 1
    imul rbx, 385
    add rbx, r14

    mov rax, r9
    imul rax, 3
    add rax, r11
    shr rax, 2
    mov [output_buffer + rbx], al                     ; h

    ; d = (3*a + c)/4
    mov rax, r9
    imul rax, 3
    add rax, r10
    shr rax, 2        ; a
    mov rsi, r11
    imul rsi, 3
    add rsi, r12
    shr rsi, 2        ; c
    mov rdi, rax
    imul rdi, 3
    add rdi, rsi
    shr rdi, 2
    mov [output_buffer + rbx + 1], dil                ; d

    ; e = (3*b + l)/4
    mov rax, r10
    imul rax, 3
    add rax, r9
    shr rax, 2        ; b
    mov rsi, r12
    imul rsi, 3
    add rsi, r11
    shr rsi, 2        ; l
    mov rdi, rax
    imul rdi, 3
    add rdi, rsi
    shr rdi, 2
    mov [output_buffer + rbx + 2], dil                ; e

    mov rax, r10
    imul rax, 3
    add rax, r12
    shr rax, 2
    mov [output_buffer + rbx + 3], al                 ; f

    ; --- Tercera fila ---
    mov rbx, r13
    add rbx, 2
    imul rbx, 385
    add rbx, r14

    mov rax, r11
    imul rax, 3
    add rax, r9
    shr rax, 2
    mov [output_buffer + rbx], al                     ; g

    mov rax, r9
    imul rax, 3
    add rax, r11
    shr rax, 2        ; h
    mov rsi, r11
    imul rsi, 3
    add rsi, r9
    shr rsi, 2        ; g
    mov rdi, rax
    imul rdi, 3
    add rdi, rsi
    shr rdi, 2
    mov [output_buffer + rbx + 1], dil                ; i

    mov rax, r12
    imul rax, 3
    add rax, r10
    shr rax, 2        ; k
    mov rsi, r10
    imul rsi, 3
    add rsi, r12
    shr rsi, 2        ; f
    mov rdi, rsi
    imul rdi, 3
    add rdi, rax
    shr rdi, 2
    mov [output_buffer + rbx + 2], dil                ; j

    mov rax, r12
    imul rax, 3
    add rax, r10
    shr rax, 2
    mov [output_buffer + rbx + 3], al                 ; k

    ; --- Cuarta fila ---
    mov rbx, r13
    add rbx, 3
    imul rbx, 385
    add rbx, r14
    mov [output_buffer + rbx], r11b                  ; P3

    mov rax, r11
    imul rax, 3
    add rax, r12
    shr rax, 2
    mov [output_buffer + rbx + 1], al                 ; c

    mov rax, r12
    imul rax, 3
    add rax, r11
    shr rax, 2
    mov [output_buffer + rbx + 2], al                 ; l

    mov [output_buffer + rbx + 3], r12b               ; P4

    inc rdx
    jmp .loop_x
.next_row:
    inc rcx
    jmp .loop_y

.end:
    ; Guardar resultado
    mov rax, 2
    mov rdi, output_file
    mov rsi, 0x42
    mov rdx, 0666o
    syscall
    mov rdi, rax

    mov rax, 1
    mov rsi, output_buffer
    mov rdx, 385*385
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall


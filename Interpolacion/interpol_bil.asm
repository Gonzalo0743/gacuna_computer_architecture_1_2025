section .data
    input_file db "quadrant.img", 0
    output_file db "interpolated_image.img", 0

section .bss
    buffer resb 97*97             ; Imagen original
    output_buffer resb 289*289    ; Imagen escalada

section .text
    global _start

_start:
    ; Abrir imagen original
    mov rax, 2
    mov rdi, input_file
    mov rsi, 0
    syscall
    mov rdi, rax

    ; Leer imagen original
    mov rax, 0
    mov rsi, buffer
    mov rdx, 97*97
    syscall

    ; Escalado bilineal
    xor rcx, rcx        ; y loop: 0 to 95
.loop_y:
    cmp rcx, 96
    jge .end_interp
    xor rdx, rdx        ; x loop: 0 to 95
.loop_x:
    cmp rdx, 96
    jge .next_row

    ; Cargar píxeles
    mov r8, rcx
    imul r8, 97
    add r8, rdx
    movzx r9,  byte [buffer + r8]         ; P1
    movzx r10, byte [buffer + r8 + 1]     ; P2
    movzx r11, byte [buffer + r8 + 97]    ; P3
    movzx r12, byte [buffer + r8 + 98]    ; P4

    ; Coordenadas base en nueva imagen
    mov r13, rcx
    imul r13, 3           ; y*3
    mov r14, rdx
    imul r14, 3           ; x*3

    ; Posición base en buffer nuevo
    mov r15, r13
    imul r15, 289
    add r15, r14

    ; P1
    mov [output_buffer + r15], r9b

    ; a = (P1*3 + P2)/4
    mov rax, r9
    imul rax, 3
    add rax, r10
    shr rax, 2
    mov [output_buffer + r15 + 1], al

    ; b = (P1 + P2*3)/4
    mov rax, r9
    add rax, r10
    imul r10, 2
    add rax, r10
    shr rax, 2
    mov [output_buffer + r15 + 2], al

    ; P2
    mov [output_buffer + r15 + 3], r10b

    ; Segunda fila
    mov rbx, r13
    add rbx, 1
    imul rbx, 289
    add rbx, r14

    ; h = (P1*3 + P3)/4
    mov rax, r9
    imul rax, 3
    add rax, r11
    shr rax, 2
    mov [output_buffer + rbx], al

    ; d = interpolación vertical entre a y c
    mov rax, r11
    imul rax, 3
    add rax, r12
    shr rax, 2          ; c
    mov rsi, rax        ; guardar c
    movzx rdi, byte [output_buffer + r15 + 1] ; a
    mov rax, rdi
    imul rax, 3
    add rax, rsi
    shr rax, 2
    mov [output_buffer + rbx + 1], al    ; d

    ; f = (P2*3 + P4)/4
    mov rax, r10
    imul rax, 3
    add rax, r12
    shr rax, 2
    mov [output_buffer + rbx + 3], al

    ; Tercera fila
    mov rsi, r13
    add rsi, 2
    imul rsi, 289
    add rsi, r14

    ; P3
    mov [output_buffer + rsi], r11b

    ; c = ya está en rsi (lo copiamos de antes)
    mov [output_buffer + rsi + 1], sil

    ; l = (P3 + P4*3)/4
    mov rax, r11
    add rax, r12
    imul r12, 2
    add rax, r12
    shr rax, 2
    mov [output_buffer + rsi + 2], al

    ; P4
    mov [output_buffer + rsi + 3], r12b


    inc rdx
    jmp .loop_x
.next_row:
    inc rcx
    jmp .loop_y

.end_interp:
    ; Guardar imagen interpolada
    mov rax, 2
    mov rdi, output_file
    mov rsi, 0x42
    mov rdx, 0666o
    syscall
    mov rdi, rax

    mov rax, 1
    mov rsi, output_buffer
    mov rdx, 289*289
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall


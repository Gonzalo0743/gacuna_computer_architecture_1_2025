section .data
    width  dd 97   ; Ancho del cuadrante
    height dd 97   ; Alto del cuadrante
    input_file db "quadrant.img", 0    ; Archivo de entrada (cuadrante)
    output_file db "interpolated_image.img", 0  ; Archivo de salida

section .bss
    buffer resb 97*97           ; Buffer para la imagen de entrada
    output_buffer resb 97*97    ; Buffer para la imagen interpolada

section .text
    global _start

_start:
    ; Abrir archivo de entrada (quadrant.img)
    mov rax, 2          ; syscall: open
    mov rdi, input_file ; nombre del archivo
    mov rsi, 0          ; modo de solo lectura
    syscall
    mov rdi, rax        ; Guardar descriptor de archivo

    ; Leer la imagen en buffer
    mov rax, 0          ; syscall: read
    mov rsi, buffer     ; destino del buffer
    mov rdx, 97*97      ; tamaño de la imagen (9409 bytes)
    syscall

    ; Aplicar interpolación bilineal (recorre 97×97)
    mov rcx, 1          ; y = 1 (evitar bordes)
.interp_loop_y:
    cmp rcx, 95         ; Hasta 95 (porque la imagen es 97×97)
    jge .end_interp
    mov rdx, 1          ; x = 1
.interp_loop_x:
    cmp rdx, 95
    jge .next_row
    
    ; Calcular posición en la imagen
    mov r8, rcx
    imul r8, 97
    add r8, rdx
    movzx r9, byte [buffer + r8 - 98] ; P1 (arriba izquierda)
    movzx r10, byte [buffer + r8 - 97] ; P2 (arriba derecha)
    movzx r11, byte [buffer + r8 - 1]  ; P3 (abajo izquierda)
    movzx r12, byte [buffer + r8]      ; P4 (abajo derecha)
    
    ; Promedio simple (mejorable con pesos)
    add r9, r10
    add r9, r11
    add r9, r12
    shr r9, 2  ; Dividir entre 4

    ; Guardar en output_buffer
    mov [output_buffer + r8], r9b

    inc rdx
    jmp .interp_loop_x
.next_row:
    inc rcx
    jmp .interp_loop_y
.end_interp:

    ; Guardar la imagen interpolada en el archivo de salida
    mov rax, 2           ; syscall: open
    mov rdi, output_file ; nombre del archivo
    mov rsi, 0x42        ; O_CREAT | O_WRONLY
    mov rdx, 0666o       ; permisos
    syscall
    mov rdi, rax         ; Guardar descriptor

    mov rax, 1          ; syscall: write
    mov rsi, output_buffer
    mov rdx, 97*97      ; Escribir 9409 bytes
    syscall
    
    ; Salir del programa
    mov rax, 60
    xor rdi, rdi
    syscall


section .bss
    buffer resb 390*390  ; Reservamos espacio para la imagen en memoria

section .data
    filename db "processed_image.img", 0  ; Nombre del archivo
    filedesc dq 0  ; Descriptor de archivo

section .text
    global _start
    extern printf

_start:
    ; Abrir el archivo en modo lectura
    mov rax, 2          ; syscall: open
    mov rdi, filename   ; Nombre del archivo
    mov rsi, 0          ; Modo de solo lectura
    syscall             ; Llamada al sistema
    mov [filedesc], rax ; Guardamos el descriptor

    ; Verificar si el archivo se abrió correctamente
    cmp rax, 0
    jl error            ; Si es menor que 0, hubo error

    ; Leer el archivo en el buffer
    mov rdi, [filedesc] ; Descriptor de archivo
    mov rax, 0          ; syscall: read
    mov rsi, buffer     ; Dirección del buffer
    mov rdx, 390*390    ; Cantidad de bytes a leer
    syscall             ; Llamada al sistema

    ; Cerrar el archivo
    mov rdi, [filedesc] ; Descriptor de archivo
    mov rax, 3          ; syscall: close
    syscall             ; Llamada al sistema

    ; Salir del programa
    mov rax, 60  ; syscall: exit
    xor rdi, rdi ; Código de salida 0
    syscall

error:
    mov rax, 60  ; syscall: exit
    mov rdi, 1   ; Código de error 1
    syscall


.model small
.stack 100h
.data
    menu db "Please choose from the following options:", 0Dh, 0Ah
         db "1. Prime number checker", 0Dh, 0Ah
         db "2. Caesar shift coder", 0Dh, 0Ah
         db "3. Exit", 0Dh, 0Ah
         db "Enter your choice: $"
    ask_for_prime db "Enter a number between 2 and 255 (end with '.'): $"
    ask_for_string db "Type a string (only small characters in English, end with '.'): $"
    ask_for_offset db "Enter a number between 2 and 9: $"
    msg_prime db "The number is prime. Here's yer triangle:", 0Dh, 0Ah, "$"
    msg_not_prime db "The number is not prime. Here's yer cube:", 0Dh, 0Ah, "$"  
    msg_encoded db "Encoded string: $"
    Number dw ?
    String1 db 100 dup(?)
    String2 db 100 dup(?)
    Offset db ?

.code
start:
    mov ax, @data
    mov ds, ax

menu_loop:
    ; Display menu
    mov dx, offset menu
    mov ah, 9
    int 21h

    ; Get user input
    mov ah, 1
    int 21h

    cmp al, '1'
    je prime_checker
    cmp al, '2'
    je caesar_shift
    cmp al, '3'
    jne menu_loop  ; If not 3, go back to menu
    jmp far ptr exit_program  ; Use far jump for option 3

prime_checker:
    call print_newline
    ; Get number input
    mov dx, offset ask_for_prime
    mov ah, 9
    int 21h

    xor bx, bx  ; Clear BX to store the number
    mov cx, 10  ; Multiplier for decimal conversion

;a loop that keeps asking for inputs until we recieve a "."
input_loop:
    mov ah, 1
    int 21h
    cmp al, '.'
    je end_input
    sub al, '0'
    xor ah, ah
    push ax
    mov ax, bx
    mul cx
    pop bx
    add bx, ax
    jmp input_loop

end_input:
    mov Number, bx

    ; Check if prime
    call Check
    call print_newline
    jmp menu_loop

caesar_shift:
    call print_newline
    ; Get string input
    mov dx, offset ask_for_string
    mov ah, 9
    int 21h

    mov si, offset String1
;asks for an input until a "*" is given
input_string:;
    mov ah, 1
    int 21h
    cmp al, '.'
    je end_string
    mov [si], al
    inc si
    jmp input_string

end_string:
    mov byte ptr [si], '$'  ; Null-terminate the string
    call print_newline

    ; Get our offset between 2 and 9
    mov dx, offset ask_for_offset
    mov ah, 9
    int 21h

    mov ah, 1
    int 21h
    sub al, '0'
    mov Offset, al

    ; Perform Caesar shift
    mov si, offset String1
    mov di, offset String2
shift_loop:
    mov al, [si]
    cmp al, '$'
    je end_shift
    sub al, 'a'
    add al, Offset
    cmp al, 26
    jl no_wrap
    sub al, 26
no_wrap:
    add al, 'a'
    mov [di], al
    inc si
    inc di
    jmp shift_loop

end_shift:
    mov byte ptr [di], '$'

    ; Print encoded string
    call print_newline
    mov dx, offset msg_encoded
    mov ah, 9
    int 21h
    mov dx, offset String2
    mov ah, 9
    int 21h
    call print_newline

    jmp menu_loop

exit_program:
    mov ah, 4Ch
    int 21h

Check proc
    mov ax, Number
    cmp ax, 2
    jb not_prime
    mov cx, 2
check_loop:
    mov dx, 0
    div cx
    cmp dx, 0
    je not_prime
    inc cx
    mov ax, Number
    cmp cx, ax
    jb check_loop
    ; If prime, print a right triangle
    mov dx, offset msg_prime;prints the is prime message
    mov ah, 9
    int 21h
    mov cx, Number
    call print_triangle
    call print_newline
    ret
not_prime:
    mov dx, offset msg_not_prime;prints the not prime message
    mov ah, 9
    int 21h
    mov cx, Number
    call print_cube
    call print_newline
    ret
Check endp

print_triangle proc
    mov bx, 1
triangle_loop:
    push cx
    mov cx, bx
star_loop:
    mov dl, '@';prints out @'s
    mov ah, 2
    int 21h
    mov dl, ' ';prints spaces between out @'s
    mov ah, 2
    int 21h
    loop star_loop
    call print_newline
    inc bx
    pop cx
    loop triangle_loop
    ret
print_triangle endp

print_cube proc
    call print_newline;if we dont print a new line the first line of * weirdly prints after Number
    mov bx, 1
cube_loop1:
    push cx
    mov cx, Number
cube_loop2:
    mov dl, '*';prints our *'s
    mov ah, 2
    int 21h
    mov dl, ' ';prints spaces between our *'s
    mov ah, 2
    int 21h
    loop cube_loop2
    call print_newline
    inc bx
    pop cx
    cmp bx, Number
    jle cube_loop1
    ret
print_cube endp

print_newline proc
    mov dl,0Ah
    mov ah,02h
    int 21h
    ret
print_newline endp

end start
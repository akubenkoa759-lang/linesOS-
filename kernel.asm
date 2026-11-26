[BITS 16]
[ORG 0x1000]

start:
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

desktop:
    mov ax, 0x0003
    int 0x10
    mov ax, 0x0600
    mov bh, 0x1F
    xor cx, cx
    mov dx, 0x184F
    int 0x10

    mov dh, 0
    mov dl, 0
    mov bl, 0x1F
    mov si, top_txt
    call print_at

    mov dh, 2
    mov dl, 2
    mov bl, 0x1E
    mov si, hint_txt
    call print_at

    mov byte [len], 0
    mov byte [buf], 0

cmd_loop:
    mov ax, 0x0600
    mov bh, 0x70
    mov cx, 0x1800
    mov dx, 0x184F
    int 0x10

    mov dh, 24
    mov dl, 1
    mov bl, 0x70
    mov si, prm_txt
    call print_at

    mov dh, 24
    mov dl, 10
    mov bl, 0x70
    mov si, buf
    call print_at
    mov al, '_'
    call put_g

    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je run_cmd
    cmp al, 0x08
    je bksp

    mov cl, [len]
    cmp cl, 40
    jge cmd_loop
    cmp al, 'A'
    jb .ok
    cmp al, 'Z'
    ja .ok
    add al, 32
.ok:
    xor bh, bh
    mov bl, cl
    mov [buf + bx], al
    inc byte [len]
    mov byte [buf + bx + 1], 0
    jmp cmd_loop

bksp:
    cmp byte [len], 0
    je cmd_loop
    dec byte [len]
    xor bh, bh
    mov bl, [len]
    mov byte [buf + bx], 0
    jmp cmd_loop

run_cmd:
    mov si, buf
    mov di, s_clock
    call cmp_s
    jc app_clock
    mov di, s_note
    call cmp_s
    jc app_note
    mov di, s_calc
    call cmp_s
    jc app_calc
    mov di, s_reb
    call cmp_s
    jc do_reb
    mov di, s_off
    call cmp_s
    jc do_off
    mov byte [len], 0
    mov byte [buf], 0
    jmp cmd_loop

do_reb

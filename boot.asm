[BITS 16]
[ORG 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl

    mov ah, 0x02
    mov al, 16
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    mov bx, 0x1000
    int 0x13
    jc disk_error

    jmp 0x0000:0x1000

disk_error:
    mov si, err_txt
    mov ah, 0x0E
.loop:
    lodsb
    or al, al
    jz $
    int 0x10
    jmp .loop

boot_drive db 0
err_txt    db 'Disk Read Error!', 0

times 510 - ($ - $$) db 0
dw 0xAA55

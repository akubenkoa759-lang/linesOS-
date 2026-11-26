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

do_reb:
    jmp 0xFFFF:0x0000

do_off:
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x0102
    int 0x15
    mov ax, 0x5307
    mov bx, 1
    mov cx, 3
    int 0x15
    cli
    hlt

; === CLOCK ===
app_clock:
    mov ch, 6
    mov cl, 20
    mov dh, 15
    mov dl, 59
    mov bh, 0x70
    call box
    mov dh, 6
    mov dl, 20
    mov bl, 0x1F
    mov si, t_clock
    call print_at
    mov dh, 8
    mov dl, 22
    mov bl, 0x70
    mov si, l_time
    call print_at
    mov dh, 10
    mov dl, 22
    mov bl, 0x70
    mov si, l_tmr
    call print_at
    mov dh, 12
    mov dl, 22
    mov bl, 0x70
    mov si, l_alm
    call print_at
    mov dh, 14
    mov dl, 22
    mov bl, 0x71
    mov si, l_clk_h
    call print_at

    mov ah, 0x02
    int 0x1A
    mov [ah_v], ch
    mov [am_v], cl

.cl:
    mov ah, 0x02
    int 0x1A
    mov [ch_v], ch
    mov [cm_v], cl
    mov [cs_v], dh

    mov dh, 8
    mov dl, 35
    call cur
    mov al, [ch_v]
    call bcd
    mov al, ':'
    call put_g
    mov al, [cm_v]
    call bcd
    mov al, ':'
    call put_g
    mov al, [cs_v]
    call bcd

    cmp byte [trun], 1
    jne .dt
    mov al, [cs_v]
    cmp al, [lsec]
    je .dt
    mov [lsec], al
    inc word [tsec]
.dt:
    mov dh, 10
    mov dl, 35
    call cur
    mov ax, [tsec]
    call dec_g
    mov si, s_sec
    mov bl, 0x70
    call print_r

    mov dh, 12
    mov dl, 35
    call cur
    mov al, [ah_v]
    call bcd
    mov al, ':'
    call put_g
    mov al, [am_v]
    call bcd

    cmp byte [aon], 1
    jne .ck
    mov al, [ch_v]
    cmp al, [ah_v]
    jne .ck
    mov al, [cm_v]
    cmp al, [am_v]
    jne .ck
    mov dh, 12
    mov dl, 42
    mov bl, 0x74
    mov si, s_ring
    call print_at

.ck:
    mov ah, 0x01
    int 0x16
    jz .cl
    mov ah, 0x00
    int 0x16
    cmp al, 27
    je desktop
    cmp al, 't'
    je .tg
    cmp al, 'r'
    je .rs
    cmp al, 'a'
    je .sa
    jmp .cl
.tg:
    xor byte [trun], 1
    mov al, [cs_v]
    mov [lsec], al
    jmp .cl
.rs:
    mov word [tsec], 0
    mov byte [trun], 0
    jmp .cl
.sa:
    mov byte [aon], 1
    mov al, [ch_v]
    mov [ah_v], al
    mov al, [cm_v]
    add al, 1
    daa
    mov [am_v], al
    jmp .cl

; === NOTEPAD ===
app_note:
    mov ch, 4
    mov cl, 12
    mov dh, 19
    mov dl, 67
    mov bh, 0x70
    call box
    mov ch, 5
    mov cl, 13
    mov dh, 18
    mov dl, 66
    mov bh, 0xF0
    call box
    mov dh, 4
    mov dl, 12
    mov bl, 0x1F
    mov si, t_note
    call print_at
    mov byte [nr], 5
    mov byte [nc], 13
.nl:
    mov dh, [nr]
    mov dl, [nc]
    call cur
    mov al, '_'
    call put_w
    mov ah, 0x00
    int 0x16
    cmp al, 27
    je desktop
    cmp al, 0x0D
    je .ne
    cmp al, 0x08
    je .nb
    cmp al, 32
    jb .nl
    mov dh, [nr]
    mov dl, [nc]
    call cur
    call put_w
    inc byte [nc]
    cmp byte [nc], 66
    jb .nl
.ne:
    mov dh, [nr]
    mov dl, [nc]
    call cur
    mov al, ' '
    call put_w
    cmp byte [nr], 18
    jge .nl
    inc byte [nr]
    mov byte [nc], 13
    jmp .nl
.nb:
    mov dh, [nr]
    mov dl, [nc]
    call cur
    mov al, ' '
    call put_w
    cmp byte [nc], 13
    jle .nl
    dec byte [nc]
    jmp .nl

; === CALC ===
app_calc:
    mov word [n1], 0
    mov word [n2], 0
    mov byte [op], 0
    mov byte [st], 0
.rc:
    mov ch, 6
    mov cl, 22
    mov dh, 15
    mov dl, 57
    mov bh, 0x70
    call box
    mov dh, 6
    mov dl, 22
    mov bl, 0x1F
    mov si, t_calc
    call print_at
    mov ch, 8
    mov cl, 24
    mov dh, 9
    mov dl, 55
    mov bh, 0x0A
    call box
    mov dh, 11
    mov dl, 24
    mov bl, 0x70
    mov si, c_h1
    call print_at
    mov dh, 13
    mov dl, 24
    mov bl, 0x71
    mov si, c_h2
    call print_at

    mov dh, 8
    mov dl, 25
    call cur
    mov ax, [n1]
    call dec_gr
    cmp byte [op], 0
    je .wk
    mov al, ' '
    call put_gr
    mov al, [op]
    call put_gr
    mov al, ' '
    call put_gr
    cmp byte [st], 1
    jb .wk
    mov ax, [n2]
    call dec_gr
.wk:
    mov ah, 0x00
    int 0x16
    cmp al, 27
    je desktop
    cmp al, 'c'
    je app_calc
    cmp al, '0'
    jb .co
    cmp al, '9'
    ja .co
    sub al, '0'
    xor ah, ah
    mov bx, ax
    cmp byte [st], 1
    je .d2
    mov ax, [n1]
    mov dx, 10
    mul dx
    add ax, bx
    mov [n1], ax
    jmp .rc
.d2:
    mov ax, [n2]
    mov dx, 10
    mul dx
    add ax, bx
    mov [n2], ax
    jmp .rc
.co:
    cmp al, '+'
    je .so
    cmp al, '-'
    je .so
    cmp al, '*'
    je .so
    cmp al, '/'
    je .so
    cmp al, 0x0D
    je .ev
    cmp al, '='
    je .ev
    jmp .wk
.so:
    mov [op], al
    mov byte [st], 1
    jmp .rc
.ev:
    mov ax, [n1]
    mov bx, [n2]
    mov cl, [op]
    cmp cl, '+'
    je .a
    cmp cl, '-'
    je .s
    cmp cl, '*'
    je .m
    cmp cl, '/'
    je .d
    jmp .wk
.a: add ax, bx
    jmp .sr
.s: sub ax, bx
    jmp .sr
.m: mul bx
    jmp .sr
.d: xor dx, dx
    div bx
.sr:
    mov [n1], ax
    mov word [n2], 0
    mov byte [op], 0
    mov byte [st], 0
    jmp .rc

; === UTILS ===
box: mov ax, 0x0600; int 0x10; ret
cur: mov ah, 0x02; xor bh, bh; int 0x10; ret
print_at: call cur
print_r: lodsb; or al, al; jz .d; mov ah, 0x09; mov bh, 0; mov cx, 1; int 0x10; inc dl; call cur; jmp print_r
.d: ret
put_g: mov bl, 0x70; jmp put_c
put_w: mov bl, 0xF0; jmp put_c
put_gr: mov bl, 0x0A
put_c: mov ah, 0x09; mov bh, 0; mov cx, 1; int 0x10; inc dl; call cur; ret
bcd: push ax; shr al, 4; add al, '0'; call put_g; pop ax; and al, 0x0F; add al, '0'; call put_g; ret
dec_g: mov cx, 0; mov bx, 10
.l1: xor dx, dx; div bx; push dx; inc cx; test ax, ax; jnz .l1
.p1: pop ax; add al, '0'; call put_g; loop .p1; ret
dec_gr: mov cx, 0; mov bx, 10
.l2: xor dx, dx; div bx; push dx; inc cx; test ax, ax; jnz .l2
.p2: pop ax; add al, '0'; call put_gr; loop .p2; ret
cmp_s: push si; push di
.l: mov al, [si]; mov bl, [di]; cmp al, bl; jne .n; or al, al; jz .e; inc si; inc di; jmp .l
.n: pop di; pop si; clc; ret
.e: pop di; pop si; stc; ret

top_txt  db ' linesOS v1.2 | Apps: clock, notepad, calc', 0
hint_txt db 'Commands: clock | notepad | calc | reboot | shutdown', 0
prm_txt  db 'linesOS>', 0
s_clock  db 'clock', 0
s_note   db 'notepad', 0
s_calc   db 'calc', 0
s_reb    db 'reboot', 0
s_off    db 'shutdown', 0
t_clock  db ' [ Clock / Timer / Alarm ] [ESC] ', 0
l_time   db 'Time: ', 0
l_tmr    db 'Timer:', 0
l_alm    db 'Alarm:', 0
l_clk_h  db '[T] Start/Stop [R] Reset [A] +1m', 0
s_sec    db 's  ', 0
s_ring   db 'ALARM!', 0
t_note   db ' [ Notepad ] [ESC: Exit] ', 0
t_calc   db ' [ Calculator ] [ESC] ', 0
c_h1     db 'Keys: [0-9] [+ - * /]', 0
c_h2     db '[Enter/=] Result [C] Clear', 0

ch_v db 0; cm_v db 0; cs_v db 0; ah_v db 0; am_v db 0; aon db 0; trun db 0; tsec dw 0; lsec db 0
nr db 5; nc db 13; n1 dw 0; n2 dw 0; op db 0; st db 0; len db 0; buf times 45 db 0

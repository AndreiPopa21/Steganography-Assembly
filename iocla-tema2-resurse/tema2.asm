%include "/home/student/Desktop/Prov/Tema2/iocla-tema2-resurse/include/io.inc"

extern atoi
extern printf
extern exit
extern malloc
extern free

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1
    img_backup: resd 1
    img_dim:    resd 1
    blur_sum:   resd 1
    morse_off:  resd 1
    morse_msg:  resd 1
    rand_msg:   resd 1
    brute_line: resd 1
    brute_key:  resd 1
    lsb_msg:    resd 1
    lsb_msg_len:resd 1
    lsb_start:  resd 1
    lsb_end:    resd 1

section .text
global main
main:
    mov ebp, esp; for correct debugging
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    ;PRINT_UDEC 4,eax
    ;NEWLINE
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
   
    mov [task], eax
    
    
    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done


solve_task1:
    ; TODO Task1
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp,4
    
    xor ecx,ecx
    xor edx,edx
    
    mov dx,ax
    push edx
    shr eax,16
    mov cx,ax
    push ecx
    
    push dword[img_backup]
    call print_task1
    add esp,12
    jmp done
    
    
solve_task2:
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp,4
    
    xor ecx,ecx
    xor edx,edx
    
    mov dx,ax
    push edx
    shr eax,16
    mov cx,ax
    push ecx
    
    push dword[img_backup]
    call encrypt_msg_task2
    add esp,12    
      
    push dword[img_height]
    push dword[img_width]
    push dword[img_backup]
    call print_image
    add esp,12   
    jmp done


solve_task3:
    ; TODO Task3
    mov eax,[ebp+12]
    mov ecx,[eax+12]
    
    mov eax,[ebp+12]
    push ecx ; save ecx on stack
    push dword[eax+16] ; decode the byte-id
    call atoi ; atoi on byte-ide
    add esp,4
    pop ecx ; restore ecx from stack

    push eax ; arg3 - byte-id
    push ecx ; arg2 - the message
    push dword[img] ; arg1 - the image
    call morse_encrypt
    add esp,12  
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp,12
    
    jmp done
    
    
solve_task4:
    mov eax,[ebp+12]
    mov ebx,[eax+12] ; mesajul
    push dword[eax+16] ; byte-id, dar nu in format numeric
    call atoi
    add esp,4
    
    mov ecx,eax ; byte-id, in format numeric
    push ecx
    push ebx
    push dword[img]
    call lsb_encode
    add esp,12  
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp,12    
    jmp done
    
    
solve_task5:
    ; TODO Task5
    mov eax,[ebp+12]
    push dword[eax+12]
    call atoi
    add esp,4
    
    push eax
    push dword[img]
    call lsb_decode
    add esp,8   
    jmp done
    
    
solve_task6:
    call blur
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
morse_encrypt:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; imaginea originala
    mov ebx,[ebp+12] ; mesajul
    mov edx,[ebp+16] ; byte-id
                     ; edx este un contor care tine evidenta pixelului
                     ; curent din poza. nu se reseteaza
    
    mov edi,eax ; se salveaza imaginea in edi
    
    xor ecx,ecx ; cu ecx se parcurge fiecare caracter din mesaj
morse_char:   
    cmp byte[ebx+ecx],0 ; se verifica daca nu s-a terminat mesajul
    jz end_morse_char
  
    xor eax,eax ; se curata eax, se stocheaza in acesta un caracter
    mov al,byte[ebx+ecx]
    
    push eax ; arg2 - caracterul din mesaj
    push edi ; arg1 - imaginea
    call morse_encode_one_char
    add esp,8
    
    add ecx,1
    jmp morse_char
    
end_morse_char:  
    sub edx,1 ; se suprascrie ultimul space cu valoarea 0
    mov dword[edi+4*edx],0
    
    leave
    ret

; ................................................................
morse_encode_one_char:
    push ebp
    mov ebp,esp
    
    ; edx se incrementeaza constant, dar nu se reseteaza
    
    push ebx
    
    mov ebx,[ebp+8] ; the image
    mov eax,[ebp+12] ; the char to be encoded
    
    cmp al,'A'
    jz a_char
    cmp al,'B'
    jz b_char
    cmp al,'C'
    jz c_char
    cmp al,'D'
    jz d_char
    cmp al,'E'
    jz e_char
    cmp al,'F'
    jz f_char
    cmp al,'G'
    jz g_char
    cmp al,'H'
    jz h_char
    cmp al,'I'
    jz i_char
    cmp al,'J'
    jz j_char
    cmp al,'K'
    jz k_char
    cmp al,'L'
    jz l_char
    cmp al,'M'
    jz m_char
    cmp al,'N'
    jz n_char
    cmp al,'O'
    jz o_char
    cmp al,'P'
    jz p_char
    cmp al,'Q'
    jz q_char
    cmp al,'R'
    jz r_char
    cmp al,'S'
    jz s_char
    cmp al,'T'
    jz t_char
    cmp al,'U'
    jz u_char
    cmp al,'V'
    jz v_char
    cmp al,'X'
    jz x_char
    cmp al,'Y'
    jz y_char
    cmp al,'W'
    jz w_char
    cmp al,'Z'
    jz z_char
    cmp al,','
    jz comma_char
    cmp al,'1'
    jz one_char
    cmp al,'2'
    jz two_char
    cmp al,'3'
    jz three_char
    cmp al,'4'
    jz four_char
    cmp al,'5'
    jz five_char
    cmp al,'6'
    jz six_char
    cmp al,'7'
    jz seven_char
    cmp al,'8'
    jz eight_char
    cmp al,'9'
    jz nine_char
    cmp al,'0'
    jz zero_char
    
    ; se scrie pentru fiecare litera codul corespunzator in . sau -
    ; se concateneaza la final mereu caracterul SPACE
    
a_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
b_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
c_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
d_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
e_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],32
    add edx,2
    jmp end_morse_conv
f_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
g_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
h_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
i_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
j_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
k_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
l_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
m_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
n_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
o_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
p_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
q_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
r_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
s_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
t_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],32
    add edx,2
    jmp end_morse_conv
u_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
v_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
x_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
w_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
y_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
z_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv  
comma_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],45
    mov dword[ebx+4*edx+24],32
    add edx,7
    jmp end_morse_conv
one_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
two_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
three_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
four_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
five_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
six_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
seven_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
eight_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
nine_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
zero_char:  
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
 
end_morse_conv:   
    pop ebx
    leave
    ret


; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lsb_decode:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; imaginea originala
    mov edx,[ebp+12] ; byte-id
    
    sub edx,1 ; se obtine indexul corect de start
    
    ; in continuare, se construiesc caracterele bit cu bit
    ; in ebx se va construi codul ASCII al fiecarui char
    mov ecx,edx ; se reseteaza iteratorul 
lsb_decode_chars:
    xor ebx,ebx 
    xor edx,edx
build_ascii:
    cmp edx,8 ; se parcurg grupuri de cate 8 pixeli pentru un caracter
    jz end_build_ascii
    shl ebx,1
    mov edi,[eax+4*ecx]
    add ecx,1
    test edi,1 ; se foloseste o masca de biti pentru a vedea ultimul bit
    jnz build_put_1
    jmp build_put_0
build_put_1:
    add ebx,1
build_put_0: 
    add edx,1   
    jmp build_ascii 
end_build_ascii:
    test ebx,ebx
    jz end_lsb_decode_chars
    ; in ebx exista caracterul construit bit cu bit
    PRINT_CHAR ebx ; se afiseaza in stdout
    jmp lsb_decode_chars

end_lsb_decode_chars:
    NEWLINE
    leave
    ret    
            
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lsb_encode:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; imaginea originala
    mov ebx,[ebp+12] ; mesajul
    mov edx,[ebp+16] ; byte id
    
    sub edx,1 ; se obtine indexul pixelului de start 
    mov ecx,edx
    
    push ecx ; se salveaza indexul de start
    
    xor ecx,ecx
strlen_lsb:
    add ecx,1
    cmp byte[ebx+ecx],0
    jnz strlen_lsb
  
    mov esi,ecx ; se obtine in ecx dimensiunea mesajului   
    pop ecx ; se da restore la indexul de start
    
    mov edx,esi
    imul edx,8 ; un caracter e un octet
               ; pentru cate caracter e nevoie de 8 pixeli
    add edx,ecx ; se adauga offsetul dat de indexul de start
    
    mov dword[lsb_msg_len],esi ; dimensiunea mesajului
    mov dword[lsb_start],ecx ; indexul pixelului de start
    mov dword[lsb_end],edx ; indexul pixelului de end
    mov dword[lsb_msg],ebx ; mesajul original
    mov esi,eax ; se salveaza imaginea in esi
    
    mov ecx,[lsb_start]
    xor edx,edx ; edx este iteratorul de caractere din mesaj
    
lsb_chars:
    cmp edx,[lsb_msg_len] ; se parcurge fiecare caracter din mesaj
    jz lsb_chars_end
    
    xor eax,eax
    mov ebx,[lsb_msg]
    mov al,byte[ebx+edx]
    push eax
    call get_mirror_binary
    add esp,4 ; eax are valoarea binara in oglinda
    
    push edx ; se salveaza edx pe stiva
    
    xor edx,edx ; se itereaza cu edx prin bitii octetului rezultat
lsb_bits:
    cmp edx,8
    jz end_bits
    test al,1
    jz lsb_bits_even
    jmp lsb_bits_odd
lsb_bits_even: ; se pune 0
    mov edi,[esi+4*ecx]
    test edi,1
    jz skip_put_0
    sub edi,1
    mov [esi+4*ecx],edi
skip_put_0:    
    add ecx,1
    add edx,1
    shr eax,1
    jmp lsb_bits
lsb_bits_odd: ; se pune 1
    mov edi,[esi+4*ecx]
    test edi,1
    jnz skip_put_1
    add edi,1
    mov [esi+4*ecx],edi   
skip_put_1:
    add ecx,1
    add edx,1
    shr eax,1
    jmp lsb_bits
    
end_bits: 
    pop edx ; se restaureaza vechea functiei a iteratorului edx
    add edx,1
    jmp lsb_chars    
     
lsb_chars_end:
    
    
    ; se cripteaza si terminatorul de sir pe 8 pixeli
    xor edx,edx 
lsb_terminator:
    cmp edx,8
    jz lsb_terminator_end   
    mov edi,[esi+4*ecx]
    test edi,1
    jz skip_terminator
    sub edi,1
    mov [esi+4*ecx],edi
skip_terminator:    
    add ecx,1
    add edx,1
    jmp lsb_terminator
     
lsb_terminator_end:       
    leave
    ret
  
; ......................................................
get_mirror_binary:
    push ebp
    mov ebp,esp
    
    ; se salveaza registrii pe stiva
    push ebx
    push ecx
    push edx
    
    mov ebx,[ebp+8] ; caracterul ASCII
       
    xor eax,eax
    xor ecx,ecx
convert_bin:
    test bl,1
    jz conv_even
    jmp conv_odd
conv_even:
    shl eax,1
    shr ebx,1
    add ecx,1
    cmp ecx,8
    jz end_mirror_binary
    jmp convert_bin
conv_odd:
    shl eax,1
    add eax,1
    shr ebx,1
    add ecx,1
    cmp ecx,8
    jz end_mirror_binary
    jmp convert_bin
    
end_mirror_binary:    
    ; se restaureaza vechii registrii
    pop edx
    pop ecx
    pop ebx    
    leave
    ret

; +++++++++++++++++++++++++++++++++++++++++++++++++++++
encrypt_msg_task2:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; mesajul decriptat
    mov ebx,[ebp+12] ; cheia veche 
    mov edx,[ebp+16] ; linia veche
    
    add edx,1 ; raspunsul e criptat pe urmatoarea linie
    push edx ; se salveaza noua linie si mesajul pe stiva
    push eax
    
    ; se obtine in ebx cheia noua de criptare
    imul ebx,2
    add ebx,3
    xor edx,edx
    mov eax,ebx
    mov ecx,5
    div ecx
    sub eax,4
    mov ebx,eax
    
    pop eax ; se restaureaza adresa imaginii
    pop edx ; se restaureaza vechea linie
    
    
    push edx
    push eax
    call encrypt_reply
    add esp,8
    
    push ebx
    push eax
    call encrypt_with_new_key
    add esp,8 
    
    leave
    ret

; =====================================================
encrypt_with_new_key:
    push ebp
    mov ebp,esp
    
    ; se salveaza registrii pe stiva
    push eax
    push ebx
    push ecx
    push edx
    
    mov eax,[ebp+8] ; poza originala decriptata
    mov ebx,[ebp+12] ; cheia noua de criptare
    
    ; se calculeaza dimensiunea imaginii
    mov ecx,[img_height]
    mov edx,[img_width]
    imul edx,ecx
    
    xor ecx,ecx
encrypt:
    mov esi,[eax+4*ecx]
    xor esi,ebx ; se xoreaza fiecare pixel dupa noua cheie
    mov [eax+4*ecx],esi
    add ecx,1
    cmp ecx,edx
    jnz encrypt
       
    ; se restaureaza vechii registrii de pe stiva
    pop edx
    pop ecx
    pop ebx
    pop eax    
    leave
    ret
    
; ...........................................................
encrypt_reply:
    push ebp
    mov ebp,esp
    
    push eax
    push ebx
    push ecx
    push edx
     
    mov eax,[ebp+8] ; imaginea originala decriptata
    mov edx,[ebp+12] ; linia noua
    
    ; se calculeaza in functie de noua linie, pixelul de start
    mov ecx,edx
    mov ebx,[img_width]
    imul ecx,ebx
    
    mov dword[eax+4*ecx],'C'
    mov dword[eax+4*ecx+4],39
    mov dword[eax+4*ecx+8],'e'
    mov dword[eax+4*ecx+12],'s'
    mov dword[eax+4*ecx+16],'t'
    mov dword[eax+4*ecx+20],' '
    mov dword[eax+4*ecx+24],'u'
    mov dword[eax+4*ecx+28],'n'
    mov dword[eax+4*ecx+32],' '
    mov dword[eax+4*ecx+36],'p'
    mov dword[eax+4*ecx+40],'r'
    mov dword[eax+4*ecx+44],'o'
    mov dword[eax+4*ecx+48],'v'
    mov dword[eax+4*ecx+52],'e'
    mov dword[eax+4*ecx+56],'r'
    mov dword[eax+4*ecx+60],'b'
    mov dword[eax+4*ecx+64],'e'
    mov dword[eax+4*ecx+68],' '
    mov dword[eax+4*ecx+72],'f'
    mov dword[eax+4*ecx+76],'r'
    mov dword[eax+4*ecx+80],'a'
    mov dword[eax+4*ecx+84],'n'
    mov dword[eax+4*ecx+88],'c'
    mov dword[eax+4*ecx+92],'a'
    mov dword[eax+4*ecx+96],'i'
    mov dword[eax+4*ecx+100],'s'
    mov dword[eax+4*ecx+104],'.'
    mov dword[eax+4*ecx+108],0    
    
    ; se restaureaza vechii registrii
    pop edx
    pop ecx
    pop ebx
    pop eax    
    leave
    ret


; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bruteforce_singlebyte_xor:
    push ebp
    mov ebp,esp
    ; get the image
    mov eax,[ebp+8]
    mov ecx,[img_height]
    mov edx,[img_width]
    imul ecx,edx
    
    ; save the img dimension
    push ecx
    ; save the original img
    push eax
    xor ebx,ebx
    mov ebx,ecx
    imul ebx,4
    
    push ebx
    call malloc
    ; get backup location
    mov [img_backup],eax
    add esp,4
    ; restore original img
    pop eax
    ; restore the img dimension
    pop ecx   
    
    ; start with key from 0
    xor esi,esi   
brute:
    
    ; with every key, we make a new copy  
    push ecx
    push dword[img_backup]
    push dword[img]
    call backup_img
    add esp,12
   
     ; we apply XOR with key on that copy    
    push ecx
    push esi
    push dword[img_backup]
    call xor_img_with_key
    add esp,12   
    
    ; check for reviert
    push ecx
    push dword[img_backup]
    call check_for_revient
    add esp,8
    
    ; if we found the key, break bruteforce
    cmp eax,-1
    jnz found_right_key
    
    ; increment key and check its size
    add esi,1
    cmp esi,256
    jl brute
 
found_right_key:
     mov [brute_line],eax
     mov [brute_key],esi
     mov ebx,[img_width]
     imul eax,ebx
     mov edx,[img_backup]
     
     xor eax,eax
     xor ecx,ecx
     
     mov ecx,[brute_key]
     add eax,ecx
     shl eax,16
     xor ecx,ecx
     mov ecx,[brute_line]
     add eax,ecx
       
    leave
    ret
; ====================================================
print_task1:
    push ebp
    mov ebp,esp
    
    push eax
    push ebx
    push ecx
    push edx
    
    ; the xor-ed image
    mov eax,[ebp+8]
    ; the key
    mov ebx,[ebp+12]
    ; the original line
    mov edx,[ebp+16]
      
    push ebx
       
    mov ecx,[img_width]
    imul ecx,edx
    
print_mesg_task1:
    mov ebx,[eax+4*ecx]
    cmp ebx,0
    jz end_print_mesg_task1
    PRINT_CHAR ebx
    add ecx,1
    jmp print_mesg_task1
    
end_print_mesg_task1:
    pop ebx
    NEWLINE
    PRINT_UDEC 4,ebx
    NEWLINE
    PRINT_UDEC 4,edx
    NEWLINE
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    leave
    ret
; ====================================================
check_for_revient:
    push ebp
    mov ebp,esp
    
    push ebx
    push ecx
    push edx
      
    mov eax,[ebp+8]
    mov edx,[ebp+12]
    
    xor ecx,ecx
    sub edx,10
search_rev:
    mov ebx,[eax+4*ecx]
    cmp ebx,'r'
    jnz not_revient
    mov ebx,[eax+4*ecx+4]
    cmp ebx,'e'
    jnz not_revient
    mov ebx,[eax+4*ecx+8]
    cmp ebx,'v'
    jnz not_revient
    mov ebx,[eax+4*ecx+12]
    cmp ebx,'i'
    jnz not_revient
    mov ebx,[eax+4*ecx+16]
    cmp ebx,'e'
    jnz not_revient
    mov ebx,[eax+4*ecx+20]
    cmp ebx,'n'
    jnz not_revient
    mov ebx,[eax+4*ecx+24]
    cmp ebx,'t'
    jnz not_revient
    ; after revient is found  
    xor edx,edx
    mov eax,ecx
    mov ebx,[img_width]
    div ebx
    jmp end_check_for_revient
not_revient:
    add ecx,1
    cmp ecx,edx
    jnz search_rev
    mov eax,-1
end_check_for_revient:    
    pop edx
    pop ecx
    pop ebx
   
    leave
    ret

; ====================================================
xor_img_with_key:
    push ebp
    mov ebp,esp
    
    push eax
    push ebx
    push ecx
    push edx
        
    ; first arg - the image address
    mov eax,[ebp+8]
    ; second arg - the key
    mov ebx,[ebp+12]
    ; third arg - the img dimension
    mov edx,[ebp+16]
  
    xor ecx,ecx
xor_img:
    push edx
    mov edx,[eax+4*ecx]
    xor edx,ebx
   
    mov [eax+4*ecx],edx
        
    add ecx,1
    pop edx
    cmp ecx,edx
    jnz xor_img

    pop edx
    pop ecx
    pop ebx
    pop eax
       
    leave 
    ret
    
; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

blur:
    push ebp
    mov ebp,esp
   
    
    mov eax,[img_width]
    mov ebx,[img_height]
    imul eax,ebx
    mov [img_dim],eax
    
    ; compute length of image
    mov ecx,[img_dim]
    imul ecx,4
    
    ; allocated memory dynamically for backup
    push ecx,
    call malloc
    add esp,4
    mov [img_backup],eax
    
    ; copied image to backup  
    push dword[img_dim]
    push dword[img_backup]
    push dword[img]
    call backup_img
    add esp,12
    
    push dword[img_backup]
    push dword[img]
    call blur_values
    add esp,8
    
    leave 
    ret
 
; ===============================================
backup_img:
    push ebp
    mov ebp,esp
    
    push eax
    push ebx
    push ecx
    push edx
   
    ; adresa catre vectorul original
    mov eax,[ebp+8]
    ; adresa catre vectorul backup
    mov ebx,[ebp+12]
    ; dimensiunea vectorul
    mov ecx,[ebp+16]
    
    
back_proc:
    mov edx,[eax+4*ecx-4]
    mov [ebx+4*ecx-4],edx    
    sub ecx,1   
    cmp ecx,0
    jnz back_proc
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    leave
    ret
; ================================================   
blur_values:
    push ebp
    mov ebp,esp
    push eax
    push ebx
    push ecx
    mov eax,[ebp+8]
    mov ebx,[ebp+12]
    mov ecx,[img_height]
    mov edx,[img_width]
    
    
    sub ecx,1  
iter_height:
    sub ecx,1
    cmp ecx,0
    jz blur_end
    mov edx,[img_width]
    sub edx,2
iter_width:   
    mov dword[blur_sum],0   
    ; =======================================
    push edx
    push ecx
    push ebx
    push eax
  
    call get_current
    add [blur_sum],eax
  
    pop eax
    pop ebx
    pop ecx
    pop edx
    ; =======================================
    push edx
    push ecx
    push ebx
    push eax
    
    call get_left
    add [blur_sum],eax
    
    pop eax
    pop ebx
    pop ecx
    pop edx
    ; =======================================
    push edx
    push ecx
    push ebx
    push eax
    
    call get_right
    add [blur_sum],eax
    
    pop eax
    pop ebx
    pop ecx
    pop edx
    ; ========================================
    push edx
    push ecx
    push ebx
    push eax
    
    call get_top
    add [blur_sum],eax
    
    pop eax
    pop ebx
    pop ecx
    pop edx
    ; ========================================
    push edx
    push ecx
    push ebx
    push eax
    
    call get_bottom
    add [blur_sum],eax
    
    pop eax
    pop ebx
    pop ecx
    pop edx
    ; ========================================   
    push eax
    push edx
    push ecx
    mov eax,[blur_sum]
    mov ecx,5
    xor edx,edx
    div ecx
    mov [blur_sum],eax
      
    pop ecx
    pop edx
    pop eax
    ; ========================================
    push edx
    push ecx
    push ebx
    push eax
    
    push edx
    push ecx
   
    call blur_current_value
    add esp,8
    
    pop eax
    pop ebx
    pop ecx
    pop edx
    
    sub edx,1  
    cmp edx,0
    jz iter_height
    jmp iter_width
    
blur_end:
    mov eax,[img]
    mov ebx,[img_width]
    mov ecx,[img_height]
    push ecx
    push ebx
    push eax
    call print_image
    add esp,12
    
    mov eax,[img_backup]
    push eax
    call free
    add esp,4

    pop ecx
    pop ebx
    pop eax
    leave
    ret

; ===================================================
get_current:
    push ebp
    mov ebp,esp
    
    mov ebx,[ebp+12]
    mov ecx,[ebp+16]
    mov edx,[ebp+20]
    
    push ebx
    
    mov eax,[img_width]
    imul eax,4
    imul eax,ecx 
    mov ebx,edx
    imul ebx,4
    add eax,ebx
    mov ecx,eax
    
    pop ebx
    mov eax,[ebx+ecx]
     
    leave
    ret
; ====================================================
get_left:
    push ebp
    mov ebp,esp
    
    mov ebx,[ebp+12]
    mov ecx,[ebp+16]
    mov edx,[ebp+20]
    
    push ebx
    
    mov eax,[img_width]
    imul eax,4
    imul eax,ecx 
    mov ebx,edx
    imul ebx,4
    add eax,ebx
    mov ecx,eax
    sub ecx,4
    
    pop ebx
    mov eax,[ebx+ecx]
     
    leave
    ret
; ====================================================
get_right:
    push ebp
    mov ebp,esp
    
    mov ebx,[ebp+12]
    mov ecx,[ebp+16]
    mov edx,[ebp+20]
    
    push ebx
    
    mov eax,[img_width]
    imul eax,4
    imul eax,ecx 
    mov ebx,edx
    imul ebx,4
    add eax,ebx
    mov ecx,eax
    add ecx,4
    
    pop ebx
    mov eax,[ebx+ecx]
     
    leave
    ret
; ===================================================
get_top:
    push ebp
    mov ebp,esp
    
    mov ebx,[ebp+12]
    mov ecx,[ebp+16]
    mov edx,[ebp+20]
    
    push ebx
    
    mov eax,[img_width]
    sub ecx,1
    imul eax,4
    imul eax,ecx 
    mov ebx,edx
    imul ebx,4
    add eax,ebx
    mov ecx,eax
    
    pop ebx
    mov eax,[ebx+ecx]
    
    leave
    ret
; ====================================================
get_bottom:
    push ebp
    mov ebp,esp
    
    mov ebx,[ebp+12]
    mov ecx,[ebp+16]
    mov edx,[ebp+20]
    
    push ebx
    
    mov eax,[img_width]
    add ecx,1
    imul eax,4
    imul eax,ecx 
    mov ebx,edx
    imul ebx,4
    add eax,ebx
    mov ecx,eax
    
    pop ebx
    mov eax,[ebx+ecx]
     
    leave
    ret
; ====================================================
blur_current_value:
    push ebp
    mov ebp,esp

    mov ecx,[ebp+8]
    mov edx,[ebp+12]
    
    mov eax,[img_width]
    imul eax,4
    imul eax,ecx 
    mov ebx,edx
    imul ebx,4
    add eax,ebx
    mov ecx,eax
    
    mov eax,[img]
    mov edx,[blur_sum]
    mov [eax+ecx],edx
    
    leave
    ret

    
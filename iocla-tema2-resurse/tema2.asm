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

section .text
global main
main:
    mov ebp, esp; for correct debugging
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    PRINT_UDEC 4,eax
    NEWLINE
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
    ;mov ecx,[eax+8]
    ;xor edx,edx
    ;mov dl,byte[ecx]
    ;PRINT_UDEC 4,edx
    ;NEWLINE
    call atoi
    add esp, 4
   ; PRINT_UDEC 4,eax
   ; NEWLINE
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
    jmp done
solve_task2:
    ; TODO Task2
    jmp done
solve_task3:
    ; TODO Task3
    mov eax,[ebp+12]
    mov ecx,[eax+12]
    mov [morse_msg],ecx
    
    mov eax,[ebp+12]
    push dword[eax+16]
    call atoi
    mov [morse_off],eax
    
    push eax
    push ecx
    push dword[img]
    call morse_encrypt
    add esp,12
    
    jmp done
solve_task4:
    ; TODO Task4
    jmp done
solve_task5:
    ; TODO Task5
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

; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
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
    PRINT_UDEC 4,ebx
    NEWLINE
    push ebx
    call malloc
    ; get backup location
    mov [img_backup],eax
    add esp,4
    ; restore original img
    pop eax
    ; restore the img dimension
    pop ecx   
    ; set the key start from 0
    xor esi,esi   
brute:
    
    ; with every key, we make a new copy  
    push ecx
    push dword[img_backup]
    push dword[img]
    call backup_img
    add esp,12

    
    push ecx
    push esi
    push dword[img_backup]
    call xor_img_with_key
    add esp,12
   
  
    ; increment key and check its size
    add esi,1
    cmp esi,256
    jl brute
    
    ; how to print the string
    ;mov eax,4
    ;push eax
    ;call malloc
    ;mov [rand_msg],eax
    ;add esp,4
    ;mov eax,[rand_msg]
    
    ;mov byte[eax],'a'  
    ;mov byte[eax+1],'n'
    ;mov byte[eax+2],'a'
    ;mov byte[eax+3],0 
    ;mov ecx,1
    ;PRINT_CHAR [eax+ecx]
    
    leave
    ret
; ====================================================
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
    
    ; push dword[img_height]
    ; push dword[img_width]
    ; push dword[img_backup]
    ; call print_image
    ; add esp,12
    
   
    
    
    pop edx
    pop ecx
    pop ebx
    pop eax
   
    
    leave 
    ret



; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
morse_encrypt:
    push ebp
    mov ebp,esp
    leave
    ret










; =================================================
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

    
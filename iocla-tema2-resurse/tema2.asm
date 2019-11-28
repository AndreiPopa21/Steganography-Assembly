%include "/home/student/Desktop/Prov/Tema2/iocla-tema2-resurse/include/io.inc"

extern atoi
extern printf
extern exit
extern malloc

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
    i_cont:     resd 1
    j_cont:     resd 1

section .text
global main
main:
    mov ebp, esp; for correct debugging
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
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
    jmp done
solve_task2:
    ; TODO Task2
    jmp done
solve_task3:
    ; TODO Task3
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

; =================================================

blur:
    push ebp
    mov ebp,esp
   
    
    mov eax,[img_width]
    mov ebx,[img_height]
    imul eax,ebx
    mov [img_dim],eax
    
    mov ecx,[img_dim]
    imul ecx,4
    PRINT_UDEC 4,ecx
    NEWLINE
    
    push ecx,
    call malloc
    add esp,4
    mov [img_backup],eax
    
    ; adresele img si img_backup trebuie dublu-deref
  
    ;push eax
    ;push ebx
    ;push ecx
    ;push edx
    ;mov ecx,[img_dim]   
    ;mov ebx,[img_backup]
    ;mov eax,[img]
    ;push ecx
    ;push ebx
    ;push eax
    push dword[img_dim]
    push dword[img_backup]
    push dword[img]
    call backup_img
    add esp,12
    ;pop edx
    ;pop ecx
    ;pop ebx
    ;pop eax
    
    ;mov eax,[img_backup]
    ;PRINT_UDEC 4,[eax+4]
    ;NEWLINE
    
    push dword[img_dim]
    push dword[img_backup]
    call show_image
    add esp,8
    
    leave 
    ret
 
; ===============================================
       
log_udec:
    push ebp
    mov ebp,esp
    mov eax,[esp+8]
    PRINT_UDEC 4,eax
    NEWLINE
    leave
    ret

; ================================================

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
    mov edx,[eax+4*ecx-4]
    PRINT_UDEC 4,edx
     NEWLINE
       
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

show_image:
    push ebp
    mov ebp,esp
    push eax
    push ecx
    push edx
    mov eax,[ebp+8]
    mov ecx,[ebp+12]

display:
    mov edx, [eax+ecx*4-4]
    PRINT_UDEC 4,edx
    NEWLINE
    sub ecx,1
    cmp ecx,0
    jnz display
    
    pop edx
    pop ecx
    pop eax
    
    leave
    ret

; ================================================
 

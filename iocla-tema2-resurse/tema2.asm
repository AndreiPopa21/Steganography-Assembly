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
    
    ; compute length of image
    mov ecx,[img_dim]
    imul ecx,4
    ;PRINT_UDEC 4,ecx
    ;NEWLINE
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
    
    ;push dword[img_dim]
    ;push dword[img_backup]
    ;call show_image
    ;add esp,8
    push dword[img_backup]
    push dword[img]
    call blur_values
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
    ;mov edx,[eax+4*ecx-4]
    ;PRINT_UDEC 4,edx
    ;NEWLINE
       
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

;show_image:
;    push ebp
;    mov ebp,esp
;    push eax
;    push ecx
;    push edx
;    mov eax,[ebp+8]
;    mov ecx,[ebp+12]

;display:
;    mov edx, [eax+ecx*4-4]
;    PRINT_UDEC 4,edx
;    NEWLINE
;    sub ecx,1
;    cmp ecx,0
;    jnz display
    
;    pop edx
;    pop ecx
;    pop eax
    
;    leave
;    ret

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
    jz blur_values_end
    mov edx,[img_width]
    sub edx,2
iter_width:
    
    mov dword[blur_sum],0
    
    ; =======================================
    push edx
    push ecx
    push ebx
    push eax
    
    ;PRINT_UDEC 4,ecx
    ;PRINT_STRING ","
    ;PRINT_UDEC 4,edx
    ;PRINT_STRING " ==  "
    
    call get_current
    add [blur_sum],eax
    ;PRINT_UDEC 4,eax
    ;PRINT_STRING " - "
  
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
    ;PRINT_UDEC 4,eax
    ;PRINT_STRING " - "
    
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
    ;PRINT_UDEC 4,eax
    ;PRINT_STRING " - "
    
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
    ;PRINT_UDEC 4,eax
    ;PRINT_STRING " - "
    
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
    ;PRINT_UDEC 4,eax
    ;NEWLINE
    
    ;PRINT_UDEC 4,[blur_sum]
    ;NEWLINE
    
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
    
    ;PRINT_UDEC 4,ecx
    ;PRINT_STRING ","
    ;PRINT_UDEC 4,edx
    ;NEWLINE
    
    sub edx,1  
    cmp edx,0
    jz iter_height
    jmp iter_width


blur_values_end:  
    
    xor ecx,ecx
    sub ecx,1
  
    jmp blur_end
    
show_img_x:
    add ecx,1
    cmp ecx,[img_height]
    jz blur_end
    xor edx,edx
show_img_y:    
    mov eax,ecx
    mov esi,[img_width]
    imul eax,esi
    add eax,edx
    mov ebx,[img]
    PRINT_UDEC 4,[ebx+4*eax]
    PRINT_STRING " "
    
    add edx,1
    cmp edx,[img_width]
    jnz show_img_y
    NEWLINE
    jmp show_img_x

    
blur_end:
    mov eax,[img]
    mov ebx,[img_width]
    mov ecx,[img_height]
    push ecx
    push ebx
    push eax
    call print_image
    add esp,12
    
    ;mov eax,[img_backup]
    ;push eax
    ;call free
    ;add esp,4

    pop ecx
    pop ebx
    pop eax
    leave
    ret

; ===================================================
get_current:
    push ebp
    mov ebp,esp
    
    ;mov eax,[ebp+8]
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
    ;PRINT_UDEC 4,eax
    ;PRINT_STRING "|"
     
    leave
    ret
; ====================================================
get_left:
    push ebp
    mov ebp,esp
    
    ;mov eax,[ebp+8]
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
    
    ;mov eax,[ebp+8]
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
   ; PRINT_UDEC 4,eax
   ; NEWLINE
     
    leave
    ret
; ===================================================
get_top:
    push ebp
    mov ebp,esp
    
    ;mov eax,[ebp+8]
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
    ;PRINT_UDEC 4,eax
    ;NEWLINE
     
    leave
    ret
; ====================================================
get_bottom:
    push ebp
    mov ebp,esp
    
    ;mov eax,[ebp+8]
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
    ;PRINT_UDEC 4,eax
    ;NEWLINE
     
    leave
    ret
; ====================================================
blur_current_value:
    push ebp
    mov ebp,esp
    
    ;mov eax,[ebp+8]
    ;mov ebx,[ebp+12]
    mov ecx,[ebp+8]
    mov edx,[ebp+12]
    
    ;push eax
    ;push ebx
    
    mov eax,[img_width]
    imul eax,4
    imul eax,ecx 
    mov ebx,edx
    imul ebx,4
    add eax,ebx
    mov ecx,eax
    
  
    ;pop ebx
    ;pop eax
    mov eax,[img]
    mov edx,[blur_sum]
    mov [eax+ecx],edx
    ;PRINT_UDEC 4,[eax+ecx]
    ;NEWLINE
    ;PRINT_STRING "=="
    
    leave
    ret

    
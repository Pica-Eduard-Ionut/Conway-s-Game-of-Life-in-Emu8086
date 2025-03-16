; Conway's Game of Life
; Rules:
; 1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
; 2. Any live cell with two or three live neighbours lives on to the next generation.
; 3. Any live cell with more than three live neighbours dies, as if by overpopulation.
; 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

include emu8086.inc     

org 100h
          
; set graphical mode to text 80x25  
; starts from [0,0] to [24,79] -> 25 rows, 80 columns     
mov al, 03h
mov ah, 0
int 10h  
    
; example usage
; set the pattern of pixels on page 0

mov BH,0 ; set page to 0
                      
 ; make a glider                      
; set an alive pixel    
mov row,2
mov col,2

call setCursor
call setColorAlive   

; set an alive pixel 
mov row,3
mov col,3

call setCursor
call setColorAlive 

; set an alive pixel 
mov row,4
mov col,1

call setCursor
call setColorAlive

mov row,4
mov col,3

call setCursor
call setColorAlive

mov row,4
mov col,2

call setCursor
call setColorAlive
   
     
mov row,2
mov col,3
call setCursor                 
                   
;backupCursor Position
mov currentRow, dh ; backing up position
mov currentCol, dl ; backing up position
 
 
;call searchNeighborsPG0  

mov row,1
mov col,3
call setCursor                
                   
;backupCursor Position
mov currentRow, dh ; backing up position
mov currentCol, dl ; backing up position
 
 
;call searchNeighborsPG0

mov row,3
mov col,3
call setCursor                 
                   
;backupCursor Position
mov currentRow, dh ; backing up position
mov currentCol, dl ; backing up position
 
mov debugpage,0
;call searchNeighborsPG0

page0:
    mov row,1  ; begin from 1 because we search around the pixel
    rowloop0:
        mov col,1 ; begin from 1 because we search around the pixel
        mov dh,row
        mov currentRow, dh ; backing up position
    
        colloop0:
            mov dl,col
            mov dh,currentRow
            mov currentCol, dl ; backing up position
            call setCursor      
            call searchNeighborsPG0  
                
            inc col
            cmp col,78  ; checks 78 rows
            jl colloop0
    
        inc row
        cmp row,18 ; checks 18 rows
        jl rowloop0

; wipe page0
call clearPage        
; change page to page1
call changePage1
mov debugpage,1
inc generation        
            


page1:
    mov row,1  ; begin from 1 because we search around the pixel
    rowloop1:
        mov col,1 ; begin from 1 because we search around the pixel
        mov dh,row
        mov currentRow, dh ; backing up position
    
        colloop1:
            mov dl,col
            mov dh,currentRow
            mov currentCol, dl ; backing up position
            call setCursor      
            call searchNeighborsPG1  
                
            inc col
            cmp col,78  ; checks 78 rows
            jl colloop1
    
        inc row
        cmp row,18 ; checks 18 rows
        jl rowloop1      
                   
; wipe page1
call clearPage                   
                   
; change page to page0
call changePage0 
mov debugpage,0
inc generation

    
    
jmp page0 ; after looping on page1 go back to page 0 so it becomes an infinite loop    
    
    
ret 

; variables
row db 0
col db 0

currentRow db 0
currentCol db 0

count dw 0
debugpage db 0
generation db 0

setCursor PROC
mov dh, row   ; row
mov dl, col   ; col
;mov bh, 0    ; page nr
mov ah, 2    ; set cursor pos interrupt
int 10h      ; call the interrupt

RET    
setCursor ENDP

getColor PROC
;mov BH,0 ; page 0
mov AH,08h; read attr
int 10h 
 
RET
getColor ENDP

setColorAlive PROC
;mov BH,0     ; page 1
mov AH,09h   ; set attr  
;mov AL,219  ; this is a full block
mov AL,178     ; set char to display
mov CX,1     ; number of times to write 
mov BL,0010  ; color to display
int 10h
   
RET
setColorAlive ENDP 

setColorDead PROC
;mov BH,0     ; page 1
mov AH,09h   ; set attr  
mov AL,0     ; set char to null so it clears the pixel
mov CX,1     ; number of times to write 
mov BL,0000  ; color to display
int 10h 
  
RET
setColorDead ENDP  

    
    
    
searchNeighborsPG0 PROC   
mov BH,0 ; read page 0
mov count,0

; check first row 
dec row ; row
step1:
    ; look for -1,-1 neighbour
    dec col ; col
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc1 ; if so increase the counter

; look for -1,0 neighbour
step2:
    inc col ; col
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc2

step3:
    ; look for -1,+1 neighbour
    inc col ; col
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc3
 
step4:
    ; check second row 
    inc row ; row 
    mov dh,row
    
    ; look for 0,+1 neighbour
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc4

step5:
    ; look for 0,-1 neighbour
    dec col ; cell's col
    dec col ; first col 
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc5                                   

step6:
    ; check third row
    inc row ; row
    mov dh,row
    
    ; loot for +1,-1 neighbour
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc6
   
step7:
    ; loof for +1,0 neighbour
    inc col ; col
    mov dl,col
    call setCursor
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc7
  
step8:
    ; look for +1,+1 neighbour
    inc col ; col
    mov dl,col
    call setCursor
    call getColor
    cmp ah,0Ah  ; check if cell is alive
    je inc8    ; if cell is alive increment
    jmp compare    ; else end the search

inc1: 
    inc count
    jmp step2
    
inc2: 
    inc count
    jmp step3
    
inc3: 
    inc count
    jmp step4
    
inc4: 
    inc count
    jmp step5
    
inc5: 
    inc count
    jmp step6
    
inc6: 
    inc count
    jmp step7
    
inc7: 
    inc count
    jmp step8
    
inc8:
    inc count
    jmp compare
    
compare:
    call resetCursorPos
    mov bh,0 ; set page to 0 to read cells
    call getColor
    ;cmp ax,07h  ; if cell is dead
    cmp al,0   ; compare by character because color is buggy or i'm doing something wrong
    je rule4  
    ; would be wise to add these too so it only works with green color
    ;cmp ax,2 ; if cell is alive
    ;je rule1
    ;jmp end    
           
rule1:     ; live cell ; if less than 2 neighbors alive then die
    cmp count,2
    jge rule2
    jmp die
    
rule2:     ; live cell ; two or three live neighbours lives on to the next generation. 
    cmp count,3
    jg rule3
    jmp live

rule3:     ; live cell ; more than three live neighbours dies, as if by overpopulation.
    jmp die

rule4:     ; dead cell ; with exactly three live neighbours becomes a live cell, as if by reproduction. 
    cmp count,3
    jne die
    
live:
    mov BH,1 ; set page to 1 to write to it
    call setCursor
    mov BH,1 ; set page to 1 to write to it
    call setColorAlive
    jmp end
    
die:
    mov BH,1 ; set page to 1 to write to it
    call setCursor
    mov BH,1 ; set page to 1 to write to it
    call setColorDead
        
end:  
    call getColor      
    ;reset cursor position to original
    call resetCursorPos
    
    call setCursor
    ;mov ax,count
    ;call print_num
   
RET
searchNeighborsPG0 ENDP

searchNeighborsPG1 PROC   
mov BH,1 ; read page 1
mov count,0

; check first row 
dec row ; row
step1pg1:
    ; look for -1,-1 neighbour
    dec col ; col
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc1pg1 ; if so increase the counter

; look for -1,0 neighbour
step2pg1:
    inc col ; col
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc2pg1

step3pg1:
    ; look for -1,+1 neighbour
    inc col ; col
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc3pg1
 
step4pg1:
    ; check second row 
    inc row ; row 
    mov dh,row
    
    ; look for 0,+1 neighbour
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc4pg1

step5pg1:
    ; look for 0,-1 neighbour
    dec col ; cell's col
    dec col ; first col 
    mov dl,col
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc5pg1                                   

step6pg1:
    ; check third row
    inc row ; row
    mov dh,row
    
    ; loot for +1,-1 neighbour
    call setCursor 
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc6pg1
   
step7pg1:
    ; loof for +1,0 neighbour
    inc col ; col
    mov dl,col
    call setCursor
    call getColor
    cmp ah,0Ah ; check if cell is alive
    je inc7pg1
  
step8pg1:
    ; look for +1,+1 neighbour
    inc col ; col
    mov dl,col
    call setCursor
    call getColor
    cmp ah,0Ah  ; check if cell is alive
    je inc8pg1    ; if cell is alive increment
    jmp comparepg1    ; else end the search

inc1pg1: 
    inc count
    jmp step2pg1
    
inc2pg1: 
    inc count
    jmp step3pg1
    
inc3pg1: 
    inc count
    jmp step4pg1
    
inc4pg1: 
    inc count
    jmp step5pg1
    
inc5pg1: 
    inc count
    jmp step6pg1
    
inc6pg1: 
    inc count
    jmp step7pg1
    
inc7pg1: 
    inc count
    jmp step8pg1
    
inc8pg1:
    inc count
    jmp comparepg1
    
comparepg1:
    call resetCursorPos
    mov bh,1 ; set page to 1 to read cells
    call getColor
    cmp al,0   ; compare by character because color is buggy or i'm doing something wrong
    je rule4pg1  
           
rule1pg1:     ; live cell ; if less than 2 neighbors alive then die
    cmp count,2
    jge rule2pg1
    jmp diepg1
    
rule2pg1:     ; live cell ; two or three live neighbours lives on to the next generation. 
    cmp count,3
    jg rule3pg1
    jmp livepg1

rule3pg1:     ; live cell ; more than three live neighbours dies, as if by overpopulation.
    jmp diepg1

rule4pg1:     ; dead cell ; with exactly three live neighbours becomes a live cell, as if by reproduction. 
    cmp count,3
    jne diepg1
    
livepg1:
    mov BH,0 ; set page to 0 to write to it
    call setCursor
    mov BH,0 ; set page to 0 to write to it
    call setColorAlive
    jmp endpg1
    
diepg1:
    mov BH,0 ; set page to 0 to write to it
    call setCursor
    mov BH,0 ; set page to 0 to write to it
    call setColorDead
        
endpg1:  
    call getColor      
    ;reset cursor position to original
    call resetCursorPos
    
    call setCursor
    ;mov ax,count
    ;call print_num
   
RET
searchNeighborsPG1 ENDP 


changePage0 PROC
mov AH,05h
mov AL,0
int 10h   
RET
changePage0 ENDP

changePage1 PROC
mov AH,05h
mov AL,1
int 10h   
RET
changePage1 ENDP 

clearPage PROC
mov ah,07h
mov al,00h
int 10h    
RET
clearPage ENDP


resetCursorPos PROC
mov DH,currentRow
mov row,DH
mov DL,currentCol 
mov col,DL
call setCursor        
RET
resetCursorPos ENDP   


; emu8086.inc functions
DEFINE_SCAN_NUM
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
DEFINE_PTHIS

END   
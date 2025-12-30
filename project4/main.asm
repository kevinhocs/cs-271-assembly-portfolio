TITLE Proj4_hokev.asm
; Author: Kevin Ho
; Last Modified: 17 Nov 2025
; OSU email address: ho.kev@oregonstate.edu
; Course number/section: CS 271_400_F2025
; Project Number: Project 4       Due Date: 16 Nov 2025
; Description: 
;   This program prompts user for a number of rows (1 - 20)
;   validates the input, and prints the number of rows of pascal's triangle

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; CONSTANTS
; ---------------------------------------------------------------------------------
UPPER_BOUND = 20
LOWER_BOUND = 1

; ---------------------------------------------------------------------------------
; GLOBALS
; ---------------------------------------------------------------------------------
.data
userRows   DWORD   ?
nVal       DWORD   ?
kVal       DWORD   ?
resultBin  DWORD   ?

introMsg1  BYTE "Pascal's Triangulator - Programmed by Kevin!",0
introMsg2  BYTE "This program will print up to 20 rows of Pascal's Triangle, on your input.",0
ecMsg      BYTE "**EC: This program prints up to 20 rows of Pascal's Triangle.",0
promptMsg BYTE "Enter total number of rows to print [1...20]: ",0
errMsg     BYTE "ERROR: Input out of range. Try again.",0
space      BYTE " ",0
byeMsg     BYTE "Thank you for using Pascal's Triangulator. Goodbye!",0

.code

; ------------------------------------------------------------
; INTRODUCTION
; ------------------------------------------------------------
introduction PROC
    mov edx, OFFSET introMsg1
    call WriteString
    call Crlf

    mov edx, OFFSET introMsg2
    call WriteString
    call Crlf

     mov edx, OFFSET ecMsg
    call WriteString
    call Crlf
    call Crlf
    ret
introduction ENDP


; -------------------------------------------------------------
; Name: getUserInput
; Description:
;   Prompts the user for an integer between 1 and 20.
;   Repeats until valid input is entered
;
; Preconditions: None
;
; Postconditions: Stores validated value in global variable userRows
; Receives: None
;
; Returns: userRows = validated input
; -------------------------------------------------------------
getUserInput PROC

getInputLoop:
    mov edx, OFFSET promptMsg
    call WriteString
    call ReadInt

    cmp eax, LOWER_BOUND
    jl invalidInput

    cmp eax, UPPER_BOUND
    jg invalidInput

    mov userRows, eax
    jmp endInput

invalidInput:
    mov edx, OFFSET errMsg
    call WriteString
    call Crlf
    jmp getInputLoop

endInput:
    ret
getUserInput ENDP


; -------------------------------------------------------------
; Name: nChooseK
; Description: Computes the binomial coefficient "n choose k"
;   using multiplicative formula. Uses global nVal and kVal
;
; Preconditions:
;   nVal >= 0
;   kVal >= 0 and kVal <= nVal
;
; Postconditions:
;   resultBin contains the computed nCk value
;
; Receives: nVal, kVal
;
; Returns: resultBin
; -------------------------------------------------------------
nChooseK PROC

    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov eax, kVal
    cmp eax, 0
    je returnOne

    mov ebx, nVal
    cmp eax, ebx
    je returnOne

    mov eax, 1
    mov esi, nVal
    mov edi, kVal

numeratorLoop:
    mul esi
    dec esi
    dec edi
    jnz numeratorLoop

    mov ebx, eax
    mov eax, 1
    mov ecx, kVal

denominatorLoop:
    mul ecx
    dec ecx
    jnz denominatorLoop

  
    mov ecx, eax      

    mov edx, 0 
    mov eax, ebx
    div ecx

    mov resultBin, eax
    jmp restore

returnOne:
    mov resultBin, 1

    restore:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

nChooseK ENDP

; -------------------------------------------------------------
; Name: printPascalRow
; Description:
;   Prints one row of Pascal's Triangle. Uses global nVal as the
;   row index and calls nChooseK to compute each element.
;
; Preconditions: nVal contains the row index to print (0..19)
;
; Postconditions: Prints all elements for the given row

; Receives: None
;
; Returns: None
; -------------------------------------------------------------
printPascalRow PROC
    
    push ebx
    push ecx

    mov eax, nVal
    mov ecx, eax
    inc ecx 

    mov ebx, 0

kLoop:
    mov kVal, ebx

    push ecx
    call nChooseK
    pop ecx        

    mov eax, resultBin
    call WriteDec

    mov edx, OFFSET space
    call WriteString

    inc ebx
    loop kLoop

    call Crlf

    pop ecx
    pop ebx
    ret

printPascalRow ENDP



; -------------------------------------------------------------
; Name: printPascalTriangle
; Description:
;   Iterates from row 0 up to userRows - 1 and prints each row
;   using printPascalRow.
;
; Preconditions:
;   userRows contains the valid number of rows to print
;
; Postconditions: Prints all rows
;
; Receives: userRows (global)
;
; Returns: Console output of Pascal’s Triangle
; -------------------------------------------------------------
printPascalTriangle PROC
    mov ecx, userRows
    mov edi, 0

rowLoop:
    mov nVal, edi
    call printPascalRow

    inc edi
    loop rowLoop

    ret
printPascalTriangle ENDP


; -------------------------------------------------------------
; Name: farewell
; Description:
;   Prints a closing message to the user
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: None
;
; Returns: None
; -------------------------------------------------------------
farewell PROC
    mov edx, OFFSET byeMsg
    call WriteString
    call Crlf
    ret
farewell ENDP


; -------------------------------------------------------------
; MAIN PROCEDURE
; Calls all top-level procedures in program order.
; Must not contain any logic other than procedure calls.
; -------------------------------------------------------------

main PROC

    call introduction
    call getUserInput
    call printPascalTriangle
    call farewell

    exit
main ENDP

END main
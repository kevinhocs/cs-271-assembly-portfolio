TITLE Proj3_hokev.asm
; Author: Kevin Ho
; Last Modified: 25 Nov 2025
; OSU email address: ho.kev@oregonstate.edu
; Course number/section: CS 271_400_F2025
; Project Number: Project 5       Due Date: 23 Nov 2025
; Description: 
;   This program will print out random temperatures and
;   calcculate the highest temperature of each row, and the lowest
;   it will also calculate the average of the highest low in that set

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; CONSTANTS
; ---------------------------------------------------------------------------------
DAYS_MEASURED   = 14
TEMPS_PER_DAY   = 11
MIN_TEMP        = 20
MAX_TEMP        = 80

; ---------------------------------------------------------------------------------
; GLOBALS
; ---------------------------------------------------------------------------------
.data
tempArray    SDWORD DAYS_MEASURED * TEMPS_PER_DAY DUP(?)
dailyHighs   SDWORD DAYS_MEASURED DUP(?)
dailyLows    SDWORD DAYS_MEASURED DUP(?)

greet1       BYTE "Welcome to Chaotic Temperature Statistics",0
greet2       BYTE "This program generates temperatures and computes daily high/low and average temps.",0

titleTemp    BYTE "The temperature readings are as follows (one row is one day):",0
titleHighs   BYTE "The highest temperature of each day was:",0
titleLows    BYTE "The lowest temperature of each day was:",0
titleAverageHigh BYTE "The average high temperature was: ",0
titleAverageLow  BYTE "The average low temperature was: ",0

averageHigh  SDWORD ?
averageLow   SDWORD ?

.code

; ------------------------------------------------------------
; INTRODUCTION
; ------------------------------------------------------------;
main PROC
    call Randomize

    ; Greeting
    push OFFSET greet2
    push OFFSET greet1
    call printGreeting

    ; Generate the temperatures
    push OFFSET tempArray
    call generateTemperatures

    ; Highs
    push OFFSET dailyHighs
    push OFFSET tempArray
    call findDailyHighs

    ; Lows
    push OFFSET dailyLows
    push OFFSET tempArray
    call findDailyLows

    ; Averages
    push OFFSET averageLow
    push OFFSET averageHigh
    push OFFSET dailyLows
    push OFFSET dailyHighs
    call calcAverageLowHighTemps

    ; Display full 2D table
    push TEMPS_PER_DAY
    push DAYS_MEASURED
    push OFFSET tempArray
    push OFFSET titleTemp
    call displayTempArray

    ; Daily highs
    push DAYS_MEASURED
    push 1
    push OFFSET dailyHighs
    push OFFSET titleHighs
    call displayTempArray

    ; Daily lows
    push DAYS_MEASURED
    push 1
    push OFFSET dailyLows
    push OFFSET titleLows
    call displayTempArray

    ; Average high
    push averageHigh
    push OFFSET titleAverageHigh
    call displayTempWithString

    ; Average low
    push averageLow
    push OFFSET titleAverageLow
    call displayTempWithString

    call CrLf
    exit
main ENDP

; -------------------------------------------------------------
; Name: printGreeting
; Description:
;   Prints two title strings to introduce the program
;
; Preconditions: Strings must be null-terminated
; Postconditions: Both titles are printed
; Receives: title1, title2 
; Returns:
; -------------------------------------------------------------

printGreeting PROC
    push ebp
    mov  ebp, esp

    mov edx, [ebp+8]
    call WriteString
    call CrLf

    mov edx, [ebp+12]
    call WriteString
    call CrLf
    call CrLf

    pop ebp
    ret 8
printGreeting ENDP

; -------------------------------------------------------------
; Name: generateTemperatures
; Description:
;   Fills tempArray with random temps in the MIN_TEMP..MAX_TEMP range
;
; Preconditions: tempArray is large enough
; Postconditions: Array contains DAYS_MEASURED*TEMPS_PER_DAY temps
; Receives: tempArray
; Returns:
; -------------------------------------------------------------

generateTemperatures PROC
    push ebp
    mov  ebp, esp
    push esi
    push ecx
    push eax

    mov esi, [ebp+8]
    mov ecx, DAYS_MEASURED * TEMPS_PER_DAY

genLoop:
    mov eax, (MAX_TEMP - MIN_TEMP + 1)
    call RandomRange
    add eax, MIN_TEMP
    mov [esi], eax
    add esi, 4
    loop genLoop

    pop eax
    pop ecx
    pop esi
    pop ebp
    ret 4
generateTemperatures ENDP

; -------------------------------------------------------------
; Name: findDailyHighs
; Description:
;   Computes highest temperature of each day
;
; Preconditions: tempArray is full of temps
; Postconditions: dailyHighs contains one high per day
; Receives: tempArray, dailyHighs 
; Returns:
; -------------------------------------------------------------
findDailyHighs PROC
    push ebp
    mov  ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push ebx
    push edx

    mov esi, [ebp+8]
    mov edi, [ebp+12]

    xor ecx, ecx

high_outer:
    cmp ecx, DAYS_MEASURED
    jge high_done

    mov edx, ecx
    imul edx, TEMPS_PER_DAY
    shl edx, 2
    add edx, esi

    mov eax, [edx]
    mov ebx, TEMPS_PER_DAY-1

high_inner:
    add edx, 4
    mov ebp, [edx]
    cmp ebp, eax
    jle high_noUpdate
    mov eax, ebp

high_noUpdate:
    dec ebx
    jg high_inner

    mov ebp, ecx
    shl ebp, 2
    mov [edi + ebp], eax

    inc ecx
    jmp high_outer

high_done:
    pop edx
    pop ebx
    pop ecx
    pop eax
    pop edi
    pop esi
    pop ebp
    ret 8
findDailyHighs ENDP

; -------------------------------------------------------------
; Name: findDailyLows
; Description:
;   Computes lowest temperature of each day
;
; Preconditions: tempArray is full of temps
; Postconditions: dailyLows contains one low per day
; Receives: tempArray, dailyLows
; Returns:
; -------------------------------------------------------------
findDailyLows PROC
    push ebp
    mov  ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push ebx
    push edx

    mov edi, [ebp+12]

    xor ecx, ecx

low_outer:
    cmp ecx, DAYS_MEASURED
    jge low_done

    mov esi, [ebp+8]

    mov edx, ecx
    imul edx, TEMPS_PER_DAY
    shl edx, 2
    add edx, esi

    mov eax, [edx]
    mov ebx, TEMPS_PER_DAY-1

low_inner:
    add edx, 4
    mov esi, [edx]
    cmp esi, eax
    jge low_noUpdate
    mov eax, esi

low_noUpdate:
    dec ebx
    jg  low_inner

    mov edx, ecx
    shl edx, 2
    mov [edi + edx], eax

    inc ecx
    jmp low_outer

low_done:
    pop edx
    pop ebx
    pop ecx
    pop eax
    pop edi
    pop esi
    pop ebp
    ret 8
findDailyLows ENDP

; -------------------------------------------------------------
; Name: calcAverageLowHighTemps
; Description:
;   Calculates truncated average high and average low
;
; Preconditions: dailyHighs and dailyLows contain valid values
; Postconditions: averageHigh and averageLow updated
; Receives: dailyHighs, dailyLows, averageHigh, averageLow
; Returns:
; -------------------------------------------------------------
calcAverageLowHighTemps PROC
    push ebp
    mov  ebp, esp
    push esi
    push edi
    push eax
    push ebx
    push ecx

    mov esi, [ebp+8]
    xor eax, eax
    mov ecx, DAYS_MEASURED
sumHigh:
    add eax, [esi]
    add esi, 4
    loop sumHigh

    mov ebx, DAYS_MEASURED
    cdq
    idiv ebx
    mov edi, [ebp+16]
    mov [edi], eax

    mov esi, [ebp+12]
    xor eax, eax
    mov ecx, DAYS_MEASURED

sumLow:
    add eax, [esi]
    add esi, 4
    loop sumLow

    mov ebx, DAYS_MEASURED
    cdq
    idiv ebx
    mov edi, [ebp+20]
    mov [edi], eax

    pop ecx
    pop ebx
    pop eax
    pop edi
    pop esi
    pop ebp
    ret 16
calcAverageLowHighTemps ENDP

; -------------------------------------------------------------
; Name: displayTempArray
; Description:
;   Prints an array formatted as rows x columns with two spaces
;
; Preconditions: Valid title and array pointer
; Postconditions: Array displayed with correct formatting
; Receives: title, arrayPtr, rows, cols
; Returns: 
; -------------------------------------------------------------
displayTempArray PROC
    push ebp
    mov  ebp, esp
    push esi
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov edx, [ebp+8]
    call WriteString
    call CrLf

    mov edi, 0

rowLoop:
    cmp edi, [ebp+16]
    jge doneDisplay

    mov eax, [ebp+20]
    mov ebx, edi
    imul ebx, eax
    shl ebx, 2

    mov esi, [ebp+12]
    add esi, ebx

    mov ecx, eax

colLoop:
    mov eax, [esi]
    call WriteDec

    cmp ecx, 1
    jle noSpaces
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    noSpaces:
    add esi, 4
    loop colLoop

    call CrLf
    inc edi
    jmp rowLoop

doneDisplay:
    call CrLf

    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop esi
    pop ebp
    ret 16
displayTempArray ENDP

; -------------------------------------------------------------
; Name: displayTempWithString
; Description:
;   Prints a string followed by an integer value
;
; Preconditions: Title is null-terminated
; Postconditions: "<title><value>" is displayed
; Receives: title, value
; Returns:
; -------------------------------------------------------------
displayTempWithString PROC
    push ebp
    mov  ebp, esp
    push edx
    push eax

    mov edx, [ebp+8]
    call WriteString

    mov eax, [ebp+12]
    call WriteDec
    call CrLf

    pop eax
    pop edx
    pop ebp
    ret 8
displayTempWithString ENDP

END main
TITLE String Primitives and Macros     (Proj5_hovekev.asm)

; Author: Kevin Ho
; Last Modified: 07 Dec 2025
; OSU email address: hokev@oregonstate.edu
; Course number/section: CS 271_400_F2025
; Project Number: Project 6       Due Date: 07 Dec 2025
; Description:
;   Reads a file of comma-delimited temperature values,
;   converts them to SDWORDs, and prints them in reverse order

; Note: .model flat, stdcall and .stack 4096 are required for VS/Irvine32
; to run on my system. They don't affect program logic.

.model flat, stdcall
.stack 4096
 
INCLUDE Irvine32.inc
 
; -------------------------------------------------------------
; CONSTANTS
; -------------------------------------------------------------
 
TEMPS_PER_DAY EQU 24
DELIMITER     EQU ','
MAX_FILENAME  EQU 80
MAX_FILEBUF   EQU 512
 
; -------------------------------------------------------------
; MACROS
; -------------------------------------------------------------

; -------------------------------------------------------------
; Name: mGetString
; Description: Prints prompt and reads string input.
; Preconditions: dest has space.
; Postconditions: Stores input & length.
; Receives: prompt, dest, maxCount, bytesOut
; Returns: None
; -------------------------------------------------------------
mGetString MACRO prompt, dest, maxCount, bytesOut
    pushad
    mov edx, prompt
    call WriteString
    mov edx, dest
    mov ecx, maxCount
    call ReadString
    mov ebx, bytesOut
    mov [ebx], eax
 
    mov ebx, dest
    add ebx, eax
    mov BYTE PTR [ebx], 0
 
    popad
ENDM
 
 ; -------------------------------------------------------------
; Name: mDisplayString
; Description: Prints a null-terminated string
; -------------------------------------------------------------
mDisplayString MACRO strPtr
    pushad
    mov edx, strPtr
    call WriteString
    popad
ENDM
 
 ; -------------------------------------------------------------
; Name: mDisplayChar
; Description: Prints a single ASCII character
; -------------------------------------------------------------
mDisplayChar MACRO charval
    pushad
    mov al, charval
    call WriteChar
    popad
ENDM
 
.data
intro1     BYTE "Welcome to the intern error-corrector!",13,10,0
intro2     BYTE "I will reverse the temperature order.",13,10,13,10,0
promptFile BYTE "Please enter filename: ",0
afterMsg   BYTE 13,10,"Corrected temperature order:",13,10,0
byeMsg     BYTE 13,10,"Goodbye!",13,10,0
errOpen    BYTE "Error: Could not open file.",13,10,0
ecMsg      BYTE "Extra Credit #1: Handle mulitple file lines.",13,10,0
 
fileName   BYTE MAX_FILENAME DUP(?)
fileLen    DWORD ?
fileBuffer BYTE MAX_FILEBUF DUP(?)
bytesRead  DWORD ?
tempArray  SDWORD TEMPS_PER_DAY DUP(?)
 
.code
 
; -------------------------------------------------------------
; Name: main
; Description:
;   Gets filename, loads file, parses temperatures, prints reversed
;
; Preconditions: 
;
; Postconditions: File processed and output printed
;
; Receives: 
;
; Returns: 
; -------------------------------------------------------------
 
main PROC STDCALL
 
    mDisplayString OFFSET intro1
    mDisplayString OFFSET intro2
    mDisplayString OFFSET ecMsg
 
    mGetString OFFSET promptFile, OFFSET fileName, MAX_FILENAME, OFFSET fileLen
 
    mov edx, OFFSET fileName
    call OpenInputFile
    cmp eax, -1
    je FileError
    mov ebx, eax
 
    mov edx, OFFSET fileBuffer
    mov ecx, MAX_FILEBUF
    call ReadFromFile
    mov bytesRead, eax
 
    mov eax, ebx
    call CloseFile

    mov esi, OFFSET fileBuffer
    add esi, bytesRead
    mov BYTE PTR [esi], 0

    mov esi, OFFSET fileBuffer

ProcessLine:
    cmp BYTE PTR [esi], 0
    je AllDone

    push OFFSET tempArray
    push esi
    call ParseTempsFromString

    mDisplayString OFFSET afterMsg
    push OFFSET tempArray
    call WriteTempsReverse
    call Crlf

SkipToNextLine:
    mov al, [esi]
    cmp al, 0
    je AllDone
    cmp al, 10 
    je FoundLF
    inc esi
    jmp SkipToNextLine

FoundLF:
    inc esi
    jmp ProcessLine

AllDone:
    mDisplayString OFFSET byeMsg
    jmp EndMain
 
FileError:
    mDisplayString OFFSET errOpen
 
EndMain:
    exit
main ENDP
 
; -------------------------------------------------------------
; Name: ParseTempsFromString
; Description:
;   Conver temperatures into SDWORD values
;
; Preconditions: pBuffer contains TEMPS_PER_DAY values
;
; Postconditions: Parsed integers stored in pArray
;
; Receives: pBuffer, pArray 
;
; Returns: None
; -------------------------------------------------------------

 
ParseTempsFromString PROC STDCALL,
    pBuffer:PTR BYTE,
    pArray:PTR SDWORD

    pushad

    mov esi, pBuffer
    mov edi, pArray
    mov ecx, TEMPS_PER_DAY

ParseValue:
    xor ebx, ebx
    xor edx, edx

NextChar:
    lodsb

    cmp al, 13
    je StoreValue
    cmp al, 10
    je StoreValue

    cmp al, '-'
    jne NotMinus
    mov edx, 1
    jmp NextChar

NotMinus:
    cmp al, DELIMITER
    je StoreValue

    cmp al, '0'
    jb NextChar
    cmp al, '9'
    ja NextChar

    sub al, '0'
    movzx eax, al
    imul ebx, ebx, 10
    add ebx, eax
    jmp NextChar

StoreValue:
    cmp edx, 0
    je StorePositive
    neg ebx
StorePositive:
    mov [edi], ebx
    add edi, 4
    loop ParseValue

    popad
    ret

ParseTempsFromString ENDP
 
; -------------------------------------------------------------
; Name: WriteTempsReverse
; Description:
;   Prints the SDWORD array in reverse order using delimiter
;
; Preconditions: pArray contains TEMPS_PER_DAY integers
;
; Postconditions: Values printed in reverse sequence
;
; Receives: pArray
;
; Returns: None
; -------------------------------------------------------------
 
WriteTempsReverse PROC STDCALL,
    pArray:PTR SDWORD

    pushad

    mov esi, pArray
    mov ecx, TEMPS_PER_DAY

PrintLoop:
    sub ecx, 1
    mov eax, [esi + ecx*4]
    call WriteInt
    mDisplayChar DELIMITER
    cmp ecx, 0
    jne PrintLoop

    popad
    ret

WriteTempsReverse ENDP
 
END main
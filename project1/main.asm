TITLE Simple Arithmetic

; Author: Kevin Ho
; Last Modified: 10/18/2025
; OSU email address: ho.kev@oregonstate.edu
; Course number/section: CS 271_400_F2025
; Project Number: Project 1        Due Date: 20 October 2025
; Description: 
;   Prompts the user for two integers X and Y (where X > Y)
;   Calculates their sum, difference, and product, then displays
;   the results in formatted arithmetic expressions
;   Finally, displays a goodbye message

INCLUDE Irvine32.inc

.data
; ---------------------------------------------------------------------------------
; GLOBAL
; ---------------------------------------------------------------------------------
titleMessage    BYTE    "Simple Arithmetic",0
inputMessage    BYTE    "Enter two integers X > Y:",0
promptX         BYTE    "X = ",0
promptY         BYTE    "Y = ",0
plusSign        BYTE    " + ",0
minusSign       BYTE    " - ",0
multiplySign    BYTE    " * ",0
equalSign       BYTE    " = ",0
byeMessage      BYTE    "Thanks for using Simple Arithmetic! Goodbye!",0

; ---------------------------------------------------------------------------------
; EXTRA CREDIT
; ---------------------------------------------------------------------------------
verifyInput    BYTE    "EC: Program verifies input as X > Y",0
errorMessage    BYTE    "Error: Numbers are not in descending order",0

X               SDWORD  ?
Y               SDWORD  ?
sum             SDWORD  ?
difference      SDWORD  ?
product         SDWORD  ?

.code
; ---------------------------------------------------------------------------------
; Name: main
;
; Description:
;   Main procedure for Simple Arithmetic. Displays introduction,
;   prompts for user input (two integers), performs arithmetic 
;   operations, displays results, and exits with a farewell message.
;
; Preconditions:
;   Irvine32 library must be properly linked.
;
; Postconditions:
;   Arithmetic results displayed on the console.
;
; Receives: none
;
; Returns: none
; ---------------------------------------------------------------------------------
main PROC

    ; ----------------------------
    ; Introduction Section
    ; Displays the title and instructions to the user
    ;
    ; ----------------------------
    mov     edx, OFFSET titleMessage
    call    WriteString
    call    Crlf

  
    mov     edx, OFFSET verifyInput
    call    WriteString
    call    Crlf
    call    Crlf

    mov     edx, OFFSET inputMessage
    call    WriteString
    call    Crlf

    ; ----------------------------
    ; Input Section
    ; Get yser-entered data
    ;
    ; ----------------------------
    mov     edx, OFFSET promptX
    call    WriteString
    call    ReadInt
    mov     X, eax

    mov     edx, OFFSET promptY
    call    WriteString
    call    ReadInt
    mov     Y, eax

    ; ----------------------------
    ; EXTRA CREDIT: verify X > Y
    ; Verify if X is greater than Y, if false, give error message
    ; ----------------------------
    mov     eax, X
    cmp     eax, Y
    jg      continueCalc       

    ; --- If not descending ---
    mov     edx, OFFSET errorMessage
    call    WriteString
    call    Crlf
    jmp     programEnd  

continueCalc:

    ; ----------------------------
    ; Calculation Section
    ; Performs addition, subtraction, and multiplication
    ;
    ; ----------------------------
    mov     eax, X
    add     eax, Y
    mov     sum, eax

    mov     eax, X
    sub     eax, Y
    mov     difference, eax

    mov     eax, X
    imul    eax, Y
    mov     product, eax

    ; ----------------------------
    ; Output Section
    ; Displays formatted results of arithmetic operations
    ;
    ; ----------------------------
    call    Crlf

    ; Display: X + Y = sum
    mov     eax, X
    call    WriteDec
    mov     edx, OFFSET plusSign
    call    WriteString
    mov     eax, Y
    call    WriteDec
    mov     edx, OFFSET equalSign
    call    WriteString
    mov     eax, sum
    call    WriteDec
    call    Crlf

    ; Display: X - Y = difference
    mov     eax, X
    call    WriteDec
    mov     edx, OFFSET minusSign
    call    WriteString
    mov     eax, Y
    call    WriteDec
    mov     edx, OFFSET equalSign
    call    WriteString
    mov     eax, difference
    call    WriteDec
    call    Crlf

    ; Display: X * Y = product
    mov     eax, X
    call    WriteDec
    mov     edx, OFFSET multiplySign
    call    WriteString
    mov     eax, Y
    call    WriteDec
    mov     edx, OFFSET equalSign
    call    WriteString
    mov     eax, product
    call    WriteDec
    call    Crlf

    ; ----------------------------
    ; Termination Section
    ; Prints a goodbye message and exits the program
    ;
    ; ----------------------------
programEnd:
    call    Crlf
    mov     edx, OFFSET byeMessage
    call    WriteString
    call    Crlf

    exit
main ENDP

END main
TITLE Proj2_hokev.asm

; Author: Kevin Ho
; Last Modified: 11/03/2025
; OSU email address: hokev@oregonstate.edu
; Course number/section: CS 271 Section 400_F2025
; Project Number: 3 Due Date: 11/02/2025
; Description: Ask user for their name and 7 temperature inputs
; Calculate average,number of hot and cold days, and the coldest and hotest day
;

INCLUDE Irvine32.inc

; --------------------------------------------------------
; CONSTANTS
; --------------------------------------------------------
MIN_TEMP    = -30
MAX_TEMP    = 50
COLD_MAX    = -1
COOL_MAX    = 15
WARM_MAX    = 30

TARGET_COUNT = 7

; --------------------------------------------------------
; DATA
; --------------------------------------------------------
.data
welcomeMessage  BYTE "Welcome to the Temperature Tool!",0
askNameMessage  BYTE "What is your name? ",0
greetMessage    BYTE "Hello there, ",0

instructions    BYTE "Please enter 7 teperature inputs (-30 to 50 Celsius).",0
promptMessage   BYTE "Daily Temperature: ",0
invalidMessage  BYTE "Input not valid, try again.",0
thanksMessage   BYTE "Thanks! Let's work some stats:",0

maxMessage      BYTE "The maximum valid temp was: ",0
minMessage      BYTE "The minimum valid temp was: ",0
averageMessage  BYTE "The average temp was: ",0

coldMessage     BYTE "Number of Cold days: ",0
coolMessage     BYTE "Number of Cool days: ",0
warmMessage     BYTE "Number of Warm days: ",0
hotMessage      BYTE "Number of Hot days: ",0

byeMessage      BYTE "Thanks for using, bye, ",0

userName        BYTE 40 DUP(?)

tempInput       SDWORD 0
sumTemperature  SDWORD 0
countCold       SDWORD 0
countCool       SDWORD 0
countWarm       SDWORD 0
countHot        SDWORD 0
countValid      SDWORD 0

minTemp         SDWORD ?
maxTemp         SDWORD ?
average         SDWORD ?

; --------------------------------------------------------
; CODE
; --------------------------------------------------------
.code
main PROC

; --------------------------------------------------------
; Display welcome message
; --------------------------------------------------------
    mov     edx, OFFSET welcomeMessage
    call    WriteString
    call    Crlf
    call    Crlf

    mov     edx, OFFSET askNameMessage
    call    WriteString

    mov     edx, OFFSET userName
    mov     ecx, 40
    call    ReadString
    call    Crlf

    mov     edx, OFFSET greetMessage
    call    WriteString
    mov     edx, OFFSET userName
    call    WriteString
    call    Crlf
    call    Crlf

; --------------------------------------------------------
; Display instructions
; --------------------------------------------------------
    mov     edx, OFFSET instructions
    call    WriteString
    call    Crlf
    call    Crlf

; --------------------------------------------------------
; Initalise Max and Min Temp
; --------------------------------------------------------
    mov     eax, MAX_TEMP
    mov     minTemp, eax

    mov     eax, MIN_TEMP
    mov     maxTemp, eax
; --------------------------------------------------------
; Collect the 7 temperature inputs
; --------------------------------------------------------
read_loop:
    mov     eax, countValid
    cmp     eax, TARGET_COUNT
    je     compute

    mov     edx, OFFSET promptMessage
    call    WriteString
    call    ReadInt
    mov     tempInput, eax

    cmp     eax, MIN_TEMP
    jl      invalid
    cmp     eax, MAX_TEMP
    jg      invalid

    mov     eax, countValid
    inc     eax
    mov     countValid, eax

    mov     eax, sumTemperature
    add     eax, tempInput
    mov     sumTemperature, eax

    mov     eax, tempInput
    cmp     eax, minTemp
    jge     skipMin
    mov     minTemp, eax
skipMin:

    mov     eax, tempInput
    cmp     eax, maxTemp
    jle     skipMax
    mov     maxTemp, eax
skipMax:
    mov     eax, tempInput
    cmp     eax, COLD_MAX
    jl      incCold

    cmp     eax, COOL_MAX
    jle     incCool

    cmp     eax, WARM_MAX
    jle     incWarm

    jmp     incHot

incCold:
    mov     eax, countCold
    inc     eax
    mov     countCold, eax
    jmp     read_loop

incCool:
    mov     eax, countCool
    inc     eax
    mov     countCool, eax
    jmp     read_loop

incWarm:
    mov     eax, countWarm
    inc     eax
    mov     countWarm, eax
    jmp     read_loop

incHot:
    mov     eax, countHot
    inc     eax
    mov     countHot, eax
    jmp     read_loop

invalid:
    mov     edx, OFFSET invalidMessage
    call    WriteString
    call    Crlf
    jmp     read_loop

; --------------------------------------------------------
; Compute average
; --------------------------------------------------------
compute:
    mov     eax, sumTemperature
    cmp     eax, 0
    jl      negative
    add     eax, 3
    jmp     division
negative:
    sub     eax, 3
division:
    cdq
    mov     ebx, TARGET_COUNT
    idiv    ebx
    mov     average, eax

; --------------------------------------------------------
; Print results
; --------------------------------------------------------
    mov     edx, OFFSET thanksMessage
    call    WriteString
    call    Crlf

    mov     edx, OFFSET maxMessage
    call    WriteString
    mov     eax, maxTemp
    call    WriteInt
    call    Crlf

    mov     edx, OFFSET minMessage
    call    WriteString
    mov     eax, minTemp
    call    WriteInt
    call    Crlf

    mov     edx, OFFSET averageMessage
    call    WriteString
    mov     eax, average
    call    WriteInt
    call    Crlf

    mov     edx, OFFSET coldMessage
    call    WriteString
    mov     eax, countCold
    call    WriteInt
    call    Crlf

    mov     edx, OFFSET coolMessage
    call    WriteString
    mov     eax, countCool
    call    WriteInt
    call    Crlf

    mov     edx, OFFSET warmMessage
    call    WriteString
    mov     eax, countWarm
    call    WriteInt
    call    Crlf

    mov     edx, OFFSET hotMessage
    call    WriteString
    mov     eax, countHot
    call    WriteInt
    call    Crlf

; --------------------------------------------------------
; Bye Message
; --------------------------------------------------------
    mov     edx, OFFSET byeMessage
    call    WriteString
    mov     edx, OFFSET userName
    call    WriteString
    call    Crlf

    exit
main ENDP
END main
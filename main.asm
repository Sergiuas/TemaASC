    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'intrare4.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'outtest.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
msglen      DW  ?
padding     DW  0
iterations  DW  0 
x           DW  ?
x0          DW  ?
a           DW  0
b           DW  0
cod1        DB  0
cod2        DB  0
cod3        DB  0 
cod4        DB  0
aux         DB  0
cod64       DB  'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW41y5EkrqsnAxubTV03a=L/d'

nume        DB  'Amzuloiu', 0
lenNume     equ $ - nume - 1
prenume     DB  'Sergiu', 0
lenPrenume  equ $ - prenume - 1
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                  ; NU MODIFICATI!
    
    CALL    SEED                        ; TODO - Trebuie implementata

    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H
FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET
SEED:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H
                                        ; TODO1: Completati subrutina SEED
                                        ; astfel incat la final sa fie salvat
                                        ; in variabila 'x' si 'x0' continutul 
                                        ; termenului initial
                                        ; x0 = ((CH ∗ 3600 + CL ∗ 60 + DH) ∗ 100 + DL) mod 255.
    
    MOV CH, 0Eh ;
    MOV CL, 17h ; 
    MOV DH, 26h ;   hardcodare pentru teste
    MOV DL, 4Ch ;

    MOV BL, 255

    MOV AL, 60
    MUL CH
    MOV CH, 0
    ADD AX, CX
    DIV BL          ; in ah rez de la: 60*(CH+CL) mod 255

    MOV AL, 60
    MUL AH 
    DIV BL 
    
    MOV BH, AH      ; rez de la: (3600*CH+60*CL) mod 255

    MOV AL, DH  
    MOV AH, 0
    DIV BL
    MOV AL, AH      ; rez de la: DH mod 255
    MOV AH, 0
    MOV BL, BH
    MOV BH, 0
    ADD AX, BX
    MOV BL, 255
    DIV BL          ; in ah rez de la: (3600*CH+60*CL+DH) mod 255
    MOV AL, 100
    MUL AH
    DIV BL

    MOV BH, AH      ; in ah rez de la: ((3600*CH+60*CL+DH)*100) mod 255

    MOV AL, DL
    MOV AH, 0
    DIV BL
    MOV AL, AH      ; in ah rez de la: DL mod 255 
    MOV AH, 0
    MOV BL, BH
    MOV BH, 0
    ADD AX, BX
    MOV BX, 255
    DIV BL          ; rezultatul final: ((3600*CH+60*CL+DH)*100+DL)mod255
    MOV AL, AH
    MOV AH, 0
    MOV x0, AX
    MOV x, AX

    MOV x0, 13      ; hardcodare pentru teste
    MOV x, 13   ;
                     ; Sum call for both strings
    CALL CALC_VAR

    MOV a, 104      ; hardcodare pentru teste
    MOV b, 200

    RET
ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
                                            ; TODO3: Completati subrutina ENCRYPT
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator
                                          
CRIPT_LOOP:
    MOV AL, [SI]
    MOV BX, x
    XOR AL, BL
    MOV [SI], AL
    INC SI
    CMP CX, 1
    JE OVER_JMP         ; break loop sa ramana Xn-1
    CALL RAND
    LOOP CRIPT_LOOP
OVER_JMP:
    RET
RAND:
    MOV     AX, [x]
   ; MOV 	x0, AX
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'
    MOV BX, a                               ; xn=(a*xn-1 + b) mod255
    MUL BL 
    MOV BL, 255
    DIV BL
    MOV AL, AH
    MOV AH, 0  

    MOV DL, AL
    MOV DH, 0

    MOV AX, b
    DIV BL
    MOV AL, AH
    MOV AH, 0

    ADD AX, DX
    DIV BL
    MOV AL, AH
    MOV AH, 0
    
    MOV x, AX
    RET
ENCODE:
                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat
                                            ; in enuntul problemei si rezultatul va fi stocat
                                            ; in cadrul variabilei encoded
    MOV AX, [msglen]
    MOV BL, 3h
    DIV BL              ; calculam padding-ul necesar
    MOV AL, AH
    MOV AH, 0
    ;
    CMP AX, 0h
    JNE CONTINUA_CU
    MOV padding, 0
    MOV AX, 3
    ;
CONTINUA_CU:
    MOV padding, 3
    SUB padding, AX
    ;
    MOV BX, [msglen]
    MOV AX, padding
    ADD AX, BX
    MOV BL, 3
    DIV BL

    MOV CX, AX
    MOV iterations, AX ;

    MOV BL, 4
    MUL BL ; in ax e lungimea encoded

    MOV SI, OFFSET message
    MOV DI, OFFSET encoded
CODING_LOOP:
    CALL CALC_CODES

    LOOP CODING_LOOP

    MOV CX, padding
    CMP CX, 0h
    JE OVER_CODING
PADDING_LOOP:
    DEC DI
    
    MOV byte ptr [DI], 2Bh
    LOOP PADDING_LOOP
OVER_CODING:
    RET
WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET

CALC_VAR:
    MOV AX, 0
    MOV SI, OFFSET nume
    MOV CX, lenNume
    MOV BH, 0
B_LOOP:
    MOV BL, [SI]
    ADD AX, BX
    INC SI
    LOOP B_LOOP         ; Suma valorilor literelor

    MOV BL, 255
    DIV BL  
    MOV AL, AH
    MOV AH, 0           ; suma mod 255
    MOV b, AX

    MOV AX, 0  
    MOV BX, OFFSET a
    MOV SI, OFFSET prenume
    MOV CX, lenPrenume 
    MOV BH, 0
A_LOOP:  
    MOV BL, [SI]
    ADD AX, BX
    INC SI
    LOOP A_LOOP         ; Suma valorilor literelor

    MOV BL, 255
    DIV BL  
    MOV AL, AH
    MOV AH, 0           ; suma mod 255
    MOV a, AX

    RET


CALC_CODES:
    MOV AL,byte ptr [SI]        ; in cod1 se pun primii 6 biti
    MOV cod1, AL                ; din primul octet din grupul de 3 initial
    SHR cod1, 2

    INC SI
    MOV AH, byte ptr [SI]       ; in cod2 se pun ultimii 2 biti ai primei
    MOV cod2, AL                ;  ai primului octet si urmatorii 4 din 
    AND cod2, 3                 ; din octetul urmator
    SHL cod2, 4
    MOV aux, AH
    SHR aux, 4
    MOV BL, aux
    OR cod2, BL

    MOV cod3, AH                ; in cod3 se pun ultimii 4 biti din 
    AND cod3, 15                ; al doilea octet si urmatorii 2 din 
    SHL cod3, 2                 ; al treilea octet din grupul intial
    INC SI
    MOV AL, byte ptr [SI]
    mov aux, AL
    SHR aux, 6
    MOV BL, aux
    OR cod3, BL

    MOV cod4, AL                ; in cod4 se pun ultimii 6 biti
    SHL cod4, 2                 ; din al treilea octet din grupul initial
    SHR cod4, 2                 

    PUSH SI                     ; vom folosi SI sa parcurgem baza de codare
                                ; si DI stringul encoded
                                ; codurile reprezinta pozitia din baza de codare
    MOV SI, OFFSET cod64
    MOV AL, cod1
    MOV AH, 0
    ADD SI, AX
    MOV BX, [SI]
    MOV [DI], BX
    INC DI

    MOV SI, OFFSET cod64
    MOV AL, cod2
    ADD SI, AX
    MOV BX, [SI]
    MOV [DI], BX
    INC DI

    MOV SI, OFFSET cod64
    MOV AL, cod3
    ADD SI, AX
    MOV BX, [SI]
    MOV [DI], BX
    INC DI

    MOV SI, OFFSET cod64
    MOV AL, cod4
    ADD SI, AX
    MOV BX, [SI]
    MOV [DI], BX
    INC DI

    POP SI
    INC SI

    RET

WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1

    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [iterations]
    MOV     BX, 4
    MUL     BX
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
    END START
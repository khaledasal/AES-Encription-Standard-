include 'emu8086.inc'     
org 100h 
   
.DATA 
    
X DB 019H,0A0H,09AH,0E9H
  DB 03DH,0F4H,0C6H,0F8H
  DB 0E3H,0E2H,08DH,048H
  DB 0BEH,02BH,02AH,008H
          
SBOX DB 063H,07cH,077H,07bH,0f2H,06bH,06fH,0c5H,030H,001H,067H,02bH,0feH,0d7H,0abH,076H
     DB 0caH,082H,0c9H,07dH,0faH,059H,047H,0f0H,0adH,0d4H,0a2H,0afH,09cH,0a4H,072H,0c0H
     DB 0b7H,0fdH,093H,026H,036H,03fH,0f7H,0ccH,034H,0a5H,0e5H,0f1H,071H,0d8H,031H,015H
     DB 004H,0c7H,023H,0c3H,018H,096H,005H,09aH,007H,012H,080H,0e2H,0ebH,027H,0b2H,075H
     DB 009H,083H,02cH,01aH,01bH,06eH,05aH,0a0H,052H,03bH,0d6H,0b3H,029H,0e3H,02fH,084H
     DB 053H,0d1H,000H,0edH,020H,0fcH,0b1H,05bH,06aH,0cbH,0beH,039H,04aH,04cH,058H,0cfH
     DB 0d0H,0efH,0aaH,0fbH,043H,04dH,033H,085H,045H,0f9H,002H,07fH,050H,03cH,09fH,0a8H
     DB 051H,0a3H,040H,08fH,092H,09dH,038H,0f5H,0bcH,0b6H,0daH,021H,010H,0ffH,0f3H,0d2H
     DB 0cdH,00cH,013H,0ecH,05fH,097H,044H,017H,0c4H,0a7H,07eH,03dH,064H,05dH,019H,073H
     DB 060H,081H,04fH,0dcH,022H,02aH,090H,088H,046H,0eeH,0b8H,014H,0deH,05eH,00bH,0dbH
     DB 0e0H,032H,03aH,00aH,049H,006H,024H,05cH,0c2H,0d3H,0acH,062H,091H,095H,0e4H,079H
     DB 0e7H,0c8H,037H,06dH,08dH,0d5H,04eH,0a9H,06cH,056H,0f4H,0eaH,065H,07aH,0aeH,008H
     DB 0baH,078H,025H,02eH,01cH,0a6H,0b4H,0c6H,0e8H,0ddH,074H,01fH,04bH,0bdH,08bH,08aH
     DB 070H,03eH,0b5H,066H,048H,003H,0f6H,00eH,061H,035H,057H,0b9H,086H,0c1H,01dH,09eH
     DB 0e1H,0f8H,098H,011H,069H,0d9H,08eH,094H,09bH,01eH,087H,0e9H,0ceH,055H,028H,0dfH
     DB 08cH,0a1H,089H,00dH,0bfH,0e6H,042H,068H,041H,099H,02dH,00fH,0b0H,054H,0bbH,016H

KEY DB 02bH,028H,0abH,09H
    DB 07eH,0aeH,0F7H,0cfH
    DB 015H,0d2H,015H,04fH
    DB 016H,0a6H,088H,03cH
     
    
RCON DB 01H,02H,04H,08H,10H,20H,40H,80H,1BH,36H
     DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
     DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
     DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H 
     
COL4    DB 00H,00H,00H,00H
SUBCOL4 DB 00H,00H,00H,00H
RCONX   DB 00H,00H,00H,00H     
COL1    DB 00H,00H,00H,00H

MATRIX DB 2,3,1,1
       DB 1,2,3,1
       DB 1,1,2,3
       DB 3,1,1,2 

MIXNUM DB 00H,00H,00H,00H
       DB 00H,00H,00H,00H
       DB 00H,00H,00H,00H
       DB 00H,00H,00H,00H 
       
X1 DB 00H,00H,00H,00H
   DB 00H,00H,00H,00H
   DB 00H,00H,00H,00H
   DB 00H,00H,00H,00H
       
.CODE
 

MOV SI,0
MOV CX,9

CALL INPUT
FINAL:    
CALL SUBBYTES
CALL SHIFTROWS
CALL MIXCOLOUMNS
CALL ADDROUNDKEY
CALL OUTPUT
INC SI
LOOP FINAL

CALL SUBBYTES
CALL SHIFTROWS
CALL ADDROUNDKEY
CALL OUTPUT

 

RET
    
    
INPUT PROC 
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DX
    
    MOV AH,01H
    MOV CX,16
    MOV SI,0            
               
    PRINT "ENTER YOUR INPUT: "
    PRINTN
        
    INPUT1: 
      INT 21H
      CALL CONVERT
    
      SAL AL,4
      MOV BL,AL 
      
      INT 21H 
      CALL CONVERT 
       
      ADD AL,BL
      MOV X[SI],AL
      INC SI
      LOOP INPUT1
    
    POP DX
    POP SI
    POP CX
    POP BX
    POP AX
    
    RET    
ENDP  


CONVERT PROC 
    
    CMP AL,065
    JL  ISNUM                       
    SUB AL,055
    RET                    
    ISNUM:
       AND AL,0FH                         
    RET     
ENDP   


OUTPUT PROC 
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DX
    
    MOV SI,0
    MOV CX,16 
    
    PRINTN
    PRINT "YOUR OUTPUT IS: " 
    PRINTN
    
    OUTPUT1: 
      MOV AX,0
      MOV BX,0
      
      MOV AL,X[SI]
      MOV BL,10H
      DIV BL 
    
      MOV BL,AL
      MOV BH,AH
    
      CALL CONVERT_BL
      CALL CONVERT_BH 
      
    
      MOV AH,02H
      MOV DL,BL 
      INT 21H
    
      MOV DL,BH
      INT 21H
    
      MOV DL," "
      INT 21H        
            
      INC SI
    LOOP OUTPUT1
    
    POP DX
    POP SI
    POP CX
    POP BX
    POP AX
    
    RET
ENDP 

PROC CONVERT_BL
    CMP BL,9
    JA NOTNUM
    ADD BL,48
    RET
    
    NOTNUM:
      ADD BL,55
    RET
ENDP

PROC CONVERT_BH
    CMP BH,9
    JA NOTNUM1
    ADD BH,48
    RET
    
    NOTNUM1:
      ADD BH,55
    RET
ENDP
 
 
PROC SUBBYTES
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH BP
    PUSH DX
    
    MOV SI,0
    MOV CX,16
    
    SUBBYTES1:
    
      MOV AL,X[SI]
      MOV BL,10H
      DIV BL 
   
      MOV BH,AH 
      MOV AH,0
      MOV BL,16
      MUL BL
      ADD AL,BH
    
      MOV BP,AX
      MOV BL,SBOX[BP]
      MOV X[SI],BL
      INC SI
    LOOP SUBBYTES1
    
    POP DX
    POP BP
    POP SI
    POP CX
    POP BX
    POP AX
    RET
ENDP

PROC SHIFTROWS
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    SHIFT1:
    MOV SI,4
    MOV AL,X[SI]
    MOV AH,X[SI+1]
    MOV BL,X[SI+2]
    MOV BH,X[SI+3]
    MOV X[SI],AH
    MOV X[SI+1],BL
    MOV X[SI+2],BH
    MOV X[SI+3],AL 
    
    
    SHIFT2:
    MOV SI,8
    MOV AL,X[SI]
    MOV AH,X[SI+1]
    MOV BL,X[SI+2]
    MOV BH,X[SI+3]
    MOV X[SI],BL
    MOV X[SI+1],BH
    MOV X[SI+2],AL
    MOV X[SI+3],AH
    
    SHIFT3:
    MOV SI,12
    MOV AL,X[SI]
    MOV AH,X[SI+1]
    MOV BL,X[SI+2]
    MOV BH,X[SI+3]
    MOV X[SI],BH
    MOV X[SI+1],AL
    MOV X[SI+2],AH
    MOV X[SI+3],BL 
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
ENDP

PROC KEYSCHEDULE
     CALL MOVCOLS
     CALL SUBBYTESCOL4 
     CALL SETRCONX
     CALL XOR3
     CALL XORFINAL
     RET
ENDP




PROC MOVCOLS 
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV AL,KEY[3]
    MOV AH,KEY[7]
    MOV BL,KEY[11]
    MOV BH,KEY[15] 
    MOV COL4[0],AL
    MOV COL4[1],AH
    MOV COL4[2],BL
    MOV COL4[3],BH
    
    SHIFTING:
    MOV AL,COL4[0]
    MOV AH,COL4[1]
    MOV BL,COL4[2]
    MOV BH,COL4[3] 
    MOV COL4[0],AH
    MOV COL4[1],BL
    MOV COL4[2],BH
    MOV COL4[3],AL
     
    
    MOV AL,KEY[0]
    MOV AH,KEY[4]
    MOV BL,KEY[8]
    MOV BH,KEY[12] 
    MOV COL1[0],AL
    MOV COL1[1],AH
    MOV COL1[2],BL
    MOV COL1[3],BH 
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ENDP

PROC SUBBYTESCOL4
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH BP
            
    MOV SI,0
    MOV CX,4
    
    SUBBYTES4:
    
      MOV AL,COL4[SI]
      MOV BL,10H
      DIV BL 
   
      MOV BH,AH 
      MOV AH,0
      MOV BL,16
      MUL BL
      ADD AL,BH
    
      MOV BP,AX
      MOV BL,SBOX[BP]
      MOV COL4[SI],BL
      INC SI
    LOOP SUBBYTES4
    
    POP BP
    POP SI
    POP CX
    POP BX
    POP AX
    RET
ENDP 

PROC SETRCONX ;SI IS NEEDED
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX  
    
    MOV AL,RCON[SI]
    MOV AH,RCON[SI+10]
    MOV BL,RCON[SI+20]
    MOV BH,RCON[SI+30]
    
    MOV RCONX[0],AL
    MOV RCONX[1],AH
    MOV RCONX[2],BL
    MOV RCONX[3],BH 
    
    INC SI
    
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
ENDP

PROC XOR3 ;XOR SUBBYTESCOL4 RCONX COL1
     
     PUSH AX
     PUSH BX
     PUSH CX
     PUSH DX
     PUSH SI
     
     XOR1:
     MOV AL,COL4[0]
     XOR AL,RCONX[0]
     MOV KEY[0],AL
     
     MOV AL,COL4[1]
     XOR AL,RCONX[1]
     MOV KEY[4],AL
     
     MOV AL,COL4[2]
     XOR AL,RCONX[2]
     MOV KEY[8],AL
     
     MOV AL,COL4[3]
     XOR AL,RCONX[3]
     MOV KEY[12],AL
     
     XOR2:
     MOV AL,KEY[0]
     XOR AL,COL1[0]
     MOV KEY[0],AL 
     
     MOV AL,KEY[4]
     XOR AL,COL1[1]
     MOV KEY[4],AL 
     
     MOV AL,KEY[8]
     XOR AL,COL1[2]
     MOV KEY[8],AL 
     
     MOV AL,KEY[12]
     XOR AL,COL1[3]
     MOV KEY[12],AL
     
     POP SI
     POP DX
     POP CX
     POP BX
     POP AX    
     
     RET
ENDP

PROC XORFINAL ;COL1 XOR EACH 
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH BP 
     
    MOV SI,1
    MOV BP,0
    MOV CX,3
            
    XORR:        
    MOV AL,KEY[SI]
    XOR AL,KEY[BP]
    MOV KEY[SI],AL 
    
    MOV AL,KEY[SI+4]
    XOR AL,KEY[BP+4]
    MOV KEY[SI+4],AL
     
    
    MOV AL,KEY[SI+8]
    XOR AL,KEY[BP+8]
    MOV KEY[SI+8],AL
    
    
    MOV AL,KEY[SI+12]
    XOR AL,KEY[BP+12]
    MOV KEY[SI+12],AL
    
    INC BP              
    INC SI
    LOOP XORR
     
    POP BP
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
ENDP
 
PROC ADDROUNDKEY
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    CALL KEYSCHEDULE
    
    MOV SI,0
    MOV BP,4
    
    ROUNDKEY:
    MOV AL,KEY[SI]
    MOV BL,KEY[SI+4]
    MOV CL,KEY[SI+8]
    MOV DL,KEY[SI+12] 
    
    MOV AH,X[SI]
    MOV BH,X[SI+4]
    MOV CH,X[SI+8]
    MOV DH,X[SI+12] 
    
    XOR AH,AL
    MOV X[SI],AH
    XOR BH,BL
    MOV X[SI+4],BH 
    XOR CH,CL
    MOV X[SI+8],CH
    XOR DH,DL
    MOV X[SI+12],DH 
    
    INC SI
    DEC BP
    CMP BP,0
    JA ROUNDKEY
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
ENDP
                  
PROC MIXCOLOUMNS
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
      PUSH SI
      PUSH BP
      
      MOV SI,0
      MOV BP,0
      MOV CX,4 
      MOV AL,0
      MOV DH,16 
      
      MIXCOL: 
      MOV AH,X[BP]               
      MOV BL,MATRIX[SI]          
                                 
      CMP BL,1
      JZ CASE1
      CMP BL,2
      JZ CASE2
      CMP BL,3
      JZ CASE3
      A3: 
      MOV BH,X[BP]
      AND BH,80H
      CMP BH,80H
      JZ HANDEL1
      A1:
      MOV MIXNUM[SI],AH
      
      MOV DI,BP
      INC SI
      ADD BP,4 
      LOOP MIXCOL
      MOV BP,DI 
       
      DEC SI 
      MOV CX,3 
      MOV BX,BP
      MOV AH,0
      MOV BP,AX
      
     
      MOV BH,MIXNUM[SI-3]
      MOV X1[BP],BH
      MOV BH,0 
       
      ADDING:
      MOV DI,BP
      MOV DL,MIXNUM[SI]
      XOR X1[BP],DL
      DEC SI
      LOOP ADDING
      MOV BP,DI 
       
      MOV BP,BX
      CMP BP,15
      JZ RESTART
      SUB BP,11
      A2:
      INC AL
      MOV CX,4 
      DEC DH
      CMP DH,0 
      JA MIXCOL
      
      
      MOV CX,16
      MOV SI,0
      RETURN:
      MOV AL,X1[SI]
      MOV X[SI],AL
      INC SI
      LOOP RETURN
      
      POP BP
      POP SI
      POP DX
      POP CX
      POP BX
      POP AX
      
      RET
      
      
      
      HANDEL1:
      XOR AH,27
      JMP A1
      
      RESTART:
      MOV BP,0
      ADD SI,4
      JMP A2
      
      CASE1:
      JMP A1
      
      CASE2:
      SHL AH,1
      JMP A3
      
      CASE3:
      SHL AH,1
      XOR AH,X[BP] 
      JMP A3 
      
ENDP
      
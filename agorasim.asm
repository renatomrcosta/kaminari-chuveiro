; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                        GRUPO KAMINARI		   		   				    *
; *		HIDR�METRO DIGITAL COM TIMER			          					*
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         CONFIGURA��ES PARA GRAVA��O                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

 __CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_ON & _WDT_ON & _XT_OSC

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINI��O DAS VARI�VEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTE BLOCO DE VARI�VEIS EST� LOCALIZADO LOGO NO IN�CIO DO BANCO 0

	CBLOCK	0X20			; POSI��O INICIAL DA RAM

		TEMPO1
		TEMPO0			; CONTADORES P/ DELAY

		FILTRO_BOTOES		; FILTRO PARA RUIDOS

		FLAG			; FLAG DE USO GERAL
		FLAG1			; FLAGS PARA USO DAS ROTINAS ADCIONAIS DE ESCRITA
		FLAG2
		FLAG3
		FLAG4
		FLAG5

		FLAG6
		FLAG7

		FLAGHI

		TIME2


		AUX			; REGISTRADOR AUXILIAR DE USO GERAL
		

	
		UNIDADE			; ARMAZENA VALOR DA UNIDADE
		DEZENA			; ARMAZENA VALOR DA DEZENA
		CENTENA			; ARMAZENA VALOR DA CENTENA

		QTDE_LITROS		; INTENSIDADE DO VENTILADOR
		
		CONTAGEM_MINUTOS 	; VALOR DE MINUTOS NO TIMER PROGRAMA��O INICIAL
		CONTAGEM_SEGUNDOS	; VARIAVEL DE SEGUNDOS
		CONTAGEM_DECIMOS	; VARIAVEL DE MINUTOS
		RESULTANTE		; VARIAVEL PARA PARADA

		PULSOSBEEP		; TRABALHO COM O BUZZER


	

		ACCaHI			; ACUMULADOR a DE 16 BITS UTILIZADO
		ACCaLO			; NA ROTINA DE DIVIS�O

		ACCbHI			; ACUMULADOR b DE 16 BITS UTILIZADO
		ACCbLO			; NA ROTINA DE DIVIS�O

		ACCcHI			; ACUMULADOR c DE 16 BITS UTILIZADO
		ACCcLO			; NA ROTINA DE DIVIS�O

		ACCdHI			; ACUMULADOR d DE 16 BITS UTILIZADO
		ACCdLO			; NA ROTINA DE DIVIS�O

		temp			; CONTADOR TEMPOR�RIO UTILIZADO
					; NA ROTINA DE DIVIS�O

		H_byte			; ACUMULADOR DE 16 BITS UTILIZADO
		L_byte			; P/ RETORNAR O VALOR DA ROTINA
					; DE MULTIPLICA��O

		mulplr			; OPERADOR P/ ROTINA DE MUTIPLICA��O
		mulcnd			; OPERADOR P/ ROTINA DE MUTIPLICA��O

		TEMPERATURA		
		TEMP_CELSIUS	
					

		TEMPO_TURBO		; TEMPORIZADOR P/ TUBO DO TECLADO

		TEMPO_1S		; TEMPORIZADOR DE 1 SEGUNDO

		CONT_VENT_HIGH
		CONT_VENT_LOW		; CONTADORES PARA ROTA��O DO SENSOR


		WORK_TEMP
		STATUS_TEMP
		PCLATH_TEMP
		FSR_TEMP		; REGISTRADORES UTILIZADOS P/ SALVAR
					; O CONTEXTO DURANTE AS INTERRUP��ES


	ENDC

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                DEFINI��O DAS VARI�VEIS INTERNAS DO PIC                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	#INCLUDE <P16F877A.INC>		; MICROCONTROLADOR UTILIZADO

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      DEFINI��O DOS BANCOS DE RAM                        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  OS PSEUDOS-COMANDOS "BANK0" E "BANK1", AQUI DEFINIDOS, AJUDAM A COMUTAR
;  ENTRE OS BANCOS DE MEM�RIA.

#DEFINE	BANK1	BSF	STATUS,RP0 	; SELECIONA BANK1 DA MEMORIA RAM
#DEFINE	BANK0	BCF	STATUS,RP0	; SELECIONA BANK0 DA MEMORIA RAM

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           CONSTANTES INTERNAS                           *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  A DEFINI��O DE CONSTANTES FACILITA A PROGRAMA��O E A MANUTEN��O.

FILTRO_TECLA	EQU	.200		; FILTRO P/ EVITAR RUIDOS DOS BOT�ES

TURBO_TECLA		EQU	.70		; TEMPERIZADOR P/ TURBO DO TECLADO

TMR1_HIGH	EQU	HIGH (.65536-.62500)
TMR1_LOW	EQU	LOW  (.65536-.62500)

COMPARA		EQU	.255		;VARIAVEL DE COMPARA��O DE SEGUNDOS

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                    DECLARA��O DOS FLAGs DE SOFTWARE                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  A DEFINI��O DE FLAGs AJUDA NA PROGRAMA��O E ECONOMIZA MEM�RIA RAM.

#DEFINE	TELA_PRINCIPAL	FLAG,0		; FLAG P/ INDICAR QUE DEVE MOSTRAR
					; A TELA PRINCIPAL
					; 1-> MOSTRA TELA PRINCIPAL
					; 0-> TELA PRINCIPAL J� FOI MOSTRADA
#DEFINE	TELA_DE_STANDBY	FLAG2,0


#DEFINE	TELA_DE_AGRADECIMENTO	FLAG3,0


#DEFINE	ATUALIZAR_TELA	FLAG,0		; FLAG PARA MOSTRAR A ROTA��O NO LCD
					; 1 -> DEVE MOSTRAR A ROTA��O
					; 0 -> NAO DEVE MOSTRAR A ROTA��O

#DEFINE	MOSTRA_TEMP	FLAG,1		; FLAG PARA MOSTRAR A TEMPERATURA NO LCD
					; 1 -> DEVE MOSTRAR A TEMPERATURA
					; 0 -> NAO DEVE MOSTRAR A TEMPERATURA


#DEFINE		VARI_PAUSE		FLAG6,0			; VARI PRA RESETAR CIRCUITO NO PAUSE
#DEFINE		VARI_PAUSE_2		FLAG7,0			;VARI PRA N ZERAR GASTO NO PAUSE
#DEFINE		VARI_ESTADO_PAUSE	FLAG6,1

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                ENTRADAS                                 *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  AS ENTRADAS DEVEM SER ASSOCIADAS A NOMES PARA FACILITAR A PROGRAMA��O E
;  FUTURAS ALTERA��ES DO HARDWARE.

#DEFINE	BOTAO_0		PORTB,0		; ESTADO DO BOT�O 0
					; 1 -> LIBERADO                 
					; 0 -> PRESSIONADO

#DEFINE	BOTAO_1		PORTB,1		; ESTADO DO BOT�O 1
					; 1 -> LIBERADO
					; 0 -> PRESSIONADO

#DEFINE	BOTAO_2		PORTB,2		; ESTADO DO BOT�O 2
					; 1 -> LIBERADO
					; 0 -> PRESSIONADO

#DEFINE	BOTAO_3		PORTB,3		; ESTADO DO BOT�O 3 - ATIVA��O DO TIMER
										; 1 -> CONTANDO
										; 0 -> PARADO

#DEFINE	VARIAVEL_PAUSE		FLAG5,0		;PARA TRAVAR OS BOT�ES DURANTE O PAUSE DO CIRCUITO

#DEFINE	ESTADO_TIMER		PORTA,5	

#DEFINE	BUZZER			PORTA,0

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                 SA�DAS                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  AS SA�DAS DEVEM SER ASSOCIADAS A NOMES PARA FACILITAR A PROGRAMA��O E
;  FUTURAS ALTERA��ES DO HARDWARE.

#DEFINE	DISPLAY		PORTD		; BARRAMENTO DE DADOS DO DISPLAY

#DEFINE	RS		PORTE,0		; INDICA P/ O DISPLAY UM DADO OU COMANDO
					; 1 -> DADO
					; 0 -> COMANDO

#DEFINE	ENABLE		PORTE,1		; SINAL DE ENABLE P/ DISPLAY
					; ATIVO NA BORDA DE DESCIDA

#DEFINE	DB0			PORTE,0		;PULSO DE CLEAR NO LCD. QUANDO SETADO
					;RESETAMOS A TELA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   VETOR DE RESET DO MICROCONTROLADOR                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  POSI��O INICIAL PARA EXECU��O DO PROGRAMA

	ORG	0X0000			; ENDERE�O DO VETOR DE RESET
	GOTO	CONFIG			; PULA PARA CONFIG DEVIDO A REGI�O
					; DESTINADA AS ROTINAS SEGUINTES


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           VETOR DE INTERRUP��O                          *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  POSI��O DE DESVIO DO PROGRAMA QUANDO UMA INTERRUP��O ACONTECE

	ORG	0X0004			; ENDERE�O DO VETOR DE INTERRUP��O

;  � MUITO IMPORTANTE QUE OS REGISTRADORES PRIORIT�RIOS AO FUNCIONAMENTO DA
;  M�QUINA, E QUE PODEM SER ALTERADOS TANTO DENTRO QUANTO FORA DAS INTS SEJAM
;  SALVOS EM REGISTRADORES TEMPOR�RIOS PARA PODEREM SER POSTERIORMENTE
;  RECUPERADOS


SALVA_CONTEXTO
	MOVWF	WORK_TEMP		; SALVA REGISTRADOR DE TRABALHO E 
	SWAPF	STATUS,W		; DE STATUS DURANTE O TRATAMENTO 
	MOVWF	STATUS_TEMP		; DA INTERRUP��O.
	MOVF	FSR,W
	MOVWF	FSR_TEMP		; SALVA REGISTRADOR FSR
	MOVF	PCLATH,W
	MOVWF	PCLATH_TEMP		; SALVA REGISTRADOR PCLATH

	CLRF	PCLATH			; LIMPA REGISTRADOR PCLATH
					; (SELECIONA P�GINA 0)
	CLRF	STATUS			; LIMPA REGISTRADOR STATUS
					; (SELECIONA BANCO 0)


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                TRATAMENTO DA INTERRUP��O DE TIMER 2                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
INT_TMR2
	BCF	PIR1,TMR2IF		; LIMPA FLAG DA INTERRUP��O

	DECFSZ	TEMPO_1S,F		; FIM DO 1 SEGUNDO ?
	GOTO	INT_TMR2_2		; N�O - PULA P/ INT_TMR2_2
					; SIM
	MOVLW	.100
	MOVWF	TEMPO_1S		; RECARREGA TEMPORIZADOR DE 1 SEGUNDO

	BCF	T1CON,TMR1ON		; PARALIZA CONTADOR DO TMR1

	MOVF	TMR1H,W
	MOVWF	CONT_VENT_HIGH
	MOVF	TMR1L,W
	MOVWF	CONT_VENT_LOW		; SALVA VALOR DO TMR1 EM CONT_VENT

	CLRF	TMR1H
	CLRF	TMR1L			; RESETA CONTADORES

	BSF	T1CON,TMR1ON		; LIBERA CONTADORES DO TMR1

	BSF	ATUALIZAR_TELA		; SETA FLAG P/ MOSTRAR VALOR
					; ATUALIZADO DA TELA

INT_TMR2_2
	MOVF	ADRESH,W
	MOVWF	TEMPERATURA		;
					;
	BSF	ADCON0,GO		; 

	BSF	MOSTRA_TEMP		; 
					;

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           SA�DA DA INTERRUP��O                          *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ANTES DE SAIR DA INTERRUP��O, O CONTEXTO SALVO NO IN�CIO DEVE SER
;  RECUPERADO PARA QUE O PROGRAMA N�O SOFRA ALTERA��ES INDESEJADAS.

SAI_INT
	MOVF	PCLATH_TEMP,W
	MOVWF	PCLATH			; RECUPERA REG. PCLATH (PAGINA��O)
	MOVF	FSR_TEMP,W
	MOVWF	FSR			; RECUPERA REG. FSR (END. INDIRETO)
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS			; RECUPERA REG. STATUS
	SWAPF	WORK_TEMP,F
	SWAPF	WORK_TEMP,W		; RECUPERA REG. WORK
	RETFIE				; RETORNA DA INTERRUP��O (HABILITA GIE)

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           ROTINA DE DIVIS�O                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;****************************************************************************
;                       Double Precision Division
;****************************************************************************
;   Division : ACCb(16 bits) / ACCa(16 bits) -> ACCb(16 bits) with
;                                               Remainder in ACCc (16 bits)
;      (a) Load the Denominator in location ACCaHI & ACCaLO ( 16 bits )
;      (b) Load the Numerator in location ACCbHI & ACCbLO ( 16 bits )
;      (c) CALL D_divF
;      (d) The 16 bit result is in location ACCbHI & ACCbLO
;      (e) The 16 bit Remainder is in locations ACCcHI & ACCcLO
;****************************************************************************

D_divF
	MOVLW	.16
	MOVWF	temp			; CARREGA CONTADOR PARA DIVIS�O

	MOVF	ACCbHI,W
	MOVWF	ACCdHI
	MOVF	ACCbLO,W
	MOVWF	ACCdLO			; SALVA ACCb EM ACCd

	CLRF	ACCbHI
	CLRF	ACCbLO			; LIMPA ACCb

	CLRF	ACCcHI
	CLRF	ACCcLO			; LIMPA ACCc

DIV
	BCF	STATUS,C
	RLF	ACCdLO,F
	RLF	ACCdHI,F
	RLF	ACCcLO,F
	RLF	ACCcHI,F
	MOVF	ACCaHI,W
	SUBWF	ACCcHI,W          	;check if a>c
	BTFSS	STATUS,Z
	GOTO	NOCHK
	MOVF	ACCaLO,W
	SUBWF	ACCcLO,W		;if msb equal then check lsb
NOCHK
	BTFSS	STATUS,C		;carry set if c>a
	GOTO	NOGO
	MOVF	ACCaLO,W		;c-a into c
	SUBWF	ACCcLO,F
	BTFSS	STATUS,C
	DECF	ACCcHI,F
	MOVF	ACCaHI,W
	SUBWF	ACCcHI,F
	BSF	STATUS,C		;shift a 1 into b (result)
NOGO
	RLF	ACCbLO,F
	RLF	ACCbHI,F

	DECFSZ	temp,F			; FIM DA DIVIS�O ?
	GOTO	DIV			; N�O - VOLTA P/ DIV
					; SIM
	RETURN				; RETORNA


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           ROTINA DE MULTIPLICA��O                       *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;****************************************************************************
;                   8x8 Software Multiplier
;               ( Fast Version : Straight Line Code )
;****************************************************************************
;
;   The 16 bit result is stored in 2 bytes
; Before calling the subroutine " mpy ", the multiplier should
; be loaded in location " mulplr ", and the multiplicand in
; " mulcnd " . The 16 bit result is stored in locations
; H_byte & L_byte.
;       Performance :
;                       Program Memory  :  37 locations
;                       # of cycles     :  38
;                       Scratch RAM     :   0 locations
;*******************************************************************

; ********************************************
;  Define a macro for adding & right shifting
; ********************************************

mult    MACRO   bit			; Begin macro

	BTFSC	mulplr,bit
	ADDWF	H_byte,F
	RRF	H_byte,F
	RRF	L_byte,F

	ENDM				; End of macro

; *****************************
;   Begin Multiplier Routine
; *****************************

mpy_F
	CLRF	H_byte
	CLRF	L_byte
	MOVF	mulcnd,W		; move the multiplicand to W reg.
	BCF	STATUS,C		; Clear carry bit in the status Reg.

	mult    0
	mult    1
	mult    2
	mult    3
	mult    4
	mult    5
	mult    6
	mult    7

	RETURN				; RETORNA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                     ROTINA DE DELAY (DE 1MS AT� 256MS)                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA � UMA ROTINA DE DELAY VARI�VEL, COM DURA��O DE 1MS X O VALOR PASSADO
;  EM WORK (W).

DELAY_MS
	MOVWF	TEMPO1			; CARREGA TEMPO1 (UNIDADES DE MS)
	MOVLW	.250
	MOVWF	TEMPO0			; CARREGA TEMPO0 (P/ CONTAR 1MS)

	CLRWDT				; LIMPA WDT (PERDE TEMPO)
	DECFSZ	TEMPO0,F		; FIM DE TEMPO0 ?
	GOTO	$-2			; N�O - VOLTA 2 INSTRU��ES
					; SIM - PASSOU-SE 1MS
	DECFSZ	TEMPO1,F		; FIM DE TEMPO1 ?
	GOTO	$-6			; N�O - VOLTA 6 INSTRU��ES
					; SIM
	RETURN				; RETORNA

; DELAY COMUM
DELAY

	MOVLW	.50
	MOVWF	TIME2

DL
	NOP
	NOP
	DECFSZ TIME2,F
	GOTO DL
	RETURN


DELAY_FINAL

	MOVLW	.150
	MOVWF	TIME2
	
DL1
	NOP
	NOP
	DECFSZ	TIME2,F
	GOTO	DL
	RETURN

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               ROTINA DE ESCRITA DE UM CARACTER NO DISPLAY               *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA ENVIA UM CARACTER PARA O M�DULO DE LCD. O CARACTER A SER
;  ESCRITO DEVE SER COLOCADO EM WORK (W) ANTES DE CHAMAR A ROTINA.

ESCREVE
	MOVWF	DISPLAY			; ATUALIZA DISPLAY (PORTD)
	NOP				; PERDE 1US PARA ESTABILIZA��O
	BSF	ENABLE			; ENVIA UM PULSO DE ENABLE AO DISPLAY
	GOTO	$+1			; .
	BCF	ENABLE			; .

	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS
	RETURN				; RETORNA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                               AJUSTE DECIMAL                            *
; *           W [HEX] =  CENTENA [DEC] : DEZENA [DEC] ; UNIDADE [DEC]       *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA RECEBE UM ARGUMENTO PASSADO PELO WORK E RETORNA NAS VARI�VEIS
;  CENTENA, DEZENA E UNIDADE O N�MERO BCD CORRESPOND�NTE AO PAR�METRO PASSADO.

AJUSTE_DECIMAL
	MOVWF	AUX			; SALVA VALOR A CONVERTER EM AUX
	
	CLRF	UNIDADE
	CLRF	DEZENA
	CLRF	CENTENA			; RESETA REGISTRADORES

	MOVF	AUX,F
	BTFSC	STATUS,Z		; VALOR A CONVERTER = 0 ?
	RETURN				; SIM - RETORNA
		

	INCF	UNIDADE,F		; INCREMENTA UNIDADE

	MOVF	UNIDADE,W
	XORLW	0X0A
	BTFSS	STATUS,Z		; UNIDADE = 10d ?
	GOTO	$+3			; N�O
					; SIM
	CLRF	UNIDADE			; RESETA UNIDADE
	INCF	DEZENA,F		; INCREMENTA DEZENA

	MOVF	DEZENA,W
	XORLW	0X0A
	BTFSS	STATUS,Z		; DEZENA = 10d ?
	GOTO	$+3			; N�O
					; SIM
	CLRF	DEZENA			; RESETA DEZENA
	INCF	CENTENA,F		; INCREMENTA CENTENA

	DECFSZ	AUX,F			; FIM DA CONVERS�O ?
	GOTO	$-.14			; N�O - VOLTA P/ CONTINUAR CONVERS�O
	RETURN				; SIM


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *             ROTINA PARA ATUALIZAR A TELA DE LCD		            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA ATUALIZA O MOSTRADOR NO LCD (TEMPO E GASTO) NO LCD.

ATUALIZAR_TELA_LCD

	BCF	ATUALIZAR_TELA				; LIMPA FLAG DE ATUALIZA��O DA RPS

	
;MOSTRA MINUTOS E SEGUNDOS E DECIMOS

	MOVF	CONTAGEM_MINUTOS,W	
	CALL	AJUSTE_DECIMAL			

	BCF		RS						
	MOVLW	0X88					
	CALL	ESCREVE					
	BSF		RS						



	MOVF	DEZENA,W
	ADDLW	0X30					
	CALL	ESCREVE					
	MOVF	UNIDADE,W
	ADDLW	0X30					
	CALL	ESCREVE					


	
	MOVF	CONTAGEM_SEGUNDOS,W		
	CALL	AJUSTE_DECIMAL			

	BCF		RS						
	MOVLW	0X8B					
	CALL	ESCREVE					
	BSF		RS						



	MOVF	DEZENA,W
	ADDLW	0X30					
	CALL	ESCREVE					

	MOVF	UNIDADE,W
	ADDLW	0X30				
	CALL	ESCREVE				


	MOVF	CONTAGEM_DECIMOS,W	
	CALL	AJUSTE_DECIMAL		
	BCF		RS					
	MOVLW	0X8E				
	CALL	ESCREVE				
	BSF		RS					


	MOVF	DEZENA,W
	ADDLW	0X30				
	CALL	ESCREVE				

	MOVF	UNIDADE,W
	ADDLW	0X30				
	CALL	ESCREVE				



;MOSTRA LITROS GASTOS

	BCF	RS						
	MOVLW	0XC8				
	CALL	ESCREVE				
	BSF	RS						




	MOVF	QTDE_LITROS,W
	CALL	AJUSTE_DECIMAL			
						
	MOVF	CENTENA,W
	ADDLW	0X30				
	CALL	ESCREVE				

	MOVF	DEZENA,W
	ADDLW	0X30				
	CALL	ESCREVE				

	MOVF	UNIDADE,W
	ADDLW	0X30				
	CALL	ESCREVE				



	RETURN			


;======================================================
;		TELA DE AGRADECIMENTO
;======================================================	

MOSTRA_TELA_DE_AGRADECIMENTO

	BCF		TELA_DE_AGRADECIMENTO
	
	BSF		DB0

	BCF		RS

	MOVLW	0X01
	CALL 	ESCREVE
	MOVLW	.1
	CALL 	DELAY_MS
	MOVLW	0X83
	CALL 	ESCREVE
	BSF		RS

	MOVLW	'O'		;
	CALL ESCREVE	;	
	MOVLW	'B'		;
	CALL ESCREVE	;		MOSTRA GASTO EM L E m�
	MOVLW	'R'		;		
	CALL ESCREVE	;	
	MOVLW	'I'		;
	CALL ESCREVE	;	
	MOVLW	'G'		;
	CALL ESCREVE	;
	MOVLW	'A'		;
	CALL ESCREVE	;	
	MOVLW	'D'		;		
	CALL ESCREVE	;	
	MOVLW	'O'		;
	CALL ESCREVE	;
	MOVLW	'!'
	CALL ESCREVE	

	BCF		RS
	MOVLW	0XC0
	CALL	ESCREVE
	BSF		RS

	MOVLW	'G'		;
	CALL ESCREVE	;	
	MOVLW	'A'		;
	CALL ESCREVE	;		
	MOVLW	'S'		;		
	CALL ESCREVE	;	
	MOVLW	'T'		;
	CALL ESCREVE	;	
	MOVLW	'O'		;
	CALL ESCREVE	;

	MOVLW	':'		;
	CALL ESCREVE	;	
	MOVLW	' '		;
	CALL ESCREVE	;		



	BCF		RS
	MOVLW	0XCC
	CALL	ESCREVE
	BSF		RS


	MOVLW	'L'
	CALL	ESCREVE



	MOVF	QTDE_LITROS,W
	CALL	AJUSTE_DECIMAL

	BCF	RS			
	MOVLW	0XC8			
	CALL	ESCREVE			
	BSF	RS			

	MOVF	CENTENA,W
	ADDLW	0X30		
	CALL	ESCREVE			

	MOVF	DEZENA,W
	ADDLW	0X30			
	CALL	ESCREVE			

	MOVF	UNIDADE,W
	ADDLW	0X30			
	CALL	ESCREVE			



	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS



	BSF		DB0
	
	BCF		RS

	MOVLW	0X01
	CALL 	ESCREVE
	MOVLW	.1
	CALL 	DELAY_MS
	MOVLW	0X83
	CALL 	ESCREVE
	BSF		RS

	MOVLW	'O'		;
	CALL ESCREVE	;	
	MOVLW	'B'		;
	CALL ESCREVE	;		
	MOVLW	'R'		;		
	CALL ESCREVE	;	
	MOVLW	'I'		;
	CALL ESCREVE	;	
	MOVLW	'G'		;
	CALL ESCREVE	;
	MOVLW	'A'		;
	CALL ESCREVE	;	
	MOVLW	'D'		;		
	CALL ESCREVE	;	
	MOVLW	'O'		;
	CALL ESCREVE	;	
	MOVLW	'!'
	CALL ESCREVE

	BCF		RS
	MOVLW	0XC0
	CALL	ESCREVE
	BSF		RS

	MOVLW	'G'		;
	CALL ESCREVE	;	
	MOVLW	'A'		;
	CALL ESCREVE	;		
	MOVLW	'S'		;		
	CALL ESCREVE	;	
	MOVLW	'T'		;
	CALL ESCREVE	;	
	MOVLW	'O'		;
	CALL ESCREVE	;

	MOVLW	':'		;
	CALL ESCREVE	;	
	MOVLW	' '		;
	CALL ESCREVE	;		


	BCF		RS
	MOVLW	0XCD
	CALL	ESCREVE
	BSF		RS


	MOVLW	'm'
	CALL	ESCREVE
	MOVLW	'3'
	CALL	ESCREVE


	BCF		RS
	MOVLW	0XC8
	CALL	ESCREVE
	BSF		RS


	MOVLW	'0'
	CALL	ESCREVE
	MOVLW	','
	CALL	ESCREVE

	MOVF	QTDE_LITROS,W
	CALL	AJUSTE_DECIMAL

	BCF	RS			
	MOVLW	0XCA			
	CALL	ESCREVE			
	BSF	RS		

	MOVF	CENTENA,W
	ADDLW	0X30			
	CALL	ESCREVE			

	MOVF	DEZENA,W
	ADDLW	0X30			
	CALL	ESCREVE		


	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	CALL	DELAY_MS
	


	GOTO	MOSTRA_TELA_DE_STANDBY


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               ROTINA DE ESCRITA DA TELA PRINCIPAL                       *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MOSTRA_TELA_PRINCIPAL			;ROTINA DE MOSTRA DA TELA PRINCIPAL



	BCF		TELA_PRINCIPAL


	BCF		RS
	MOVLW	0X01
	CALL 	ESCREVE
	MOVLW	.1
	CALL 	DELAY_MS
	MOVLW	0XC2
	CALL	ESCREVE
	BSF		RS

	MOVLW	'G'		;
	CALL ESCREVE	;	
	MOVLW	'R'		;
	CALL ESCREVE	;		SAUDA��O DO GRUPO KAMINARI
	MOVLW	'U'		;		
	CALL ESCREVE	;	
	MOVLW	'P'		;
	CALL ESCREVE	;	
	MOVLW	'O'		;
	CALL ESCREVE	;

	MOVLW	' '		;
	CALL ESCREVE	;	
	
					;		
	MOVLW	'K'		;		
	CALL ESCREVE	;	
	MOVLW	'A'		;
	CALL ESCREVE	;	
	MOVLW	'M'		;
	CALL ESCREVE	;
	MOVLW	'I'		;
	CALL ESCREVE	;	
	MOVLW	'N'		;
	CALL ESCREVE	;		
	MOVLW	'A'		;		
	CALL ESCREVE	;	
	MOVLW	'R'		;
	CALL ESCREVE	
	MOVLW	'I'		;
	CALL ESCREVE	;		


	BCF		RS
	MOVLW	0X80
	CALL 	ESCREVE
	BSF		RS
	
	MOVLW	'B'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'O'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'M'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	' '
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'B'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'A'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'N'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'H'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'O'
	CALL ESCREVE
	CALL DELAY_MS
	MOVLW	'!'
	CALL ESCREVE

	CALL DELAY_MS
	CALL DELAY_MS
	CALL DELAY_MS
	CALL DELAY_MS
	CALL DELAY_MS
	CALL DELAY_MS
	CALL DELAY_MS
	CALL DELAY_MS


MOSTRA_TELA_DE_STANDBY

	BCF		TELA_DE_STANDBY
	BCF		RS
	MOVLW	0X01
	CALL 	ESCREVE
	MOVLW	.1
	CALL 	DELAY_MS
	MOVLW	0X80
	CALL 	ESCREVE
	BSF		RS

	MOVLW	'T'		;
	CALL ESCREVE	;	
	MOVLW	'E'		;
	CALL ESCREVE	;		AQUI EST� A EXIBI��O DO TEMPO INICIAL, QUE SER� MODIFICADO
	MOVLW	'M'		;		PELOS BOT�ES
	CALL ESCREVE	;	
	MOVLW	'P'		;
	CALL ESCREVE	;	
	MOVLW	'O'		;
	CALL ESCREVE	;

	MOVLW	':'		;
	CALL ESCREVE	;	
	
					;		AQUI EST� A EXIBI��O DO TEMPO INICIAL, QUE SER� MODIFICADO
	MOVLW	' '		;		PELOS BOT�ES
	CALL ESCREVE	;	
	MOVLW	' '		;
	CALL ESCREVE	;	
	MOVLW	'0'		;
	CALL ESCREVE	;
	MOVLW	'0'		;
	CALL ESCREVE	;	
	MOVLW	':'		;
	CALL ESCREVE	;		AQUI EST� A EXIBI��O DO TEMPO INICIAL, QUE SER� MODIFICADO
	MOVLW	'0'		;		PELOS BOT�ES
	CALL ESCREVE	;	
	MOVLW	'0'		;
	CALL ESCREVE	
	MOVLW	':'		;
	CALL ESCREVE	;		AQUI EST� A EXIBI��O DO TEMPO INICIAL, QUE SER� MODIFICADO
	MOVLW	'0'		;		PELOS BOT�ES
	CALL ESCREVE	;	
	MOVLW	'0'		;
	CALL ESCREVE	

	BCF		RS
	MOVLW	0XC0
	CALL	ESCREVE
	BSF		RS

	MOVLW	'G'		;
	CALL ESCREVE	;	
	MOVLW	'A'		;
	CALL ESCREVE	;		AQUI EST� A EXIBI��O DO TEMPO INICIAL, QUE SER� MODIFICADO
	MOVLW	'S'		;		PELOS BOT�ES
	CALL ESCREVE	;	
	MOVLW	'T'		;
	CALL ESCREVE	;	
	MOVLW	'O'		;
	CALL ESCREVE	;

	MOVLW	':'		;
	CALL ESCREVE	;	
	MOVLW	' '		;
	CALL ESCREVE	;		AQUI EST� A EXIBI��O DO TEMPO INICIAL, QUE SER� MODIFICADO
	MOVLW	' '		;		PELOS BOT�ES
	CALL ESCREVE	;	
	MOVLW	'0'		;
	CALL ESCREVE	;	
	MOVLW	'0'		;
	CALL ESCREVE	;
	MOVLW	'0'		;
	CALL ESCREVE	;	
	MOVLW	' '		;
	CALL ESCREVE	;		AQUI EST� A EXIBI��O DO TEMPO INICIAL, QUE SER� MODIFICADO
	MOVLW	'L'		;		PELOS BOT�ES
	CALL ESCREVE	;	

	BSF		ATUALIZAR_TELA


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                               LOOP PRINCIPAL                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESSA ROTINA CONTROLA O ACESSO AOS BOT�ES E ATRAV�S DE FLAGS DECREMENTA O TIMER
; DE ACORDO COM O TEMPO

LOOP_PRINCIPAL

	BSF	ADCON0,GO				; INICIA CONVERS�O A/D
								; EXECUTADA APENAS UMA VEZ
	BSF	INTCON,GIE				; HABILITA FLAG GLOBAL DAS
								; INTERRUP��ES

VARRE
	CLRWDT						; LIMPA WATCHDOG TIMER


	BTFSC	ATUALIZAR_TELA			; DEVE MOSTRAR ATUALIZAR LCD ?
	CALL	ATUALIZAR_TELA_LCD		; SIM - CHAMA ROTINA P/ ATUALIZAR TELA




	BTFSC	ESTADO_TIMER		; ROTINA DE TIMER
	CALL	DECREMENTA_TIMER

	BTFSC	BOTAO_3				; O BOT�O 3 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_3		; SIM - PULA P/ TRATA_BOTAO_3
								; N�O


	BTFSC	BOTAO_2				; O BOT�O 2 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_2		; SIM - PULA P/ TRATA_BOTAO_2
								; N�O

	BTFSC	BOTAO_0				; O BOT�O 0 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_0		; SIM - PULA P/ TRATA_BOTAO_0
								; N�O
	BTFSC	BOTAO_1				; O BOT�O 1 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_1		; SIM - PULA P/ TRATA_BOTAO_1
								; N�O




	MOVLW	FILTRO_TECLA		; CARREGA NO WORK O VALOR DE FILTRO_TECLA
	MOVWF	FILTRO_BOTOES		; SALVA EM FILTRO_BOTOES
								; RECARREGA FILTRO P/ EVITAR RUIDOS
	MOVLW	.1	
	MOVWF	TEMPO_TURBO			; CARREGA TEMPO DO TURBO DAS TECLAS
								; COM 1 - IGNORA O TURBO A PRIMEIRA
								; VEZ QUE A TECLA � PRESSIONADA


	GOTO	VARRE				; VOLTA PARA VARRER TECLADO


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                        ROTINAS DE BEEP                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

BEEP
		MOVLW 	0XF0
		MOVWF 	PULSOSBEEP

		BSF 	BUZZER
		MOVLW 	3
		CALL	DELAY
		BCF 	BUZZER
		MOVLW 	3
		CALL	DELAY
		DECFSZ 	PULSOSBEEP,F
		GOTO 	$-7

		RETURN

BEEP_FINAL

		MOVLW 	0XF0
		MOVWF	PULSOSBEEP
		BSF 	BUZZER
		MOVLW 	3
		CALL	DELAY_FINAL
		BCF 	BUZZER
		MOVLW 	3
		CALL	DELAY_FINAL
		DECFSZ 	PULSOSBEEP,F
		GOTO 	$-7

		RETURN

	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         TRATAMENTO DOS BOT�ES                           *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; ************************* TRATAMENTO DO BOT�O 0 ***************************

TRATA_BOTAO_0

	BTFSC	ESTADO_TIMER
	GOTO	VARRE


	BTFSC	VARI_PAUSE_2
	GOTO	DESLIGA_TIMER_GERAL

	DECFSZ	FILTRO_BOTOES,F			; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE				; N�O - VOLTA P/ VARRE
						; SIM - BOT�O PRESSIONADO

	DECFSZ	TEMPO_TURBO,F			; FIM DO TEMPO DE TURBO ?
								; SIM
	GOTO	VARRE				; N�O - VOLTA P/ VARRE

	MOVLW	TURBO_TECLA
	MOVWF	TEMPO_TURBO			; RECARREGA TEMPORIZADOR DO TURBO
								; DAS TECLA
	MOVLW	.15
	XORWF	CONTAGEM_MINUTOS,W
	BTFSS	STATUS,Z
	CALL	BEEP



	MOVLW	.15
	XORWF	CONTAGEM_MINUTOS,W
	BTFSS	STATUS,Z			; LIMITA OS MINUTOS POSS�VEIS EM 15
	INCF	CONTAGEM_MINUTOS,F		; CASO OS MINUTOS ATINJAM TAL VALOR, N�O INCREMENTAR MAIS
				

	MOVF	CONTAGEM_MINUTOS,W		;FAZ AJUSTE DECIMAL
	CALL	AJUSTE_DECIMAL			;DOS MINUTOS E ATUALIZA O LCD

	BCF		RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0X88				; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE				; LINHA E COLUNA
	BSF		RS			; SELECIONA O DISPLAY P/ DADOS


	MOVF	DEZENA,W
	ADDLW	0X30			; FAZ AJUSTE ASCII DA DEZENA
	CALL	ESCREVE			; ESCREVE VALOR NO LCD

	MOVF	UNIDADE,W
	ADDLW	0X30			; FAZ AJUSTE ASCII DA UNIDADE
	CALL	ESCREVE			; ESCREVE VALOR NO LCD
	


									
	GOTO	VARRE				; VOLTA P/ VARREDURA DOS BOT�ES


; ************************* TRATAMENTO DO BOT�O 1 ***************************

TRATA_BOTAO_1

	
	BTFSC	ESTADO_TIMER
	GOTO	VARRE

	BTFSC	VARI_PAUSE_2
	GOTO	DESLIGA_TIMER_GERAL

	DECFSZ	FILTRO_BOTOES,F			; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE				; N�O - VOLTA P/ VARRE
						; SIM - BOT�O PRESSIONADO

	DECFSZ	TEMPO_TURBO,F			; FIM DO TEMPO DE TURBO ?
	GOTO	VARRE				; N�O - VOLTA P/ VARRE
						; SIM
	MOVLW	TURBO_TECLA
	MOVWF	TEMPO_TURBO			; RECARREGA TEMPORIZADOR DO TURBO
						; DAS TECLAS

	MOVF	CONTAGEM_MINUTOS,F
	BTFSS	STATUS,Z
	CALL	BEEP


	MOVF	CONTAGEM_MINUTOS,F
	BTFSS	STATUS,Z			; DECREMENTAR OS MINUTOS AT� ZERO
	DECF	CONTAGEM_MINUTOS,F		; CASO ZERO, N�O REDUZIR MAIS OS MINUTOS
				

	MOVF	CONTAGEM_MINUTOS,W	; FAZ O AJUSTE DECIMAL DOS MINUTOS
	CALL	AJUSTE_DECIMAL		; E ATUALIZA O LCD

	BCF		RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0X88				; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE				; LINHA E COLUNA
	BSF		RS			; SELECIONA O DISPLAY P/ DADOS


	MOVF	DEZENA,W
	ADDLW	0X30			; FAZ AJUSTE ASCII DA DEZENA
	CALL	ESCREVE			; ESCREVE VALOR NO LCD

	MOVF	UNIDADE,W
	ADDLW	0X30			; FAZ AJUSTE ASCII DA UNIDADE
	CALL	ESCREVE			; ESCREVE VALOR NO LCD




	GOTO	VARRE			; VOLTA P/ VARREDURA DOS BOT�ES

; ************************* TRATAMENTO DO BOT�O 2 ***************************

TRATA_BOTAO_2

	BTFSC	VARIAVEL_PAUSE
	GOTO	VARRE
		
	BTFSS	ESTADO_TIMER
	GOTO	VARRE

	DECFSZ	FILTRO_BOTOES,F		; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM - BOT�O PRESSIONADO

	DECFSZ	TEMPO_TURBO,F		; FIM DO TEMPO DE TURBO ?
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM
	MOVLW	.255
	XORWF	CONT_VENT_LOW,W
	BTFSS	STATUS,Z		; INCREMENTA A VARI�VEL A SER DIVIDIDA
	INCF	CONT_VENT_LOW,F		; PELO SENSOR DE VAZ�O
					; N�O
	
	MOVF	CONT_VENT_HIGH,W
	MOVWF	ACCbHI
	MOVF	CONT_VENT_LOW,W		
	MOVWF	ACCbLO			; CARREGA ACCb COM VALOR DO CONTADOR

	CLRF	ACCaHI
	MOVLW	.1
	MOVWF	ACCaLO			; CARREGA ACCa COM O N�MERO DA DIVIS�O
					; DE CALIBRA��O POR LITROS


	CALL	D_divF				; CHAMA ROTINA DE DIVIS�O

	MOVLW	.1				; CHECA O VALOR DA VARI�VEL
	XORWF	ACCbLO				; CASO SEJA O VALOR DIVIDIDO, ELE ADCIONA 1 L NO LCD
	BTFSS	STATUS,Z			; E LIMPA A VARI�VEL
	GOTO	VARRE
	

	INCF	QTDE_LITROS

	CLRF	CONT_VENT_LOW
	
	BSF	ATUALIZAR_TELA

	GOTO	VARRE
; ************************* TRATAMENTO DO BOT�O 3 ***************************

TRATA_BOTAO_3
	DECFSZ	FILTRO_BOTOES,F		; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM - BOT�O PRESSIONADO

	DECFSZ	TEMPO_TURBO,F		; FIM DO TEMPO DE TURBO ?
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM
	MOVLW	TURBO_TECLA
	MOVWF	TEMPO_TURBO		; RECARREGA TEMPORIZADOR DO TURBO
					; DAS TECLAS

	CALL	BEEP			; CHAMA ROTINA DO BUZZER

	BTFSC	VARI_PAUSE_2		; CHECA O ESTADO DE PAUSE
	GOTO	LIGA_TIMER_3		

	BTFSS	ESTADO_TIMER		; LIGA O TIMER CASO DESLIGADO E PAUSA CASO LIGADO
	GOTO	LIGA_TIMER


PAUSA_TIMER				 ; ROTINA RESPONSAVEL PELA PAUSA DO TIMER
	
	BCF	ESTADO_TIMER

	BSF	VARI_PAUSE_2
	
	GOTO	VARRE


DESLIGA_TIMER_GERAL			; DESLIGAMENTO GERAL DO TIMER

	BCF	ESTADO_TIMER

	BCF	VARI_PAUSE
	BCF	VARI_PAUSE_2

	CLRF	CONTAGEM_MINUTOS
	CLRF	CONTAGEM_SEGUNDOS
	CLRF	CONTAGEM_DECIMOS
	CLRF	RESULTANTE	

	CALL	BEEP_FINAL


	GOTO	MOSTRA_TELA_DE_AGRADECIMENTO



; ****************************DECREMENTO DO TIMER****************************

LIGA_TIMER
	

	MOVF	CONTAGEM_SEGUNDOS
	BTFSS	STATUS,Z	
	GOTO	LIGA_TIMER_2

	MOVF	CONTAGEM_MINUTOS
	BTFSS	STATUS,Z
	GOTO	LIGA_TIMER_2
	
	GOTO	VARRE



LIGA_TIMER_2
	
	BSF	ESTADO_TIMER		; ACIONA VALVULA

	MOVF	QTDE_LITROS
	BTFSS	STATUS,Z
	CLRF	QTDE_LITROS

	MOVF	CONT_VENT_LOW
	BTFSS	STATUS,Z
	CLRF	CONT_VENT_LOW
	
	GOTO	VARRE


LIGA_TIMER_3
	
	BSF	ESTADO_TIMER		; ACIONA VALVULA

	BCF	VARI_PAUSE_2

	BCF	VARI_PAUSE
	
	BCF	VARI_ESTADO_PAUSE

	GOTO	VARRE

	
DECREMENTA_TIMER

	DECFSZ	TEMPO_1S,F			; FIM DO 1 SEGUNDO ?
	RETURN
	
	MOVLW	.100
	MOVWF	TEMPO_1S			; RECARREGA TEMPORIZADOR DE 1 SEGUNDO	
	BSF		ATUALIZAR_TELA

	MOVF	CONTAGEM_DECIMOS,F
	BTFSS	STATUS,Z	 		; CONTAGEM DE DECIMOS
	DECF	CONTAGEM_DECIMOS,F		; SIM - DECREMENTA 

	
	MOVF	CONTAGEM_DECIMOS,F		;CHECA SE D�CIMOS = 0
	BTFSS	STATUS,Z			; CASO SEJA, RECARREGA COM 60S
	RETURN
	

	MOVLW	.60
	MOVWF	CONTAGEM_DECIMOS		; REGARREGA COM SESSENTA SEGUNDOS


	MOVF	CONTAGEM_SEGUNDOS
	BTFSS	STATUS,Z			; SE ZERO, N�O DECREMENTE MAIS
	DECF	CONTAGEM_SEGUNDOS,F		; SIM - DECREMENTA

	MOVF	CONTAGEM_SEGUNDOS,F
	BTFSS	STATUS,Z			; SE ZERO, RECARREGUE COM 59 SEGUNDOS
	RETURN

	MOVLW	.59
	MOVWF	CONTAGEM_SEGUNDOS		; RECARREGAR COM 59 SEGUNDOS

	MOVF	CONTAGEM_MINUTOS		; CHECA CONTAGEM DE MINUTOS, CASO ZERO, N�O DECREMENTE MAIS
	BTFSS	STATUS,Z	
	DECF	CONTAGEM_MINUTOS

	MOVF	CONTAGEM_MINUTOS		; CASO CONTAGEM CHEGUE A ZERO, FAZER ULTIMAS COMPARA��ES
	BTFSS	STATUS,Z
	RETURN

	INCF	RESULTANTE

	XORLW	.2
	XORWF	RESULTANTE
	BTFSS	STATUS,Z
	RETURN

	
	GOTO	DESLIGA_TIMER_GERAL
	

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                CONFIGURA��ES INICIAIS DE HARDWARE E SOFTWARE            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  NESTA ROTINA S�O INICIALIZADAS AS PORTAS DE I/O DO MICROCONTROLADOR E AS
;  CONFIGURA��ES DOS REGISTRADORES ESPECIAIS (SFR). A ROTINA INICIALIZA A
;  M�QUINA E AGUARDA O ESTOURO DO WDT.

CONFIG
	CLRF	PORTA			; GARANTE AS SA�DAS EM ZERO
	CLRF	PORTB
	CLRF	PORTC
	CLRF	PORTD
	CLRF	PORTE

	BANK1				; SELECIONA BANCO 1 DA RAM

	MOVLW	B'11011110'
	MOVWF	TRISA			; CONFIGURA I/O DO PORTA

	MOVLW	B'11111111'
	MOVWF	TRISB			; CONFIGURA I/O DO PORTB

	MOVLW	B'11111111'
	MOVWF	TRISC			; CONFIGURA I/O DO PORTC

	MOVLW	B'00000000'
	MOVWF	TRISD			; CONFIGURA I/O DO PORTD

	MOVLW	B'00000100'
	MOVWF	TRISE			; CONFIGURA I/O DO PORTE

	MOVLW	B'11011111'
	MOVWF	OPTION_REG		; CONFIGURA OPTIONS
					; PULL-UPs DESABILITADOS
					; INTER. NA BORDA DE SUBIDA DO RB0
					; TIMER0 INCREM. PELO CICLO DE M�QUINA
					; WDT   - 1:128
					; TIMER - 1:1
					
	MOVLW	B'00000000'		
	MOVWF	INTCON			; CONFIGURA INTERRUP��ES
					; DESABILITADA TODAS AS INTERRUP��ES

	MOVLW	B'00000111'
	MOVWF	ADCON1			; CONFIGURA CONVERSOR A/D
					; CONFIGURA PORTA E PORTE COM I/O DIGITAL

	BANK0				; SELECIONA BANCO 0 DA RAM

;  AS INSTRU��ES A SEGUIR FAZEM COM QUE O PROGRAMA TRAVE QUANDO HOUVER UM
;  RESET OU POWER-UP, MAS PASSE DIRETO SE O RESET FOR POR WDT. DESTA FORMA,
;  SEMPRE QUE O PIC � LIGADO, O PROGRAMA TRAVA, AGUARDA UM ESTOURO DE WDT
;  E COME�A NOVAMENTE. ISTO EVITA PROBLEMAS NO START-UP DO PIC.

	BTFSC	STATUS,NOT_TO		; RESET POR ESTOURO DE WATCHDOG TIMER?
	GOTO	$			; N�O - AGUARDA ESTOURO DO WDT
					; SIM

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         INICIALIZA��O DA RAM                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA IR� LIMPAR TODA A RAM DO BANCO 0, INDO DE 0X20 A 0X7F.
;  EM SEGUIDA, AS VARI�VEIS DE RAM DO PROGRAMA S�O INICIALIZADAS.

	MOVLW	0X20
	MOVWF	FSR			; APONTA O ENDERE�AMENTO INDIRETO PARA
					; A PRIMEIRA POSI��O DA RAM
LIMPA_RAM
	CLRF	INDF			; LIMPA A POSI��O
	INCF	FSR,F			; INCREMENTA O PONTEIRO P/ A PR�X. POS.
	MOVF	FSR,W
	XORLW	0X80			; COMPARA O PONTEIRO COM A �LT. POS. +1
	BTFSS	STATUS,Z		; J� LIMPOU TODAS AS POSI��ES?
	GOTO	LIMPA_RAM		; N�O - LIMPA A PR�XIMA POSI��O
					; SIM

	BSF	TELA_PRINCIPAL		; INICIALIZA MOSTRANDO TELA PRINCIPAL

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                    CONFIGURA��ES INICIAIS DO DISPLAY                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA INICIALIZA O DISPLAY P/ COMUNICA��O DE 8 VIAS, DISPLAY PARA 2
; LINHAS, CURSOR APAGADO E DESLOCAMENTO DO CURSOR � DIREITA. 

INICIALIZACAO_DISPLAY
	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS

	MOVLW	0X30			; ESCREVE COMANDO 0X30 PARA
	CALL	ESCREVE			; INICIALIZA��O

	MOVLW	.3
	CALL	DELAY_MS		; DELAY DE 3MS (EXIGIDO PELO DISPLAY)

	MOVLW	0X30			; ESCREVE COMANDO 0X30 PARA
	CALL	ESCREVE			; INICIALIZA��O

	MOVLW	0X30			; ESCREVE COMANDO 0X30 PARA
	CALL	ESCREVE			; INICIALIZA��O

	MOVLW	B'00111000'		; ESCREVE COMANDO PARA
	CALL	ESCREVE			; INTERFACE DE 8 VIAS DE DADOS

	MOVLW	B'00000001'		; ESCREVE COMANDO PARA
	CALL	ESCREVE			; LIMPAR TODO O DISPLAY

	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS

	MOVLW	B'00001100'		; ESCREVE COMANDO PARA
	CALL	ESCREVE			; LIGAR O DISPLAY SEM CURSOR

	MOVLW	B'00000110'		; ESCREVE COMANDO PARA INCREM.
	CALL	ESCREVE			; AUTOM�TICO � DIREITA

	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

	GOTO	MOSTRA_TELA_PRINCIPAL

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                              FIM DO PROGRAMA                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END				; FIM DO PROGRAMA


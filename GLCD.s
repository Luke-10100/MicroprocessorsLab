#include <xc.inc>

extrn LCD_delay_x4us, LCD_delay_ms
global	GLCD_Setup, GLCD_Test_Write, GLCD_Reset, GLCD_X, GLCD_Y
    
psect	udata_acs   ; named variables in access ram
GLCD_X:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
GLCD_Y:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
GLCD_tmp:	ds 1   ; reserve 1 byte for temporary use
GLCD_I_tmp:	ds 1
GLCD_D_tmp:	ds 1
GLCD_counter:	ds 1   ; reserve 1 byte for counting through nessage

	GLCD_E	EQU 4	; LCD enable bit
    	GLCD_RS	EQU 2	; LCD register select bit
	GLCD_RW	EQU 3	; GLCD r/w select bit
	GLCD_CS2 EQU 1
	GLCD_CS1 EQU 0
	GLCD_RST EQU 5

psect	GLCD_code,class=CODE
    
GLCD_Setup:
	clrf	TRISB, A
	clrf	TRISD, A
	setf    LATB, A
	
	bsf	LATB, GLCD_CS1, A
	bcf	LATB, GLCD_CS2, A
	call	GLCD_on
	
	bcf	LATB, GLCD_CS1, A
	bsf	LATB, GLCD_CS2, A
	call	GLCD_on
	return

GLCD_Write_D:    ; write data on w to display
;    movwf   GLCD_D_tmp, A
    bcf	    LATB, GLCD_E, A	; E low
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bcf	    LATB, GLCD_RW, A	; RW low
    bsf	    LATB, GLCD_RS, A	; RS high
    movf    GLCD_tmp, W, A	
    movwf   LATD, A		; PORTD data in w
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bsf	    LATB, GLCD_E, A	; E high
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bcf	    LATB, GLCD_E, A	; E low
    
    movlw   0x01
    call    LCD_delay_x4us
    
    setf    LATB, A
    setf    LATD, A
    return

GLCD_Write_I:	; write instruction on w to display
    movwf   GLCD_I_tmp, A
    
    bcf	    LATB, GLCD_E, A	; E low
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bcf	    LATB, GLCD_RW, A	; RW low
    bcf	    LATB, GLCD_RS, A	; RS low
    movf    GLCD_I_tmp, W, A	
    movwf   LATD, A		; PORTD data in w
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bsf	    LATB, GLCD_E, A	; E high
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bcf	    LATB, GLCD_E, A	; E low
    
    movlw   0x01
    call    LCD_delay_x4us
    
    setf    LATB, A
    setf    LATD, A
    return

GLCD_Status:    
    bcf	    LATB, GLCD_E, A	; E low
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bsf	    LATB, GLCD_RW, A	; RW low
    bcf	    LATB, GLCD_RS, A	; RS low
    movlw   00010000B	
    movwf   LATD, A		; PORTD data in w
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bsf	    LATB, GLCD_E, A	; E high
    
    movlw   0x01
    call    LCD_delay_x4us
    
    bcf	    LATB, GLCD_E, A	; E low
    
    movlw   0x01
    call    LCD_delay_x4us
    
    setf    LATB, A
    setf    LATD, A
    return
    
GLCD_on:
;    bcf	    LATB, GLCD_RS, A
;    bcf	    LATB, GLCD_RW, A
;    bsf	    LATB, GLCD_CS1, A
;    bcf	    LATB, GLCD_CS2, A
    movlw   00111111B
;    movwf   LATD, A
    call    GLCD_Write_I
;    bsf	    LATB, GLCD_CS1, A
;    bsf	    LATB, GLCD_CS2, A
;    bsf	    LATB, GLCD_RS, A
;    bsf	    LATB, GLCD_RW, A
    return
    
GLCD_Reset:
    bsf	    LATB, GLCD_CS1, A
    bcf	    LATB, GLCD_CS2, A
    bcf	    LATB, GLCD_RST, A
    bsf	    LATB, GLCD_RST, A
    bsf	    LATB, GLCD_CS1, A
    bcf	    LATB, GLCD_CS2, A
    call    GLCD_on

    bcf	    LATB, GLCD_CS1, A
    bsf	    LATB, GLCD_CS2, A
    call    GLCD_on
;    call    GLCD_Status
    return
    
GLCD_Set_L_X:
    bsf	    LATB, GLCD_CS1, A
    bcf	    LATB, GLCD_CS2, A	    
    movlw   10111000B
    iorwf   GLCD_X, W, A
    call    GLCD_Write_I
    return
    
GLCD_Set_R_X:
    bcf	    LATB, GLCD_CS1, A
    bsf	    LATB, GLCD_CS2, A	    
    movlw   10111000B
    iorwf   GLCD_X, W, A
    call    GLCD_Write_I
    return
    
GLCD_Set_L_Y:
    bsf	    LATB, GLCD_CS1, A
    bcf	    LATB, GLCD_CS2, A	    
    movlw   01000000B
    iorwf   GLCD_Y, W, A
    call    GLCD_Write_I
    return
    
GLCD_Set_R_Y:
    bsf	    LATB, GLCD_CS1, A
    bcf	    LATB, GLCD_CS2, A	    
    movlw   01000000B
    iorwf   GLCD_Y, W, A
    call    GLCD_Write_I
    return
    
GLCD_Test_Write:
    movwf   GLCD_tmp, A
    
    call    GLCD_Set_L_X
    movlw   10
    call    LCD_delay_x4us
    
    call    GLCD_Set_R_X
    movlw   10
    call    LCD_delay_x4us
    
    call    GLCD_Set_L_Y
    movlw   10
    call    LCD_delay_x4us
    
    call    GLCD_Set_R_Y
    movlw   10
    call    LCD_delay_x4us

    bsf	    LATB, GLCD_CS1, A
    bcf	    LATB, GLCD_CS2, A

    call    GLCD_Write_D
    movlw   10
    call    LCD_delay_x4us
    return
    
GLCD_Write_tmp:    
    bsf	    LATB, GLCD_CS1, A
    bcf	    LATB, GLCD_CS2, A
    movf    GLCD_tmp, W, A
    call    GLCD_Write_D
    
    movlw   10
    call    LCD_delay_x4us	; wait 40ms for GLCD to start up properly
    
    bcf	    LATB, GLCD_CS1, A
    bsf	    LATB, GLCD_CS2, A
    movf    GLCD_tmp, W, A
    call    GLCD_Write_D
    
    movlw   10
    call    LCD_delay_x4us
    return

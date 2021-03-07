#include <xc.inc>

extrn LCD_delay_x4us, LCD_delay_ms
global	GLCD_Setup
    
psect	udata_acs   ; named variables in access ram
GLCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
GLCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
GLCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
GLCD_tmp:	ds 1   ; reserve 1 byte for temporary use
GLCD_counter:	ds 1   ; reserve 1 byte for counting through nessage

	GLCD_E	EQU 4	; LCD enable bit
    	GLCD_RS	EQU 3	; LCD register select bit
	GLCD_RW	EQU 2	; GLCD r/w select bit

psect	GLCD_code,class=CODE
    
GLCD_Setup:
	clrf    LATB, A
	movlw   11000000B	    ; RB0:5 all outputs
	movwf	TRISB, A
	movlw	00111111B
	call	GLCD_Write_I
	movlw   40
	call	LCD_delay_ms	; wait 40ms for GLCD to start up properly
	return

GLCD_Write_D:    ; write data on w to display
    movwf   LATD, A
    bcf	    LATB, GLCD_RW, A
    bsf	    LATB, GLCD_RS, A
    call    GLCD_Enable
    return

GLCD_Write_I:	; write instruction on w to display
    movwf   LATD, A
    bcf	    LATB, GLCD_RW, A
    bcf	    LATB, GLCD_RS, A
    call    GLCD_Enable
    return
    
;GLCE_Read_Data:	    ; read data
    
GLCD_Enable:	    ; pulse enable bit LCD_E for 500ns
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    bsf	LATB, GLCD_E, A	    ; Take enable high
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    bcf	LATB, GLCD_E, A	    ; Writes data to LCD
    return
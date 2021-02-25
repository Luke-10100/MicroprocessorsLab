	#include <xc.inc>

psect	code, abs

main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
	; a delay subroutine
wait: 
	movlw	0x01
	movwf	0x30, A
waitloop:
	decfsz	0x30, A
	bra	waitloop
	return
	
delay: 
	movlw	0x0f
	movwf	0x20, A
	call	delayloop
	return
	
delayloop:
	movlw	0xff
	movwf	0x30, A
	call	delay1
	decfsz	0x20, A
	bra	delayloop
	return
delay1: 
	movlw	0xff
	movwf	0x40, A
	call	delay2
	decfsz	0x30, A
	bra	delay1
	return
delay2: 
	decfsz	0x01, A
	bra	delay2
	return
SPI_MasterInit:
	bsf	CKE	    ;set for rising, clear for faling edge
	movlw	(SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf	SSP2CON1, A
	bcf	TRISD, PORTD_SDO2_POSN, A
	bcf	TRISD, PORTD_SCK2_POSN, A
	return
incramentalCounter:		    ; loops up to maxCount 
	counter	    equ	    0xb0
	maxCount    equ	    0xff
    	movlw	0x0
	movwf	counter, B
	bra 	test
loop:
	call	delay
	movf	counter, W, B
	call	SPI_MasterTransit
	incf 	counter, F, B
test:
	movlw 	maxCount	    ; Count up to this number OR
	cpfsgt 	counter, A
	bra 	loop		    ; Not yet finished goto start of loop again
	return
simpleTest:			    ; swaps between 0x0f and 0xf0
	movlw	0xf0
	call	SPI_MasterTransit
	call	delay
	movlw	0x0f
	call	SPI_MasterTransit
	call	delay
SPI_MasterTransit:		    ; outputs the contents of w
	movwf   SSP2BUF, A
Wait_Transmit:			    ; wait till completion
	btfss   SSP2IF
	bra	Wait_Transmit
	bcf	SSP2IF
	return
start:
	call	SPI_MasterInit
;test SPI
test_loop:
	call    incramentalCounter	; incraments up to 0xff
;	call	simpleTest		; swaps between 0x0f and 0xf0
	bra	test_loop
	end	main

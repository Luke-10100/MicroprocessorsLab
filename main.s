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
	bsf	CKE
	movlw	(SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf	SSP2CON1, A
	bcf	TRISD, PORTD_SDO2_POSN, A
	bcf	TRISD, PORTD_SCK2_POSN, A
	return
incramentalCounter: 
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
	movwf	counter, A	    ; Test for end of loop condition
	movlw 	maxCount	    ; Count up to this number OR
	cpfsgt 	counter, A
	bra 	loop		    ; Not yet finished goto start of loop again
	return
simpleTest:
	movlw	0xf0
	call	SPI_MasterTransit
	call	delay
	movlw	0x0f
	call	SPI_MasterTransit
	call	delay
SPI_MasterTransit:
    movwf   SSP2BUF, A
Wait_Transmit:
    btfss   SSP2IF
    bra	    Wait_Transmit
    bcf	    SSP2IF
    return
start:
	call	SPI_MasterInit

;test for if new thing
test_loop:
	call    incramentalCounter	; incraments up to memWrite1/2
;	call	simpleTest
	bra	test_loop
	end	main

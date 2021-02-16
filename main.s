	#include <xc.inc>

psect	code, abs

main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
	; a delay subroutine
delay: 
	movlw	0xff
	movwf	0x30, A
	call delay1
	decfsz	0x20, A
	bra delay
	return
delay1: 
	movlw	0x0f
	movwf	0x40, A
	call delay2
	decfsz 0x30, A
	bra delay1
	return
delay2: 
	decfsz 0x40, A
	bra delay2
	return
setup: 
	movlw 	0x0
	movwf	TRISD, A	    ; Port C all outputs
	movlw	0xff
;	movlw	0x1
;	movwf	RD0
	bsf	PORTD, 0, A
	bsf	PORTD, 1, A
	bcf	PORTD, 2, A
	bsf	PORTD, 3, A
	return
start:
	call setup
	
	goto start
	end	main

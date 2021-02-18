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
	movlw	0xff
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
setup: 
	movlw 	0x0		    
	movwf	TRISD, A	    ; Port D all outputs
	setf	TRISE, A
	banksel	PADCFG1
	bsf	REPU
	movlb	0x00
	bsf	PORTD, 0, A	    ; bit 0 = ct1
	bsf	PORTD, 1, A	    ; bit 1 = ct2
	bsf	PORTD, 2, A	    ; bit 2 = oe1
	bsf	PORTD, 3, A	    ; bit 3 = oe2
				    ; all bits start on
	return
clockPulse1: 
	bcf	PORTD, 0, A
	call	wait
	bsf	PORTD, 0, A
	return
clockPulse2: 
	bcf	PORTD, 1, A
	call	wait
	bsf	PORTD, 1, A
	return
readMem1:
;	bsf	PORTD, 3, A		; OE2 high
	bcf	PORTD, 2, A		; OE1 low
	call	clockPulse1		; c1 pulse
	call	wait
;	bsf	PORTD, 2, A		; Reset OE1
					; c2 nothing
	return
readMem2: 
;    	bsf	PORTD, 2, A		; OE1 high
	bcf	PORTD, 3, A		; OE2 low
	call	clockPulse2		; c2 pulse
	bsf	PORTD, 3, A		; Reset OE2
					; c1 nothing
	return
writeMem1: 
;	bsf	PORTD, 2, A		; OE1 high
;	bcf	PORTD, 3, A		; OE2 low
	clrf	TRISE, A
	movlw	0x0f
	movwf	LATE, A
	call	clockPulse1		; c1 pulse
	setf	TRISE, A
;	bsf	PORTD, 3, A		; Reset OE2
					; c2 nothing
	return
writeMem2: 
;	bsf	PORTD, 3, A		; OE2 high
;	bcf	PORTD, 2, A		; OE1 low
	call	clockPulse2		; c2 pulse
;	bsf	PORTD, 2, A		; Reset OE1
					; c1 nothing
	return
start:
	call	setup
;	call	readMem1
;	call	delay
	call	writeMem1
test_loop:
;	call	readMem1
	call	writeMem1
;	call	readMem1
;	call	delay
;	call	delay
;	call	readMem2
;	call	writeMem2
	goto	test_loop
	end	main

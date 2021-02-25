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
setup: 
	movlw 	0x0		    
	movwf	TRISD, A	    ; Port D all outputs
	movlw	0xff
	movwf	PORTD, A
;	bsf	PORTD, 0, A	    ; bit 0 = ct1
;	bsf	PORTD, 1, A	    ; bit 1 = ct2
;	bsf	PORTD, 2, A	    ; bit 2 = oe1
;	bsf	PORTD, 3, A	    ; bit 3 = oe2
				    ; all bits start on
	movlw	0x0
	movwf	TRISC, A
	setf	TRISE, A
	banksel	PADCFG1
	bsf	REPU
	movlb	0x00
	memWrite1	equ	0xA0
	memWrite2	equ	0xA1
	movlw	0xff
	movwf	memWrite1, B
	movlw	0xff
	movwf	memWrite2, B

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
	bcf	PORTD, 2, A		; OE1 low
	call	wait
	call	wait
	movf	PORTE, W, A
	movwf	LATC, A
	bsf	PORTD, 2, A		; Reset OE1
	return
readMem2: 
	bcf	PORTD, 3, A		; OE2 low
	call	wait
	call	wait
	movf	PORTE, W, A
	movwf	LATC, A
	bsf	PORTD, 3, A		; Reset OE2
	return
writeMem1: 
	clrf	TRISE, A
	call	wait
	movf	memWrite1, W, B
	movwf	LATE, A
	call	clockPulse1		; c1 pulse
;	clrf	LATE, A
	setf	TRISE, A
	call	wait
	return
writeMem2: 
	clrf	TRISE, A
	call	wait
	movf	memWrite2, W, B
	movwf	LATE, A
	call	clockPulse2		; c2 pulse
;	CLRF	LATE, A
	setf	TRISE, A
	call	wait
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
;	movwf	memWrite1, B
;	call	writeMem1
;	call	wait
;	call	readMem1
	movwf	memWrite2, B
	call	writeMem2
	call	wait
	call	readMem2
	incf 	counter, F, B
test:
	movwf	counter, A	    ; Test for end of loop condition
	movlw 	maxCount	    ; Count up to this number OR
	cpfsgt 	counter, A
	bra 	loop		    ; Not yet finished goto start of loop again
	return
readWriteTest: 
	call	writeMem1
	call	writeMem2
	call	readMem1
	call	delay
	call	readMem2
	call	delay
	return
start:
	call	setup
	movlw	0x0f			; Move value to be written to external
	movwf	memWrite1, B		; memory 1 to variable memWrite1
	movlw	0xf0			; Move value to be written to external 
   	movwf	memWrite2, B		; memory 2 to variable memWrite2

;test for if new thing
test_loop:
;	call    incramentalCounter	; incraments up to memWrite1/2
	call	readWriteTest		; swaps between memory 1 and 2
	bra	test_loop
	end	main

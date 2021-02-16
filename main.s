	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
	; a delay subroutine
delay: 
	movlw	0xff
	movwf	0x20, A
delayloop:
	movlw	0xff
	movwf	0x30, A
	call delay1
	decfsz	0x20, A
	bra delayloop
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
start:
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	movlw	0xff
	movwf	TRISD, A	    ; Port d all input
	counter equ 0x06
	maxNum	equ 0x1F
	wLoc	equ 0x240
	movlb	0x02
 	movlw	0x0
	movwf	counter, b
	lfsr	0, wLoc
	lfsr	1, wLoc
	bra 	write_test
write_loop:
;	call	delay
	movf	counter, w, b
	movwf	POSTINC0, f, a
	incf 	counter, w, b
write_test:
	movwf	counter, b  ; Test for end of loop condition
	movlw 	maxNum	    ; Count up to this number OR
;	movf	PORTD, W    ; Count up to input number on port D
	cpfsgt 	counter, b
	bra 	write_loop		    ; Not yet finished goto start of loop again
	movlw	0x0
	movwf	counter, b
	lfsr	1, wLoc
	goto read_test
;	goto 	0x0		    ; Re-run program from start
	;test
read_loop: 
	call	delay
	movf	POSTINC1, w, a
	movwf	PORTC, f, a
	incf 	counter, W, b
	
read_test:
	movwf	counter, b	    ; Test for end of loop condition
	movlw 	maxNum		    ; Count up to this number OR
	cpfsgt 	counter, b
	bra 	read_loop	    ; Not yet finished goto start of loop again
	movlw	0x0
	movwf	counter, b
	lfsr	1, wLoc
	goto read_loop
	
	end	main

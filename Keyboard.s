#include <xc.inc>

global  Check_key_press

extrn	LCD_delay_ms, LCD_delay_x4us


psect	udata_acs   ; reserve data space in access ram
row_input: ds	    1
column_input: ds    1
final_input: ds	    1
asci_return: ds	    1
loop_counter: ds    1

psect	udata_bank5 ; reserve data anywhere in RAM (here at 0x400)
solArray:    ds 0x80 ; reserve 128 bytes for message data
    
psect	data
solTable:
	db	0x00, 0x82,0x11,0x12,0x14,0x21,0x22,0x24,0x41,0x42,0x44,0x81,0x84, 0x88, 0x48, 0x28, 0x18, 0x0a
					; message, plus carriage return
		; none, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F
	solTable_l   EQU	18	; length of data
	align	2
	
psect	keyboard_code,class=CODE
	
Keyboard_Setup:
    banksel PADCFG1
    bsf	    REPU
    clrf    LATE, A
    movlw   0x0f
    movwf   TRISE, A
    movlw   1
    call    LCD_delay_x4us
    return

solution_setup:
    call    table_RAM_setup
    return
    
table_RAM_setup:lfsr	0, solArray	; Load FSR0 with address in RAM	
    movlw	low highword(solTable)	; address of data in PM
    movwf	TBLPTRU, A		; load upper bits to TBLPTRU
    movlw	high(solTable)	; address of data in PM
    movwf	TBLPTRH, A		; \load high byte to TBLPTRH
    movlw	low(solTable)	; address of data in PM
    movwf	TBLPTRL, A		; load low byte to TBLPTRL
    movlw	solTable_l	; bytes to read
    movwf 	loop_counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
    movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
    decfsz	loop_counter, A		; count down to zero
    bra	loop		; keep going until finished
    return

example_get_ram_data:
	movlw	solTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, solArray	
	movlw	solTable_l
	addlw	0xff		; don't send the final carriage return to LCD
	return
    
Find_Row:
    movlw   0x0f
    movwf   TRISE, A
    movlw   10
    call    LCD_delay_x4us
    movf    PORTE, W, A
    andlw   0x0f
    movwf   row_input, A
    return

Swap_IO:
    movlw   0xf0
    movwf   TRISE, A
    movlw   1
    call    LCD_delay_x4us
    return

Find_Column:
    movlw   0xf0 
    movwf   TRISE, A
    movlw   10
    call    LCD_delay_x4us
    movf    PORTE, W, A
    andlw   0xf0
    movwf   column_input, A
    return

Check_Input:
	movlw	solTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, solArray	
	movf    row_input, W, A
	iorwf   column_input, W, A
	movwf	final_input, A
	movlw	0xff
	xorwf	final_input, F, A
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra button_pressed
	retlw   0x00
    button_pressed:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_0
	retlw   0x30
    not_sol_0:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_1
	retlw   0x31
    not_sol_1:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_2
	retlw   0x32
    not_sol_2:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_3
	retlw   0x33
    not_sol_3:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_4
	retlw   0x34
    not_sol_4:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_5
	retlw   0x35
    not_sol_5:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_6
	retlw   0x36
    not_sol_6:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_7
	retlw   0x37
    not_sol_7:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_8
	retlw   0x38
    not_sol_8:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_9
	retlw   0x39
    not_sol_9:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_A
	retlw   0x41
    not_sol_A:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_B
	retlw   0x42
    not_sol_B:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_C
	retlw   0x43
    not_sol_C:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_D
	retlw   0x44
    not_sol_D:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	    not_sol_E
	retlw   0x45
    not_sol_E:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_F
	retlw   0x46
    not_sol_F:
	retlw   0xff

    ;    routine to be called
    Check_key_press: 
	call solution_setup
    wait_button:
	call Keyboard_Setup
	call Find_Row
	call Swap_IO
	call Find_Column
	call Check_Input
	movwf asci_return, A
	movlw   0x00
	cpfseq  asci_return, A
	bra found_button
	bra wait_button
    found_button:
	movf   asci_return, W, A
	return

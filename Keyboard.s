#include <xc.inc>

global  Check_key_press

extrn	LCD_delay_ms, LCD_delay_x4us


psect	udata_acs   ; reserve data space in access ram
row_input: ds	    1
column_input: ds    1
final_input: ds	    1
asci_return: ds	    1
loop_counter: ds    1

psect	udata_bank5 ; reserve data anywhere in RAM (here at 0x500)
solArray:    ds 0x80 ; reserve 128 bytes for solutions
    
psect	data
solTable:
	db	0x00, 0x82,0x11,0x12,0x14,0x21,0x22,0x24,0x41,0x42,0x44,0x81,0x84, 0x88, 0x48, 0x28, 0x18, 0x0a
					; message, plus carriage return
		; none, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F
	solTable_l   EQU	18	; length of data
	align	2
	
psect	keyboard_code,class=CODE
	
Keyboard_Setup:
	banksel PADCFG1			; set pull-ups on PORTE
	bsf	REPU
	clrf    LATE, A			; CLEAR LATE
	movlw   0x0f
	movwf   TRISE, A		; bits 0-3 input & 4-7 output
	movlw   1
	call    LCD_delay_x4us		; short delay
	return

solution_setup:
	call    table_RAM_setup
	return
    
table_RAM_setup:lfsr	0, solArray	; Load FSR0 with address in RAM	
        movlw	low highword(solTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(solTable)		; address of data in PM
	movwf	TBLPTRH, A		; \load high byte to TBLPTRH
	movlw	low(solTable)		; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	solTable_l		; bytes to read
	movwf 	loop_counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	loop_counter, A		; count down to zero
	bra	loop		; keep going until finished
	return
    
Find_Row:
	movlw   0x0f
	movwf   TRISE, A	; drive bits 4-7 low
	movlw   10
	call    LCD_delay_x4us	; short delay
	movf    PORTE, W, A	; read bits 0-3 as input
	andlw   0x0f
	movwf   row_input, A	; save in variable row_input
	return

Swap_IO:
	movlw   0xf0		; set bits 0-3 as output and 4-7 as input
	movwf   TRISE, A
	movlw   1
	call    LCD_delay_x4us
	return

Find_Column:
	movlw   0xf0 
	movwf   TRISE, A	; drive bits 0-3 low
	movlw   10
	call    LCD_delay_x4us	; short delay
	movf    PORTE, W, A	; read bits 4-7 as input
	andlw   0xf0
	movwf   column_input, A	; save in variable column_input
	return

Check_Input:
	movlw	solTable_l	
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, solArray	; load array location in RAM
	movf    row_input, W, A	; combine row and column to 1 value
	iorwf   column_input, W, A
	movwf	final_input, A
	movlw	0xff		; XOR this value as analysis was done reversed
	xorwf	final_input, F, A   
	movf    POSTINC2, W, A	; loop through array to find solution
	cpfseq  final_input, A
	bra button_pressed
	retlw   0x00		; if no button pressed (shouldn't happen)
button_pressed:
	movf    POSTINC2, W, A	; loops through solutions 0 -> 9, A -> F
	cpfseq  final_input, A	; if valid solution is found then corresponding
	bra	not_sol_0	; asci code is returned
	retlw   0x30
not_sol_0:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_1
	retlw   0x31
not_sol_1:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_2
	retlw   0x32
not_sol_2:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_3
	retlw   0x33
not_sol_3:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_4
	retlw   0x34
not_sol_4:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_5
	retlw   0x35
not_sol_5:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_6
	retlw   0x36
not_sol_6:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_7
	retlw   0x37
not_sol_7:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_8
	retlw   0x38
not_sol_8:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_9
	retlw   0x39
not_sol_9:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_A
	retlw   0x41
not_sol_A:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra     not_sol_B
	retlw   0x42
not_sol_B:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra     not_sol_C
	retlw   0x43
not_sol_C:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra     not_sol_D
	retlw   0x44
not_sol_D:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_E
	retlw   0x45
not_sol_E:
	movf    POSTINC2, W, A
	cpfseq  final_input, A
	bra	not_sol_F
	retlw   0x46
not_sol_F:
	retlw   0xff		; if no solution is valid then return 0xff

    ;    Waits until key is pressed then returns ASCII char or 0xff if error
Check_key_press: 
	call solution_setup	; Writes valid solutions from PM --> RAM
wait_button:
	call Keyboard_Setup	; Sets up PORTE for keyboard
	call Find_Row		; Finds the row pressed
	movlw	0x0f		; if no button pressed loop back to the start
	cpfseq	row_input, A
	bra	key_pressed	; key pressed so continue 
	bra	wait_button
key_pressed:
	call Swap_IO		; swap PORTEs output and input to find column
	call Find_Column	; find which column was pressed
	call Check_Input	; check the row column input and returns ASCI
				; char is valid configuration or 0xff if error
	movwf asci_return, A	; saves value to asci_return
	movlw   0x00		; checks if no key input
	cpfseq  asci_return, A
	bra found_button	; found a button so return it
	bra wait_button		; wait for button press
found_button:
	movf   asci_return, W, A    ; return the asci char on w
	return

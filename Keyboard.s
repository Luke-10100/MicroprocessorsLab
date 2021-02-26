#include <xc.inc>

global  Check_key_press

extrn	LCD_delay_ms, LCD_delay_x4us


psect	udata_acs   ; reserve data space in access ram
UART_counter: ds    1	    ; reserve 1 byte for variable UART_counter
row_input: ds	    1
column_input: ds    1
final_input: ds	    1
asci_return: ds	    1

;psect	udata_bank4
sol_none: ds	    1
sol_0: ds	    1
sol_1: ds	    1
sol_2: ds	    1
sol_3: ds	    1
sol_4: ds	    1
sol_5: ds	    1
sol_6: ds	    1
sol_7: ds	    1
sol_8: ds	    1
sol_9: ds	    1
sol_A: ds	    1
sol_B: ds	    1
sol_C: ds	    1
sol_D: ds	    1
sol_E: ds	    1
sol_F: ds	    1

    
;psect	data
;solTable:
;	db	0x00, 0x21,0x81,0x82,0x84,0x41,0x42,0x44,0x21,0x22,0x24,0x11,0x14, 0x18, 0x28, 0x38, 0x48,0x0a
;					; message, plus carriage return
;		; none, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F
;	solTable_1   EQU	17	; length of data
;	align	2
	
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
    movlb   0x04
    movlw   0x00
    movwf   sol_none, A
    movlw   0x21
    movwf   sol_0, A
    movlw   0x81
    movwf   sol_1, A
    movlw   0x82
    movwf   sol_2, A
    movlw   0x84
    movwf   sol_3, A
    movlw   0x41
    movwf   sol_4, A
    movlw   0x42
    movwf   sol_5, A
    movlw   0x44
    movwf   sol_6, A
    movlw   0x21
    movwf   sol_7, A
    movlw   0x22
    movwf   sol_8, A
    movlw   0x24
    movwf   sol_9, A
    movlw   0x11
    movwf   sol_A, A
    movlw   0x14
    movwf   sol_B, A
    movlw   0x18
    movwf   sol_C, A
    movlw   0x28
    movwf   sol_D, A
    movlw   0x48
    movwf   sol_E, A
    movlw   0x88
    movwf   sol_F, A
    return
    
Find_Row:
    movlw   0x0f 
    movwf   PORTD, A
    movf    PORTD, W, A
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
    movwf   PORTD, A
    movf    PORTD, W, A
    andlw   0xf0
    movwf   column_input, A
    return

Check_Input:
    movf    row_input, W, A
    iorwf   column_input, W, A
    movwf   final_input, A
    cpfseq  sol_none, A
    bra button_pressed
    retlw   0x00
button_pressed:
    movwf   final_input, A
    cpfseq  sol_0, A
    bra	    not_sol_0
    retlw   0x30
not_sol_0:
    movwf   final_input, A
    cpfseq  sol_1, A
    bra	    not_sol_1
    retlw   0x31
not_sol_1:
    movwf   final_input, A
    cpfseq  sol_2, A
    bra	    not_sol_2
    retlw   0x32
not_sol_2:
    movwf   final_input, A
    cpfseq  sol_3, A
    bra	    not_sol_3
    retlw   0x33
not_sol_3:
    movwf   final_input, A
    cpfseq  sol_4, A
    bra	    not_sol_4
    retlw   0x34
not_sol_4:
    movwf   final_input, A
    cpfseq  sol_5, A
    bra	    not_sol_5
    retlw   0x35
not_sol_5:
    movwf   final_input, A
    cpfseq  sol_6, A
    bra	    not_sol_6
    retlw   0x36
not_sol_6:
    movwf   final_input, A
    cpfseq  sol_7, A
    bra	    not_sol_7
    retlw   0x37
not_sol_7:
    movwf   final_input, A
    cpfseq  sol_8, A
    bra	    not_sol_8
    retlw   0x38
not_sol_8:
    movwf   final_input, A
    cpfseq  sol_9, A
    bra	    not_sol_9
    retlw   0x39
not_sol_9:
    movwf   final_input, A
    cpfseq  sol_A, A
    bra	    not_sol_A
    retlw   0x41
not_sol_A:
    movwf   final_input, A
    cpfseq  sol_B, A
    bra	    not_sol_B
    retlw   0x42
not_sol_B:
    movwf   final_input, A
    cpfseq  sol_C, A
    bra	    not_sol_C
    retlw   0x43
not_sol_C:
    movwf   final_input, A
    cpfseq  sol_D, A
    bra	    not_sol_D
    retlw   0x44
not_sol_D:
    movwf   final_input, A
    cpfseq  sol_E, A
    bra	    not_sol_E
    retlw   0x45
not_sol_E:
    movwf   final_input, A
    cpfseq  sol_F, A
    bra	    not_sol_F
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
    movlw   asci_return
    return
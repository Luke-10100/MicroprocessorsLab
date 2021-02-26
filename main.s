#include <xc.inc>
;test if new
extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D, LCD_clear, LCD_delay_ms, LCD_shiftLine, LCD_moveCurser, LCD_Write_Program_Message
extrn	Check_key_press
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
input_byte: ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	movlw	0xFF
	movwf	TRISD, A
	goto	start
	
read_data_RAM_setup:lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; \load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
	return

write_data_RAM:
	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message
	movlw	myTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray	
	movlw	myTable_l
	addlw	0xff		; don't send the final carriage return to LCD
	call	LCD_Write_Message
	return
	
write_data_PM:
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; \load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l
	addlw	0xff
	call	LCD_Write_Program_Message
	return
	
	; ******* Main programme ****************************************
start: 	
	call	check_key_press
	movwf	input_byte, A
	movlw	0xff
	cpfseq	input_byte, A
	bra	no_error
	bra	start
no_error:
	movf	input_byte, W, A
	call	LCD_Send_Byte_D
;	movlw	0x04
;	cpfslt	PORTD, A
;    	call	LCD_moveCurser	; moves curser to 2nd line
;	call	read_data_RAM_setup ; reads data from progra memory to RAM
;	call	write_data_RAM	; writes data from RAM to LCD
;	call	write_data_PM	; writes data from PM to LCD
	
	movlw	0xff		; 500ms delay
	call	LCD_delay_ms
	movlw	0xff
	call	LCD_delay_ms
	
	call	LCD_clear	; clear display
	
	movlw	0xff		; 500ms delay
	call	LCD_delay_ms
	movlw	0xff
	call	LCD_delay_ms
	
	bra	start	; loop
;	call	LCD_shiftLine
	goto	$		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst
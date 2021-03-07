#include <xc.inc>

global  mult_test, convert_hex_to_bin, bit_16_low, bit_16_high, digit_1, digit_2, digit_3, digit_4
    

psect	udata_acs
bit_8:		    ds 1	; reserve one byte for a counter variable
bit_16_high:	    ds 1    ; reserve one byte for counter in the delay routine
bit_16_low:	    ds 1
prod_16_temp_high:  ds 1
prod_16_temp_low:   ds 1
bit_24_1:	    ds 1
bit_24_2:	    ds 1
bit_24_3:	    ds 1
bit_16_2_high:	    ds 1
bit_16_2_low:	    ds 1
prod_24_temp_low:   ds 1
prod_24_temp_middle:ds 1
prod_24_temp_high:  ds 1   
bit_32_low:	    ds 1
bit_32_lmiddle:	    ds 1
bit_32_umiddle:	    ds 1
bit_32_upper:	    ds 1
prod_24_temp_mhigh: ds 1
prod_24_temp_mlow:  ds 1
digit_1:	    ds 1
digit_2:	    ds 1
digit_3:	    ds 1
digit_4:	    ds 1

psect	Maths_code, class=CODE

check_final_val_24: 
    movf    bit_24_1, w, A
    movf    bit_24_2, w, A
    movf    bit_24_3, w, A
    return
    
check_final_val_32:
    movf    bit_32_low, w, A
    movf    bit_32_lmiddle, w, A
    movf    bit_32_umiddle, w, A
    movf    bit_32_upper, w, A
    return
    
mult_8_x_16:
    movf	bit_8, W, A
    mulwf	bit_16_high, A	    ; Multiply 8 bit number to high 16 bit
    
    movf	PRODH, W, A	    
    movwf	prod_16_temp_high, A    ; store high bit prod_1_temp_high
    
    movf	PRODL, W, A
    movwf	prod_16_temp_low, A	    ; store low bit prod_1_temp_low
    
    movf	bit_8, W, A
    mulwf	bit_16_low, A	    ; multiply 8 bit to low 16 bit
    
    movf	PRODL, W, A
    movwf	bit_24_1, A	    ; low bit is unchanged in 24 bit
    
    movf	PRODH, W, A
    addwf	prod_16_temp_low, W, A	    ; add the initial mult low bit to this high bit
    movwf	bit_24_2, A		    ; store as middle bit
    
    movlw	0x00
    addwfc	prod_16_temp_high, W, A     ; add the carry bit to final value 
    movwf	bit_24_3, A
    return

mult_16_x_16:
    movf    bit_16_2_low, W, A
    movwf   bit_8, A
    call    mult_8_x_16		    ; multiply lower 8 bit by 16 bit
    
    movf    bit_24_1, W, A
    movwf   prod_24_temp_low, A	    ; store in temp variables, low
    
    movf    bit_24_2, W, A
    movwf   prod_24_temp_middle, A  ; middle
    
    movf    bit_24_3, W, A
    movwf   prod_24_temp_high, A    ; high
    
    movf    bit_16_2_high, W, A
    movwf   bit_8, A		    
    call    mult_8_x_16		    ; multiply upper 8 bit by 16 bit
    
    movf    prod_24_temp_low, W, A
    movwf   bit_32_low, A	    ; 0 = L
    
    movf    prod_24_temp_middle, W, A
    addwf   bit_24_1, W, A	    
    movwf   bit_32_lmiddle, A	    ; 1 = M + L'
    
    movf    prod_24_temp_high, W, A
    addwfc  bit_24_2, W, A
    movwf   bit_32_umiddle, A	    ; 2 = U + M' + C
    
    movlw   0x00
    addwfc  bit_24_3, W, A
    movwf   bit_32_upper, A	    ; 3 = U' + C
    
    return

mult_8_x_24:
    movf	bit_8, W, A
    mulwf	bit_24_3, A	    ; Multiply 8 bit number to high 24 bit
    
    movf	PRODH, W, A	    
    movwf	prod_24_temp_high, A    ; store high bit prod_1_temp_high
    
    movf	PRODL, W, A
    movwf	prod_24_temp_low, A	    ; store low bit prod_1_temp_low
    
    movf	bit_8, W, A
    mulwf	bit_24_2, A	    ; multiply 8 bit to middle 24 bit
    
    movf	PRODH, W, A
    movwf	prod_24_temp_mhigh, A	   ; high bit stored prod_24_temp_mhigh
    
    movf	PRODL, W, A
    movwf	prod_24_temp_mlow, A	   ; low bit stored prod_24_temp_mlow
    
    movf	bit_8, W, A
    mulwf	bit_24_1, A	    ; multiply 8 bit to low 24 bit
    
    movf	PRODL, W, A
    movwf	bit_32_low, A	    ; 0 = L0
    
    movf	PRODH, W, A
    addwf	prod_24_temp_mlow, W, A
    movwf	bit_32_lmiddle, A   ; 1 = L1 + M0 
    
    movf	prod_24_temp_mhigh, W, A
    addwfc	prod_24_temp_low, W, A
    movwf	bit_32_umiddle, A   ; 2 = M1 + U0 + C
    
    movlw	0x00
    addwfc	prod_24_temp_high, W, A
    movwf	bit_32_upper, A	    ; 3 = U1 + C
    
    return
    
select_nums:
;    ; selecting an 8 bit and 16 bit number
;    movlw	0x0A
;    movwf	bit_8, A
;    movlw	0x93
;    movwf	bit_16_low, A
;    movlw	0xD4
;    movwf	bit_16_high, A
    
;    ; selecting 2 16 bit numbers
;    movlw	0xDE
;    movwf	bit_16_2_high, A
;    movlw	0xAD
;    movwf	bit_16_2_low, A
;    movlw	0x69
;    movwf	bit_16_low, A
;    movlw	0x69
;    movwf	bit_16_high, A
    
    ; selecting an 8 bit and 21 bit number
    movlw	0xBB
    movwf	bit_8, A
    movlw	0x69
    movwf	bit_24_3, A
    movlw	0x52
    movwf	bit_24_2, A
    movlw	0x0D
    movwf	bit_24_1, A
    return
    
mult_test:
    call    select_nums
    call    mult_8_x_24
    call    check_final_val_32
    return

convert_hex_to_bin:
    movlw	0x8A
    movwf	bit_16_2_low, A
    movlw	0x41
    movwf	bit_16_2_high, A	; k = 0x418A
    
;    movlw	0x04
;    movwf	bit_16_high, A
;    movlw	0xD2
;    movwf	bit_16_low, A	 ; input value, here 0x042D
    
    call	mult_16_x_16		; k * input digit
    movf	bit_32_upper, W, A	
    movwf	digit_1, A		; first digit output
    
    movf	bit_32_umiddle, W, A	; remainder * 0x0A
    movwf	bit_24_3, A
    movf	bit_32_lmiddle, W, A
    movwf	bit_24_2, A
    movf	bit_32_low, W, A
    movwf	bit_24_1, A
    movlw	0x0A
    movwf	bit_8, A		; n = 10
    call	mult_8_x_24
    
    movf	bit_32_upper, W, A
    movwf	digit_2, A		; first digit output
    
    movf	bit_32_umiddle, W, A	; remainder * 0x0A
    movwf	bit_24_3, A
    movf	bit_32_lmiddle, W, A
    movwf	bit_24_2, A
    movf	bit_32_low, W, A
    movwf	bit_24_1, A
    movlw	0x0A
    movwf	bit_8, A		; n = 10
    call	mult_8_x_24
    
    movf	bit_32_upper, W, A	; output first digit
    movwf	digit_3, A
    
    movf	bit_32_umiddle, W, A	; remainder * 0x0A
    movwf	bit_24_3, A
    movf	bit_32_lmiddle, W, A
    movwf	bit_24_2, A
    movf	bit_32_low, W, A
    movwf	bit_24_1, A
    movlw	0x0A
    movwf	bit_8, A		; n = 10
    call	mult_8_x_24
    
    movf	bit_32_upper, W, A
    movwf	digit_4, A		; output 4th digit
    
    return
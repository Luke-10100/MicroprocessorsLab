#include <xc.inc>

global  mult_test
    

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
bit_36_low:	    ds 1
bit_36_lmiddle:	    ds 1
bit_36_umiddle:	    ds 1
bit_36_upper:	    ds 1

psect	Maths_code, class=CODE

check_final_val_8_16: 
    movf    bit_24_1, w, A
    movf    bit_24_2, w, A
    movf    bit_24_3, w, A
    return
    
check_final_val_16_16:
    movf    bit_36_low, w, A
    movf    bit_36_lmiddle, w, A
    movf    bit_36_umiddle, w, A
    movf    bit_36_upper, w, A
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
    movwf   bit_36_low, A	    ; 0 = L
    
    movf    prod_24_temp_middle, W, A
    addwf   bit_24_1, W, A	    
    movwf   bit_36_lmiddle, A	    ; 1 = M + L'
    
    movf    prod_24_temp_high, W, A
    addwfc  bit_24_2, W, A
    movwf   bit_36_umiddle, A	    ; 2 = U + M' + C
    
    movlw   0x00
    addwfc  bit_24_3, W, A
    movwf   bit_36_upper, A	    ; 3 = U' + C
    
    return

mult_8_x_24:
    movf	bit_8, W, A
    mulwf	bit_24_3, A	    ; Multiply 8 bit number to high 24 bit
    
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
    
select_nums:
;    movlw	0x0A
;    movwf	bit_8, A
;    movlw	0x93
;    movwf	bit_16_low, A
;    movlw	0xD4
;    movwf	bit_16_high, A
    movlw	0xDE
    movwf	bit_16_2_high, A
    movlw	0xAD
    movwf	bit_16_2_low, A
    movlw	0x69
    movwf	bit_16_low, A
    movlw	0x69
    movwf	bit_16_high, A
    return
    
mult_test:
    call    select_nums
    call    mult_16_x_16
    call    check_final_val_16_16
    return
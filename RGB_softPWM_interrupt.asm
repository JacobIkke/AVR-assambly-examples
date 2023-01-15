;
; Asm RGB_softPWM_interrupt.asm
;
; Created: 15-1-2023 18:23:27
; Author : Peetgaming
;

.include "tn13def.inc"

.def red_pwm = r16   ; register for PWM duty cycles red
.def green_pwm = r17 ; register for PWM duty cycles red
.def blue_pwm = r18 ; register for PWM duty cycles red
.def red_compare = r19
.def green_compare = r20
.def blue_compare = r21

.def pwm_counter = r22

; ISR routine
.org 0x00 ; Interrupt vector at location
rjmp ISR ; Jump to ISR routine

ISR:
    push r16 ; Save all the registers
    push r17
    push r18
    push r19
    push r20
    push r21
    push r22

    inc pwm_counter						; counter++
    cpi pwm_counter, 0xFF				; Comaper PWM counter 
    breq reset							; If equal branch to reset:

	red:
		cp pwm_counter, red_compare				
		brlo red_off
		sbi PORTB, PB0				; Turn PB0 on (red)
		rjmp green
	red_off:
		cbi PORTB, PB0				; Turn PB0 off (red)

	green:
		cp pwm_counter, green_compare
		brlo green_off
		sbi PORTB, PB1 ; Turn on green LED
		rjmp blue

	green_off:
		cbi PORTB, PB1 ; Turn off green LED

	blue:
		cp pwm_counter, blue_compare
		brlo blue_off
		sbi PORTB, PB2 ; Turn on blue LED
		rjmp end

	blue_off:
		cbi PORTB, PB2 ; Turn off blue LED

	end:
		pop r22 ; Restore registers
		pop r21
		pop r20
		pop r19
		pop r18
		pop r17
		pop r16
		reti ; Return from interrupt

	reset:
		ldi pwm_counter, 0x00
		rjmp end

; Set the RGB colors
rgb_pwm:
    mov red_pwm, r24	; Red duty into registers
    mov green_pwm, r23  ; Green duty into registers
    mov blue_pwm, r22	; Blue duty into registers
	;RED
		clr r1 ; Clear carry flag
		ldi r16, 8
		subi red_pwm, 100
		brcc red_comp_done
		ldi red_compare, 0xff
		rjmp red_comp_done
	red_comp_loop:
		asr red_pwm
		dec r16
	red_comp_done:
	;Green
		clr r1
		ldi r16, 8
		subi green_pwm, 100
		brcc green_end
		ldi green_compare, 0xff
		rjmp green_end
	green_comp_loop:
		asr green_pwm
		dec r16
	green_end:

	; Blue
		clr r1
		ldi r16, 8
		subi blue_pwm, 100
		brcc blue_comp_done
		ldi blue_compare, 0xff
		rjmp blue_comp_done
	blue_comp_loop:
		asr blue_pwm
		dec r16
	blue_comp_done:
		ret


; main program
.org 0x100
rjmp init

init:
    ldi r16, (1 << PB0) | (1 << PB1) | (1 << PB2)	                ; Set RGB pins as output
    out DDRB, r16													; Set initial color
    rcall rgb_pwm												; Call set_rgb_pwm
    ldi r16, (1 << CS00)											; Load bit CS00 for TCCR0B into r16 
    out TCCR0B, r16													; Set Timer0 for overflow interrupt
    ldi r16, (1 << TOIE0)											; load bit for TOIE0 register into r16
    out TIMSK0, r16													; set TIMSK0 
    sei																;  Enable interrupts

main_loop:															
    ldi r24, 100			; 100 0 0
    ldi r23, 0
    ldi r22, 0
    rcall rgb_pwm
    ldi r25, 20
wait_1:
    dec r25
    brne wait_1
    ldi r24, 0				; 0 100 0
    ldi r23, 100
    ldi r22, 0
    rcall rgb_pwm
    ldi r25, 20
wait_2:
    dec r25
    brne wait_2
    ldi r24, 0				; 0 0 100
    ldi r23, 0
    ldi r22, 100
    rcall rgb_pwm
    ldi r25, 30
wait_3:
    dec r25
    brne wait_3
    ldi r24, 0				; 0 100 0
    ldi r23, 100
    ldi r22, 0
    rcall rgb_pwm
    ldi r25, 20
wait_4:
    dec r25
    brne wait_4
    rjmp main_loop

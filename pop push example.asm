;
; Stack pop and push test 1.asm
;
; Created: 5-1-2023 22:13:22
; Author : PeetGaming
;
; Push and POP example code
; Example: Led on pin PB4 will blink fast, delay, blink slow, delay. Repeat this infinity
; In this code we push two values on the stack and pop them back when needed for the delay
; r19 will hold value that will be move into r18 of the delay1 loop, that will effect the delay speed. 

init:
    ldi r16, 0b0010000			; load bit for PB4 into r16    
    out DDRB, r16    

main:
	
	ldi r19, 0x05			; load 0x02 into r19
	PUSH r19			; push it on the stack - stack 1
	ldi r19, 0x25			; load 0x0a into r19 
	PUSH r19			; push it on the stack - stack 2

		
	pop r19				; r19 will load stack 2 into r19 = 0x05  last in, first out
	sbi PORTB, PB4              	; PB4 HIGH
    	rcall delay1			; delay depenent on r19 value, higher value is longer delay
	cbi PORTB, PB4              	; PB4 LOW
    	rcall delay1			; delay 

	rcall delay_long		; fixed delay between two examples. 


	pop r19				; r19 will load stack 1 into r19 = 0x25  last in, first out
	sbi PORTB, PB4              	; PB4 HIGH
    	rcall delay1			; delay depenent on r19 value, higher value is longer delay
	cbi PORTB, PB4              	; PB4 LOW
   	 rcall delay1			; delay 

	rcall delay_long		; fixed delay between two examples. 

	rjmp main   			; jump to main, infinity loop

delay1:					; The outer loop
   	ldi r16, 255               	; Initial the timers values
    	ldi r17, 255
	mov r18, r19
delay_i:				; The inner loop
    	dec  r16                    	; dec r16 255 times, 255 x 1 cycle delay
    	brne delay_i			; branch if not equal to beginning of timerb
	dec  r17                    	; if r16 is not equal that dec r17 255, 255 x 1 cycle delay
    	brne delay_i			; branch if not equal to beginning of timer2 - 1 clock * 256, then 1
    	dec  r18			; if r16 is 0 that dec r17 255, 255 x 1 cycle delay
    	brne delay_i                	; Branch if not equal to beginning of timer2 - 1 clock * 5, then 1
    	ret   

delay_long:				; The outer loop
	ldi r16, 255                	; Initial the timers values
	ldi r17, 255
	ldi r18, 75
delay_i2:				; The inner loop
   	dec  r16                    	; dec r16 255 times, 255 x 1 cycle delay
    	brne delay_i2			; branch if not equal to beginning of timerb
	dec  r17                    	; if r16 is not equal that dec r17 255, 255 x 1 cycle delay
    	brne delay_i2			; branch if not equal to beginning of timer2 - 1 clock * 256, then 1
    	dec  r18			; if r16 is 0 that dec r17 255, 255 x 1 cycle delay
    	brne delay_i2                	; Branch if not equal to beginning of timer2 - 1 clock * 5, then 1
    	ret 

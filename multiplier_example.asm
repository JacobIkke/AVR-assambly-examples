;
; Mulitplier ASM github.asm
;
; Created: 7-1-2023 22:47:37
; Author : PeetGaming
;
; Software multipleir function, because attiny cores don't have MUL instuction we must do it in software.

.dseg							            ; Start Data segment
.org 0x0060						        ; Start storing, for attiny13 the RAM starts at 0x0060 end at 0x009F, 64 x 8bit

multiplier: .byte 1				    ; initial 1 byte for multiplier
multiplicand: .byte 1			    ; initial 1 byte for the multiplicand
result: .byte 1					      ; initial 1 byte for the results

.cseg							            ; Start Code segment
init:
    ldi r16, 0b0010000			  ; Load bit PB4 into r16    
    out DDRB, r16    

main:
	ldi r16, 0x01				        ; Load multiplier value in r16
	sts multiplier, r16			    ; Store r16 into ram
	ldi r16, 0x010				      ; Load multiplicand value in r16
	sts multiplicand, r16		    ; Store r16 into ram
	
	rcall multplier				      ; call the  multiplier routine

  sbi PORTB, PB4              ; Clock HIGH
  rcall timer					        ; delay          
  cbi PORTB, PB4              ; clcok LOW
	rcall timer					        ; delay

    rjmp main

multplier: 
	lds	r16, multiplier			    ; load multipleir form memory into register
	lds	r17, multiplicand		    ; load multiplicand form memory into register
	ldi	r19, 0					        ; Load zero into r18 to make sure that it's zero when we start the multipleir loop
multi_inner1:
	add r19, r16				        ; add multiplicand to the result register
	dec r17						          ; decrease the multiplier
	brne multi_inner1			      ; compare if multipleir is zero jet, if not barnch back to multi_inner label. 
	sts result, r19				      ; if multipleir is zero store the result in the result register R19. 
	ret

timer:							            ; The outer loop
    ldi r16,255                 ; Initial the timers values
    ldi r17,255
	  mov r18, r19
timer_i:						            ; The inner loop
    dec r16                     ; dec r16 255 times, 255 x 1 cycle delay
    brne timer_i				        ; branch if not equal to the beginning of timer loop
	  dec r17                     ; if r16 is not equal that dec r17 255, 255 x results of multipleir cycle delay
    brne timer_i				        ; branch if not equal to beginning of timer2 - 1 clock * 256, then 1
    dec r18						          ; if r16 is 0 that dec r17 255, 255 x 1 cycle delay
    brne timer_i                ; Branch if not equal to beginning of timer2 - 1 clock * 5, then 1
    ret                         ; End after 256 * 256 * results of multipleir = cycles delay   

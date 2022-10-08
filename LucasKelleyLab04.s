;*******************************************************************************
;
;    CS 107: Computer Architecture and Organization -- LAB 4
;    Filename: Lab04.s
;    Date: [3/29/22]
;    Author: [Lucas Kelley]
;
;*******************************************************************************
;
	GLOBAL __main
	AREA main, CODE, READONLY
	EXPORT __main
	EXPORT __use_two_region_memory
__use_two_region_memory EQU 0
	EXPORT SystemInit
	ENTRY


; System Init routine
SystemInit
;
	LDR		R0, =data_bfr
	LDR		R1, =0x589d654c
	LDR		R2, =0xcf678e09
	MOV		R3, #256
sysinit_loop
	EOR		R4, R1, R2
	STR		R4, [R0], #4
	AND		R4, #0xF
	RORS	R1, R1, R4
	RRX		R2, R2
	SUBS	R3, #1
	BNE		sysinit_loop
;
	BX		LR
;
; Main program
;
__main
;
; 1. Clear data_bfr... Fill data_bfr by all zeros
;
; 256 of 0x00 bytes or 128 of 0x0000 halfwords or 64 of 0x00000000 words
;
; 'data_bfr' is placed beginning address 0x10000000
; Use 'Memory' windows in debugger to make sure first 256 bytes are 0's.
;
; +-------------------------------------------------------------------+
; !                                                                   !
; !  Please, do not use 'hardcoded' address 0x10000000 in your code!  !
; !                                                                   !
; !                   Use label 'data_bfr' instead!                   !
; !                   -----------------------------                   !
; !                                                                   !
; !                For example: 'LDR   R0, =data_bfr'                 !
; !                                                                   !
; +-------------------------------------------------------------------+
;
;-- Your instructions here ---

	LDR 	R0, =data_bfr
	MOV 	R1, #0x00000100
	ADD 	R1, R0
	MOV 	R2, #0
loop
	STRB 	R2, [R0]
	ADD 	R0, #1
	TEQ		R0, R1
	BNE 	loop

;
; 2. Write the code that calculates the length of null-terminated string.
;
; R0 - address of null-terminated string.
; R1 - length of the string.
;
; Make sure your code works with empty string too!
;
; You may use any other register(s)
;
; Possible implementation:
;
;
;  ln = 0
;  while (*(r0++)) {
;     ln++;}
;
; Test your code with both 'test_str_1' (length = 11) and 'test_str_2' 
; (length = 0) strings.
; 
; ---------------------
	ADR		R0, test_str_1
; ---------------------
;	ADR		R0, test_str_2
;-- Your instructions here ---

	MOV R0, #0x5100 

	MOV 	R1, #0
loop_2
	LDRB 	R3, [R0, #0]
	TEQ 	R3, #0
	BEQ 	done_2
	ADD 	R0, #1
	ADD 	R1, #1
	B 		loop_2
	
done_2

;
; 3. Write the code that copies null-terminated string into 'data_bfr'
;
; R0 - address of null-terminated string.
;
; Make shure you are copiing the null-byte in the end of the string too!
;
; Make sure your code works with empty string too!
;
; You may use any other register(s)
;
; Possible implementation:
;
; dst_ptr = @data_bfr
; do {
;      c = *r0++
;	   *dst_ptr++ = c
; } while(c != 0)
;
; Test your code with both 'test_str_1' and 'test_str_2' strings.
;
; Use 'Memory' windows at address 0x10000000 in debugger to see if the strings
; are copied properly
;
; ---------------------
	ADR		R0, test_str_1
; ---------------------
;	ADR		R0, test_str_2
;-- Your instructions here ---

	LDR 	R1, =data_bfr
loop_3
	LDRB 	R3, [R0, #0]
	TEQ 	R3, R2
	BEQ 	done_3
	STRB 	R3, [R1]
	ADD 	R0, #1
	ADD 	R1, #1
	B 		loop_3
	
done_3

;
; 4. Calculate an average value of all elements in array. Elements are
; unsigned 16-bit integer ([0...0xffff]).
; 
; R0 - address of first element in the array;
; R1 - the number of elements in array (may be any number,
;      not a power of 2. May be 0 also)
; R2 - calculated average
;
; If number of elements is 0, the average should be zero. 
; *** Remember! You can not divide by 0! ***
;
; You may use any other register(s)
;
; Check your code for all 3 test cases.
; 
	ADR		R0, test_data_1
	MOV		R1, #10				; result = 59 (0x3B)
; ---------------------
;	ADR		R0, test_data_1
;	MOV		R1, #0				; result = 0
; ---------------------
;	ADR		R0, test_data_2
;	MOV		R1, #12				; result = 0xFFF0
;-- Your instructions here ---
	
	MOV 	R2, #0
	MOV 	R3, #0
loop_4
	TEQ 	R3, R1
	BEQ 	divide
	ADD 	R3, #1
	LDRH 	R4, [R0]
	ADD 	R0, R0, #2
	ADD 	R2, R4
	B loop_4
divide
	TEQ 	R1, #0
	BEQ		done_4
	UDIV 	R2, R1
	
done_4

;
; 5. Decrypt the secret message. The secret message is placed beginning 'secret_message' label
; The key is placed at 'secret_key' label. The length of the key is 16 bytes (you may use it in
; your code). The decoding procedure is XOR between message character and key character. 
; The message is longer than key, so, if the end of key is reached, start using the key again from it's
; first cheracter. Like this:
; 
; Msg:    m0  m1  m2  ... m14 m15 m16 m17 m18 ...
;         xor xor xor ... xor xor xor xor xor ...
; Key:    'H' 'u' 'm' ... '4' '5' 'H' 'u' 'm' ...
;
; Rslt:   s0  s1  s2  ... s14 s15 s16 s17 s18 ...
;
; You should continue while decrypted character is not null ('\0' or 0x00)
;
; You may use any other register(s)
;
; Possible implementation:
;
;  key_index = 0
;  message_ptr = @secret_message;
;  result_ptr = @data_bfr;
;  do {
;		c = *message_ptr++;
;		c = c xor secret_key[key_index];
;		*result_ptr = c;
;		key_index = (key_index++) & 0xf
;  } while (c != 0)
;
; Use 'Memory' windows at address 0x10000000 in debugger to read decrypted secret message.
;
;-- Your instructions here ---

	LDR 	R0, =data_bfr
	LDR 	R1, =secret_message
	LDR 	R2, =secret_key
	MOV 	R6, #16
	MOV 	R7, #0
loop_5
	LDRB 	R3, [R1, #0]
	LDRB 	R4, [R2, #0]
	EOR 	R3, R4
	TEQ 	R3, #0
	BEQ 	done_5
	STRB	R3, [R0]
	ADD 	R0, #1
	ADD 	R1, #1
	ADD 	R2, #1
	ADD 	R7, #1
	TEQ 	R7, R6
	LDREQ 	R2, =secret_key
	MOVEQ 	R7, #0
	B 		loop_5
	
done_5
	
;
; 6. (ADWANCED) Suppose you do not know the 'endianness' of your processor. 
; Write a program that writes '1' to R0 if the processor is little-endian 
; or '2' if the processor is big-endian.
;
; You may use any other register(s)
;
; LPC4088 is 'little-endian', so correct result is R1 = 1. Check yourself!
;
;-- Your instructions here ---
;--- About 7 instructions ----

	LDR 	R0, =data_bfr
	LDR 	R1, =0x12345678
	STR 	R1, [R0]
	LDRB 	R2, [R0, #0]
	TEQ 	R2, #0x00000078
	MOVEQ 	R1, #1
	MOVNE 	R2, #2
;
; 7. (BONUS) Write the code to convert value of R0 (binary unsigned number in the 
; range of [0..9999]) to null-terminated string. Store the resulting string
; into 'data_bfr'.
;
; Result string should be null-terminated, right-aligned with leading spaces.
;
; Examples:
;
;   R0 = 0    -> '   0'\0
;   R0 = 5    -> '   5'\0
;   R0 = 78   -> '  78'\0
;   R0 = 1542 -> '1542'\0
;
; You may use any other register(s)
;
; data_bfr is placed beginning address 0x10000000
; Use 'Memory' windows in debugger to read decripted secret message.
;
; Check your code for all 4 test cases.
;
	MOV		R0, #0
; ---------------------
;	MOV		R0, #5
; ---------------------
;	MOV		R0, #78
; ---------------------
;	MOV		R0, #1524

;-- Your instructions here ---	

;
; 8. (BONUS+) Based on code for previous task, change the output format to:
;
;                    'd.ddd' 
;
; d - is a digit from 0 throw 9.
;
; Examples:
;
;   R0 = 0    -> '0.000'\0
;   R0 = 5    -> '0.005'\0
;   R0 = 78   -> '0.078'\0
;   R0 = 1542 -> '1.542'\0
;
; You may use any other register(s)
;
; data_bfr is placed beginning address 0x10000000
; Use 'Memory' windows in debugger to read decripted secret message.
;
; Check your code for all 4 test cases.
;
	MOV		R0, #0
; ---------------------
;	MOV		R0, #5
; ---------------------
;	MOV		R0, #78
; ---------------------
;	MOV		R0, #1524

;-- Your instructions here ---



;
stop
	B		stop
	ALIGN

test_str_1
	DCB		"SBCC CS 107", 0
	ALIGN
test_str_2
	DCB		0
	ALIGN		
test_data_1
	DCW		45, 30, 127, 64, 82, 1, 56, 13, 84, 95 
	ALIGN
test_data_2
	DCW		0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0, 0xFFF0
	ALIGN
secret_key
	DCB		"HumanitiesLab245"   ; 16 symbols
	ALIGN
secret_message
	DCB     0x0b, 0x26, 0x5c, 0x51, 0x59, 0x49, 0x1d, 0x1a
	DCB     0x45, 0x07, 0x24, 0x04, 0x42, 0x50, 0x51, 0x46
	DCB		0x3c, 0x55, 0x0e, 0x0e, 0x02, 0x05, 0x11, 0x0E
	DCB		0x00, 0x53, 0x2f, 0x0d, 0x03, 0x41, 0x47, 0x15
	DCB		0x2d, 0x03, 0x08, 0x13, 0x4f, 0x69
	ALIGN
		
	AREA variables, DATA, ALIGN=2
data_bfr
	SPACE	256

	END
@ Test code for my own new function called from C
 
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
 
 
    .code   16              @ This directive selects the instruction set being generated.
                            @ The value 16 selects Thumb, with the value 32 selecting ARM.

    @ Data section - initialized values
    .data

    all_light_ticks:    .word 0
    delay:              .word 0
    button_pressed:     .word 0

    LEDaddress:         .word 0x48001014
 
    .text                   @ Tell the assembler that the upcoming section is to be considered
                            @ assembly language instructions - Code section (text -> ROM)
 
@@ Function Header Block
    .align  2               @ Code alignment - 2^n alignment (n=2)
                            @ This causes the assembler to use 4 byte alignment
 
    .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                            @ instructions. The default is divided (separate instruction sets)
 
    .global yj_watch
    .global _xx_a5_tick_handler
    .global _xx_a5_button_handler
    .global toggle_all_lights
 
    .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
    .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                            @ encoded function. Necessary for interlinking between ARM and THUMB code.

@ Define a constant
    .equ BUTTON_NOT_PRESSED, 0
    .equ BUTTON_PRESSED, 1

@ Function Declaration: int yj_watch(uint32_t timeout, uint32_t delay)
@
@ Input: r0, r1, r2 (i.e. r0 holds timeout, r1 holds delay)
@ Returns: n/a
@
@ Here is the actual function
yj_watch:
    push {r4-r7, lr}        @@ Put aside registers we want to restore later

    @ store input value r1 to the address of variable delay and all_light_ticks
    ldr r3, =delay
    str r1, [r3]
    ldr r3, =all_light_ticks
    str r1, [r3]

    bl mes_InitIWDG         @@ init watchdog, set input value r0 as timeout

    bl mes_IWDGStart        @@ start watchdog

    pop {r4-r7, lr}
    bx lr

@@ Function Declaration : void _xx_a5_tick_handler( void )
@
@ The method react to timer interrupt
@
@ Input: n/a
@ Returns: n/a
@
@ Here is the actual function
_xx_a5_tick_handler:
   
    push {r4-r7, lr}

    @ compare if delay value is 0, if true, go to end
    ldr r1, =delay
    ldr r0, [r1]
    cmp r0, #0
    beq end

    @ compare if button_pressed value is BUTTON_PRESSED, if true, jump over refreshing watchdog
    ldr r1, =button_pressed
    ldr r0, [r1]
    cmp r0, #BUTTON_PRESSED
    beq buttonPressedNoMoreWatchDogRefesh

    @ refreshing watchdog
    bl mes_IWDGRefresh

buttonPressedNoMoreWatchDogRefesh:
    @ load ticks value and substract one if the current on light is kept on target
    ldr r1, =all_light_ticks  @@ Address of all_light_ticks stored in r1
    ldr r0, [r1]              @@ Load r0 with the address pointed at by r1 (all_light_ticks address)
    subs r0, r0, #1           @@ Decrease r0 by 1
    str  r0, [r1]             @@ Store the current r0 value back to the address pointed at by r1

    @ if all_light_ticks is greater than zero, go to end, otherwise toggle all lights and reset all_light_ticks
    bgt end

    @ toggle all the lights
    bl toggle_all_lights

    @ set all_light_ticks value back to delay
    ldr r1, =delay
    ldr r0, [r1]
    ldr r1, =all_light_ticks
    str r0, [r1]

    b end

end:
    pop {r4-r7, lr}
    bx  lr                  @@ Return to the address stored in lr
    .size   _xx_a5_tick_handler, .-_xx_a5_tick_handler    @@ - symbol size (not req)

@ Function Declaration: void toggle_all_lights()
@
@ The method toggles all the lights
@
@ Input: n/a
@ Returns: n/a
@
@ Here is the actual function
toggle_all_lights:
    push {r4-r7, lr}

    ldr r1, =LEDaddress @ Load the GPIO address we need
    ldr r1, [r1]        @ Dereference r1 to get the value we want
    ldrh r0, [r1]       @ Get the current state of that GPIO (half word only)
    eor r0, r0, #0xff00 @ Use bitwise XOR (EOR) to reset the bit at 0xff00
    strh r0, [r1]       @ Write the half word back to the memory address for the GPIO

    pop {r4-r7, lr}
    bx lr


@@ Function Declaration : void _xx_a5_button_handler( void )
@
@ The method react to timer interrupt
@
@ Input: n/a
@ Returns: n/a
@
@ Here is the actual function
_xx_a5_button_handler:
    push {r4-r7, lr}        @@ Put aside registers we want to restore later

    @ set button_pressed to BUTTON_PRESSED
    ldr r3, =button_pressed
    mov r0, #BUTTON_PRESSED
    str r0, [r3]

    pop {r4-r7, lr}
    bx lr

@ Assembly file ended by single .end directive on its own line
.end
 
Things past the end directive are not processed, as you can see here.
; stack layout and handling

STACK = $0100 ; the 6502 stack is always located at page 1

; the base of the stack for every task always contains the following
EXIT    = STACK + 0xF6  ; pointer to exit function
OUTPUTP = STACK + 0xF8  ; output parameters
OUTPUT  = STACK + 0xFA  ; output function pointer
INPUTP  = STACK + 0xFC  ; input parameters
INPUT   = STACK + 0xFE  ; input function pointer
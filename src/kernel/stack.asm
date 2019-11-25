; stack layout and handling

STACK = $0100 ; stack is always at page 1

; the base of the stack for every task always contains the following
INIT_EP     = STACK + $F2  ; initial process stack pointer
EXITP       = STACK + $F4  ; pointer to exit function
TASKID      = STACK + $F6  ; task identifier
OUTPUTP     = STACK + $F8  ; output parameters
OUTPUT      = STACK + $FA  ; output function pointer
INPUTP      = STACK + $FC  ; input parameters
INPUT       = STACK + $FE  ; input function pointer
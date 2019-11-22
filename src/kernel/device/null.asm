; null device

; The null device is a dummy I/O device that can be used to redirect a task's
; input or output to a device that essentially does nothing.

; always returns End of Stream error
dev_null_input:
    lda IO_EOS
    sec
    rts

; always returns success
dev_null_output:
    clc
    rts

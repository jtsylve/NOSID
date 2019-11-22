; I/O subsystem

; NOSID supports arbitrary redirection of each tasks input and output to any
; device that conforms to the appropriate interface.  At the base of the tasks'
; stack there are two pointers (INPUT and OUTPUT).  Changing these pointers
; effectively redirect input or output to the device of your choosing.
;
; The INPUT function must meet the following interface requirements:
;   -   There are two bytes of parameters stored on that tasks stack at INPUTP.
;       The contents of these bytes are implementation defined.
;   -   Return status is indicated by the carry bit.  If the bit is clear, then
;       the byte read is returned in A.  If the bit is set, an error condition
;       that is defined in this file is stored in A.
;
; The OUTPUT function must meet the following interface requirements:
;   -   There are two bytes of parameters stored on that tasks stack at OUTPUTP.
;       The contents of these bytes are implementation defined.
;   -   Return status is indicated by the carry bit.  The bit is clear on 
;       success.  If the bit is set, an error condition that is defined in this 
;       file is stored in A.

IO_SUCCESS      = 0 ; the I/O operation was successful
IO_ERROR        = 1 ; generic I/O error
IO_NODATA       = 2 ; there is currently no data to read
IO_EOS          = 3 ; all data has been read (end of stream)
IO_BROKEN_PIPE  = 4 ; the I/O device is no longer active

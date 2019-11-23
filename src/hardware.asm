; convenience labels for hardware registers

; 6510 CPU
CPU_DDR     = $0000 ; data direction register
CPU_OUTR    = $0001 ; output register

; interrupt vectors
VECTOR_NMI  = $FFFA ; non-maskable interrupt vector
VECTOR_CS   = $FFFC ; cold start vector
VECTOR_IRQ  = $FFFE ; IRQ/BRK vector

; CIA 1
CIA1_PRA        = $DC00 ; data port A
CIA1_PRB        = $DC01 ; data port B
CIA1_DDRA       = $DC02 ; data direction port A
CIA1_DDRB       = $DC03 ; data direction port B
CIA1_TA_LO      = $DC04 ; timer A latch low byte
CIA1_TA_HI      = $DC05 ; timer A latch high byte
CIA1_TB_LO      = $DC06 ; timer B latch low byte
CIA1_TB_HI      = $DC07 ; timer B latch high byte
CIA1_TOD_10THS  = $DC08 ; RTC 1/10th seconds
CIA1_TOD_SEC    = $DC09 ; RTC seconds
CIA1_TOD_MIN    = $DC0A ; RTC minutes
CIA1_TOD_HR     = $DC0B ; RTC hours
CIA1_SDR        = $DC0C ; serial shift register
CIA1_ICR        = $DC0D ; interrupt control and status
CIA1_CRA        = $DC0E ; control timer A
CIA1_CRB        = $DC0F ; control timer B

; CIA 2
CIA2_PRA        = $DD00 ; data port A
CIA2_PRB        = $DD01 ; data port B
CIA2_DDRA       = $DD02 ; data direction port A
CIA2_DDRB       = $DD03 ; data direction port B
CIA2_TA_LO      = $DD04 ; timer A latch low byte
CIA2_TA_HI      = $DD05 ; timer A latch high byte
CIA2_TB_LO      = $DD06 ; timer B latch low byte
CIA2_TB_HI      = $DD07 ; timer B latch high byte
CIA2_TOD_10THS  = $DD08 ; RTC 1/10th seconds
CIA2_TOD_SEC    = $DD09 ; RTC seconds
CIA2_TOD_MIN    = $DD0A ; RTC minutes
CIA2_TOD_HR     = $DD0B ; RTC hours
CIA2_SDR        = $DD0C ; serial shift register
CIA2_ICR        = $DD0D ; interrupt control and status
CIA2_CRA        = $DD0E ; control timer A
CIA2_CRB        = $DD0F ; control timer B

; VICII
VICII_M0X   = $D000 ; X coordinate sprite 0
VICII_M0Y   = $D001 ; Y coordinate sprite 0
VICII_M1X   = $D002 ; X coordinate sprite 1
VICII_M1Y   = $D003 ; Y coordinate sprite 1
VICII_M2X   = $D004 ; X coordinate sprite 2
VICII_M2Y   = $D005 ; Y coordinate sprite 2
VICII_M3X   = $D006 ; X coordinate sprite 3
VICII_M3Y   = $D007 ; Y coordinate sprite 3
VICII_M4X   = $D008 ; X coordinate sprite 4
VICII_M4Y   = $D009 ; Y coordinate sprite 4
VICII_M5X   = $D00A ; X coordinate sprite 5
VICII_M5Y   = $D00B ; Y coordinate sprite 5
VICII_M6X   = $D00C ; X coordinate sprite 6
VICII_M6Y   = $D00D ; Y coordinate sprite 6
VICII_M7X   = $D00E ; X coordinate sprite 7
VICII_M7Y   = $D00F ; Y coordinate sprite 7
VICII_MSB   = $D010 ; MSBs of X coordinates
VICII_CR1   = $D011 ; control register 1
VICII_RAS   = $D012 ; raster counter
VICII_LPX   = $D013 ; light pen X
VICII_LPY   = $D014 ; light pen Y
VICII_SE    = $D015 ; sprint enable
VICII_CR2   = $D016 ; control register 2
VICII_MYE   = $D017 ; sprite Y expansion
VICII_PTR   = $D018 ; memory pointers
VICII_IR    = $D019 ; interrupt register
VICII_IE    = $D01A ; interrupt enabled
VICII_MDP   = $D01B ; sprite data priority
VICII_MMC   = $D01C ; sprite multicolor
VICII_MXE   = $D01D ; sprite X expansion
VICII_MM    = $D01E ; sprite-sprite collision
VICII_MD    = $D01F ; sprite-data collision
VICII_EC    = $D020 ; border color
VICII_B0C   = $D021 ; background color 0
VICII_B1C   = $D022 ; background color 1
VICII_B2C   = $D023 ; background color 2
VICII_B3C   = $D024 ; background color 3
VICII_MM0   = $D025 ; sprite multicolor 0
VICII_MM1   = $D026 ; sprite multicolor 1
VICII_M0C   = $D027 ; sprite 0 color
VICII_M1C   = $D028 ; sprite 1 color
VICII_M2C   = $D029 ; sprite 2 color
VICII_M3C   = $D02A ; sprite 3 color
VICII_M4C   = $D02B ; sprite 4 color
VICII_M5C   = $D02C ; sprite 5 color
VICII_M6C   = $D02D ; sprite 6 color
VICII_M7C   = $D02E ; sprite 7 color

; color ram
COLOR_RAM       = $D800
COLOR_RAM_SIZE  = $03E8

; VICII colors
BLACK       = 0
WHITE       = 1
RED         = 2
CYAN        = 3
PURPLE      = 4
GREEN       = 5
BLUE        = 6
YELLOW      = 7
ORANGE      = 8
BROWN       = 9
LIGHT_RED   = 10
DARK_GRAY   = 11
MED_GRAY    = 12
LIGHT_GREEN = 13
LIGHT_BLUE  = 14
LIGHT_GRAY  = 15
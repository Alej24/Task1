.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
.exportzp player_x, player_y

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00


  JSR draw_player

  STA $2005
  STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes


  JSR draw_obstacles


vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; write player ship tile numbers
  LDA #$04
  STA $0201
  LDA #$05
  STA $0205
  LDA #$06
  STA $0209
  LDA #$07
  STA $020d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_obstacles
	; Draw obstacles
  ; and update attribute tables

	; draw ships facing right
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$43
	STA PPUADDR	
	LDX #$28		; sails of pirate ships
	STX PPUDATA
	LDX #$29
	STX PPUDATA
	LDX #$28
	STX PPUDATA
	LDX #$29
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$63
	STA PPUADDR
	LDX #$2a		; bottom half of pirate ships
	STX PPUDATA
	LDX #$2b
	STX PPUDATA
	LDX #$2c
	STX PPUDATA
	LDX #$2d
	STX PPUDATA


	; draw ships facing up
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$47
	STA PPUADDR
	LDX #$42		; sails of pirate ships
	STX PPUDATA
	LDX #$43
	STX PPUDATA
	LDX #$46
	STX PPUDATA
	LDX #$47
	STX PPUDATA
	LDX #$4a
	STX PPUDATA
	LDX #$4b
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$67
	STA PPUADDR
	LDX #$44		; bottom half of pirate ships
	STX PPUDATA
	LDX #$45
	STX PPUDATA
	LDX #$48
	STX PPUDATA
	LDX #$49
	STX PPUDATA
	LDX #$4c
	STX PPUDATA
	LDX #$4d
	STX PPUDATA


	; draw ships facing left
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$81
	STA PPUADDR
	LDX #$2e		; sails of pirate ships
	STX PPUDATA
	LDX #$2f
	STX PPUDATA
	LDX #$2e
	STX PPUDATA
	LDX #$2f
	STX PPUDATA
	LDX #$2e
	STX PPUDATA
	LDX #$2f
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$a1
	STA PPUADDR
	LDX #$30		; bottom half of pirate ships
	STX PPUDATA
	LDX #$31
	STX PPUDATA
	LDX #$32
	STX PPUDATA
	LDX #$33
	STX PPUDATA
	LDX #$34
	STX PPUDATA
	LDX #$35
	STX PPUDATA


	; draw ships facing down
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$87
	STA PPUADDR
	LDX #$36		; sails of pirate ships
	STX PPUDATA
	LDX #$37
	STX PPUDATA
	LDX #$3a
	STX PPUDATA
	LDX #$3b
	STX PPUDATA
	LDX #$3e
	STX PPUDATA
	LDX #$3f
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$a7
	STA PPUADDR
	LDX #$38		; bottom half of pirate ships
	STX PPUDATA
	LDX #$39
	STX PPUDATA
	LDX #$3c
	STX PPUDATA
	LDX #$3d
	STX PPUDATA
	LDX #$40
	STX PPUDATA
	LDX #$41
	STX PPUDATA


	; draw level 1 sprites (sand, crate, seaweed)
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$e1
	STA PPUADDR
	LDX #$50		; top half of sand
	STX PPUDATA
	LDX #$51
	STX PPUDATA
	LDX #$54		; top half of crate
	STX PPUDATA
	LDX #$55
	STX PPUDATA
	LDX #$58		;top half of seaweed
	STX PPUDATA
	LDX #$59
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$01
	STA PPUADDR
	LDX #$52		; bottom half of sand
	STX PPUDATA
	LDX #$53
	STX PPUDATA
	LDX #$56		; bottom half of crate
	STX PPUDATA
	LDX #$57
	STX PPUDATA
	LDX #$5a		; bottom half of seaweed
	STX PPUDATA
	LDX #$5b
	STX PPUDATA


	; draw level 2 sprites (buoy, arch tentacle, tentacle tip)
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$e9
	STA PPUADDR
	LDX #$60		; top half of buoy
	STX PPUDATA
	LDX #$61
	STX PPUDATA
	LDX #$64		; top half of arch tentacle
	STX PPUDATA
	LDX #$65
	STX PPUDATA
	LDX #$68		; top half of tentacle tip
	STX PPUDATA
	LDX #$69
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$09
	STA PPUADDR
	LDX #$62		; bottom half of buoy
	STX PPUDATA
	LDX #$63
	STX PPUDATA
	LDX #$66		; bottom half of arch tentacle
	STX PPUDATA
	LDX #$67
	STX PPUDATA
	LDX #$6a		; bottom half of tentacle tip
	STX PPUDATA
	LDX #$6b
	STX PPUDATA



	; attribute tables
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c0
	STA PPUADDR
	LDA #%10101010
	STA PPUDATA

    LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c1
	STA PPUADDR
	LDA #%10101010
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c2
	STA PPUADDR
	LDA #%10101010
	STA PPUDATA

    LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c3
	STA PPUADDR
	LDA #%10101010
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c8
	STA PPUADDR
	LDA #%00001010
	STA PPUDATA

    LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c9
	STA PPUADDR
	LDA #%00001010
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$ca
	STA PPUADDR
	LDA #%01011010
	STA PPUDATA

    LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$cb
	STA PPUADDR
	LDA #%01011010
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$d0
	STA PPUADDR
	LDA #%00000000
	STA PPUDATA

    LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$d1
	STA PPUADDR
	LDA #%00000000
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$d2
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$d3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

	RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $2c, $07, $17, $38
.byte $2c, $04, $25, $30
.byte $2c, $0f, $07, $30
.byte $2c, $19, $09, $29

.byte $2c, $0f, $07, $30
.byte $2c, $19, $09, $29
.byte $2c, $24, $09, $29
.byte $2c, $3a, $24, $11

.segment "CHR"
.incbin "spriteAnim.chr"
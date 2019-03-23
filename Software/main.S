/*
 *  Hamed Mirlohi
 *  Box Detection and Image Replacement Final Project
 * 	Last Modified: 3/22/2019
 *
 * 	Description:
	Implented GUI using seven sagments and switches to control the menu.
 *  ============
 *  
*/

# ======================
# === Port Addresses ===
# ======================

# Nexys 4 board base I/O interface ports compatible with the Nexy$4 I/O interface
# Port Addresses
PORT_LEDS 			= 0xbf800000		# (o) LEDs
PORT_SLSWTCH		= 0xbf800004		# (i) slide switches
PORT_PBTNS 			= 0xbf800008		# (i) pushbuttons inputs

# ========================================================================
# Change the following port address, as implemented by you in the hardware
# ========================================================================

PORT_SEVENSEG_EN 	= 0xbf700000		# (o) 7 Segment enable
PORT_SEVENSEG_HGH	= 0xbf700004		# (o) 7 Segment Higher Display
PORT_SEVENSEG_LOW	= 0xbf700008		# (o) 7 Segment Lower Display
PORT_SEVENSEG_DP	= 0xbf70000c		# (o) 7 segment Decimal Point Display

PORT_IP_CONTROL     = 0xbf800010


ENABLE				= 0x01000E1C		# value for "Enable"
BLUE				= 0x0B1A0000		# value for "Blue"

.text
.globl main
main:
				add	$23, $0, ENABLE				// initialize color select to 1-En
				add $20, $0, BLUE				// initialize color select to Bl-0

				li 	$2, PORT_SEVENSEG_EN		// Enable 7sagments, leave out 3rd and 6th sagment off
				li 	$25, 0x24
				sw	$25, 0($2)
				li 	$2, PORT_SEVENSEG_LOW		// Write to Low and High 7sagments
				sw  $23, 0($2)

                li	$3, PORT_IP_CONTROL         // address of register of IP control is loaded on register $3

				li 	$2, PORT_SEVENSEG_HGH       // loading the PORT_SEVENSEG_HGH to $2 register
				sw	$20, 0($2)                  // write data to PORT_SEVENSEG_HGH from $20 register ( currently it holds data to display b on 7 segment display )

# ==================
# === Main  Loop ===
# ==================
												
main_L1:

				li	  $2, PORT_SLSWTCH		// load current positions of the switches
				lw	  $21, 0($2)            // store the current position of switches to register $21
                sw	  $21, 0($3)            // storing the switch data to register $3

				and $18, $21, 0x1			//masking the 1st switch which tells us enable/disable superimpose feature
				and $17, $21, 0x6			//masking the 2nd & 3rd switch which will give us 4 options of which image to superimpose.
				and $16, $21, 0x8			//masking the 4th switch to decide which color box to detect.


				beq $18, $0, disable		// if $18 is 0 then jump to disable subroutine.
				nop

				en:
				beq $18, 0x1,enable         // if $18 is 1 then jump to enable subroutine.
				nop

				img0:
				beq $17, $0, img_0          // if $17 is 0 then jump to img_0
				nop

				img1:
				beq $17, 0x2, img_1         // if $17 is 1 then jump to img_1
				nop


				img2:
				beq $17, 0x4, img_2         // if $17 is 2 then jump to img_2
				nop

				img3:
				beq $17, 0x6, img_3         // if $17 is 3 then jump to img_3
				nop

				gr:
				beq $16, $0, green          // if $16 is 0 then jump to green
				nop

				bl:
				beq $16, 0x8, blue          // if $16 is 1 then jump to blue
				nop


				j	main_L1						// no switch is triggered, back to main loop



disable:
				li	 $2, PORT_SEVENSEG_LOW
				and  $8,$23,0xFFFF0000			// mask lower 2 letters
				or 	 $23, $8, 0x0d18            // loading data which displays 'di' 
				sw  $23, 0($2)                  // display di on 1st & 2nd 7 segment display
				j en

enable:
				li	 $2, PORT_SEVENSEG_LOW
				and  $8,$23,0xFFFF0000			// mask lower 2 letters
				or 	 $23, $8, 0x0E1C            // loading data which displays 'En' 
				sw  $23, 0($2)                  // display En on 3rd & 4th 7 segment display
				j img0
img_0:

				li	 $2, PORT_SEVENSEG_LOW
				and  $8,$23,0x0000FFFF
				or 	 $23, $8, 0x01000000        // loading data which displays '1' 
				sw  $23, 0($2)                  // display 1 on 4th 7 segment display
				j img1
img_1:

				li	 $2, PORT_SEVENSEG_LOW
				and  $8,$23,0x0000FFFF
				or 	 $23, $8, 0x02000000        // loading data which displays '2' 
				sw  $23, 0($2)                  // display 2 on 4th 7 segment display
				j img2

img_2:

				li	 $2, PORT_SEVENSEG_LOW
				and  $8,$23,0x0000FFFF
				or 	 $23, $8, 0x03000000        // loading data which displays '3' 
				sw  $23, 0($2)                  // display 3 on 4th 7 segment display
				j img3

img_3:

				li	 $2, PORT_SEVENSEG_LOW
				and  $8,$23,0x0000FFFF
				or 	 $23, $8, 0x04000000        // loading data which displays '4' 
				sw  $23, 0($2)                  // display 4 on 4th 7 segment display
				j gr

green:
				li 	$2, PORT_SEVENSEG_HGH
				add $20, $0, 0x1F1B0000
				sw	$20, 0($2)                  // loading data which displays 'gr' 
				sw  $23, 0($2)                  // display gr on 7th & 8th 7 segment display

blue:
				li 	$2, PORT_SEVENSEG_HGH
				add $20, $0, 0x0B1A0000         // loading data which displays 'bl' 
				sw  $23, 0($2)                  // display bl on 7th & 8th 7 segment display
				j main_L1						// back to main loop
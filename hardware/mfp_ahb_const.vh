// 
// mfp_ahb_const.vh
//
// Verilog include file with AHB definitions
// 

//---------------------------------------------------
// Physical bit-width of memory-mapped I/O interfaces
//---------------------------------------------------
`define MFP_N_LED             16
`define MFP_N_SW              16
`define MFP_N_SEG         	  8
`define MFP_N_PB              5


//---------------------------------------------------
// Memory-mapped I/O addresses
//---------------------------------------------------
`define H_LED_ADDR    			(32'h1f800000)
`define H_SW_ADDR   			(32'h1f800004)
`define H_PB_ADDR   			(32'h1f800008)

`define H_LED_IONUM   			(4'h0)
`define H_SW_IONUM  			(4'h1)
`define H_PB_IONUM  			(4'h2)

`define SEG_EN_ADDR  			(32'h1f700000)
`define SEG_MSB_ADDR  			(32'h1f700004)
`define SEG_LSB_ADDR  			(32'h1f700008)
`define DEC_POINT_ADDR  		(32'h1f70000C)

`define H_SEG_EN_IONUM   			(4'h0)
`define H_SEG_MSB_IONUM  			(4'h1)
`define H_SEG_LSB_IONUM  			(4'h2)
`define H_SEG_DP_IONUM  			(4'h3)

`define PORT_IP_ADDR  				(32'h1f800010)

`define PORT_IP_IONUM 				(8'h10)

//---------------------------------------------------
// RAM addresses
//---------------------------------------------------
`define H_RAM_RESET_ADDR 		(32'h1fc?????)
`define H_RAM_ADDR	 		    (32'h0???????)
`define H_RAM_RESET_ADDR_WIDTH  (8) 
`define H_RAM_ADDR_WIDTH		(16) 

`define H_RAM_RESET_ADDR_Match  (7'h7f)
`define H_RAM_ADDR_Match 		(1'b0)

`define H_LED_ADDR_Match		(7'h7e)
`define H_LED_ADDR_UPPER_Match	(8'h08)

`define H_SEG_ADDR_Match		(7'h7d)

`define H_IP_ADDR_Match			(7'h7e)
`define H_IP_ADDR_Upper_Match	(8'h08)

//---------------------------------------------------
// AHB-Lite values used by MIPSfpga core
//---------------------------------------------------

`define HTRANS_IDLE    2'b00
`define HTRANS_NONSEQ  2'b10
`define HTRANS_SEQ     2'b11

`define HBURST_SINGLE  3'b000
`define HBURST_WRAP4   3'b010

`define HSIZE_1        3'b000
`define HSIZE_2        3'b001
`define HSIZE_4        3'b010

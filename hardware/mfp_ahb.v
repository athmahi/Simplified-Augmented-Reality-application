// mfp_ahb.v
// 
// February 22, 2019
//
// AHB-lite bus module with 5 slaves: boot RAM, program RAM, and
// GPIO (memory-mapped I/O: switches and LEDs from the FPGA board) and
// 7 segment display and rojo bot.
// The module includes an address decoder and multiplexer (for 
// selecting which slave module produces HRDATA).

`include "mfp_ahb_const.vh"


module mfp_ahb
(
    input                       HCLK,
    input                       HRESETn,
    input      [ 31         :0] HADDR,
    input      [  2         :0] HBURST,
    input                       HMASTLOCK,
    input      [  3         :0] HPROT,
    input      [  2         :0] HSIZE,
    input      [  1         :0] HTRANS,
    input      [ 31         :0] HWDATA,
    input                       HWRITE,
    output     [ 31         :0] HRDATA,
    output                      HREADY,
    output                      HRESP,
    input                       SI_Endian,

	// memory-mapped I/O
    input      [`MFP_N_SW-1 :0] IO_Switch,
    input      [`MFP_N_PB-1 :0] IO_PB,
    output     [`MFP_N_LED-1:0] IO_LED,    
	
	// memory-mapped 7 segment
	output 	   [`MFP_N_SEG-1:0]	IO_AN,
	output 						IO_CA, IO_CB, IO_CC, IO_CD, IO_CE, IO_CF, IO_CG,
	output 						IO_DP,
	
	// memory-mapped ip block
	output     [7  :0] 			 PORT_IP_CTRL
);


	wire [31:0] HRDATA4, HRDATA3, HRDATA2, HRDATA1, HRDATA0;
	//make HSEL 5 bit wide
	wire [ 4:0] HSEL;
	reg  [ 4:0] HSEL_d;

	assign HREADY = 1;
	assign HRESP = 0;
	
	// Delay select signal to align for reading data
	always @(posedge HCLK)
		HSEL_d <= HSEL;

	// Module 0 - boot ram
	mfp_ahb_b_ram mfp_ahb_b_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
							  HTRANS, HWDATA, HWRITE, HRDATA0, HSEL[0]);
	// Module 1 - program ram
	mfp_ahb_p_ram mfp_ahb_p_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
							  HTRANS, HWDATA, HWRITE, HRDATA1, HSEL[1]);
	// Module 2 - GPIO
	mfp_ahb_gpio mfp_ahb_gpio(HCLK, HRESETn, HADDR[5:2], HTRANS, HWDATA, HWRITE, HSEL[2], 
							HRDATA2, IO_Switch, IO_PB, IO_LED);
						
	// Module 3 - 7 segment
	mfp_ahb_segment mfp_ahb_segment(HCLK, HRESETn, HADDR[5:2], HTRANS, HWDATA, HWRITE, HSEL[3], IO_AN,
									IO_CA, IO_CB, IO_CC, IO_CD, IO_CE, IO_CF, IO_CG, IO_DP);  
	// Module 4 - ip_block
	mfp_ahb_ip mfp_ahb_ip(HCLK, HRESETn, HADDR[7:0], HTRANS, HWDATA, HWRITE, HSEL[4], HRDATA4
									, PORT_IP_CTRL);  

	ahb_decoder ahb_decoder(HADDR, HSEL);
	ahb_mux ahb_mux(HCLK, HSEL_d, HRDATA4, HRDATA3, HRDATA2, HRDATA1, HRDATA0, HRDATA);

endmodule


module ahb_decoder
(
    input  [31:0] HADDR,
	//add two bit extra for HSEL
    output [ 4:0] HSEL
);

  // Decode based on most significant bits of the address
  assign HSEL[0] = (HADDR[28:22] == `H_RAM_RESET_ADDR_Match); // 128 KB RAM  at 0xbfc00000 (physical: 0x1fc00000)
  assign HSEL[1] = (HADDR[28]    == `H_RAM_ADDR_Match);       // 256 KB RAM at 0x80000000 (physical: 0x00000000)
  assign HSEL[2] = (HADDR[28:22] == `H_LED_ADDR_Match 
					&& HADDR[7:0] <= `H_LED_ADDR_UPPER_Match);// GPIO at 0xbf800000 (physical: 0x1f800000)
  assign HSEL[3] = (HADDR[28:22] == `H_SEG_ADDR_Match);       // Segment at 0xbf700000 (physical: 0x1f700000)
  assign HSEL[4] = (HADDR[28:22] == `H_IP_ADDR_Match 
					&& HADDR[7:0] > `H_IP_ADDR_Upper_Match);  // IP block at 0xbf80000C (physical: 0x1f80000C)
endmodule


module ahb_mux
(
    input             HCLK,
    input      [ 4:0] HSEL,
    input      [31:0] HRDATA4, HRDATA3, HRDATA2, HRDATA1, HRDATA0,
    output reg [31:0] HRDATA
);

    always @(*)
      casez (HSEL)
	      5'b????1:    HRDATA = HRDATA0;
	      5'b???10:    HRDATA = HRDATA1;
	      5'b??100:    HRDATA = HRDATA2;
	      5'b?1000:    HRDATA = HRDATA3;
	      5'b10000:    HRDATA = HRDATA4;
	      default:   HRDATA = HRDATA1;
      endcase
endmodule


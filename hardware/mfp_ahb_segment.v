// mfp_ahb_segment.v
//
// 7 segment module for Altera's DE2-115 and 
// Digilent's (Xilinx) Nexys4-DDR board


`include "mfp_ahb_const.vh"

module mfp_ahb_segment(
    input                        HCLK,
    input                        HRESETn,
    input      [  3          :0] HADDR,
    input      [  1          :0] HTRANS,
    input      [ 31          :0] HWDATA,
    input                        HWRITE,
    input                        HSEL,

	// memory-mapped 7 segment
	// output reg [`MFP_N_SEG-1:0]	IO_AN,
	// output reg IO_CA, IO_CB, IO_CC, IO_CD, IO_CE, IO_CF, IO_CG,
	// output reg IO_DP
	output [`MFP_N_SEG-1:0]	IO_AN,
	output IO_CA, IO_CB, IO_CC, IO_CD, IO_CE, IO_CF, IO_CG,
	output IO_DP
	
);

	//internal signal to enable disable individual display
	//content will come from memory mapped IO
	reg [7:0] enSeg;
	//data register which will be used to put values to
	//7 segment display
	//content of memory mapped IO
	//will go into this signal
	reg [63:0] segData;
	//internal signal to enable disable individual decimal point
	//so based on memory mapped IO
	//value of this signal should be changed
	reg [7:0] enDP;
	
	//enable signals for 7 segment
	//which are given directly to pins
	// wire [7:0] segMuxEnData;
	// wire [7:0] segDataToDisp;
  
	/*
	//My 7 segment interface
	//this interface connects 7segment pins 
	//to segment timer circuit
	//AN if you make them 0
	//It will enable that segment
	//even CA are active low
	always@(*)
	begin
		
		//MSB is the decimal point
		//followed by individual LEDs a,b,c,d,e,f,g
		IO_DP = segDataToDisp[7];
		IO_CA = segDataToDisp[6];
		IO_CB = segDataToDisp[5];
		IO_CC = segDataToDisp[4];
		IO_CD = segDataToDisp[3];
		IO_CE = segDataToDisp[2];
		IO_CF = segDataToDisp[1];
		IO_CG = segDataToDisp[0];
		//this is responsible for multiplexing 
		//enable signals
		IO_AN = segMuxEnData;
	end
	*/
  
	//module instance of 7 segment muliplexar driver
	//inputs for the instance will come from values inside memory
	//outputs will drive actla segments
	//populate output signals throughout the hirearchy
	mfp_ahb_sevensegtimer seven_segment_driver(
							.clk(HCLK)
							,.resetn(HRESETn)
							,.EN(enSeg)
							,.DIGITS(segData)
							,.dp(enDP)
							,.DISPENOUT(IO_AN)
							,.DISPOUT({IO_DP,IO_CA
								,IO_CB
								,IO_CC
								,IO_CD
								,IO_CE
								,IO_CF
								,IO_CG
								})
							);




	reg  [3:0]  HADDR_d;
	reg         HWRITE_d;
	reg         HSEL_d;
	reg  [1:0]  HTRANS_d;
	wire        we;            // write enable

	// delay HADDR, HWRITE, HSEL, and HTRANS to align with HWDATA for writing
	always @ (posedge HCLK) 
	begin
		HADDR_d  <= HADDR;
		HWRITE_d <= HWRITE;
		HSEL_d   <= HSEL;
		HTRANS_d <= HTRANS;
	end
  
	// overall write enable signal
	assign we = (HTRANS_d != `HTRANS_IDLE) & HSEL_d & HWRITE_d;

    always @(posedge HCLK or negedge HRESETn)
	begin
		if (~HRESETn) begin
			enSeg <= 8'b11111111;
			segData <= 64'h0000000000000000;
			enDP <= 8'b11111111;
		end else if (we)
		begin
			case (HADDR_d)
				//segment enable register
				`H_SEG_EN_IONUM: enSeg <= HWDATA[7:0];
				//segment MSB 4 digits
				`H_SEG_MSB_IONUM: segData[63:32] <= HWDATA;
				//segment LSB 4 digits
				`H_SEG_LSB_IONUM: segData[31:0] <= HWDATA;
				//decimal point enable register
				`H_SEG_DP_IONUM: enDP <= HWDATA[7:0];
			endcase
		end
	end	 
endmodule
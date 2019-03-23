//	mfp_ahb_ip.v - ahb lite peripheral for image processing block 
//	Version:		1.0	
//	Author:			Hamed Mirlohi, Jagir Charla


`include "mfp_ahb_const.vh"

module mfp_ahb_ip(
    input                        HCLK,
    input                        HRESETn,
    input      [  7          :0] HADDR,
    input      [  1          :0] HTRANS,
    input      [ 31          :0] HWDATA,
    input                        HWRITE,
    input                        HSEL,
    output     [ 31          :0] HRDATA,

	output reg [7  :0] 			 PORT_IP_CTRL
);

	reg  [7:0]  HADDR_d;
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
	
	assign HRDATA = 0;
  
	// overall write enable signal
	assign we = (HTRANS_d != `HTRANS_IDLE) & HSEL_d & HWRITE_d;

	//this is for writig some value to rojobots register
    always @(posedge HCLK or negedge HRESETn) begin
		//on reset
		if (~HRESETn) begin
			PORT_IP_CTRL <= 8'h0;  
		end
		//based on address decide which register to update
		//which gets bubbled up, all the way to top
		else if (we) begin
			case (HADDR_d)
				`PORT_IP_IONUM: PORT_IP_CTRL <= HWDATA[7:0];
			endcase
		end
	end
endmodule


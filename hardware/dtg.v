//	dtg.v - Horizontal & Vertical Display Timing & Sync generator for VESA timing
//	640 * 480 working
//	Version:		3.0	
//	Author:			Srivatsa Yogendra, John Lynch & Roy Kravitz, Jagir Charla
//	Last Modified:	17-Mar-2019
//	
//	 Revision History
//	 ----------------
//	 02-Feb-06		JDL	Added video_on output; simplified counter logic
//	 25-Oct-12		Modified for kcpsm6 and Nexys3
//   20-Sep-17		Modified the design, to produce signals for 1024*768 resolution
//   20-Sep-17		Modified the design, to produce signals for 1024*768 resolution
//   17-Mar-2019	Modified the design, to produce signals for 640*480 resolution
//
//	Description:
//	------------
//	 This circuit provides pixel location and horizontal and 
//	 vertical sync for a 640 x 480 video image. 
//	
//	 Inputs:
//			clock           - 25MHz Clock
//			rst             - Active-high synchronous reset
//	 Outputs:
//			horiz_sync_out	- Horizontal sync signal to display
//			vert_sync_out	- Vertical sync signal to display
//			Pixel_row		- (12 bits) current pixel row address
//			Pixel_column	- (12 bits) current pixel column address
//			video_on        - 1 = in active video area; 0 = blanking;
//			
//////////

module dtg(
	input				clock, rst,
	output	reg			horiz_sync, vert_sync, video_on,		
	output	reg	[11:0]	pixel_row, pixel_column
);

// Timing parameters (for 25MHz pixel clock and 640 x 480 display)

parameter
		HORIZ_PIXELS = 640,  HCNT_MAX  = 800, 		
		HSYNC_START  = 640+16,  HSYNC_END = 640+16+96,

		VERT_PIXELS  = 480,  VCNT_MAX  = 480+10+2,
		VSYNC_START  = 480+10,  VSYNC_END = 480+10+2+33;
			
// generate video signals and pixel counts
always @(posedge clock) begin
	if (rst) begin
		pixel_column <= 0;
		pixel_row    <= 0;
		horiz_sync   <= 0;
		vert_sync    <= 0;
		video_on     <= 0;
	end
	else begin
		// increment horizontal sync counter.  Wrap if at end of row
		if (pixel_column == HCNT_MAX)	
			pixel_column <= 12'd0;
		else	
			pixel_column <= pixel_column + 12'd1;
			
		// increment vertical sync ounter.  Wrap if at end of display.  Increment if end of row
		if ((pixel_row >= VCNT_MAX) && (pixel_column >= HCNT_MAX))
			pixel_row <= 12'd0;
		else if (pixel_column == HCNT_MAX)
			pixel_row <= pixel_row + 12'd1;
									
		// generate active-low horizontal sync pulse
		horiz_sync <=  ~((pixel_column >= HSYNC_START) && (pixel_column <= HSYNC_END));
			
		// generate active-low vertical sync pulse
		vert_sync <= ~((pixel_row >= VSYNC_START) && (pixel_row <= VSYNC_END));
			
		// generate the video_on signals and the pixel counts
		video_on <= ((pixel_column < HORIZ_PIXELS) && (pixel_row < VERT_PIXELS));
	end
	
	
end // always
	
endmodule

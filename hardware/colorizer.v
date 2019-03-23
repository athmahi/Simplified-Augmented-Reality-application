//	colorizer.v - will decide what to display
//	it should be in sync with dtg
//	Version:		2.0	
//	Author:			Prasanna Kulkarni, Atharva , Hamed Mirlohi, Jagir Charla 
//
//	Description:
//	------------
//	 This circuit outputs color to VGA connector
//	
//	 Inputs:
//			video_on            - indicates blanking interval or not
//			[1:0] op_pixel		- will come from live feed block mem
//			blank_disp			- bloank display will put black
//			[2:0] superimpose_pixel	- used for superimposition, separated into 4 quadrants
//			[3:0] top_left_r	- 1st quadrant R
//			[3:0] top_left_g	- 1st quadrant G
//			[3:0] top_left_b	- 1st quadrant B
//			[3:0] top_right_r	- 2nd quadrant R
//			[3:0] top_right_g	- 2nd quadrant G
//			[3:0] top_right_b	- 2nd quadrant B
//			[3:0] bottom_left_r	- 3st quadrant R
//			[3:0] bottom_left_g	- 3st quadrant G
//			[3:0] bottom_left_b	- 3st quadrant B
//			[3:0] bottom_right_r	- 4th quadrant R
//			[3:0] bottom_right_g	- 4th quadrant G
//			[3:0] bottom_right_b	- 4th quadrant B
//	 Outputs:
//			[3:0] red	- red 	color value
//			[3:0] green	- green color value
//			[3:0] blue	- blue 	color value
//			
//////////

module colorizer(
	input				video_on,
	input		[11 :0]	op_pixel,
	input				blank_disp,
	input		[2:0]	superimpose_pixel,
	input		[3:0]	top_left_r,
	input		[3:0]	top_left_g,
	input		[3:0]	top_left_b,
	input		[3:0]	top_right_r,
	input		[3:0]	top_right_g,
	input		[3:0]	top_right_b,
	input		[3:0]	bottom_left_r,
	input		[3:0]	bottom_left_g,
	input		[3:0]	bottom_left_b,
	input		[3:0]	bottom_right_r,
	input		[3:0]	bottom_right_g,
	input		[3:0]	bottom_right_b,
	output	reg	[3 :0]	red, green, blue
);

//this is going to be combinational design
always@(*)
begin
	//if video_on is low
	//output should be black
	if(video_on == 1'b0)
	begin
		//black color
		red 	= 4'b0000;
		green 	= 4'b0000;
		blue 	= 4'b0000;
	end
	//else we should decide between back ground or patch
	else if((blank_disp == 1'b0) && (superimpose_pixel == 3'b0))
	begin
		//live feed pixel
		red = op_pixel[11:8];
		green = op_pixel[7:4];
		blue = op_pixel[3:0];
	end
	else if((blank_disp == 1'b0) && (superimpose_pixel != 3'b0))
	begin
		//or based on quadrant
		//which one to display
		case(superimpose_pixel)
			3'b001:
			begin
				red = top_left_r;
				green = top_left_g;
				blue = top_left_b;
			end
			
			3'b010:
			begin
				red = top_right_r;
				green = top_right_g;
				blue = top_right_b;
			end
			
			3'b011:
			begin
				red = bottom_left_r;
				green = bottom_left_g;
				blue = bottom_left_b;
			end
			
			3'b100:
			begin
				red = bottom_right_r;
				green = bottom_right_g;
				blue = bottom_right_b;
			end
		endcase
	end
	else
	begin
		red = 4'b0;
		green = 4'b0;
		blue = 4'b0;
	end
end

endmodule

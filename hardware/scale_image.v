//	scale_image.v - module will scale image
//	Version:		1.0	
//	Author:			Jagir Charlas
//
//	Description:
//	------------
//	 This circuit scals down the pixel_row and pixel_column
//	
//	 Inputs:
//			video_on            - indicates blanking interval or not, dont increment anything
//			[11:0] pixel_row	- pixel row
//			[11:0] pixel_column	- pixel column
//	 Outputs:
//			[13:0] image_addr   - address of 320*240 memory
//			[13:0] blank_disp   - indicates blank area of display cause of resizing
//			
//////////

module scale_image(
	input				video_on,
	input		[11 :0]	pixel_row,
	input		[11 :0]	pixel_column,
	output	reg	[16 :0]	image_addr,
	output	reg			blank_disp
);

always@(*)
begin 
	//image_addr is going to be a latch
	if((video_on == 1'b1) && (pixel_column < 320) && (pixel_row < 240))
	begin
		image_addr = pixel_row * 320 + pixel_column; 
		blank_disp = 0;
	end
	else
	begin
		blank_disp = 1;
	end
end
endmodule

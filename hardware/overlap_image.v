//	overlap_image.v - module helps to display super imposed image
//	Version:		1.0	
//	Author:			Prasanna Kulkarni, Atharva , Hamed Mirlohi, Jagir Charla
//
//	Description:
//	------------
//	 This circuit based on min max boundaries help coloriser 
//	 module to decide which color to display
//	
//	 Inputs:
//			[8:0] 		x_min	- x min of detection	
//			[8:0] 		x_max	- x max of detection	
//			[8:0] 		y_min	- y min of detection	
//			[8:0] 		y_max	- y max of detection	
//			[8:0] 		x_cen	- x cen of detection	
//			[8:0] 		y_cen	- y den of detection	
//			[11 :0] 	pixel_row,		- from dtg used for reference
//			[11 :0] 	pixel_column,	- from dtg used for reference
//						disable_overlap,- enable or disable overlap
//		
//	 Outputs:
//			[2 :0]	swap_pixel,	- based on value coloriser makes decision 
//////////

module overlap_image(
	input [8:0] 		x_min,
	input [8:0] 		x_max,
	input [8:0] 		y_min,
	input [8:0] 		y_max,
	input [8:0] 		x_cen,
	input [8:0] 		y_cen,
	input [11 :0] 		pixel_row,
	input [11 :0] 		pixel_column,
	input 				disable_overlap,
	output	reg	[2 :0]	swap_pixel
);

always@(*)
begin
	//check whether super impose enabled or not
	if(disable_overlap == 1'b0)
		//based on counter decide the colour scheme
		if((pixel_column >= {3'b0,x_min}) && (pixel_column < {3'b0,x_cen}) 
			&&(pixel_row >= {3'b0,y_min}) && (pixel_row < {3'b0,y_cen}))
		begin
			swap_pixel = 3'b001;
		end
		else if((pixel_column >= {3'b0,x_cen}) && (pixel_column < {3'b0,x_max}) 
			&&(pixel_row >= {3'b0,y_min}) && (pixel_row < {3'b0,y_cen}))
		begin
			swap_pixel = 3'b010;
		end
		else if((pixel_column >= {3'b0,x_min}) && (pixel_column < {3'b0,x_cen}) 
			&&(pixel_row >= {3'b0,y_cen}) && (pixel_row < {3'b0,y_max}))
		begin
			swap_pixel = 3'b011;
		end
		else if((pixel_column >= {3'b0,x_cen}) && (pixel_column < {3'b0,x_max})
			&&(pixel_row >= {3'b0,y_cen}) && (pixel_row < {3'b0,y_max}))
		begin
			swap_pixel = 3'b100;
		end
		else
		begin
			swap_pixel = 3'b000;
		end
	else
		swap_pixel = 3'b000;
	/*
	if((pixel_column >= {3'b0,x_min}) && (pixel_column < {3'b0,x_max}) 
		&&(pixel_row >= {3'b0,y_min}) && (pixel_row < {3'b0,y_max}))
	begin
		swap_pixel = 3'b100;
	end
	else
	begin
		swap_pixel = 3'b000;
	end*/
end
endmodule

//	filter.v - filter module 
//	Version:		1.0	
//	Author:			Prasanna Kulkarni, Atharva , Hamed Mirlohi, Jagir Charla
//
//	Description:
//	------------
//	 This circuit filters the imaged based on color and
//   selection of color to be filtered is done using color_sel signal
//	 after that computes the min max bounderies using iterative algorithm
//	 Inputs:
//		clk,			-	clk 
//		reset,			-	reset active high
//		ack_flag,		-	hand shaking for acknowledg
//		start_flag,		-	hand shaking to start filter process
//		color_sel,		-	select which color to filter
//		[11:0] data_pixel,	- current pixel to check
//	 Outputs:
//		[16:0] address_to_read,	-	address of pixel data
//		[8:0] x_min				-	x min
//		[8:0] x_max				-	x max
//		[8:0] y_min				-	y min
//		[8:0] y_max				-	y max
//		done_flag				-	hand shaking done flag
//		error_flag				-	indicates error
//////////

module filter (
	input clk,	
	input reset,	
	input ack_flag,
	input start_flag,
	input color_sel,
	input  [11:0] data_pixel,
	output [16:0] address_to_read,
	output reg [8:0] x_min, x_max, y_min, y_max,
	output reg done_flag,
	output reg error_flag
);

// First we declare the state machine variables.
localparam SM_RESET = 5'd0;
localparam IDLE = 5'd1;	
localparam RESET_XY = 5'd2;	
localparam ADDR_GEN = 5'd3;
localparam COLOR_DETECT = 5'd4;
localparam COLOR_DETECT_1 = 5'd5;
localparam CHECK_PIX_OUT = 5'd6;

localparam CHECK_X_MIN = 5'd7;
localparam UPDATE_X_MIN = 5'd8;

localparam CHECK_Y_MIN = 5'd9;
localparam UPDATE_Y_MIN = 5'd10;

localparam CHECK_X_MAX = 5'd11;
localparam UPDATE_X_MAX = 5'd12;

localparam CHECK_Y_MAX = 5'd13;
localparam UPDATE_Y_MAX = 5'd14;

localparam CHECK_MIN_MAX = 5'd15;
localparam CHECK_DONE = 5'd16;
localparam DONE = 5'd17;

//state variables
reg [4:0] CURR_STATE, NEXT_STATE;

//temp latches used for brute force iterative algorithm
reg [8:0] x_min_temp, x_max_temp, y_min_temp, y_max_temp;

//used to generate address
reg [8:0] x_count;
reg [8:0] y_count;

//computed address
reg [16:0]	address;
//status of color match
reg [0:0] 	pixel_out;

assign address_to_read = address;

//clock block for flipflop based outputs
//works as output function logic tooo
//for signals like counters and min max values
always@(posedge clk) 
begin

	if(reset == 1'b1)
	begin
		x_count <= 9'd0;
		y_count <= 9'd0;
		address <= 17'd0;
	end
	
	//reset address counters in this states
	else if (CURR_STATE == RESET_XY)
	begin
		x_count <= 9'd0;
		y_count <= 9'd0;
		address <= 17'd0;
	end
	//increment counters only in ADDR_GEN 
    else if(CURR_STATE == ADDR_GEN)
	begin
		address <= (y_count * 320) + x_count;
        if (x_count < 9'd319) 
			x_count <= x_count + 9'd1;
		else 
		begin
			if (y_count < 9'd239) 
			begin
				y_count <= y_count + 9'd1;
				x_count <= 9'd0;
			end
			else
			begin
				y_count <= 9'd0;
				x_count <= 9'd0;
			end
		end	
	end
	
	//flipflops for outputs to avoide glitch 
	if(reset == 1'b1)
	begin
		x_min <= 0;
		y_min <= 0;
		x_max <= 0;
		y_max <= 0;
	end
	else if(CURR_STATE == DONE)
	begin
		x_min <= x_min_temp;
		y_min <= y_min_temp;
		x_max <= x_max_temp;
		y_max <= y_max_temp;
	end
	
	//flipflops for temp regs to avoide glitch 
	if(reset == 1'b1)
	begin
		x_min_temp <= 9'd0;
		y_min_temp <= 9'd0;
		x_max_temp <= 9'd0;
		y_max_temp <= 9'd0;
	end
	else if(CURR_STATE == IDLE)
	begin
		x_min_temp <= 9'd319;
		y_min_temp <= 9'd239;
		x_max_temp <= 9'd0;
		y_max_temp <= 9'd0;
	end
	else if(CURR_STATE == UPDATE_X_MIN)
	begin
		x_min_temp <= x_count;
	end
	else if(CURR_STATE == UPDATE_X_MAX)
	begin
		x_max_temp <= x_count;
	end
	else if(CURR_STATE == UPDATE_Y_MIN)
	begin
		y_min_temp <= y_count;
	end
	else if(CURR_STATE == UPDATE_Y_MAX)
	begin
		y_max_temp <= y_count;
	end
	
end

// The state switching logic
always @(posedge clk) 
begin
	if (reset == 1'b1)
		CURR_STATE <= SM_RESET;
	else
		CURR_STATE <= NEXT_STATE;
end


// NEXT_STATE Transitioning block
always@(*) begin
	case(CURR_STATE)
		
		SM_RESET:
		begin
			NEXT_STATE = IDLE;			
		end
		
		IDLE: 
		begin
			//start the computation
			if (start_flag == 1'b1)
				NEXT_STATE = RESET_XY;
			else
				NEXT_STATE = IDLE;
		end
		
		//reset the counters
		RESET_XY:
		begin
			NEXT_STATE = ADDR_GEN;
		end
		
		//based on input decide which filter to pick
		ADDR_GEN:
		begin
			if(color_sel == 1'b0)
				NEXT_STATE = COLOR_DETECT;
			else
				NEXT_STATE = COLOR_DETECT_1;
		end
		
		//look for the specific color
		COLOR_DETECT: 
		begin
			NEXT_STATE = CHECK_PIX_OUT;			
		end
		
		//look for the specific color
		COLOR_DETECT_1: 
		begin
			NEXT_STATE = CHECK_PIX_OUT;			
		end
		
		//check whether current filter matches the specific color
		CHECK_PIX_OUT:
		begin
			if(pixel_out == 1'b1)
			begin
				// NEXT_STATE = CHECK_MIN_MAX;
				// NEXT_STATE = UPDATE_X_MIN;
				NEXT_STATE = CHECK_X_MIN;
			end
			else
			begin
				NEXT_STATE = CHECK_DONE;
			end
		end
		
		//check x min
		CHECK_X_MIN:
		begin
			if (x_count < x_min_temp ) 
				NEXT_STATE = UPDATE_X_MIN;
			else
				// NEXT_STATE = CHECK_MIN_MAX;
				NEXT_STATE = CHECK_X_MAX;
		end
		
		//check x max
		CHECK_X_MAX:
		begin
			if (x_count > x_max_temp ) 
				NEXT_STATE = UPDATE_X_MAX;
			else
				NEXT_STATE = CHECK_Y_MIN;
		end
		
		//check y min
		CHECK_Y_MIN:
		begin
			if (y_count < y_min_temp ) 
				NEXT_STATE = UPDATE_Y_MIN;
			else
				NEXT_STATE = CHECK_Y_MAX;
		end
		
		//check y max
		CHECK_Y_MAX:
		begin
			if (y_count > y_max_temp ) 
				NEXT_STATE = UPDATE_Y_MAX;
			else
				NEXT_STATE = CHECK_MIN_MAX;
		end
		
		//update x min
		UPDATE_X_MIN:
		begin
			NEXT_STATE = CHECK_MIN_MAX;
		end
		
		//update x max
		UPDATE_X_MAX:
		begin
			NEXT_STATE = CHECK_MIN_MAX;
		end
		
		//update y min
		UPDATE_Y_MIN:
		begin
			NEXT_STATE = CHECK_MIN_MAX;
		end
		
		//update y max
		UPDATE_Y_MAX:
		begin
			NEXT_STATE = CHECK_MIN_MAX;
		end
		
		CHECK_MIN_MAX:
		begin
			NEXT_STATE = CHECK_DONE;
		end
		
		//check whether you have exhausted entire memory space
		CHECK_DONE:
		begin
			if (address >= 17'd76799) 
			begin
				NEXT_STATE = DONE;
			end
			else
			begin
				NEXT_STATE = ADDR_GEN;
			end
		end
		
		//wait for ack 
		DONE:
		begin
			if (ack_flag == 1'b1)
				NEXT_STATE = IDLE;
			else
				NEXT_STATE = DONE;
		end
	endcase
end

// Output Generation Logic
always@(*)
begin
	case(CURR_STATE)
	
		SM_RESET:
		begin						
			pixel_out = 1'b0;		
			done_flag = 1'b0;
			
			error_flag = 1'b0; 
		end
	
		IDLE: 
		begin		
			pixel_out = 1'b0;
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		RESET_XY:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		ADDR_GEN:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		COLOR_DETECT: 
		begin
			if ((data_pixel[7:4] > 4'd12) && (data_pixel[11:8] < 4'd8 ) && (data_pixel[3:0] < 4'd8) )
			begin
				pixel_out = 1'b1;
			end	
			else
			begin
				pixel_out = 1'b0;
			end		
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		COLOR_DETECT_1:
		begin
			if ((data_pixel[3:0] > 4'd12) && (data_pixel[11:8] < 4'd8 ) && (data_pixel[7:4] < 4'd8) )
			begin
				pixel_out = 1'b1;
			end	
			else
			begin
				pixel_out = 1'b0;
			end		
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		CHECK_PIX_OUT:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		CHECK_X_MIN:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		UPDATE_X_MIN:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		CHECK_X_MAX:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		UPDATE_X_MAX:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		CHECK_Y_MIN:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		UPDATE_Y_MIN:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		CHECK_Y_MAX:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		UPDATE_Y_MAX:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		CHECK_MIN_MAX:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0; 
		end
		
		CHECK_DONE:
		begin
			done_flag = 1'b0;
			error_flag = 1'b0;
		end
		
		DONE:
		begin
			done_flag = 1'b1;
			error_flag = 1'b0; 
		end
		
	endcase
end
endmodule
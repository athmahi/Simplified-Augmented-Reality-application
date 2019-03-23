//	photo_sm.v - module syncs the capture of photo
//	Version:		1.0	
//	Author:			Prasanna Kulkarni, Atharva , Hamed Mirlohi, Jagir Charla
//
//	Description:
//	module controls the wen signal based on vsync
//	helps to sunchronize the frame capture
//	by enabling or disabling the write enable signal
//	uses handshaking signals to do the task
//	
//	 Inputs:
//		clk		-clock
//		reset 	-reset active low
//		start 	-signal to start capture
//		ack 	-signal to come out of done
//		vsync 	-signal to synchronize capture
//	 Outputs:
//		wen 	-write enable
//		started	-indicates whether started or not
//		done 	-indicates whether done or not
//		error 	-indicates error if any
//////////

module photo_sm(
	input				clk,
	input				reset,
	input				start,
	input				ack,
	input				vsync,
	output	reg 		wen,
	output	reg			started,
	output	reg			done,
	output	reg			error
);

	//state variable
	reg [2:0] curr_state;
	reg [2:0] next_state;
	
	//state names
	localparam SM_RESET = 0;	
    localparam SM_WAIT_FOR_START = 1;
    localparam SM_WAIT_FOR_VSYNC = 2;
    localparam SM_WAIT_FOR_VSYNC_0 = 3;
    localparam SM_WAIT_FOR_VSYNC_1 = 4;
    localparam SM_DONE = 5;
    localparam SM_ERROR = 6;
    
	//clock always block
	always@(posedge clk,negedge reset)
	begin
		if(reset == 1'b0)
			curr_state <= SM_RESET;
		else
			curr_state <= next_state;
	end
	
	always@(curr_state,start,vsync,ack)
	begin
		case(curr_state)
			SM_RESET:
			begin
				next_state = SM_WAIT_FOR_START;
			end
			
			//wait for start
			SM_WAIT_FOR_START:
			begin
				if(start == 1'b1)
					next_state = SM_WAIT_FOR_VSYNC;
			end
			
			//wait for vsync
			SM_WAIT_FOR_VSYNC:
			begin
				if(vsync == 1'b1)
					next_state = SM_WAIT_FOR_VSYNC_0;
				else
					next_state = SM_WAIT_FOR_VSYNC;
			end
			
			//wait for it to change
			SM_WAIT_FOR_VSYNC_0:
			begin
				if(vsync == 1'b0)
					next_state = SM_WAIT_FOR_VSYNC_1;
				else
					next_state = SM_WAIT_FOR_VSYNC_0;
			end
			
			//wait for it to become 1
			//indication of frame completion
			SM_WAIT_FOR_VSYNC_1:
			begin
				if(vsync == 1'b1)
					next_state = SM_DONE;
				else
					next_state = SM_WAIT_FOR_VSYNC_1;
			end
			
			//wait here for acknowledgement
			//indiacte done
			SM_DONE:
			begin
				if(ack == 1'b1)
					next_state = SM_WAIT_FOR_START;
			end
			
			SM_ERROR:
			begin
			end
			
			default:
			begin
				next_state = SM_ERROR;
			end
			
		endcase
	end
	
	always@(curr_state,wen)
	begin
		case(curr_state)
			SM_RESET:
			begin
				wen = 1'b0;
				started = 1'b0;
				done = 1'b0;
				error = 1'b0;
			end
			
			SM_WAIT_FOR_START:
			begin
				wen = 1'b0;
				started = 1'b0;
				done = 1'b0;
				error = 1'b0;
			end
			
			SM_WAIT_FOR_VSYNC:
			begin
				wen = 1'b0;
				started = 1'b1;
				done = 1'b0;
				error = 1'b0;
			end
			
			SM_WAIT_FOR_VSYNC_0:
			begin
				wen = 1'b1;
				started = 1'b1;
				done = 1'b0;
				error = 1'b0;
			end
			
			SM_WAIT_FOR_VSYNC_1:
			begin
				wen = 1'b1;
				started = 1'b1;
				done = 1'b0;
				error = 1'b0;
			end
			
			SM_DONE:
			begin
				wen = 1'b0;
				started = 1'b0;
				done = 1'b1;
				error = 1'b0;
			end
			
			SM_ERROR:
			begin
				wen = 1'b0;
				started = 1'b0;
				done = 1'b0;
				error = 1'b1;
			end
			
			default:
			begin
				wen = 1'b0;
				started = 1'b0;
				done = 1'b0;
				error = 1'b1;
			end
		endcase
	end
	
endmodule

/*
** Mark Tentindo
** Digital Logic II
** Professor Venkataramani
** Final Project
** 
** VBUFF_controller Module
** 
** - provides the proper color signals to the VGA_controller
** - collision detection w/ walls, trails, other players
** - sets up boundaries for playing field
** - reads trail locations from RAM
*/

module VBUFF_controller(VIDBUFF, LOSS_flag, /**/ ypos, xpos, P1_xpos, P1_ypos, P2_xpos, P2_ypos, VRAM_in);
	
	// Inputs include player and trail positions
	input [9:0] ypos;
	input [9:0] xpos;
	input [9:0] P1_xpos;
	input [9:0] P2_xpos;
	input [9:0] P1_ypos;
	input [9:0] P2_ypos;
	input VRAM_in;
	
	// Output is the 8 bits of color data for VGA controller and loss flags
	output [7:0] VIDBUFF;
	output LOSS_flag;

	// The majority of this module is combinational, only two needed
	reg [7:0] VIDBUFF;

	// Wires for connecting modules or conveying status
	wire LOSS_flag;
	wire LOSS_status;
	wire traila;
	wire [7:0] wVIDBUFF_LOSS_P1;
	wire [7:0] wVIDBUFF_LOSS_P2;

	// Initialize Register
	initial
		begin
			VIDBUFF = 8'b00000000;
		end

	// Instantialize all sub-modules
	DISP_OUTLINE border(outline_true, xpos, ypos);
	COLLISION_WALL wall_p1(collision_wall_true_p1, P1_xpos, P1_ypos);
	COLLISION_WALL wall_p2(collision_wall_true_p2, P2_xpos, P2_ypos);
	COLLISION_TRAIL trail_p1(collision_trail_true_p1, xpos, xpos, P1_xpos, P1_ypos, P2_xpos, P2_xpos, VRAM_in);
	COLLISION_TRAIL trail_p2(collision_trail_true_p2, xpos, xpos, P2_xpos, P2_ypos, P1_xpos, P1_xpos, VRAM_in);
	LOSS_P1 loss_p1(wVIDBUFF_LOSS_P1, xpos, ypos);
	LOSS_P2 loss_p2(wVIDBUFF_LOSS_P2, xpos, ypos);

	// Constant Assignments
	assign LOSS_flag = (collision_wall_true_p2 || collision_trail_true_p2 || collision_wall_true_p1 || collision_trail_true_p1 || traila);
	assign LOSS_status = (collision_wall_true_p1 || collision_trail_true_p1) ? 0:1;
	
	// Always loop responds to changes in signals
	always @ (*)
		begin
			if(LOSS_flag)
				begin
					if(LOSS_status == 0) // P1 loss
						begin
							VIDBUFF = wVIDBUFF_LOSS_P1;
						end
					if(LOSS_status == 1) // P2 loss
						begin
							VIDBUFF = wVIDBUFF_LOSS_P2;
						end
				end
			else if((!outline_true) && (!LOSS_flag))
				begin
					if((ypos == P1_ypos) && (xpos == P1_xpos)) VIDBUFF[7:0] = 8'b00011100; // P1 Green
					else if((ypos == P2_ypos) && (xpos == P2_xpos)) VIDBUFF[7:0] = 8'b11100000; // P2 Red
					else if(VRAM_in == 1) VIDBUFF[7:0] = 8'b00000010; // Trail Blue
					else VIDBUFF[7:0] = 8'b00000000;
				end
			else
				VIDBUFF = 8'b00000001; // Border/outline
		end
		
		assign traila = ((P2_ypos == P1_ypos) && (P2_xpos == P1_xpos)); //player - player collision always won by player 1
	endmodule

module DISP_OUTLINE(outline_true, xpos, ypos);
	// coordinate inputs
		input [9:0] xpos;
		input [9:0] ypos;
	
	// Output Declaration
		output outline_true;
		wire outline_true;
	
	// Calculate presence in boundary
		wire xbound_left_low = (0 <= xpos[9:0]);
		wire xbound_left_high = (xpos[9:0] < 100);
	
		wire xbound_right_low = (540 <= xpos[9:0]);
		wire xbound_right_high = (xpos[9:0] < 641);
	
		wire ybound_top_low = (0 <= ypos[9:0]);
		wire ybound_top_high = (ypos[9:0] < 20);
	
		wire ybound_bottom_low = (460 <= ypos[9:0]);
		wire ybound_bottom_high = (ypos[9:0] < 481);
	
	// Consolidate signal
		and(xbound_left, xbound_left_low, xbound_left_high);
		and(xbound_right, xbound_right_low, xbound_right_high);
		and(ybound_top, ybound_top_low, ybound_top_high);
		and(ybound_bottom, ybound_bottom_low, ybound_bottom_high);
		
		or(outline_true, xbound_left, xbound_right, ybound_top, ybound_bottom);
		
endmodule

module COLLISION_WALL(collision_wall_true, pxpos, pypos);
	// Coordinate inputs
		input [9:0] pxpos;
		input [9:0] pypos;
	
	// Ouput Declaration
		output collision_wall_true;
		wire collision_wall_true;
	
	// Collision Detection
		wire xbound_left = (pxpos[9:0] <= 100);
		wire xbound_right = (pxpos[9:0] >= 540);
		wire ybound_top = (pypos[9:0] <= 20);
		wire ybound_bottom = (pypos[9:0] >= 460);
		
	// Consolidate Signals
		or(collision_wall_true, xbound_left, xbound_right, ybound_top, ybound_bottom);
endmodule

module COLLISION_TRAIL(collision_trail_true, xpos, ypos, p1xpos, p1ypos, p2xpos, p2ypos, VRAM_in);
	// Coordinate inputs
		input [9:0] xpos;
		input [9:0] ypos;
		input [9:0] p1xpos;
		input [9:0] p1ypos;
		input [9:0] p2xpos;
		input [9:0] p2ypos;
		input VRAM_in;
		
	// Output Declaration
		output collision_trail_true;
		wire collision_trail_true;
		
	// Collision Detection
		// Check if player at location
			wire present_x = (xpos == p1xpos);
			wire present_y = (ypos == p1ypos);
			and(present, present_x, present_y);
		
		// Consolidate signals
			and(collision_trail_true, present, VRAM_in);
endmodule

// Data for Loss Screens in the next two modules
module LOSS_P1(VIDBUFF_LOSS_P1, xpos, ypos);
	input [9:0] xpos;
	input [9:0] ypos;
	
	output [7:0] VIDBUFF_LOSS_P1;
	
	reg [7:0] VIDBUFF_LOSS_P1;
	
	wire [4:0] ptext;
	wire [4:0] wintext;
	wire text;
	
	always @ (*)
		begin
			if(text) VIDBUFF_LOSS_P1 = 8'b11100000;
			else VIDBUFF_LOSS_P1 = 8'b00000000;
		end
	// Consolidate Signals
		assign text = (ptext[0] | ptext[1] | ptext[2] | ptext[3] | ptext[4] | wintext[0] | wintext[1] | wintext[2] | wintext[3] | wintext[4]);
	// Print "P2"
		assign ptext[0] = ( (((223<=xpos)&&(xpos<=334)) || ((372<=xpos)&&(xpos<=488))) && ((28<=ypos)&&(ypos<=65)) );
		assign ptext[1] = ( (((223<=xpos)&&(xpos<=260)) || ((298<=xpos)&&(xpos<=334))) && ((66<=ypos)&&(ypos<=102)) );
		assign ptext[2] = ( ((223<=xpos)&&(xpos<=334)) && ((103<=ypos)&&(ypos<=139)) );
		assign ptext[3] = ( ((223<=xpos)&&(xpos<=260)) && ((140<=ypos)&&(ypos<=213)) );
		assign ptext[4] = ( (((223<=xpos)&&(xpos<=260)) || ((372<=xpos)&&(xpos<=488))) && ((140<=ypos)&&(ypos<=213)) );
	
	// Print "WINS"
		assign wintext[0] = ( (((52<=xpos)&&(xpos <= 88)) || ((126<=xpos)&&(xpos<=162)) || ((200<=xpos)&&(xpos<=236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=606))) && ((286<=ypos)&&(ypos<=323)) );
		assign wintext[1] = ( (((52<=xpos)&&(xpos <= 88)) || ((126<=xpos)&&(xpos<=162)) || ((200<=xpos)&&(xpos<=236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=532)) ) && ((324<=ypos)&&(ypos<=360)));
		assign wintext[2] = ( (((52<=xpos)&&(xpos <= 88)) || ((126<=xpos)&&(xpos<=162)) || ((200<=xpos)&&(xpos<=236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=606)) ) && ((361<=ypos)&&(ypos<=397)));
		assign wintext[3] = ( (((52<=xpos)&&(xpos <= 236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((570<=xpos)&&(xpos<=606))) && ((398<=ypos)&&(ypos<=434)) );
		assign wintext[4] = ( (((52<=xpos)&&(xpos <= 236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=606))) && ((435<=ypos)&&(ypos<=471)) );
endmodule

module LOSS_P2(VIDBUFF_LOSS_P2, xpos, ypos);
	input [9:0] xpos;
	input [9:0] ypos;
	
	output [7:0] VIDBUFF_LOSS_P2;
	
	reg [7:0] VIDBUFF_LOSS_P2;
	
	wire [3:0] ptext;
	wire [4:0] wintext;
	wire text;
	
	always @ (*)
		begin
			if (text) VIDBUFF_LOSS_P2 = 8'b11100000;
			else VIDBUFF_LOSS_P2 = 8'b00000000;
		end
	// Consolidate Signals
		assign text = (ptext[0] | ptext[1] | ptext[2] | ptext[3] | wintext[0] | wintext[1] | wintext[2] | wintext[3] | wintext[4]);
	// Print "P1"
		assign ptext[0] = ( (((223<=xpos)&&(xpos<=334)) || ((372<=xpos)&&(xpos<=488))) && ((28<=ypos)&&(ypos<=65)) );
		assign ptext[1] = ( (((223<=xpos)&&(xpos<=260)) || ((298<=xpos)&&(xpos<=334)) || ((372<=xpos)&&(xpos<=488))) && ((66<=ypos)&&(ypos<=102)) );
		assign ptext[2] = ( (((223<=xpos)&&(xpos<=334)) || ((372<=xpos)&&(xpos<=488))) && ((103<=ypos)&&(ypos<=139)) );
		assign ptext[3] = ( (((223<=xpos)&&(xpos<=260)) || ((372<=xpos)&&(xpos<=488))) && ((140<=ypos)&&(ypos<=213)) );
			
	// Print "WINS"
		assign wintext[0] = ( (((52<=xpos)&&(xpos <= 88)) || ((126<=xpos)&&(xpos<=162)) || ((200<=xpos)&&(xpos<=236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=606))) && ((286<=ypos)&&(ypos<=323)));
		assign wintext[1] = ( (((52<=xpos)&&(xpos <= 88)) || ((126<=xpos)&&(xpos<=162)) || ((200<=xpos)&&(xpos<=236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=532))) && ((324<=ypos)&&(ypos<=360)));
		assign wintext[2] = ( (((52<=xpos)&&(xpos <= 88)) || ((126<=xpos)&&(xpos<=162)) || ((200<=xpos)&&(xpos<=236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=606))) && ((361<=ypos)&&(ypos<=397)));
		assign wintext[3] = ( (((52<=xpos)&&(xpos <= 236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((570<=xpos)&&(xpos<=606))) && ((398<=ypos)&&(ypos<=434)));
		assign wintext[4] = ( (((52<=xpos)&&(xpos <= 236)) || ((274<=xpos)&&(xpos<=310)) || ((348<=xpos)&&(xpos<=384)) || ((422<=xpos)&&(xpos<=458)) || ((496<=xpos)&&(xpos<=606))) && ((435<=ypos)&&(ypos<=471)));
endmodule

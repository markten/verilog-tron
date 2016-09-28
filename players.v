/*
** Mark Tentindo
** Digital Logic II
** Professor Venkataramani
** Final Project
** 
** PLAYERS Module
**
** - updates player positions based on current direction
** - receives button presses and adjust direction values
** - holds player initialization positions
*/

module PLAYERS(P1_xpos, P1_ypos, P2_xpos, P2_ypos, WEB, COMP_ADDR_B, /**/ CLK_VGA, P1_left, P1_right, P2_left, P2_right, RST, LOSS_flag);

	// Inputs include clock and buttons
	input CLK_VGA, RST, LOSS_flag;
	input P1_left, P1_right, P2_left, P2_right;
	
	// Outputs include player positions and RAM Address and write enable for port B
	output [9:0] P1_xpos;
	output [9:0] P1_ypos;
	output [9:0] P2_xpos;
	output [9:0] P2_ypos;
	output WEB;
	output [17:0] COMP_ADDR_B;

	// Register for all values and clock dividers
	reg [9:0] P1_xpos, P1_xpos_old;
	reg [9:0] P1_ypos, P1_ypos_old;
	reg [9:0] P2_xpos, P2_xpos_old;
	reg [9:0] P2_ypos, P2_ypos_old;
	reg [1:0] P1_dir;
	reg [1:0] P2_dir;
	reg WEB;
	reg RAM_toggle;

	// Clock dividers
	reg [21:0] CLK_GAME;
	reg [21:0] CLK_RAM;
	
	// Wires amoung modules and for constant assignments
	wire [17:0] COMP_ADDR_B;
	wire P1_left, P1_right, P2_left, P2_right;
	wire wP1_left_down, wP1_right_down, wP2_left_down, wP2_right_down;
	
	// Constant assignments ie. RAM address for port B
	assign COMP_ADDR_B = RAM_toggle ? (P1_xpos_old - 100) + (440 * (P1_ypos_old - 20)):(P2_xpos_old - 100) + (440 * (P2_ypos_old - 20));
	
	// Initialization
	initial
		begin
			P1_xpos <= 300;
			P1_ypos <= 240;
			P2_xpos <= 340;
			P2_ypos <= 240;
			P1_dir = 1;
			P2_dir = 3;
			CLK_GAME = 0;
			WEB = 0;
		end
	
	// Main Module Loop
	always @ (posedge CLK_VGA)
		begin
			// Increment Clock Dividers
				if(!LOSS_flag)
					begin
						CLK_GAME = CLK_GAME + 1;
						CLK_RAM = CLK_RAM + 1;
					end
			
			// Handle RST Signal
			if(RST)
				begin
					P1_xpos = 300;
					P1_ypos = 240;
					P2_xpos = 340;
					P2_ypos = 240;
					P1_xpos_old = 0;
					P1_ypos_old = 0;
					P2_xpos_old = 0;
					P2_ypos_old = 0;
					P1_dir = 1;
					P2_dir = 3;
					CLK_GAME = 0;
					WEB = 0;
				end
			
			// Move Players a playable speed
			if(CLK_GAME == 1562500)
				begin
					CLK_GAME = 0; 
					// Store Old Position
						P1_xpos_old = P1_xpos;
						P1_ypos_old = P1_ypos;
						P2_xpos_old = P2_xpos;
						P2_ypos_old = P2_ypos;
					// update P1 Position
						// 0 = up, 1 = right, 2 = down, 3 = left
						if(P1_dir == 0) P1_ypos = P1_ypos - 1;
						else if(P1_dir == 1) P1_xpos = P1_xpos + 1;
						else if(P1_dir == 2) P1_ypos = P1_ypos + 1;
						else if(P1_dir == 3) P1_xpos = P1_xpos - 1;
					// update P2 Position
						// 1 = up, 2 = right, 3 = down, 4 = left
						if(P2_dir == 0) P2_ypos = P2_ypos - 1;
						else if(P2_dir == 1) P2_xpos = P2_xpos + 1;
						else if(P2_dir == 2) P2_ypos = P2_ypos + 1;
						else if(P2_dir == 3) P2_xpos = P2_xpos - 1;
				end
			
			// Update RAM for trails
				if(CLK_RAM == 1)
					begin
						RAM_toggle = 1;
						WEB = 1;
					end
				if(CLK_RAM == 390625)WEB = 0;
				if(CLK_RAM == 781250)
					begin
						RAM_toggle = 0;
						WEB = 1;
					end
				if(CLK_RAM == 1562500)
					begin
						WEB = 0;
						CLK_RAM = 0;
					end
			// Adjust Player Directions based on button presses
			if(wP1_left_down == 1) P1_dir = P1_dir - 1;
			else if(wP1_right_down == 1) P1_dir = P1_dir + 1;
			if(wP2_left_down == 1) P2_dir = P2_dir - 1;
			else if(wP2_right_down == 1) P2_dir = P2_dir + 1;
		end
	
	// Debounce Signals
		
		DEBOUNCE P1L(CLK_VGA, P1_left, wP1_left_down); 
		DEBOUNCE P1R(CLK_VGA, P1_right, wP1_right_down);
		DEBOUNCE P2L(CLK_VGA, P2_left, wP2_left_down);
		DEBOUNCE P2R(CLK_VGA, P2_right, wP2_right_down);
			
endmodule

module DEBOUNCE(clk, button, button_down); // Modified from FPGA4FUN example to only send pulse on DOWN
	input clk;
	input button;

	output button_down;

	reg button_sync_0;  always @(posedge clk) button_sync_0 <= ~button;
	reg button_sync_1;  always @(posedge clk) button_sync_1 <= button_sync_0;

	reg [15:0] button_cnt;

	reg button_state;
	wire button_idle = (button_state == button_sync_1);
	wire button_cnt_ovf = &button_cnt;

	always @(posedge clk)
		if(button_idle)
			button_cnt <= 0;
		else
			begin
				button_cnt <= button_cnt + 1;
				if(button_cnt_ovf) button_state <= ~button_state;
			end

	wire button_down = ~button_state & ~button_idle & button_cnt_ovf;

endmodule

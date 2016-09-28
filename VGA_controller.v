/*
** Mark Tentindo
** Digital Logic II
** Professor Venkataramani
** Final Project
**
** VGA_controller Module
**
** - provides the horizontal and vertical sync signals
** - forwards color outputs to VGA port
** - outputs current draw position
** - outputs address for VRAM access
**
*/

module VGA_controller(H_sync_out, V_sync_out, COLOR_OUT, COMP_ADDR, xpos, ypos, /**/ CLK_VGA, VIDBUFF);

	input CLK_VGA;
	input [7:0] VIDBUFF;

	output H_sync_out;
	output V_sync_out;
	output [9:0] xpos;
	output [9:0] ypos;
	output COLOR_OUT;
	output [17:0] COMP_ADDR;

	reg [9:0] xpos;
	reg [9:0] ypos;
	reg H_sync_out, V_sync_out;
	reg H_data_on, V_data_on;

	// Initialize Values
	initial
		begin
			xpos = 0;
			ypos = 0;
		end

	// Create VRAM address by converting 2D array to 1D
	assign COMP_ADDR = (xpos - 100) + (440 * (ypos - 20));

	// Sync signal generator
	always @(posedge CLK_VGA)
		begin
			xpos = xpos + 1;
			
			if (xpos == 640) H_data_on = 0;
			if (xpos == 660) H_sync_out = 0;
			if (xpos == 755) H_sync_out = 1;
			if (xpos == 800)
				begin
					H_data_on = 1;
					xpos = 0;
					ypos = ypos + 1;
				end
			if (ypos == 480) V_data_on = 0;
			if (ypos == 494) V_sync_out = 0;
			if (ypos == 496) V_sync_out = 1;
			if (ypos == 528)
				begin
					V_data_on = 1;
					ypos = 0;
				end
		end
		
	// Create color ouput control and consolidate to wire w/ fan-out of 8
	assign RED_out2 = (VIDBUFF[7] && H_data_on && V_data_on);
	assign RED_out1 = (VIDBUFF[6] && H_data_on && V_data_on);
	assign RED_out0 = (VIDBUFF[5] && H_data_on && V_data_on);
	assign GREEN_out2 = (VIDBUFF[4] && H_data_on && V_data_on);
	assign GREEN_out1 = (VIDBUFF[3] && H_data_on && V_data_on);
	assign GREEN_out0 = (VIDBUFF[2] && H_data_on && V_data_on);
	assign BLUE_out1 = (VIDBUFF[1] && H_data_on && V_data_on);
	assign BLUE_out0 = (VIDBUFF[0] && H_data_on && V_data_on);
	
	wire [7:0] COLOR_OUT = {RED_out2, RED_out1, RED_out0, GREEN_out2, GREEN_out1, GREEN_out0, BLUE_out1, BLUE_out0};

endmodule

/*
** Mark Tentindo
** Digital Logic II
** Professor Venkataramani
** Final Project
** 
** TRON_game Module
**
** - serves as top level module
** - instantiates other modules
** - defines connections between modules
*/

module TRON_game(CLK, P1_left, P1_right, P2_left, P2_right, H_sync_out, V_sync_out, COLOR_OUT, RST);

	input CLK, RST;
	input P1_left, P1_right, P2_left, P2_right;

	output H_sync_out, V_sync_out;
	output [7:0] COLOR_OUT;
	
	// Necessary Constants and Enables
	reg dina = 0;
	reg dinb = 1;

	// Synthesizer occasionally whines about missing connections, implement them manually
	wire [9:0] wP1_xpos, wP1_ypos, wP2_xpos, wP2_ypos;
	wire [17:0] wCOMP_ADDR_A;
	wire [17:0] wCOMP_ADDR_B;
	wire [9:0] wxpos, wypos;
	wire [7:0] wVIDBUFF;
	
	// Instantiate all sub-modules
	MASTER_CLK clk(CLK, CLK_VGA, CLK_50);
	VGA_controller display(H_sync_out, V_sync_out, COLOR_OUT, wCOMP_ADDR_A, wxpos, wypos, /**/ CLK_VGA, wVIDBUFF);
	VBUFF_controller vmem(wVIDBUFF, LOSS_flag,/**/ wypos, wxpos, wP1_xpos, wP1_ypos, wP2_xpos, wP2_ypos, douta);
	VID_MEM vram(CLK_50, RST, RST, wCOMP_ADDR_A, dina, douta, CLK_50, RST, web, wCOMP_ADDR_B, dinb, doutb);
	PLAYERS controls(wP1_xpos, wP1_ypos, wP2_xpos, wP2_ypos, web, wCOMP_ADDR_B, /**/ CLK_VGA, P1_left, P1_right, P2_left, P2_right, RST, LOSS_flag);
	
endmodule

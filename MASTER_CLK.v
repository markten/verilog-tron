/*
** Mark Tentindo
** Digital Logic II
** Professor Venkataramani
** Final Project
** 
** MASTER_CLK Module
**
** - Consolidates the various clock signals into a single module
** - Forwards 50Mhz clock for general use
** - Creates 25 MHz signal for VGA_controller
** - Creates game speed clock that sets player movement rate
*/

module MASTER_CLK (CLK, CLK_VGA, CLK_50);
input CLK;
output CLK_50;
output CLK_VGA;

reg CLK_VGA;

initial
	begin
		CLK_VGA = 0;
	end

// 50 MHz Clock
	wire CLK_50 = CLK;

// 25 MHz Clock
	always @ (posedge CLK)
		begin
			CLK_VGA = ~CLK_VGA;
		end
endmodule

# Verilog TRON

This is a simple two player implementation of the lightcycle TRON game. It was originally developed using the Xilinx ISE with a Digilent Basys 2 Spartan 3 FPGA development board. It utilizes the RAM modules included on the development board as a rudimentary video buffer.

## Setup
Synthesize and write the files to the board. Make sure to map the clock and player control pins.
Connect the board to a monitor using a VGA cable. Occassionally, adding an RC circuit to two of the pins on the board helps stabilize the video output.

## Gameplay
Players try to avoid each other by turning using the four pushbuttons on the dev board.

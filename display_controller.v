`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Walid Al-Muhtaseb
// 
// Create Date:    4.17.2025 01:54:30 PM 
// Design Name: 
// Module Name:    DisplayController 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 


// Additional Comments:  https://learn.digilentinc.com/Documents/269
// - Use Bahavioural Modelling (always, initial)
// - Use the Following: clock divider, two counters(horizontal counter, vertical
// counter), 
//////////////////////////////////////////////////////////////////////////////////

// this file is requred to display the image on the screen and display the size of what is 'light' and what is '~light'
module display_controller(
	input clk,
	output hSync, vSync,
	output reg bright,
	output reg[9:0] hCount, 
	output reg [9:0] vCount // Covers 800, width of the screen, because it's 2^10 change based on the resolution
	);
	
	reg pulse;
	reg clk25;
	
	initial begin // Set all of them initially to 0 just so that we dont get weird values
		clk25 = 0;
		pulse = 0;
	end
	
	always @(posedge clk) // This is the clock divider, it divides the 100MHz clock to 25MHz
		pulse = ~pulse;
	always @(posedge pulse) // This is the clock divider, it divides the 100MHz clock to 25MHz
		clk25 = ~clk25;
		
	always @ (posedge clk25)  // This is the horizontal and vertical counter, it counts the number of pixels in the screen
		begin
		if (hCount < 10'd799)
			begin
			hCount <= hCount + 1;
			end
		else if (vCount < 10'd524)
			begin
			hCount <= 0;
			vCount <= vCount + 1;
			end
		else
			begin
			hCount <= 0;
			vCount <= 0;
			end
		end
		
	assign hSync = (hCount < 96) ? 0:1; // 96 is the width of the pulse, so it will be 0 for 96 pixels and then 1 for the rest of the screen
	assign vSync = (vCount < 2) ? 0:1;  // 2 is the height of the pulse, so it will be 0 for 2 pixels and then 1 for the rest of the screen
	//assign bright = (hCount > 10'd143 && hCount < 10'd784 && vCount > 10'd34 && vCount < 10'd516) ? 1:0; // This is the display area, so it will be 1 for the display area and 0 for the rest of the screen

	always @(posedge clk25) // This is the display area, so it will be 1 for the display area and 0 for the rest of the screen
		begin
		if(hCount > 10'd143 && hCount < 10'd784 && vCount > 10'd34 && vCount < 10'd516)
			bright <= 1; // This is the display area, so it will be 1 for the display area and 0 for the rest of the screen
		else
			bright <= 0; // This is the display area, so it will be 1 for the display area and 0 for the rest of the screen
		end	
		
endmodule

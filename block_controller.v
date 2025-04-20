`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: Walid Al-Muhtaseb
// 
// Create Date: 12/4/2025 01:54:30 PM
// Design Name: Accelerator Top Module
// Module Name: top
//////////////////////////////////////////////////////////////////////////////////

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	input [14:0] acl_data, //this is the accelerometer data, but it is not used in this example
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	
	parameter RED   = 12'b1111_0000_0000;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill) 
			rgb = RED; 
		else	
			rgb=background;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);
	
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for center of screen
			xpos<=450;
			ypos<=250;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if(right) begin // done
				if(acl_data[13:10] > 4'b0100)
					begin
						xpos<=xpos-3; //change the amount you increment to make the speed faster
					end
				else begin
					xpos<=xpos-1; //change the amount you increment to make the speed faster
				end
			end

			else if(left) begin    // done
				if(acl_data[13:10] > 4'b1011)
					begin
						xpos<=xpos+1; //change the amount you increment to make the speed faster
					end
				else begin
					xpos<=xpos+3; //change the amount you increment to make the speed faster
				end
			end



			if(up) begin   /// done
				if(acl_data[8:5] > 4'b0100)
					begin
						ypos<=ypos-3; //change the amount you increment to make the speed faster
					end
				else begin
					ypos<=ypos-1; //change the amount you increment to make the speed faster
				end
				if(ypos<=34) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					ypos<=514;
			end



			else if(down) begin  // done 
				if(acl_data[8:5] > 4'b1100)
					begin
						ypos<=ypos+1; //change the amount you increment to make the speed faster
					end
				else begin
					ypos<=ypos+3; //change the amount you increment to make the speed faster
				end
				if(ypos>=514) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					ypos<=34;
			end



			// if its in a certain radius dont move x< 3 and y< 3 do nothing 4b`0011
			if( (acl_data[13:10] < 4'b0010) || (acl_data[13:10] > 4'b1110) ) begin
				xpos <= xpos;
			end
			if( acl_data[9:5] < 4'b0010) begin
				ypos <= ypos;
			end

			/*		
	wire [3:0] x_data, y_data, z_data;
    assign x_data = acl_data[13:10];
    assign y_data = acl_data[8:5];
    assign z_data = acl_data[3:0];
			*/
		end
	end
	



	//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
				background <= 12'b1111_1111_1111;
		else
			background <= 12'b1111_1111_1111;
	end

	
	
endmodule

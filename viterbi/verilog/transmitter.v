`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2023 10:55:25 PM
// Design Name: 
// Module Name: transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module transmitter(
    input clk,
	input start,
	input [7:0] data,
	output reg TX,
	output reg done
    );
	parameter END_OF_COUNTER = 10;

    reg [3:0] i;
    wire [9:0] temp = {1'b1 , data , 1'b0};
    reg [7:0] counter; //determines Transmitting Rate ( in this code : 115200)
    reg running;

    always @(posedge clk)begin
    	if(!start) begin
    		counter <= 0;
    		TX <= 1;
    		i <= 0;
    		done <= 0;
    		running <= 0;
    	end else if(!done) begin
    		running <= 1;
    	end

    	if(running) begin
    		counter <= counter + 1;
    		if(counter == END_OF_COUNTER) begin
    			i <= i + 1 ;
    			TX <= temp [i];
    			counter <= 0;
    			if(i == 9)begin
    				i <= 0;
    				done <= 1;
    				running <= 0;
    			end
    		end
    	end
    end

endmodule

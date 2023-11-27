`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2023 10:09:13 PM
// Design Name: 
// Module Name: receiver
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


module receiver(
    input clk,
    input start,
    input rx,
    output ready,
    output[3:0] outputData
    );
    parameter END_OF_COUNTER = 10;

    reg state;
    reg [8:0] data;
    reg [7:0] counter;
    reg [3:0] i;

    reg crcStart;

    always@(posedge clk) begin
        if(!start) begin
            data <= 0;
            counter <= 0;
            i <= 0;
            state <= 0;
            crcStart <= 0;
        end else begin
            if(!state) begin
                if(rx == 0)
                    state <= 1;
            end if(state) begin
                counter <= counter + 1;
		        if(counter == END_OF_COUNTER) begin
		        	i <= i + 1;
		        	data[i] <= rx;
		        	counter <= 0;
		        	if(i == 8) begin
		        		state <= 0;
		        		i <= 0;
                        crcStart <= 1;
                    end else
                        crcStart <= 0;
		        end
            end
        end
    end

    ViterbiDecoder decoder(
        .clk(clk),
        .start(crcStart),
        .inputData(data[7:0]),
        .ready(ready),
        .outputData(outputData)
    );

endmodule

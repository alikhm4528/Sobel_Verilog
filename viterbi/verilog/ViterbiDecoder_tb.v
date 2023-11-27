`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2023 08:48:35 PM
// Design Name: 
// Module Name: ViterbiEncoder_tb
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


module ViterbiDecoder_tb;

    reg clk;
    reg start;
    reg [1:0] inputData;
    wire outputData;

    reg clk = 0;
    reg startT;
    reg startR;
    reg[7:0] inputData;

    wire doneT;


    wire data_wire;
    wire readyR;
    wire[3:0] outputData;
    wire validR;

    always@(clk)
        clk <= #5 ~clk;

    integer i;
    integer file;
    reg[`N-1:0] raw_data;
    reg[2*`N-1:0] encoded_data;

    initial begin
        file = $fopen("raw_data.mem", "r");
        $fscanf(file, "%b\n", raw_data);
        $fclose(file);

        file = $fopen("encoded_data.mem", "r");
        $fscanf(file, "%b\n", encoded_data);
        $fclose(file);
    end


endmodule

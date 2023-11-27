//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 01/05/2023 04:05:20 PM
//// Design Name: 
//// Module Name: rgb2gray
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


module rgb2gray
#(
    parameter H = 200,
    parameter W = 160
)
(
    // input clk,
    // input rstn,
    // input start,
    input[7:0] data_in_red,
    input[7:0] data_in_green,
    input[7:0] data_in_blue,
    // output reg ready,
    output reg[7:0] data_out
);
    localparam R_coeff = 30;
    localparam G_coeff = 59;
    localparam B_coeff = 11;

    always@(*) begin
        data_out =
            (R_coeff * data_in_red +
            G_coeff * data_in_green +
            B_coeff * data_in_blue) >> 7; // divide by 128
    end

 endmodule
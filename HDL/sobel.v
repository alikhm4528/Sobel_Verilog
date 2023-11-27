//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 01/05/2023 11:16:15 PM
//// Design Name: 
//// Module Name: sobel
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


module sobel
#(
    parameter H = 200,
    parameter W = 160
)
(
    input clk,
    input rstn,
    input[7:0] data_in,
	 input[7:0] THR,
    output reg ready,
    output reg data_out
);

reg signed[7:0] ROM_Gray [2:0][2:0];
// reg signed[15:0] ROM_Edge;

reg[1:0] W_counter;
reg[1:0] H_counter;

reg signed[15:0] Gx;
reg signed[15:0] Gy;

reg dataReady;

always @(posedge clk) begin
    if(!rstn) begin
        W_counter <= 0;
        H_counter <= 0;
        dataReady <= 0;
        ready <= 0;
    end else if(W_counter != 3) begin
        if(H_counter != 2) begin
            H_counter <= H_counter + 1;
        end else begin
            H_counter <= 0;
            W_counter <= W_counter + 1;
        end

        if(W_counter == 2 && H_counter == 2)
            dataReady <= 1;

        ROM_Gray[H_counter][W_counter] <= data_in;
    end else if(!dataReady) begin
        H_counter <= (H_counter == 2) ? 0 : H_counter + 1;

        ROM_Gray[H_counter][0] <= ROM_Gray[H_counter][1];
        ROM_Gray[H_counter][1] <= ROM_Gray[H_counter][2];
        ROM_Gray[H_counter][2] <= data_in;

        if(H_counter == 2)
            dataReady <= 1;
        ready <= 0;
    end else begin
        // ROM_Edge <= Gx + Gy;
        if(Gx + Gy > THR)
            data_out <= 1;
        else
            data_out <= 0;

        ready <= 1;
        dataReady <= 0;
    end
end

always @(*) begin
    Gx = -ROM_Gray[0][0] + ROM_Gray[2][0] -
        2 * ROM_Gray[0][1] + 2 * ROM_Gray[2][1] -
        ROM_Gray[0][2] + ROM_Gray[2][2];

    Gy = -ROM_Gray[0][0] - 2 * ROM_Gray[1][0] -
        ROM_Gray[2][0] + ROM_Gray[0][2] +
        2 * ROM_Gray[1][2] + ROM_Gray[2][2];
end

endmodule

      
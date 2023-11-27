`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2023 12:23:19 AM
// Design Name: 
// Module Name: CRC
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


module CRC(
        input clk,
        input start,
        input[7:0] InputData,
        output reg Ready,
        output reg valid,
        output reg[3:0] OutputData
    );

    wire[4:0] Divisor = 5'b10011;
    reg[4:0] Divident;

    reg[1:0] Counter;
    reg endOfOp;

    always @(posedge clk) begin
        if(!start) begin
            OutputData <= 0;
            Counter <= 0;
            Ready <= 0;
            endOfOp <= 0;
            Divident <= 0;
            valid <= 0;
        end else begin
            valid <= 0;
            if(!Counter)
                if(!endOfOp) begin
                    if(InputData[7])
                        Divident <= {(InputData[6:3] ^ Divisor[3:0]), InputData[2]};
                    else
                        Divident <= {InputData[6:3], InputData[2]};
                    Counter <= Counter + 1;
                end else begin
                    if(Divident == 0) begin
                        OutputData <= InputData[7:4];
                        valid <= 1;
                    end else begin
                        OutputData <= InputData[7:4]; // ??
                    end
                    Ready <= 1;
                end
            else begin
                if(Counter == 2'b11) begin
                    endOfOp <= 1;
                    if(Divident[4])
                        Divident <= Divident ^ Divisor;
                end else begin
                    if(Divident[4])
                        Divident <= {(Divident[3:0] ^ Divisor[3:0]), InputData[2 - Counter]};
                    else
                        Divident <= {Divident[3:0], InputData[2 - Counter]};
                end
                Counter <= Counter + 1;
            end
        end
    end

endmodule

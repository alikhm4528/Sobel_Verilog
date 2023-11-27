`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2023 07:11:18 PM
// Design Name: 
// Module Name: ViterbiEnccoder
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


module ViterbiDecoder(
    input clk,
    input start,
    input [7:0] inputData,
    output reg [3:0] outputData,
    output reg ready
    );
    reg [1:0] error [1:0][1:0];
    reg [3:0] cost [3:0];
    reg [1:0] lastState [3:0][3:0];

    reg[7:0] inputTemp;
    reg[2:0] counter;

    integer i;
    integer j;

    always @(posedge clk) begin
        if(!start) begin
            outputData <= 0;
            inputTemp <= 0;
            counter <= 0;
            ready <= 0;
            for(i = 0; i < 4; i = i + 1)
                for(j = 0; j < 4; j = j + 1)
                    lastState[i][j] <= 0;
            cost[0] <= 0;
            for(i = 1; i < 4; i = i + 1)
                cost[i] <= 4'b111;
        end else begin
            if(counter == 0) begin
                counter <= counter + 1;
                inputTemp <= inputData;
            end else if(counter < 5) begin
                counter <= counter + 1;
                inputTemp <= inputTemp >> 2;
                if((cost[0] + error[0][0]) < (cost[2] + error[1][1])) begin
                    cost[0] <= cost[0] + error[0][0];
                    lastState[0][counter-1] <= 0;
                end else begin
                    cost[0] <= cost[2] + error[1][1];
                    lastState[0][counter-1] <= 2;
                end

                if((cost[0] + error[1][1]) < (cost[2] + error[0][0])) begin
                    cost[1] <= cost[0] + error[1][1];
                    lastState[1][counter-1] <= 0;
                end else begin
                    cost[1] <= cost[2] + error[0][0];
                    lastState[1][counter-1] <= 2;
                end

                if((cost[1] + error[0][1]) < (cost[3] + error[1][0])) begin
                    cost[2] <= cost[1] + error[0][1];
                    lastState[2][counter-1] <= 1;
                end else begin
                    cost[2] <= cost[3] + error[1][0];
                    lastState[2][counter-1] <= 3;
                end

                if((cost[1] + error[1][0]) < (cost[3] + error[0][1])) begin
                    cost[3] <= cost[1] + error[1][0];
                    lastState[3][counter-1] <= 1;
                end else begin
                    cost[3] <= cost[3] + error[0][1];
                    lastState[3][counter-1] <= 3;
                end

            end else begin
                ready <= 1;
                if(cost[0] < cost[1]) begin
                    if(cost[0] < cost[2]) begin
                        if(cost[0] < cost[3]) begin
                            outputData <= {
                                lastState[lastState[lastState[0][3]][2]][1][0],
                                lastState[lastState[0][3]][2][0],
                                lastState[0][3][0],
                                1'b0};
                        end else begin
                            outputData <= {
                                lastState[lastState[lastState[3][3]][2]][1][0],
                                lastState[lastState[3][3]][2][0],
                                lastState[3][3][0],
                                1'b1};
                        end
                    end else begin
                        if(cost[2] < cost[3]) begin
                            outputData <= {
                                lastState[lastState[lastState[2][3]][2]][1][0],
                                lastState[lastState[2][3]][2][0],
                                lastState[2][3][0],
                                1'b0};
                        end else begin
                            outputData <= {
                                lastState[lastState[lastState[3][3]][2]][1][0],
                                lastState[lastState[3][3]][2][0],
                                lastState[3][3][0],
                                1'b1};
                        end
                    end
                end else begin
                    if(cost[1] < cost[2]) begin
                        if(cost[1] < cost[3]) begin
                            outputData <= {
                                lastState[lastState[lastState[1][3]][2]][1][0],
                                lastState[lastState[1][3]][2][0],
                                lastState[1][3][0],
                                1'b1};
                        end else begin
                            outputData <= {
                                lastState[lastState[lastState[3][3]][2]][1][0],
                                lastState[lastState[3][3]][2][0],
                                lastState[3][3][0],
                                1'b1};
                        end
                    end else begin
                        if(cost[2] < cost[3]) begin
                            outputData <= {
                                lastState[lastState[lastState[2][3]][2]][1][0],
                                lastState[lastState[2][3]][2][0],
                                lastState[2][3][0],
                                1'b0};
                        end else begin
                            outputData <= {
                                lastState[lastState[lastState[3][3]][2]][1][0],
                                lastState[lastState[3][3]][2][0],
                                lastState[3][3][0],
                                1'b1};
                        end
                    end
                end
            end
        end
    end

    always @(*) begin
        error[0][0] = {0, inputTemp[1]} + {0, inputTemp[0]};
        error[1][1] = {0, ~inputTemp[1]} + {0, ~inputTemp[0]};
        error[0][1] = {0, inputTemp[1]} + {0, ~inputTemp[0]};
        error[1][0] = {0, ~inputTemp[1]} + {0, inputTemp[0]};
    end

endmodule

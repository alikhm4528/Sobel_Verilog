`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2023 12:02:22 AM
// Design Name: 
// Module Name: receiver_tb
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

`define N 100

module receiver_tb;

    reg clk = 0;
    reg startT;
    reg startR;
    reg[7:0] inputData;

    wire doneT;


    wire data_wire;
    wire readyR;
    wire[3:0] outputData;

    always@(clk)
        clk <= #5 ~clk;

    integer numberOfErros = 0;
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

    initial begin
        startT = 0;
        startR = 0;
        inputData = 0;
        @(posedge clk);


        for(i = 0; i < 2 * `N - 8; i = i + 8) begin
            startT = #2 1;
            startR = 1;
            inputData[7] = encoded_data[i+7];
            inputData[6] = encoded_data[i+6];
            inputData[5] = encoded_data[i+5];
            inputData[4] = encoded_data[i+4];
            inputData[3] = encoded_data[i+3];
            inputData[2] = encoded_data[i+2];
            inputData[1] = encoded_data[i+1];
            inputData[0] = encoded_data[i];
            @(posedge doneT);

            @(posedge readyR);
            startT = #2 0;
            $write("output data = %b\n", outputData);
            if(raw_data[3:0] !== outputData) begin
                numberOfErros = numberOfErros + 1;
                $write("ERROR: expected %b but the output is %b\n", raw_data[3:0], outputData);
            end
            raw_data = raw_data >> 4;

            @(posedge clk);
        end

        if(numberOfErros > 0)
            $write("Number of erros = %d\n", numberOfErros);
        else
            $write("All tests passed\n");

        #20;
        $finish;
    end

    receiver receiverModule(
        .clk(clk),
        .start(startR),
        .rx(data_wire),
        .ready(readyR),
        .outputData(outputData)
    );

    transmitter transmitterModule(
        .clk(clk),
	    .start(startT),
	    .data(inputData),
	    .TX(data_wire),
	    .done(doneT)
    );

endmodule

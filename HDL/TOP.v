module TOP(
	input 		CLOCK_50,	
	input [8:0] SW,
	input [0:0] KEY,
////////////////	
	output 		VGA_CLK,   	
	output 		VGA_HS,		
	output 		VGA_VS,		
	output 		VGA_BLANK,	
	output 		VGA_SYNC,	
	output[9:0] VGA_R,   	
	output[9:0]	VGA_G,	 	
	output[9:0] VGA_B,
//////////////////
	input UART_RXD,
	output [7:0] LEDR

);
reg[1:0] state;
reg[14:0] mem_addr_write;
reg[2:0] mem_data_write;
wire uart_ready;
wire uart_valid;
wire[3:0] uart_outputData;
reg uart_ready_delay;
reg uart_start = 0;
reg endOfUartPackets = 0;

reg [7:0] led = 0;
assign LEDR = led;

parameter	IDLE = 0,
				FILL_MEM_WITH_UART_DATA = 1,
				PLOT = 2;
wire resetn;		
assign resetn = SW[8]; //changed
reg flag = 0;

reg[7:0] W_pix_cntr = 0;
reg[7:0] H_pix_cntr = 0;

reg memory_write_en;
reg flag_2;

always @(posedge CLOCK_50) begin
	if(!resetn) begin
	   state <= IDLE;
	   mem_data_write <= 0;
	   uart_start <= 0;
	   endOfUartPackets <= 0;
		flag <= 0;
		W_pix_cntr <= 0;
		H_pix_cntr <= 0;
		mem_addr_write <= 0;
		led <= 0;
		memory_write_en <= 0;
		flag_2 <= 0;
	end
	
	else begin
		// led[3:0] <= uart_outputData;
		case(state) 
			IDLE: begin
			    uart_start <= 1;
				state <= FILL_MEM_WITH_UART_DATA;
			end
			
			FILL_MEM_WITH_UART_DATA: begin
				//led <= 8'b00001111;
				if(uart_ready==1 && /*uart_ready_delay==0*/!flag ) begin //new packet uart received
					memory_write_en <= 1;
					led[4] <= uart_ready;
					led[7] <= uart_valid;
					led[3:0] <= uart_outputData;
					mem_addr_write <= H_pix_cntr * 160   +   W_pix_cntr;
					mem_data_write <= uart_outputData[3:1];
					
					if(W_pix_cntr!=159) begin
						W_pix_cntr <= W_pix_cntr + 1;
					end
					else begin
						W_pix_cntr <= 0;
						H_pix_cntr <= H_pix_cntr + 1;
					end	
					//led <= 8'b11110000;
					flag <= 1;
				end
				
				else 				memory_write_en <= 0;

				
				if(uart_ready == 0) begin
					//led <= 8'b11111111;
					flag <= 0;
				end
				
				
				if(W_pix_cntr==159 && H_pix_cntr==199) begin//159-199
					state <= PLOT;
					endOfUartPackets <= 1;
					//led <= 8'b00001111;
				end
			end
			
			PLOT: begin
				/*if(flag_2 == 0) begin
					state <= PLOT;
				end
				else if(uart_ready == 1) begin
					state <= IDLE;
					mem_data_write <= 0;
					uart_start <= 0;
					endOfUartPackets <= 0;
					flag <= 0;
					W_pix_cntr <= 0;
					H_pix_cntr <= 0;
					mem_addr_write <= 0;
					led <= 0;
					memory_write_en <= 0;
				end
				
				if(uart_ready == 0)
					flag_2 <= 1;*/
					state <= PLOT;
				//led <= 8'b00000000;
			end
		
		
		
		endcase
		
	end
	

end


always @(posedge CLOCK_50) begin
	uart_ready_delay <= uart_ready;
end



receiver my_receiver(
	.clk(CLOCK_50),
	.start(uart_start),
	.rx(UART_RXD),
	.ready(uart_ready),
	.valid(uart_valid),
	.outputData(uart_outputData)
);


sketch my_sketch(
   .CLOCK_50(CLOCK_50),						//	On Board 50 MHz
	.resetn(resetn),							//	Push Button[3:0]
	.SW(SW),
	.VGA_CLK(VGA_CLK),   						//	VGA Clock
	.VGA_HS(VGA_HS),							//	VGA H_SYNC
	.VGA_VS(VGA_VS),							//	VGA V_SYNC
	.VGA_BLANK(VGA_BLANK),						//	VGA BLANK
	.VGA_SYNC(VGA_SYNC),						//	VGA SYNC
	.VGA_R(VGA_R),   						//	VGA Red[9:0]
	.VGA_G(VGA_G),	 						//	VGA Green[9:0]
	.VGA_B(VGA_B),   						//	VGA Blue[9:0]
	///////// new handling shits
	.mem_addr_write(mem_addr_write),
	.mem_data_write(mem_data_write),
	.endOfUartPackets(endOfUartPackets),
	.state(state),
	.memory_write_en(memory_write_en)
);
	
	


    

endmodule
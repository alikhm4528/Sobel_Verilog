module sketch(
   input			CLOCK_50,				//	50 MHz
	input			resetn,						//	Button[3:0]
	input [7:0] SW,
	output		VGA_CLK,   			//	VGA Clock
	output		VGA_HS,				//	VGA H_SYNC
	output		VGA_VS,				//	VGA V_SYNC
	output		VGA_BLANK,			//	VGA BLANK
	output		VGA_SYNC,			//	VGA SYNC
	output[9:0]	VGA_R,   				//	VGA Red[9:0]
	output[9:0]	VGA_G,	 				//	VGA Green[9:0]
	output[9:0]	VGA_B,   				//	VGA Blue[9:0]
	///////////////////////////////////////////////////
	input[14:0] mem_addr_write,
	input[2:0]  mem_data_write,
	input      endOfUartPackets,
	input[1:0]  state,
	input memory_write_en
);

   parameter	IDLE = 0,
				   FILL_MEM_WITH_UART_DATA = 1,
					PLOT = 2;
	
	//wire resetn;
	//assign resetn = ~KEY[0]; //changed

   //########Create the color, x, y and writeEn wires that are inputs to the controller.########
	reg [2:0] color;
	reg [8:0] x;
	reg [7:0] y;
	reg writeEn;
			
   vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
	//#############################################################################################
	
	
	//####### Instantiate and Initialize Memory ###################################################
	wire[2:0] mem_out;
	reg[14:0] mem_address;
	
	wire[2:0] mem_in;
	assign mem_in = mem_data_write;
	
	wire 		 write_or_read;
	assign write_or_read = memory_write_en;//(state==FILL_MEM_WITH_UART_DATA)? 1 : 0;
	//parameter IMAGE_FILE = "image.mif";
	
	lpm_ram_dq my_ram(
		.inclock(CLOCK_50),
		.outclock(CLOCK_50),
		.data(mem_in),
		.address(mem_address),
		.we(write_or_read),
		.q(mem_out));

	//defparam my_ram.LPM_FILE = IMAGE_FILE;
	defparam my_ram.LPM_WIDTH = 3;
	defparam my_ram.LPM_WIDTHAD = 15;
	defparam my_ram.LPM_INDATA = "REGISTERED";
	defparam my_ram.LPM_ADDRESS_CONTROL = "REGISTERED";
	defparam my_ram.LPM_OUTDATA = "REGISTERED";
	//################################################################################################
	
  /* wire[2:0] mem_out_back;
	parameter BACK_IMAGE_FILE = "background.mif";
	lpm_ram_dq my_back(
		.inclock(CLOCK_50),
		.outclock(CLOCK_50),
		.data(black_color),
		.address(mem_address),
		.we(gnd),
		.q(mem_out_back));

	defparam my_back.LPM_FILE = BACK_IMAGE_FILE;
	defparam my_back.LPM_WIDTH = 3;
	defparam my_back.LPM_WIDTHAD = 15;
	defparam my_back.LPM_INDATA = "REGISTERED";
	defparam my_back.LPM_ADDRESS_CONTROL = "REGISTERED";
	defparam my_back.LPM_OUTDATA = "REGISTERED";
*/



    wire[7:0] gray_out;
	wire sobelReady;
	wire sobelOut;

	rgb2gray my_rgb2gray(
    	.data_in_red({8{mem_out[2]}}),
    	.data_in_green({8{mem_out[1]}}),
    	.data_in_blue({8{mem_out[0]}}),
    	.data_out(gray_out)
	);

	sobel my_sobel(
		.clk(CLOCK_50),
    	.rstn(resetn),
    	.data_in(gray_out),
		.THR(SW),
    	.ready(sobelReady),
    	.data_out(sobelOut)
	);
           
	
	
	
	
	//####Calculates mem_addr for reading proper data of each element of 3x3 matrix, column wise! #########

	reg[1:0] W_counter = 0;
	reg[1:0] H_counter = 0;
	reg[14:0] Win_counter = 0;

	reg delay;
	reg finish;

	reg[14:0] mem_address_tmp1 = 0;

	always@(posedge CLOCK_50) begin
		if(!resetn) begin
			W_counter <= 0;
			H_counter <= 0;
			Win_counter <= 2;
			delay <= 0;
			finish <= 0;
			mem_address_tmp1 <= 0;
		end 
		else if(state == PLOT) begin
			if(!delay && !finish) begin
				if(H_counter == 2) begin
					H_counter <= 0;
					Win_counter <= Win_counter + 1;
	
					if(W_counter == 2)
						delay <= 1;
					else
						W_counter <= W_counter + 1;
				end 
				else begin
					H_counter <= H_counter + 1;
				end
	
				mem_address_tmp1 <= Win_counter + H_counter * 160;
			end 
			else begin
				if(Win_counter >= 31680)
					finish <= 1;
				else
					delay <= 0;
				// Win_counter <= Win_counter + 1;
			end
		end
	end
	//#########################################################################################
	
	
	//################Draw Edges by Sobel Algorithm##############

	reg [2:0] color_tmp1;
	reg [8:0] x_tmp1;
	reg [7:0] y_tmp1;
	reg writeEn_tmp1;

	reg startDrawMainPic;
	reg flagOneTime;

	always@(posedge CLOCK_50) begin
		if(!resetn) begin
			x_tmp1 <= 0;
			y_tmp1 <= 40;
			writeEn_tmp1 <= 0;
			startDrawMainPic <= 0;
			flagOneTime <= 0;
		end 
		else if(state==PLOT) begin
			if(sobelReady && !finish) begin
				if(x_tmp1 == 159) begin
					x_tmp1 <= 0;
					y_tmp1 <= y_tmp1 + 1;
				end else begin
					x_tmp1 <= x_tmp1 + 1;
				end
				color_tmp1 <= {3{sobelOut}};
				writeEn_tmp1 <= 1;
			end 
			else begin
				if(finish) begin
					if(!flagOneTime) begin
						flagOneTime <= 1;
						// x <= 160;
						// y <= 0;
						// writeEn <= 0;
						// mem_address <= 2;
						startDrawMainPic <= 1;
					end
				end 
				else begin
					writeEn_tmp1 <= 0;
				end
			end
		end
	end
	
	//####################################################################
	
	
	//##########Start Draw Main Picture by Ram############################
	
	reg finishDrawMainPic;

	reg [2:0] color_tmp2;
	reg [8:0] x_tmp2;
	reg [7:0] y_tmp2;
	reg writeEn_tmp2;

	reg[14:0] mem_address_tmp2;

	always@(posedge CLOCK_50) begin
		if(!resetn) begin
			x_tmp2 <= 0;//160?
			y_tmp2 <= 40;
			writeEn_tmp2 <= 0;
			mem_address_tmp2 <= 0;
			finishDrawMainPic <= 0;
			// startDrawMainPic <= 1;
		end 
		else if(state == PLOT) begin
			if(!finishDrawMainPic && startDrawMainPic) begin
//				if(y_tmp2 < 40) begin
//					color_tmp2 <= mem_out_back;
//				end 
//				else begin
					mem_address_tmp2 <= mem_address_tmp2 + 1;
					color_tmp2 <= mem_out;
//				end
	
				if(x_tmp2 == 319) begin
					if(y_tmp2 < 39)
						x_tmp2 <= 0;
					else
					x_tmp2 <= 160;
					y_tmp2 <= y_tmp2 + 1;
	
					if(y_tmp2 == 39) begin
						mem_address_tmp2 <= mem_address_tmp2 + 1;
						color_tmp2 <= mem_out;
					end
				end 
				else begin
					x_tmp2 <= x_tmp2 + 1;
				end
				writeEn_tmp2 <= 1;
				if(x_tmp2 == 319 && y_tmp2 == 239)
					finishDrawMainPic <= 1;
			end
		end
	end
	//######################################################################
	
	
	
	always@(*) begin
		x = startDrawMainPic ? x_tmp2 : x_tmp1;
		y = startDrawMainPic ? y_tmp2 : y_tmp1;
		color = startDrawMainPic ? color_tmp2 : color_tmp1;
		writeEn = startDrawMainPic ? writeEn_tmp2 : writeEn_tmp1;
		mem_address = (state==FILL_MEM_WITH_UART_DATA)? mem_addr_write : (startDrawMainPic ? mem_address_tmp2 : mem_address_tmp1);
		
		
	end
	
endmodule

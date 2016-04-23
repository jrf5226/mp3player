`timescale 100ns/1ns

module spi_master_cpol0_cpha0(clk, rst, go, sclk, mosi, miso, data_in, data_out, done);
	input clk;
	input rst;
	input go;
	input [7:0] data_in;
	input  miso;
	output [7:0] data_out;
	output done;
	output sclk;
	output mosi;
	
	wire [7:0] data_out;
	wire [2:0] state;
	wire done;
	wire sclk;
	wire mosi;
	
	reg [2:0] state_q, state_d;
	reg [2:0] counter_q, counter_d;
	reg [7:0] tx_data_q, tx_data_d;
	reg [7:0] rx_data_q, rx_data_d;
	reg sclk_q, sclk_d;
	reg mosi_q, mosi_d;
	reg done_q, done_d;
	
	assign sclk = sclk_q;
	assign mosi = mosi_q;
	assign data_out = rx_data_q;
	assign done = done_q;
	
	localparam
		IDLE       = 3'h1,
		TRANSFER_L = 3'h2,
		TRANSFER_H = 3'h3,
		DONE       = 3'h4;
	
	always @ (*) begin
		state_d = state_q;
		counter_d = counter_q;
		sclk_d = sclk_q;
		mosi_d = mosi_q;
		tx_data_d = tx_data_q;
		rx_data_d = rx_data_q;
		done_d = done_q;
		
		case (state_q)
			
			IDLE: begin
				sclk_d = 1'b0;
				mosi_d = 1'b0;
				counter_d = 8'h0;
				tx_data_d = 8'h00;
				rx_data_d = 8'h00;
				done_d = 1'b0;
				if (go == 1'b1) begin
					tx_data_d = data_in;
					state_d = TRANSFER_L;
				end
			end
			
			TRANSFER_L: begin
				sclk_d = 1'b0;
				mosi_d = tx_data_q[7];
				rx_data_d[0] = miso;
				state_d = TRANSFER_H;
			end
			
			TRANSFER_H: begin
				sclk_d = 1'b1;
				counter_d = counter_q + 1'b1;
				tx_data_d = tx_data_q << 1;
				rx_data_d = rx_data_q << 1;
				if (counter_q == 3'h7) begin
					state_d = DONE;
				end else begin
					state_d = TRANSFER_L;
				end
			end
			
			DONE: begin
				done_d = 1'b1;
				sclk_d = 1'b0;
				mosi_d = 1'b0;
				state_d = IDLE;
			end
		endcase
	end
	
	always @ (posedge clk) begin
		if (rst) begin
			state_q <= IDLE;
			counter_q <= 3'h0;
			tx_data_q <= 8'h00;
			rx_data_q <= 8'h00;
			done_q <= 1'b0;
			sclk_q <= 1'b0;
			mosi_q <= 1'b0;
		end else begin
			state_q <= state_d;
			counter_q <= counter_d;
			tx_data_q <= tx_data_d;
			rx_data_q <= rx_data_d;
			done_q <= done_d;
			sclk_q <= sclk_d;
			mosi_q <= mosi_d;
		end
	end
endmodule

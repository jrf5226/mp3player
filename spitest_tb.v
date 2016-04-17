`timescale 100ns/1ns 

module spitest_tb(sclk, mosi);
	output sclk;
	output mosi;
	
	reg rst;
	
	spitest spitest_i(
		.rst(rst),
		.sclk(sclk),
		.mosi(mosi),
		.miso()
	);
	
	initial begin
		rst = 1'b1;
		
		#10 rst = 1'b0;
		
		#1000 rst = 1'b1;
	end

endmodule
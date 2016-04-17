`timescale 100ns/1ns

module spitest(rst, sclk, mosi, miso);
    input rst;
	input miso;
    output sclk;
    output mosi;

    reg [7:0] data_d, data_q;
    reg go_d, go_q;
    reg [2:0] state_d, state_q;
    reg [7:0] counter_d, counter_q;

    wire spi_done;

    localparam
        IDLE = 3'h1,
        SEND = 3'h2,
        WAIT = 3'h3;
		
	OSCH OSCH_inst(
		.STDBY(1'b0),
		.OSC(clk),
		.SEDSTDBY()
	);
	
	spi_master_cpol0_cpha0 spi_i(
		.clk(clk),
		.rst(rst),
		.state(),
		.wr_en(go_q),
		.sclk(sclk),
		.mosi(mosi),
		.miso(miso),
		.data_in(data_q),
		.data_out(),
		.rx_done(spi_done)
	);

    always @ (*) begin
        data_d = data_q;
        go_d = go_q;
        state_d = state_q;

        case (state_q)
            IDLE: begin
                data_d = 8'h00;
                state_d = SEND;
            end

            SEND: begin
                go_d = 1'b1;
                state_d = WAIT;
            end

            WAIT: begin
                go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    data_d = data_q + 8'h1;
                    state_d = SEND;
                end
            end
        endcase
    end

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            state_q <= IDLE;
            data_q <= 8'h00;
            go_q <= 1'b0;
        end else begin
            state_q <= state_d;
            data_q <= data_d;
            go_q <= go_d;
        end
    end

endmodule

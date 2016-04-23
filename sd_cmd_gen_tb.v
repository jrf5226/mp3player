`timescale 100ns/1ns

module sd_cmd_gen_tb.v(done, response, response_ready, data_xfer_in_progress, sclk, mosi, spi_cs);
    output done;
    output [7:0] response;
    output response_ready;
    output data_xfer_in_progress;
    output sclk;
    output mosi;
    output spi_cs;

    wire clk;
    reg rst;
    reg cmd;
    reg arg;
    reg go;
    reg ignore_count;
    reg state;
    wire spi_go;
    wire spi_tx_data;
    wire spi_rx_data;
    wire spi_done;

    localparam
        IDLE = 3'h1,
        S1 = 3'h2,
        S2 = 3'h3,
        S3 = 3'h4,
        S4 = 3'h5,
        DONE = 3'h6;

    OSCH OSCH_i(
        .STDBY(1'b0),
        .OSC(clk),
        .SEDSTDBY()
    );

    spi_master_cpol0_cpha0 spi_master_i(
        .clk(clk),
        .rst(rst),
        .go(spi_go),
        .data_in(spi_tx_data),
        .data_out(spi_rx_data),
        .done(spi_done),
        .sclk(sclk),
        .mosi(mosi),
        .miso()
    );

    sd_cmd_gen sd_cmd_gen_i(
        .clk(clk),
        .rst(rst),
        .cmd(cmd),
        .arg(arg),
        .go(go),
        .done(done),
        .ignore_count(ignore_count),
        .response(response),
        .response_ready(response_ready),
        .data_xfer_in_progress(data_xfer_in_progress),
        .spi_go(spi_go),
        .spi_tx_data(spi_tx_data),
        .spi_rx_data(spi_rx_data),
        .spi_done(spi_done),
        .spi_cs(spi_cs)
    );

    initial begin
        rst = 1'b1;
    end

    always @ (posedge clk) begin
        case (state)
            IDLE: begin
                rst <= 1'b0;
                cmd <= 6'h0;
                arg <= 32'h0;
                go <= 1'b0;
                state <= S1;
            end

            S1: begin
                rst <= 1'b0;
                cmd <= cmd;
                arg <= arg;
                go <= go;
                state <= S2;
            end

            S2: begin
                rst <= rst;
                cmd <= 6'b111111;
                arg <= arg;
                go <= 1'b1;
                state <= S3;
            end

            S3: begin
                rst <= rst;
                cmd <= cmd;
                arg <= arg;
                go <= 1'b0;
                state <= S3;
            end

            S4: begin
                rst <= rst;
                cmd <= cmd;
                arg <= arg;
                go <= go;
                state <= done ? DONE : S4;
            end

            DONE: begin
                rst <= rst;
                cmd <= cmd;
                arg <= arg;
                go <= go;
                state <= DONE;
            end

        endcase


endmodule



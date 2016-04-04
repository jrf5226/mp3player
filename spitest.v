module spitest(rst, sclk, mosi, miso);
    input rst;
    input miso;
    output sclk;
    output mosi;

    reg [7:0] data_d, data_q;
    reg go_d, go_q;
    reg [2:0] state_d, state_q;
    reg [7:0] counter_d, counter_q;

    wire spi_busy;

    localparam
        IDLE = 3'h1,
        SEND = 3'h2,
        WAIT = 3'h3;

    spi_master_cpol0_cpha0 spi_i(
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .tx_data(data_q),
        .rx_data(),
        .go(go_q),
        .busy(spi_busy)
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
                if (spi_busy == 1'b0) begin
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

endcase

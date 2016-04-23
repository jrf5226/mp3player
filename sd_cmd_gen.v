module sd_cmd_gen(clk, rst,
                  cmd, arg, ignore_count, go, done, data_xfer_in_progress, response, response_ready,
                  spi_go, spi_done, spi_tx_data, spi_rx_data, spi_cs);
    input clk;
    input rst;
    input go;
    input [5:0] cmd;
    input [31:0] arg;
    input [7:0] ignore_count;
    input [7:0] spi_rx_data;
    input spi_done;
    output done;
    output data_xfer_in_progress;
    output [7:0] response;
    output response_ready;
    output [7:0] spi_tx_data;
    output spi_go;
    output spi_cs;

    wire rx_data_is_response;
	wire cmd_has_block_data;
    wire [7:0] spi_tx_data;
    wire spi_go;
    wire spi_cs;
    wire done;
	wire [7:0] response;
	wire response_ready;
	wire data_xfer_in_progress;

    reg [5:0] cmd_d, cmd_q;
    reg [31:0] arg_q, arg_d;
    reg done_d, done_q;
    reg [7:0] spi_tx_data_d, spi_tx_data_q;
    reg spi_go_d, spi_go_q;
    reg spi_cs_d, spi_cs_q;
    reg [15:0] counter_d, counter_q;
    reg [7:0] ignore_counter_d, ignore_counter_q;
    reg data_xfer_in_progress_d, data_xfer_in_progress_q;
    reg resp_ready_d, resp_ready_q;
    reg [7:0] resp_d, resp_q;
	reg [5:0] state_d, state_q;

    assign spi_go = spi_go_q;
    assign spi_tx_data = spi_tx_data_q;
    assign spi_cs = spi_cs_q;
    assign done = done_q;
	assign data_xfer_in_progress = data_xfer_in_progress_q;
	assign response = resp_q;
    assign response_ready = resp_ready_q;
    assign rx_data_is_response = (spi_rx_data[7] == 0);
    assign cmd_has_block_data = (cmd_q == 17);


    localparam
        IDLE            = 6'h1,
        TOGGLE_CS       = 6'h2,
        SEND_PULSES     = 6'h3,
        WAIT_FOR_PULSES = 6'h4,
        SEND_CMD        = 6'h5,
        WAIT_FOR_CMD    = 6'h6,
        SEND_ARG1       = 6'h7,
        SEND_ARG2       = 6'h8,
        SEND_ARG3       = 6'h9,
        SEND_ARG4       = 6'hA,
        WAIT_FOR_ARG1   = 6'hB,
        WAIT_FOR_ARG2   = 6'hC,
        WAIT_FOR_ARG3   = 6'hD,
        WAIT_FOR_ARG4   = 6'hE,
        SEND_CRC        = 6'hF,
        WAIT_FOR_CRC    = 6'h10,
        GET_RESP        = 6'h11,
        WAIT_FOR_RESP   = 6'h12,
        RESPONSE_READY  = 6'h13,
        RECEIVE_BLOCK1  = 6'h14,
        RECEIVE_BLOCK2  = 6'h15,
        DONE            = 6'h16;


    always @ (*) begin
        state_d = state_q;
        cmd_d = cmd_q;
        arg_d = arg_q;
        done_d = done_q;
        spi_tx_data_d = spi_tx_data_q;
        spi_go_d = spi_go_q;
        counter_d = counter_q;
        ignore_counter_d = ignore_counter_q;
        data_xfer_in_progress_d = data_xfer_in_progress_q;
        resp_d = resp_q;
        resp_ready_d = resp_ready_q;

        case (state_q)
            IDLE: begin
                done_d = 1'b0;
                spi_cs_d = 1'b1;
                if (go == 1'b1) begin
                    cmd_d = cmd;
                    arg_d = arg;
                    ignore_counter_d = ignore_count;
                    if (cmd == 6'b111111) begin
                        state_d = SEND_PULSES;
                        counter_d = 5'h0;
                    end else begin
                        state_d = TOGGLE_CS;
                    end
                end
            end

            TOGGLE_CS: begin
                spi_cs_d = 1'b0;
                state_d = SEND_CMD;
            end

            SEND_PULSES: begin
                spi_tx_data_d = 8'hFF;
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_PULSES;
            end

            WAIT_FOR_PULSES: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    if (counter_q == 5'h9) begin
                        state_d = DONE;
                    end else begin
                        counter_d = counter_q + 5'h1;
                        state_d = SEND_PULSES;
                    end
                end
            end

            SEND_CMD: begin
                spi_tx_data_d = 8'b10000000 | cmd_q;
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_CMD;
            end

            WAIT_FOR_CMD: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    state_d = SEND_ARG1;
                end
            end

            SEND_ARG1: begin
                spi_tx_data_d = arg_q[31:24];
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_ARG1;
            end

            WAIT_FOR_ARG1: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    state_d = SEND_ARG2;
                end
            end

            SEND_ARG2: begin
                spi_tx_data_d = arg_q[23:16];
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_ARG2;
            end


            WAIT_FOR_ARG2: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    state_d = SEND_ARG3;
                end
            end

            SEND_ARG3: begin
                spi_tx_data_d = arg_q[15:8];
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_ARG3;
            end

            WAIT_FOR_ARG3: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    state_d = SEND_ARG4;
                end
            end

            SEND_ARG4: begin
                spi_tx_data_d = arg_q[7:0];
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_ARG4;
            end

            WAIT_FOR_ARG4: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    state_d = SEND_CRC;
                end
            end

            SEND_CRC: begin
                spi_tx_data_d = 8'h01;
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_CRC;
            end

            WAIT_FOR_CRC: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    state_d = GET_RESP;
                end
            end

            GET_RESP: begin
                spi_tx_data_d = 8'hFF;
                spi_go_d = 1'b1;
                state_d = WAIT_FOR_RESP;
            end

            WAIT_FOR_RESP: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    if (rx_data_is_response == 1'b1) begin
                        resp_d[7:0] = spi_rx_data;
                        resp_ready_d = 1'b1;
                        state_d = RESPONSE_READY;
                    end else begin
                        state_d = GET_RESP;
                    end
                end
            end

            RESPONSE_READY: begin
                resp_ready_d = 1'b0;
                if (cmd_has_block_data == 1'b1) begin
                    counter_d = 16'h0;
                    state_d = RECEIVE_BLOCK1;
                end else begin
                    state_d = DONE;
                end
            end

            RECEIVE_BLOCK1: begin 
                if (ignore_counter_q == 8'h0) begin
                    data_xfer_in_progress_d = 1'b1;
                end
                if (counter_q == 16'd512) begin
                    state_d = DONE;
                end else begin
                    spi_tx_data_d = 8'hFF;
                    spi_go_d = 1'b1;
                    state_d = RECEIVE_BLOCK2;
				end
            end

            RECEIVE_BLOCK2: begin
                spi_go_d = 1'b0;
                if (spi_done == 1'b1) begin
                    counter_d = counter_q + 16'h1;
                    if (ignore_counter_q > 8'h0) begin
                        ignore_counter_d = ignore_counter_q - 8'h1;
                    end
                    state_d = RECEIVE_BLOCK1;
                end
            end


            DONE: begin
                data_xfer_in_progress_d = 1'b0;
                done_d = 1'b1;
                state_d = IDLE;
                spi_cs_d = 1'b1;
            end

        endcase
    end

    always @ (posedge clk) begin
        if (rst) begin
            state_q <= IDLE;
            spi_go_q <= 1'b0;
            spi_tx_data_q <= 8'h00;
			spi_cs_q <= 1'b0;
            cmd_q <= 6'h0;
            arg_q <= 32'h0;
            counter_q <= 16'h00;
            ignore_counter_q <= 8'h00;
            data_xfer_in_progress_q <= 1'b0;
            resp_q <= 8'h00;
            resp_ready_q <= 1'b0;
			done_q <= 1'b0;
        end else begin
            state_q <= state_d;
            spi_go_q <= spi_go_d;
            spi_tx_data_q <= spi_tx_data_d;
			spi_cs_q <= spi_cs_d;
            cmd_q <= cmd_d;
            arg_q <= arg_d;
            counter_q <= counter_d;
            ignore_counter_q <= ignore_counter_d;
            data_xfer_in_progress_q <= data_xfer_in_progress_d;
            resp_q <= resp_d;
            resp_ready_q <= resp_ready_d;
			done_q <= done_d;
        end
    end

endmodule


module uart_rx #(
    parameter CLKS_PER_BIT = 10
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,

    output reg [7:0]  rx_data,
    output reg        rx_valid,
    output reg        rx_busy
);

    localparam IDLE      = 2'd0;
    localparam START_BIT = 2'd1;
    localparam DATA_BITS = 2'd2;
    localparam STOP_BIT  = 2'd3;

    reg [1:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;

    always @(posedge clk) begin

        if (reset) begin
            state     <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_data   <= 8'h00;
            rx_valid  <= 1'b0;
            rx_busy   <= 1'b0;
        end

        else begin

            rx_valid <= 1'b0;

            case (state)

                IDLE: begin
                    rx_busy   <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;

                    if (rx == 1'b0) begin
                        rx_busy   <= 1'b1;
                        clk_count <= 0;
                        state     <= START_BIT;
                    end
                end

                START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT/2 - 1)) begin
                        clk_count <= 0;

                        if (rx == 1'b0)
                            state <= DATA_BITS;
                        else
                            state <= IDLE;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA_BITS: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;

                        rx_data[bit_index] <= rx;

                        if (bit_index == 3'd7) begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP_BIT: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        rx_busy   <= 1'b0;
                        rx_valid  <= 1'b1;
                        state     <= IDLE;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
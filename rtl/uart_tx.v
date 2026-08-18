module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        tx_busy
);

    // Number of clock cycles required for one UART bit
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_counter;
    reg [3:0]  bit_index;
    reg [7:0]  data_reg;

    // UART states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;

    always @(posedge clk) begin

        if (reset) begin
            tx           <= 1'b1;
            tx_busy      <= 1'b0;
            baud_counter <= 16'd0;
            bit_index    <= 4'd0;
            data_reg     <= 8'd0;
            state        <= IDLE;
        end

        else begin

            case (state)

                // ---------------- IDLE ----------------
                IDLE: begin
                    tx           <= 1'b1;
                    tx_busy      <= 1'b0;
                    baud_counter <= 16'd0;
                    bit_index    <= 4'd0;

                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1'b1;
                        state    <= START;
                    end
                end

                // ---------------- START ----------------
                START: begin
                    tx <= 1'b0;

                    if (baud_counter < CLKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end
                    else begin
                        baud_counter <= 0;
                        state        <= DATA;
                    end
                end

                // ---------------- DATA ----------------
                DATA: begin
                    tx <= data_reg[bit_index];

                    if (baud_counter < CLKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end
                    else begin
                        baud_counter <= 0;

                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end
                        else begin
                            bit_index <= 0;
                            state     <= STOP;
                        end
                    end
                end

                // ---------------- STOP ----------------
                STOP: begin
                    tx <= 1'b1;

                    if (baud_counter < CLKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end
                    else begin
                        baud_counter <= 0;
                        tx_busy      <= 1'b0;
                        state        <= IDLE;
                    end
                end

            endcase
        end
    end
endmodule

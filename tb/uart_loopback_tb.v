module uart_loopback_tb;

    parameter CLK_FREQ = 1_000_000;
    parameter BAUD_RATE = 100_000;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    reg [7:0] expected_data;

    wire tx;
    wire tx_busy;

    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_busy;
    wire rx;

    integer pass_count;
    integer fail_count;

    assign rx = tx;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) transmitter (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_busy(rx_busy)
    );

    always #500 clk = ~clk;

    always @(posedge clk) begin
        if (rx_valid) begin

            $display("RX VALID: Received 0x%h", rx_data);

            if (rx_data == expected_data) begin
                pass_count = pass_count + 1;
                $display("PASS: Expected = 0x%h, Received = 0x%h",
                         expected_data, rx_data);
            end
            else begin
                fail_count = fail_count + 1;
                $display("FAIL: Expected = 0x%h, Received = 0x%h",
                         expected_data, rx_data);
            end

        end
    end

    task send_byte;
        input [7:0] data;

        begin
            wait(tx_busy == 1'b0);

            tx_data = data;
            expected_data = data;

            tx_start = 1'b1;
            #1000;
            tx_start = 1'b0;

            wait(tx_busy == 1'b0);

            #2000;
        end
    endtask

    initial begin

        $dumpfile("simulation/uart_loopback.vcd");
        $dumpvars(0, uart_loopback_tb);

        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;
        expected_data = 8'h00;

        pass_count = 0;
        fail_count = 0;

        #2000;
        reset = 0;

        $display("");
        $display("=========================================");
        $display("Starting UART TX -> RX MULTI-BYTE LOOPBACK");
        $display("=========================================");
        $display("");

        $display("Sending byte 1: 0x41");
        send_byte(8'h41);

        $display("Sending byte 2: 0x55");
        send_byte(8'h55);

        $display("Sending byte 3: 0xAA");
        send_byte(8'hAA);

        $display("Sending byte 4: 0x00");
        send_byte(8'h00);

        $display("Sending byte 5: 0xFF");
        send_byte(8'hFF);

        $display("Sending byte 6: 0x7E");
        send_byte(8'h7E);

        #5000;

        $display("");
        $display("===========================");
        $display("TEST SUMMARY");
        $display("===========================");
        $display("PASS COUNT = %0d", pass_count);
        $display("FAIL COUNT = %0d", fail_count);

        if (fail_count == 0 && pass_count == 6)
            $display("UART MULTI-BYTE LOOPBACK: SUCCESS");
        else
            $display("UART MULTI-BYTE LOOPBACK: FAILED");

        $display("===========================");

        $finish;
    end

endmodule
`timescale 1ns/1ps

module uart_simulation_tb;

    // ==========================================
    // UART PARAMETERS
    // ==========================================
    parameter CLK_FREQ = 1_000_000;
    parameter BAUD_RATE = 100_000;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // ==========================================
    // TESTBENCH SIGNALS
    // ==========================================
    reg clk;
    reg reset;

    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;

    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_busy;

    // Loopback connection
    wire rx;
    assign rx = tx;

    integer pass_count;
    integer fail_count;

    // ==========================================
    // UART TRANSMITTER
    // ==========================================
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

    // ==========================================
    // UART RECEIVER
    // ==========================================
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

    // ==========================================
    // CLOCK
    // 1 MHz clock = 1000 ns period
    // ==========================================
    always #500 clk = ~clk;

    // ==========================================
    // SEND BYTE TASK
    // ==========================================
    task send_byte;
        input [7:0] data;

        begin
            // Wait until transmitter is free
            wait(tx_busy == 1'b0);

            // Put data on TX
            tx_data = data;

            // Start transmission
            @(posedge clk);
            tx_start = 1'b1;

            @(posedge clk);
            tx_start = 1'b0;

            // Wait for receiver to finish
            wait(rx_valid == 1'b1);

            // Check received data
            if (rx_data == data) begin
                pass_count = pass_count + 1;

                $display(
                    "PASS: Sent = 0x%02h, Received = 0x%02h",
                    data,
                    rx_data
                );
            end
            else begin
                fail_count = fail_count + 1;

                $display(
                    "FAIL: Sent = 0x%02h, Received = 0x%02h",
                    data,
                    rx_data
                );
            end

            // Wait until rx_valid goes low
            @(posedge clk);

            // Small gap before next byte
            repeat(2) @(posedge clk);
        end
    endtask

    // ==========================================
    // MAIN TEST
    // ==========================================
    initial begin

        // VCD waveform
        $dumpfile("simulation/uart_simulation.vcd");
        $dumpvars(0, uart_simulation_tb);

        // Initial values
        clk = 1'b0;
        reset = 1'b1;
        tx_start = 1'b0;
        tx_data = 8'h00;

        pass_count = 0;
        fail_count = 0;

        // Reset
        repeat(5) @(posedge clk);
        reset = 1'b0;

        $display("");
        $display("==========================================");
        $display("       UART TX -> RX LOOPBACK TEST");
        $display("==========================================");
        $display("");

        // ======================================
        // TEST BYTES
        // ======================================

        $display("Sending byte 1: 0x41 (ASCII A)");
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

        // ======================================
        // TEST SUMMARY
        // ======================================

        $display("");
        $display("==========================================");
        $display("             TEST SUMMARY");
        $display("==========================================");

        $display("PASS COUNT = %0d", pass_count);
        $display("FAIL COUNT = %0d", fail_count);

        if (fail_count == 0) begin
            $display("");
            $display("UART LOOPBACK TEST: SUCCESS");
        end
        else begin
            $display("");
            $display("UART LOOPBACK TEST: FAILED");
        end

        $display("==========================================");
        $display("");

        $finish;
    end

endmodule
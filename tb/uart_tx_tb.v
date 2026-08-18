`timescale 1ns/1ps

module uart_tx_tb;

    // Simulation parameters
    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 9600;

    // Signals
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;

    // Instantiate UART transmitter
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // 50 MHz clock
    always #10 clk = ~clk;

    // Test sequence
    initial begin

        // Generate waveform
        $dumpfile("simulation/uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        // Initialize signals
        clk      = 0;
        reset    = 1;
        tx_start = 0;
        tx_data  = 8'h00;

        // Hold reset for 100 ns
        #100;

        reset = 0;

        // Send ASCII 'A'
        tx_data  = 8'h41;
        tx_start = 1;

        #20;

        tx_start = 0;

        // Wait until transmission finishes
        wait(tx_busy == 1);

        wait(tx_busy == 0);

        // Wait a little after transmission
        #100;

        $display("UART transmission completed successfully!");

        $finish;
    end

endmodule

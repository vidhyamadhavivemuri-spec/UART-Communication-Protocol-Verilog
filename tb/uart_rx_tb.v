`timescale 1ns/1ps

module uart_rx_tb;

    parameter CLKS_PER_BIT = 10;

    reg clk;
    reg reset;
    reg rx;

    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_busy;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_busy(rx_busy)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Send one UART bit
    task send_bit;
        input bit_value;
        begin
            rx = bit_value;
            #(CLKS_PER_BIT * 10);
        end
    endtask

    // Send one UART byte
    task send_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            send_bit(1'b0);

            // 8 data bits, LSB first
            for (i = 0; i < 8; i = i + 1)
                send_bit(data[i]);

            // Stop bit
            send_bit(1'b1);
        end
    endtask

    initial begin

        $dumpfile("simulation/uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);

        clk = 0;
        reset = 1;
        rx = 1;

        // Reset
        #100;
        reset = 0;

        // Send ASCII 'A'
        send_byte(8'h41);

        // Wait for receiver
        wait(rx_valid == 1);

        if (rx_data == 8'h41)
            $display("UART RX SUCCESS: Received ASCII 'A' (0x41)");
        else
            $display("UART RX ERROR: Received 0x%h", rx_data);

        #100;

        $finish;
    end

endmodule
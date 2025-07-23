`timescale 1ns/1ps

module spi_tb;

    reg clk = 0;
    reg reset = 1;
    reg load_data = 0;
    reg [7:0] data_in = 8'b10100101;

    wire done_send;
    wire spi_clk;
    wire spi_data;

    // Generate 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    // Instantiate SPI Master
    spi uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .load_data(load_data),
        .done_send(done_send),
        .spi_clk(spi_clk),
        .spi_data(spi_data)
    );

    initial begin
        $display("?? Starting SPI Testbench...");
        $dumpfile("spi.vcd");         // For waveform viewer if needed
        $dumpvars(0, spi_tb);

        reset = 1;
        #20 reset = 0;

        // Send data after reset
        #20 load_data = 1;
        #10 load_data = 0;

        wait(done_send);              // Wait for transfer to complete
        $display("? Transmission complete at time %t", $time);

        #100;
        $finish;
    end

endmodule

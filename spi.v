module spi (
    input clk,                   // 100 MHz system clock
    input reset,                 // Active-high reset
    input [7:0] data_in,         // Data to transmit
    input load_data,             // Pulse to start transmission
    output reg done_send,        // High when transmission completes
    output spi_clk,              // SPI clock output
    output reg spi_data          // MOSI line
);

    reg [2:0] counter;
    reg clock_10;
    reg CE;

    assign spi_clk = CE ? clock_10 : 1'b0;

    reg [1:0] state;
    parameter IDLE = 2'd0, SEND = 2'd1;

    reg [7:0] shiftReg;
    reg [2:0] bitCount;

    // Clock divider: 100 MHz to 10 MHz
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            clock_10 <= 0;
        end else begin
            if (counter < 4)
                counter <= counter + 1;
            else begin
                counter <= 0;
                clock_10 <= ~clock_10;
            end
        end
    end

    // SPI FSM
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            done_send <= 0;
            spi_data <= 1;
            CE <= 0;
            bitCount <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done_send <= 0;
                    CE <= 0;
                    if (load_data) begin
                        shiftReg <= data_in;
                        bitCount <= 0;
                        state <= SEND;
                    end
                end

                SEND: begin
                    CE <= 1;
                    if (clock_10) begin
                        spi_data <= shiftReg[7];
                        shiftReg <= {shiftReg[6:0], 1'b0};
                        if (bitCount < 7)
                            bitCount <= bitCount + 1;
                        else begin
                            CE <= 0;
                            done_send <= 1;
                            state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule

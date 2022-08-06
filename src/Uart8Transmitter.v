`ifndef __UART_TRANSMITTER_V__
`define __UART_TRANSMITTER_V__

`include "inc/Defines.vh"
`include "src/Uart8Transmitter.v"

module Uart8Transmitter #(
        parameter DATA_BITS = `DATA_BITS_8 // use 8bit as default
    )(
        input wire                   clk,      // baud rate
        input wire                   en,       // chip enable
        input wire                   start,    // start of transaction
        input wire [DATA_BITS - 1:0] in,       // data to transmit
        output reg                   out,      // tx bit
        output reg                   done,     // end on transaction
        output reg                   busy      // transaction is in process
    );

    reg [2:0] state  = `STATE_RESET;
    reg [7:0] data   = 0; // to store a copy of input data

    localparam DATA_BITS_WIDTH = $clog2(DATA_BITS);

    reg [DATA_BITS_WIDTH - 1:0] bitIdx = 0; // index

    initial begin
        out  <= 1;
        done <= 0;
        busy <= 0;
    end

    always @ (posedge clk) begin
        case (state)
            `STATE_IDLE: begin
                out    <= 1; // drive line high for idle
                done   <= 0;
                busy   <= 0;
                bitIdx <= 0;
                data   <= 0;
                if (start & en) begin
                    data  <= in; // save a copy of input data
                    state <= `STATE_START_BIT;
                end
            end

            `STATE_START_BIT: begin
                out   <= 1'b0; // send start bit (low)
                busy  <= 1'b1;
                state <= `STATE_DATA_BITS;
            end

            `STATE_DATA_BITS: begin // Wait 8 clock cycles for data bits to be sent
                out <= data[bitIdx];
                if (&bitIdx) begin
                    bitIdx <= 0;
                    state  <= `STATE_STOP_BIT;
                end else begin
                    bitIdx <= bitIdx + 1'b1;
                end
            end

            `STATE_STOP_BIT: begin // Send out Stop bit (high)
                done  <= 1'b1;
                data  <= 8'b0;
                out   <= 1'b1;
                state <= `STATE_IDLE;
            end

            default:
                state <= `STATE_IDLE;
        endcase
    end

endmodule

`endif /*__UART_TRANSMITTER_V__*/
`ifndef __UART_RECEIVER_V__
`define __UART_RECEIVER_V__

`include "inc/Defines.vh"
`include "src/Uart8Receiver.v"

module Uart8Receiver #(
        parameter OVERSAMPLING  = `OVERSAMPLING_16, // use 16x as default
        parameter DATA_BITS     = `DATA_BITS_8      // use 8bit as default
    )(
        input wire                   clk,  // baud rate
        input wire                   en,   // chip enable
        input wire                   in,   // rx line
        output reg [DATA_BITS - 1:0] out,  // received data
        output reg                   done, // end on transaction
        output reg                   busy, // transaction is in process
        output reg                   err   // error while receiving data
    );
    
    reg [2:0] state        = `STATE_RESET;
    reg [1:0] shiftReg     = 0; // shift reg for input signal state
    reg [7:0] receivedData = 0; // temporary storage for input data

    localparam CLK_CNT_WIDTH   = $clog2(OVERSAMPLING);
    localparam DATA_BITS_WIDTH = $clog2(DATA_BITS);

    reg [CLK_CNT_WIDTH - 1:0]   clockCount = 0; // count clocks for oversampling
    reg [DATA_BITS_WIDTH - 1:0] bitIdx     = 0; // index

    initial begin
        out  <= 0;
        err  <= 0;
        done <= 0;
        busy <= 0;
    end

    always @ (posedge clk) begin
        shiftReg = { shiftReg[0], in }; // shift left and append in

        if (!en) begin
            state <= `STATE_RESET;
        end

        case (state)
            `STATE_RESET: begin
                out  <= 0;
                done <= 0;
                busy <= 0;
                err  <= 0;
                bitIdx       <= 0;
                clockCount   <= 0;
                receivedData <= 0;
                if (en) begin
                    state <= `STATE_IDLE;
                end
            end

            `STATE_IDLE: begin
                done <= 1'b0;
                if (&clockCount) begin
                    out  <= 8'b0;
                    busy <= 1'b1;
                    err  <= 1'b0;
                    bitIdx       <= 3'b0;
                    clockCount   <= 4'b0;
                    receivedData <= 8'b0;
                    state <= `STATE_DATA_BITS;
                end else if (!(&shiftReg) || |clockCount) begin
                    // Check bit to make sure it's still low
                    if (shiftReg == 2'b11) begin
                        err <= 1'b1;
                        state <= `STATE_RESET;
                    end
                    clockCount <= clockCount + 1;
                end
            end

            // Wait 8 full cycles to receive serial data
            `STATE_DATA_BITS: begin
                if (&clockCount) begin // save one bit of received data
                    clockCount <= 4'b0;
                    // TODO: check the most popular value
                    receivedData[bitIdx] <= shiftReg[0];
                    if (&bitIdx) begin
                        bitIdx <= 3'b0;
                        state <= `STATE_STOP_BIT;
                    end else begin
                        bitIdx <= bitIdx + 3'b1;
                    end
                end else begin
                    clockCount <= clockCount + 4'b1;
                end
            end

            /*
            * Baud clock may not be running at exactly the same rate as the
            * transmitter. Next start bit is allowed on at least half of stop bit.
            */
            `STATE_STOP_BIT: begin
                if (&clockCount || (clockCount >= 4'h8 && !(|shiftReg))) begin
                    state <= `STATE_IDLE;
                    done <= 1'b1;
                    busy <= 1'b0;
                    out <= receivedData;
                    clockCount <= 4'b0;
                end else begin
                    clockCount <= clockCount + 1;
                    // Check bit to make sure it's still high
                    if (!(|shiftReg)) begin
                        err <= 1'b1;
                        state <= `STATE_RESET;
                    end
                end
            end

            default:
                state <= `STATE_IDLE;
        endcase
    end

endmodule

`endif /*__UART_RECEIVER_V__*/
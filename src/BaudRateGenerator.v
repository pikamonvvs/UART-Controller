`ifndef __BAUDRATE_GENERATOR_V__
`define __BAUDRATE_GENERATOR_V__

`include "inc/Defines.vh"

module BaudRateGenerator #(
        parameter CLOCK_RATE    = `CLOCK_RATE_100MHZ, // use 100MHz as default
        parameter BAUD_RATE     = `BAUD_RATE_115200,  // use 115200 as default
        parameter OVERSAMPLING  = `OVERSAMPLING_16    // use 16x as default
    )(
        input wire clk,   // main clock
        output reg rxClk, // baud rate for rx
        output reg txClk  // baud rate for tx
    );

    localparam MAX_RATE_RX  = CLOCK_RATE / (2 * BAUD_RATE * OVERSAMPLING);
    localparam MAX_RATE_TX  = CLOCK_RATE / (2 * BAUD_RATE);
    localparam RX_CNT_WIDTH = $clog2(MAX_RATE_RX);
    localparam TX_CNT_WIDTH = $clog2(MAX_RATE_TX);

    reg [RX_CNT_WIDTH - 1:0] rxCnt = 0;
    reg [TX_CNT_WIDTH - 1:0] txCnt = 0;

    initial begin
        rxClk = 1'b0;
        txClk = 1'b0;
    end

    always @ (posedge clk) begin
        // generate rx clock
        if (rxCnt == MAX_RATE_RX) begin
            rxCnt <= 0;
            rxClk <= ~rxClk;
        end else begin
            rxCnt <= rxCnt + 1'b1;
        end

        // generate tx clock
        if (txCnt == MAX_RATE_TX) begin
            txCnt <= 0;
            txClk <= ~txClk;
        end else begin
            txCnt <= txCnt + 1'b1;
        end
    end

endmodule

`endif /*__BAUDRATE_GENERATOR_V__*/
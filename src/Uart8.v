`ifndef __UART_V__
`define __UART_V__

`include "inc/Defines.vh"
`include "src/BaudRateGenerator.v"
`include "src/Uart8Receiver.v"
`include "src/Uart8Transmitter.v"

module Uart8 #(
        parameter CLOCK_RATE   = `CLOCK_RATE_100MHZ, // board internal clock
        parameter BAUD_RATE    = `BAUD_RATE_115200,  // use 115200 as default
        parameter OVERSAMPLING = `OVERSAMPLING_16,   // use 16x as default
        parameter DATA_BITS    = `DATA_BITS_8        // use 8bit as default
    )(
        input wire clk,

        // rx interface
        input wire rx,
        input wire rxEn,
        output wire [DATA_BITS - 1:0] out,
        output wire rxDone,
        output wire rxBusy,
        output wire rxErr,

        // tx interface
        output wire tx,
        input wire txEn,
        input wire txStart,
        input wire [DATA_BITS - 1:0] in,
        output wire txDone,
        output wire txBusy
    );

    wire rxClk;
    wire txClk;

    BaudRateGenerator #(
        .CLOCK_RATE(CLOCK_RATE),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(OVERSAMPLING)
    ) generatorInst (
        .clk(clk),
        .rxClk(rxClk),
        .txClk(txClk)
    );

    Uart8Receiver #(
        .OVERSAMPLING(OVERSAMPLING),
        .DATA_BITS(DATA_BITS)
    ) rxInst (
        .clk(rxClk),
        .en(rxEn),
        .in(rx),
        .out(out),
        .done(rxDone),
        .busy(rxBusy),
        .err(rxErr)
    );

    Uart8Transmitter #(
        .DATA_BITS(DATA_BITS)
    ) txInst (
        .clk(txClk),
        .en(txEn),
        .start(txStart),
        .in(in),
        .out(tx),
        .done(txDone),
        .busy(txBusy)
    );

endmodule

`endif /*__UART_V__*/
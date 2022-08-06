`timescale 10ns/1ns

`include "inc/Defines.vh"
`include "src/BaudRateGenerator.v"

module tbBaudRateGenerator();

	parameter CLOCK_RATE	= `CLOCK_RATE_100MHZ;
	parameter BAUD_RATE		= `BAUD_RATE_115200;
	parameter OVERSAMPLING	= `OVERSAMPLING_16;

	reg clk = 0;

    wire rxClk;
    wire txClk;

    BaudRateGenerator #(
        .CLOCK_RATE(CLOCK_RATE),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(OVERSAMPLING)
    ) test (
        .clk(clk),
        .rxClk(rxClk),
        .txClk(txClk)
    );

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(-1, test);
    end

	always begin
		#0.5 clk = ~clk;
	end

	initial begin
		#1000 $finish;
	end

endmodule
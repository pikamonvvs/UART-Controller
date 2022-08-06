`timescale 10ns/1ns

`include "inc/Defines.vh"
`include "src/Uart8Transmitter.v"

module tbUart8Transmitter();

	parameter CLOCK_RATE   = `CLOCK_RATE_100MHZ;
	parameter BAUD_RATE    = `BAUD_RATE_115200;
	parameter DATA_BITS    = `DATA_BITS_8;

    localparam MAX_RATE_TX = CLOCK_RATE / (2 * BAUD_RATE);
	localparam CLOCK_TX = MAX_RATE_TX * 2;

	reg                   txClk = 0;
	reg                   en    = 1;
	reg                   start = 0;
	reg [DATA_BITS - 1:0] in    = 0;

	wire out;
	wire done;
	wire busy;

	Uart8Transmitter #(
        .DATA_BITS(DATA_BITS)
    ) test (
		.clk(txClk),
        .en(en),
        .start(start),
        .in(in),
        .out(out),
        .done(done),
        .busy(busy)
    );

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(-1, test);
    end

	initial begin
		begin // (0x55)
			in <= `DATA_BITS_8'h55;

			#CLOCK_TX start <= 1'b1;
			#CLOCK_TX start <= 1'b0;

			#CLOCK_TX; // start bit
			#CLOCK_TX; // data bit
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX; // stop bit
		end

		begin // (0x96)
			in <= `DATA_BITS_8'h96;

			#CLOCK_TX start <= 1'b1;
			#CLOCK_TX start <= 1'b0;

			#CLOCK_TX; // start bit
			#CLOCK_TX; // data bit
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX;
			#CLOCK_TX; // stop bit
		end
	end

	always begin
		#MAX_RATE_TX txClk = ~txClk;
//		#0.5 txClk = ~txClk;
	end

	initial begin
		#25000 $finish;
	end

endmodule
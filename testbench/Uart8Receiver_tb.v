`timescale 10ns/1ns

`include "inc/Defines.vh"
`include "src/Uart8Receiver.v"

module tbUart8Receiver();

	parameter CLOCK_RATE   = `CLOCK_RATE_100MHZ;
	parameter BAUD_RATE    = `BAUD_RATE_115200;
	parameter OVERSAMPLING = `OVERSAMPLING_16;
	parameter DATA_BITS    = `DATA_BITS_8;

    localparam MAX_RATE_RX = CLOCK_RATE / (2 * BAUD_RATE * OVERSAMPLING);
	localparam CLOCK_RX = MAX_RATE_RX * OVERSAMPLING * 2;

	reg rxClk = 0;
	reg en	  = 1;
	reg in    = 1;

	wire [DATA_BITS - 1:0] out;
	wire                   done;
	wire                   busy;
	wire                   err;

	Uart8Receiver #(
        .OVERSAMPLING(OVERSAMPLING),
        .DATA_BITS(DATA_BITS)
	) test (
		.clk(rxClk),
        .en(en),
        .in(in),
        .out(out),
        .done(done),
        .busy(busy),
        .err(err)
    );

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(-1, test);
    end

	initial begin
		begin // (0x55)
			#CLOCK_RX in = 0; // start bit

			#CLOCK_RX in = 1; // data bit (0x55)
			#CLOCK_RX in = 0;
			#CLOCK_RX in = 1;
			#CLOCK_RX in = 0;
			#CLOCK_RX in = 1;
			#CLOCK_RX in = 0;
			#CLOCK_RX in = 1;
			#CLOCK_RX in = 0;

			#CLOCK_RX in = 1; // stop bit
		end

		begin // (0x96)
			#CLOCK_RX in = 0; // start bit

			#CLOCK_RX in = 0; // data bit (0x96)
			#CLOCK_RX in = 1;
			#CLOCK_RX in = 1;
			#CLOCK_RX in = 0;
			#CLOCK_RX in = 1;
			#CLOCK_RX in = 0;
			#CLOCK_RX in = 0;
			#CLOCK_RX in = 1;

			#CLOCK_RX in = 1; // stop bit
		end
	end

	always begin
		#MAX_RATE_RX rxClk = ~rxClk;
//		#0.5 rxClk = ~rxClk;
	end

	initial begin
		#25000 $finish;
	end

endmodule
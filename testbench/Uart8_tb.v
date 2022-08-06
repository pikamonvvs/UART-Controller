`timescale 10ns/1ns

`include "inc/Defines.vh"
`include "src/Uart8.v"

module tbUart8();

	parameter CLOCK_RATE   = `CLOCK_RATE_100MHZ;
	parameter BAUD_RATE    = `BAUD_RATE_115200;
	parameter OVERSAMPLING = `OVERSAMPLING_16;
	parameter DATA_BITS    = `DATA_BITS_8;

    //localparam MAX_RATE_RX = CLOCK_RATE / (2 * BAUD_RATE * OVERSAMPLING);
    //localparam MAX_RATE_TX = CLOCK_RATE / (2 * BAUD_RATE);
	//localparam CLOCK_RX = MAX_RATE_RX * OVERSAMPLING * 2;
	//localparam CLOCK_TX = MAX_RATE_TX * 2;
	localparam CLOCK_RX = CLOCK_RATE / BAUD_RATE;
	localparam CLOCK_TX = CLOCK_RATE / BAUD_RATE;

	reg clk = 0;
	wire [DATA_BITS - 1:0] in;
	wire [DATA_BITS - 1:0] out;

	// rx interface
	reg rx = 1;
	reg rxEn = 1;
	wire rxDone;
	wire rxBusy;
	wire rxErr;

	// tx interface
	wire tx;
	reg txEn = 1;
	reg txStart = 0;
	wire txDone;
	wire txBusy;

	assign in = out;

	Uart8 #(
        .CLOCK_RATE(CLOCK_RATE),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(OVERSAMPLING),
        .DATA_BITS(DATA_BITS)
	) test (
		.clk(clk),
        .rx(rx),
        .rxEn(rxEn),
        .out(out),
        .rxDone(rxDone),
        .rxBusy(rxBusy),
        .rxErr(rxErr),

        .tx(tx),
        .txEn(txEn),
        .txStart(txStart),
        .in(in),
        .txDone(txDone),
        .txBusy(txBusy)
	);

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(-1, test);
    end

	initial begin
		begin // (0x55)
			// rx
			#CLOCK_RX rx = 0; // start bit

			#CLOCK_RX rx = 1; // data bit (0x55)
			#CLOCK_RX rx = 0;
			#CLOCK_RX rx = 1;
			#CLOCK_RX rx = 0;
			#CLOCK_RX rx = 1;
			#CLOCK_RX rx = 0;
			#CLOCK_RX rx = 1;
			#CLOCK_RX rx = 0;

			#CLOCK_RX rx = 1; // stop bit

			// tx
			#CLOCK_TX txStart <= 1'b1;
			#CLOCK_TX txStart <= 1'b0;

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
			// rx
			#CLOCK_RX rx = 0; // start bit

			#CLOCK_RX rx = 0; // data bit (0x96)
			#CLOCK_RX rx = 1;
			#CLOCK_RX rx = 1;
			#CLOCK_RX rx = 0;
			#CLOCK_RX rx = 1;
			#CLOCK_RX rx = 0;
			#CLOCK_RX rx = 0;
			#CLOCK_RX rx = 1;

			#CLOCK_RX rx = 1; // stop bit

			// tx
			#CLOCK_TX txStart <= 1'b1;
			#CLOCK_TX txStart <= 1'b0;

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
		#0.5 clk = ~clk;
	end

	initial begin
		#50000 $finish;
	end

endmodule
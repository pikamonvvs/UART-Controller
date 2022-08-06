all: Uart8
#all: BaudRateGenerator
#all: Uart8Receiver
#all: Uart8Transmitter

Uart8: clean
	iverilog -o test.vvp testbench/Uart8_tb.v
	vvp test.vvp
	gtkwave test.vcd

BaudRateGenerator: clean
	iverilog -o test.vvp testbench/BaudRateGenerator_tb.v
	vvp test.vvp
	gtkwave test.vcd

Uart8Receiver: clean
	iverilog -o test.vvp testbench/Uart8Receiver_tb.v
	vvp test.vvp
	gtkwave test.vcd

Uart8Transmitter: clean
	iverilog -o test.vvp testbench/Uart8Transmitter_tb.v
	vvp test.vvp
	gtkwave test.vcd

clean:
	rm -f test.vcd
	rm -f test.vvp

`ifndef __DEFINES_VH__
`define __DEFINES_VH__

// States of state machine
`define STATE_RESET			3'b001
`define STATE_IDLE			3'b010
`define STATE_START_BIT		3'b011
`define STATE_DATA_BITS		3'b100
`define STATE_STOP_BIT		3'b101

// Main clocks
`define CLOCK_RATE_100MHZ	100000000

// Baudrates
`define BAUD_RATE_1200		1200
`define BAUD_RATE_9600		9600
`define BAUD_RATE_57600		57600
`define BAUD_RATE_115200	115200
`define BAUD_RATE_230400	230400
`define BAUD_RATE_460800	460800

// Oversampling rates
`define OVERSAMPLING_1		1
`define OVERSAMPLING_2		2
`define OVERSAMPLING_4		4
`define OVERSAMPLING_8		8
`define OVERSAMPLING_16		16

// Data bits
`define DATA_BITS_7 		7
`define DATA_BITS_8 		8

`endif /*__DEFINES_VH__*/
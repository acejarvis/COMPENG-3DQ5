/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

module experiment3 (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// switches                          ////////////
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// LEDs                              ////////////
		output logic[8:0] LED_GREEN_O             // 9 green LEDs
);

logic resetn;
assign resetn = ~SWITCH_I[17];

enum logic [1:0] {
	S_READ,
	S_WRITE,
	S_CALCULATE,
	S_IDLE
} state;

logic [8:0] read_write_address_a[1:0], read_write_address_b[1:0];
logic [7:0] write_data_a [1:0]; // W & X at 2k
logic [7:0] write_data_b [1:0]; // W & X at 2k+1
logic write_enable_a [1:0];
logic write_enable_b [1:0];
logic [7:0] read_data_a [1:0]; // W & X at 2k
logic [7:0] read_data_b [1:0]; // W & X at 2k+1
logic [7:0] cache_data_a [1:0]; // cache to store calculation result Y & Z at 2k
logic [7:0] cache_data_b [1:0]; // cache to store calculation result Y & Z at 2k+1

// instantiate RAM0
dual_port_RAM0 RAM_inst0 (
	.address_a ( read_write_address_a[0] ),
	.address_b ( read_write_address_b[0] ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

// instantiate RAM1
dual_port_RAM1 RAM_inst1 (
	.address_a ( read_write_address_a[1] ),
	.address_b ( read_write_address_b[1] ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);


// since write enable is disabled for the top port we can 
// assign write data on the top port to some dummy values
assign cache_data_a[0] = read_data_a[0] - read_data_b[1];// Y[2k] = W[2k] - X[2k+1]
assign cache_data_a[1] = read_data_b[0] + read_data_b[1];// Y[2k+1] = W[2k+1] + X[2k]

// the adder for the write port of the first RAM
assign cache_data_b[0] = read_data_b[0] + read_data_a[1];// Y[2k+1] = W[2k+1] + X[2k]
assign cache_data_b[1] = read_data_a[0] - read_data_a[1];// Z[2k+1] = W[2k] - X[2k]
// this is where the circuit is incomplete
// expand as requested for the write port of the RAM1

// note: this write enable must be registered
// and asserted ONLY when write data is valid

// FSM to control the read and write sequence
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		read_write_address_a[0] <= 9'd0;
		read_write_address_a[1] <= 9'd0;
		read_write_address_b[0] <= 9'd1;		
		read_write_address_b[1] <= 9'd1;		
		write_enable_a[0] <= 1'b0;
		write_enable_b[0] <= 1'b0;
		write_enable_a[1] <= 1'b0;
		write_enable_b[1] <= 1'b0;
		state <= S_IDLE;
	end else begin
		case (state)
			S_IDLE: begin
				// set 2k+1 as address for w and x
				read_write_address_b[0] <= 9'd1;		
				read_write_address_b[1] <= 9'd1;		
				// wait for switch[0] to be asserted
				if (SWITCH_I[0])
					state <= S_CALCULATE;
			end
			S_CALCULATE: begin
				// write enable will be asserted for all the ports
				write_enable_a[0] <= 1'b1;
				write_enable_a[1] <= 1'b1;
				write_enable_b[0] <= 1'b1;
				write_enable_b[1] <= 1'b1;

				state <= S_WRITE;
			end
			S_WRITE: begin
				// load calculation result to the write enabled ports
				write_data_a[0] <= cache_data_a[0];
				write_data_b[0] <= cache_data_b[0];
				write_data_a[1] <= cache_data_a[1];
				write_data_b[1] <= cache_data_b[1];
				state <= S_READ;
			end
			S_READ: begin
				// enable read for all the ports
				write_enable_a[0] <= 1'b0;
				write_enable_a[1] <= 1'b0;
				write_enable_b[0] <= 1'b0;
				write_enable_b[1] <= 1'b0;
				// prepare addresses to read/write for the next k
				read_write_address_a[0] <= read_write_address_a[0] + 9'd2;
				read_write_address_a[1] <= read_write_address_a[1] + 9'd2;
				read_write_address_b[0] <= read_write_address_b[0] + 9'd2;
				read_write_address_b[1] <= read_write_address_b[1] + 9'd2;
				// finished all the reads
				if (read_write_address_a[0] == 9'd510)
					state <= S_IDLE;
				else 
					state <= S_CALCULATE;			
			end
		endcase
	end
end

// dump some dummy values on the output green LEDs to constrain 
// the synthesis tools not to remove the circuit logic
assign LED_GREEN_O = {1'b0, {write_data_b[1] ^ write_data_b[0]}};

endmodule

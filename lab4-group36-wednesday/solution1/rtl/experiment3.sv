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
	S_IDLE
} state;

logic [8:0] address_a[1:0];
logic [8:0] address_b[1:0];
logic [7:0] write_data_a [1:0];
logic [7:0] write_data_b [1:0];
logic write_enable_a [1:0];
logic write_enable_b [1:0];
logic [7:0] read_data_a [1:0];
logic [7:0] read_data_b [1:0];

// use the same address for port A for both DP-RAMs
assign address_a[1] = address_a[0];
// use (address_a + 1) for port B for both DP-RAMs
assign address_b[0] = address_a[0] + 9'd1;
assign address_b[1] = address_b[0];

// use the same write enable signal for both ports for both DP-RAMs
assign write_enable_b[0] = write_enable_a[0];
assign write_enable_a[1] = write_enable_a[0];
assign write_enable_b[1] = write_enable_a[0];

// Instantiate RAM1
dual_port_RAM1 RAM_inst1 (
	.address_a ( address_a[1] ),
	.address_b ( address_b[1] ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);

// Instantiate RAM0
dual_port_RAM0 RAM_inst0 (
	.address_a ( address_a[0] ),
	.address_b ( address_b[0] ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

// implement Y[2k] = W[2k] - X[2k+1]
assign write_data_a[0] = read_data_a[0] - read_data_b[1];

// implement Y[2k+1] = W[2k+1] + X[2k]
assign write_data_b[0] = read_data_b[0] + read_data_a[1];

// implement Z[2k] = W[2k+1] + X[2k+1]
assign write_data_a[1] = read_data_b[0] + read_data_b[1];

// implement Z[2k+1] = W[2k] - X[2k]
assign write_data_b[1] = read_data_a[0] - read_data_a[1];

// FSM to control the read and write sequence
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		address_a[0] <= 9'd0;
		write_enable_a[0] <= 1'b0;
		state <= S_READ;
	end else begin
		case (state)
		S_IDLE: begin
		end
		S_WRITE: begin	
			state <= S_READ;
			write_enable_a[0] <= 1'b0;
			address_a[0] <= address_a[0] + 9'd2;
			if (address_a[0] == 9'd510)
				  state <= S_IDLE;
		end
		S_READ: begin
			state <= S_WRITE;
			write_enable_a[0] <= 1'b1;
		end
		endcase
	end
end

// dump some dummy value on the output green LEDs
// to make sure that synthesis tools do not remove the logic
assign LED_GREEN_O = {1'b0, {write_data_b[1] ^ write_data_b[0]}};

endmodule

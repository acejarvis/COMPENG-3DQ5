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

module experiment4 (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// switches                          ////////////
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// VGA interface                     ////////////
		output logic VGA_CLOCK_O,                 // VGA clock
		output logic VGA_HSYNC_O,                 // VGA H_SYNC
		output logic VGA_VSYNC_O,                 // VGA V_SYNC
		output logic VGA_BLANK_O,                 // VGA BLANK
		output logic VGA_SYNC_O,                  // VGA SYNC
		output logic[7:0] VGA_RED_O,              // VGA red
		output logic[7:0] VGA_GREEN_O,            // VGA green
		output logic[7:0] VGA_BLUE_O,             // VGA blue

		/////// PS2                               ////////////
		input logic PS2_DATA_I,                   // PS2 data
		input logic PS2_CLOCK_I                   // PS2 clock
);

`include "VGA_param.h"
parameter SCREEN_BORDER_OFFSET = 32;
parameter RESULT_MESSAGE_LINE = 280;
parameter RESULT_MESSAGE_START_COL = 360;
parameter KEYBOARD_MESSAGE_LINE = 320;
parameter KEYBOARD_MESSAGE_START_COL = 360;

logic resetn, enable;

logic [7:0] VGA_red, VGA_green, VGA_blue;
logic [9:0] pixel_X_pos;
logic [9:0] pixel_Y_pos;

logic [5:0] character_address;
logic rom_mux_output;

logic screen_border_on;

assign resetn = ~SWITCH_I[17];

logic [7:0] PS2_code;
logic [7:0] PS2_shift_reg [14:0];
logic PS2_code_ready;

logic PS2_code_ready_buf;
logic PS2_make_code;

// PS/2 controller
PS2_controller ps2_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PS2_clock(PS2_CLOCK_I),
	.PS2_data(PS2_DATA_I),
	.PS2_code(PS2_code),
	.PS2_code_ready(PS2_code_ready),
	.PS2_make_code(PS2_make_code)
);

logic [3:0] pressed_key_count;
logic [3:0] PS2_key_track[9:0];

logic [3:0] max_value, max_index;
logic [3:0] current_value, current_index;

integer i;
// Putting the PS2 code into a shift register
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		PS2_code_ready_buf <= 1'b0;
		for (i=0; i<15; i+=1)
			PS2_shift_reg[i] <= 8'd0;
		for (i=0; i<10; i+=1)
			PS2_key_track[i] <= 4'd0;
		pressed_key_count <= 4'd0;
		max_index <= 4'd0;
		max_value <= 4'd0;
		current_index <= 4'd0;
		current_value <= 4'd0;
	end else begin
		PS2_code_ready_buf <= PS2_code_ready;

		if (PS2_key_track[current_index] > max_value) begin
			max_value <= PS2_key_track[current_index];
			max_index <= current_index;
		end else if (PS2_key_track[current_index] == max_value) begin
			if (current_index > max_index)
				max_index <= current_index;
		end

		if (PS2_code_ready && ~PS2_code_ready_buf && PS2_make_code) begin
			// scan code detected
			if (pressed_key_count < 4'd15) begin
				pressed_key_count <= pressed_key_count + 4'd1;
				PS2_shift_reg[pressed_key_count] <= PS2_code;
				case (PS2_code)
					8'h45:	begin
							PS2_key_track[0] <= PS2_key_track[0] + 4'd1; // 0
							current_value <= PS2_key_track[0] + 4'd1;
							current_index <= 4'd0;
						end
					8'h16:	begin
							PS2_key_track[1] <= PS2_key_track[1] + 4'd1; // 1
							current_value <= PS2_key_track[1] + 4'd1;
							current_index <= 4'd1;
						end
					8'h1E: begin
							PS2_key_track[2] <= PS2_key_track[2] + 4'd1; // 2
							current_value <= PS2_key_track[2] + 4'd1;
							current_index <= 4'd2;
						end
					8'h26:	begin
							PS2_key_track[3] <= PS2_key_track[3] + 4'd1; // 3
							current_value <= PS2_key_track[3] + 4'd1;
							current_index <= 4'd3;
						end
					8'h25:	begin
							PS2_key_track[4] <= PS2_key_track[4] + 4'd1; // 4
							current_value <= PS2_key_track[4] + 4'd1;
							current_index <= 4'd4;
						end
					8'h2E:	begin
							PS2_key_track[5] <= PS2_key_track[5] + 4'd1; // 5
							current_value <= PS2_key_track[5] + 4'd1;
							current_index <= 4'd5;
						end
					8'h36: 	begin
							PS2_key_track[6] <= PS2_key_track[6] + 4'd1; // 6
							current_value <= PS2_key_track[6] + 4'd1;
							current_index <= 4'd6;
						end
					8'h3D:	begin
							PS2_key_track[7] <= PS2_key_track[7] + 4'd1; // 7
							current_value <= PS2_key_track[7] + 4'd1;
							current_index <= 4'd7;
						end
					8'h3E:	begin
							PS2_key_track[8] <= PS2_key_track[8] + 4'd1; // 8
							current_value <= PS2_key_track[8] + 4'd1;
							current_index <= 4'd8;
						end
					8'h46:	begin
							PS2_key_track[9] <= PS2_key_track[9] + 4'd1; // 9
							current_value <= PS2_key_track[9] + 4'd1;
							current_index <= 4'd9;
						end
				endcase
			end
		end
	end
end

VGA_controller VGA_unit(
	.clock(CLOCK_50_I),
	.resetn(resetn),
	.enable(enable),

	.iRed(VGA_red),
	.iGreen(VGA_green),
	.iBlue(VGA_blue),
	.oCoord_X(pixel_X_pos),
	.oCoord_Y(pixel_Y_pos),
	
	// VGA Side
	.oVGA_R(VGA_RED_O),
	.oVGA_G(VGA_GREEN_O),
	.oVGA_B(VGA_BLUE_O),
	.oVGA_H_SYNC(VGA_HSYNC_O),
	.oVGA_V_SYNC(VGA_VSYNC_O),
	.oVGA_SYNC(VGA_SYNC_O),
	.oVGA_BLANK(VGA_BLANK_O)
);

logic [2:0] delay_X_pos;

always_ff @(posedge CLOCK_50_I or negedge resetn) begin
	if(!resetn) begin
		delay_X_pos[2:0] <= 3'd0;
	end else begin
		delay_X_pos[2:0] <= pixel_X_pos[2:0];
	end
end

// Character ROM
char_rom char_rom_unit (
	.Clock(CLOCK_50_I),
	.Character_address(character_address),
	.Font_row(pixel_Y_pos[2:0]),
	.Font_col(delay_X_pos[2:0]),
	.Rom_mux_output(rom_mux_output)
);

// this experiment is in the 800x600 @ 72 fps mode
assign enable = 1'b1;
assign VGA_CLOCK_O = ~CLOCK_50_I;

always_comb begin
	screen_border_on = 0;
	if (pixel_X_pos == SCREEN_BORDER_OFFSET || pixel_X_pos == H_SYNC_ACT-SCREEN_BORDER_OFFSET)
		if (pixel_Y_pos >= SCREEN_BORDER_OFFSET && pixel_Y_pos < V_SYNC_ACT-SCREEN_BORDER_OFFSET)
			screen_border_on = 1'b1;
	if (pixel_Y_pos == SCREEN_BORDER_OFFSET || pixel_Y_pos == V_SYNC_ACT-SCREEN_BORDER_OFFSET)
		if (pixel_X_pos >= SCREEN_BORDER_OFFSET && pixel_X_pos < H_SYNC_ACT-SCREEN_BORDER_OFFSET)
			screen_border_on = 1'b1;
end

// Display text
always_comb begin

	character_address = 6'o40; // Show space by default
	
       if (pixel_Y_pos[9:3] == ((RESULT_MESSAGE_LINE) >> 3)) begin
		if (max_value == 4'd0) begin
	                case (pixel_X_pos[9:3])
	                        (RESULT_MESSAGE_START_COL >> 3) +  0: character_address = 6'o16; // N
	                        (RESULT_MESSAGE_START_COL >> 3) +  1: character_address = 6'o17; // O
	                        (RESULT_MESSAGE_START_COL >> 3) +  2: character_address = 6'o40; // space
	                        (RESULT_MESSAGE_START_COL >> 3) +  3: character_address = 6'o16; // N
	                        (RESULT_MESSAGE_START_COL >> 3) +  4: character_address = 6'o25; // U
	                        (RESULT_MESSAGE_START_COL >> 3) +  5: character_address = 6'o15; // M
	                        (RESULT_MESSAGE_START_COL >> 3) +  6: character_address = 6'o40; // space
	                        (RESULT_MESSAGE_START_COL >> 3) +  7: character_address = 6'o13; // K
	                        (RESULT_MESSAGE_START_COL >> 3) +  8: character_address = 6'o05; // E
	                        (RESULT_MESSAGE_START_COL >> 3) +  9: character_address = 6'o31; // Y
	                        (RESULT_MESSAGE_START_COL >> 3) +  10: character_address = 6'o23; // S
	                        (RESULT_MESSAGE_START_COL >> 3) +  11: character_address = 6'o40; // space
	                        (RESULT_MESSAGE_START_COL >> 3) +  12: character_address = 6'o20; // P
	                        (RESULT_MESSAGE_START_COL >> 3) +  13: character_address = 6'o22; // R
	                        (RESULT_MESSAGE_START_COL >> 3) +  14: character_address = 6'o05; // E
	                        (RESULT_MESSAGE_START_COL >> 3) +  15: character_address = 6'o23; // S
	                        (RESULT_MESSAGE_START_COL >> 3) +  16: character_address = 6'o23; // S
	                        (RESULT_MESSAGE_START_COL >> 3) +  17: character_address = 6'o05; // E
	                        (RESULT_MESSAGE_START_COL >> 3) +  18: character_address = 6'o04; // D
				default: character_address = 6'o40; // space
	                endcase
		end else begin
	                case (pixel_X_pos[9:3])
	                        (RESULT_MESSAGE_START_COL >> 3) +  0: character_address = 6'o13; // K
	                        (RESULT_MESSAGE_START_COL >> 3) +  1: character_address = 6'o05; // E
	                        (RESULT_MESSAGE_START_COL >> 3) +  2: character_address = 6'o31; // Y
	                        (RESULT_MESSAGE_START_COL >> 3) +  3: character_address = 6'o40; // space
	                        (RESULT_MESSAGE_START_COL >> 3) +  4: character_address = 6'o60 + max_index; // max index
	                        (RESULT_MESSAGE_START_COL >> 3) +  5: character_address = 6'o40; // space
	                        (RESULT_MESSAGE_START_COL >> 3) +  6: character_address = 6'o20; // P
	                        (RESULT_MESSAGE_START_COL >> 3) +  7: character_address = 6'o22; // R
	                        (RESULT_MESSAGE_START_COL >> 3) +  8: character_address = 6'o05; // E
	                        (RESULT_MESSAGE_START_COL >> 3) +  9: character_address = 6'o23; // S
	                        (RESULT_MESSAGE_START_COL >> 3) +  10: character_address = 6'o23; // S
	                        (RESULT_MESSAGE_START_COL >> 3) +  11: character_address = 6'o05; // E
	                        (RESULT_MESSAGE_START_COL >> 3) +  12: character_address = 6'o04; // D
	                        (RESULT_MESSAGE_START_COL >> 3) +  13: character_address = 6'o40; // space
	                        (RESULT_MESSAGE_START_COL >> 3) +  14: character_address = (max_value > 4'd9) ? 6'o61 : 6'o40; // BCD
	                        (RESULT_MESSAGE_START_COL >> 3) +  15: character_address = 6'o60 + max_value - ((max_value > 4'd9) ? 10 : 0);
	                        (RESULT_MESSAGE_START_COL >> 3) +  16: character_address = 6'o40; // space
	                        (RESULT_MESSAGE_START_COL >> 3) +  17: character_address = 6'o24; // T
	                        (RESULT_MESSAGE_START_COL >> 3) +  18: character_address = 6'o11; // I
	                        (RESULT_MESSAGE_START_COL >> 3) +  19: character_address = 6'o15; // M
	                        (RESULT_MESSAGE_START_COL >> 3) +  20: character_address = 6'o05; // E
	                        (RESULT_MESSAGE_START_COL >> 3) +  21: character_address = 6'o23; // S
				default: character_address = 6'o40; // space
	                endcase
		end
        end

	if (pixel_Y_pos[9:3] == ((KEYBOARD_MESSAGE_LINE) >> 3)) begin
		if ((pixel_X_pos[9:3] - (KEYBOARD_MESSAGE_START_COL >> 3)) < 9'd15) begin
			case (PS2_shift_reg[pixel_X_pos[9:3] - (KEYBOARD_MESSAGE_START_COL >> 3)])
				8'h45:   character_address = 6'o60; // 0
				8'h16:   character_address = 6'o61; // 1
				8'h1E:   character_address = 6'o62; // 2
				8'h26:   character_address = 6'o63; // 3
				8'h25:   character_address = 6'o64; // 4
				8'h2E:   character_address = 6'o65; // 5
				8'h36:   character_address = 6'o66; // 6
				8'h3D:   character_address = 6'o67; // 7
				8'h3E:   character_address = 6'o70; // 8
				8'h46:   character_address = 6'o71; // 9
				default: character_address = 6'o40; // space
			endcase
		end
	end
end

// RGB signals
always_comb begin
		VGA_red = 8'h00;
		VGA_green = 8'h00;
		VGA_blue = 8'h00;

		if (screen_border_on) begin
			// blue border
			VGA_blue = 8'hFF;
		end
		
		if (rom_mux_output) begin
			// yellow text
			VGA_red = 8'hFF;
			VGA_green = 8'hFF;
		end
end

endmodule

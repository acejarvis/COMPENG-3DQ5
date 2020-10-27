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
		output logic[7:0] VGA_BLUE_O,              // VGA blue

		/////// PS2                               ////////////
		input logic PS2_DATA_I,                   // PS2 data
		input logic PS2_CLOCK_I                   // PS2 clock
);

`include "VGA_param.h"
parameter SCREEN_BORDER_OFFSET = 32;
parameter DEFAULT_MESSAGE_LINE = 280;
parameter DEFAULT_MESSAGE_START_COL = 360;
parameter KEYBOARD_MESSAGE_LINE = 320;
parameter KEYBOARD_MESSAGE_START_COL = 360;

logic resetn, enable;

logic [7:0] VGA_red, VGA_green, VGA_blue;
logic [9:0] pixel_X_pos;
logic [9:0] pixel_Y_pos;

logic [5:0] character_address, PS2_character_address, max_pressed_address;
logic [11:0] max_pressed_count_address;
logic rom_mux_output;

logic screen_border_on;

assign resetn = ~SWITCH_I[17];

logic [7:0] PS2_code;
logic [5:0] PS2_reg[14:0];
logic [3:0] key_pressed[9:0]; // key pressed times

logic [3:0] max_pressed_count; // max key pressed times
logic [3:0] max_pressed; // which key pressed max times and largest

logic [4:0] data_count;

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

// Putting the PS2 code into a register
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		PS2_code_ready_buf <= 1'b0;
		PS2_reg[14] <= 6'd0;
		PS2_reg[13] <= 6'd0;
		PS2_reg[12] <= 6'd0;
		PS2_reg[11] <= 6'd0;
		PS2_reg[10] <= 6'd0;
		PS2_reg[9] <= 6'd0;
		PS2_reg[8] <= 6'd0;
		PS2_reg[7] <= 6'd0;
		PS2_reg[6] <= 6'd0;
		PS2_reg[5] <= 6'd0;
		PS2_reg[4] <= 6'd0;
		PS2_reg[3] <= 6'd0;
		PS2_reg[2] <= 6'd0;
		PS2_reg[1] <= 6'd0;
		PS2_reg[0] <= 6'd0;
		key_pressed[9] <= 4'h0;
		key_pressed[8] <= 4'h0;
		key_pressed[7] <= 4'h0;
		key_pressed[6] <= 4'h0;
		key_pressed[5] <= 4'h0;
		key_pressed[4] <= 4'h0;
		key_pressed[3] <= 4'h0;
		key_pressed[2] <= 4'h0;
		key_pressed[1] <= 4'h0;
		key_pressed[0] <= 4'h0;
		data_count <= 5'd0;
		max_pressed <= 4'h0;
		max_pressed_count <= 4'h0;
		max_pressed_count_address <= 12'o0000;
		max_pressed_address <= 6'o00;
	end else begin
		PS2_code_ready_buf <= PS2_code_ready;
		if (PS2_code_ready && ~PS2_code_ready_buf && PS2_make_code && data_count < 5'd15) begin
			max_pressed <= 4'h0;
			// key pressed counter
			case(PS2_code)
				8'h45:   key_pressed[0] += 4'd1; // 0
				8'h16:   key_pressed[1] += 4'd1; // 1
				8'h1E:   key_pressed[2] += 4'd1; // 2
				8'h26:   key_pressed[3] += 4'd1; // 3
				8'h25:   key_pressed[4] += 4'd1; // 4
				8'h2E:   key_pressed[5] += 4'd1; // 5
				8'h36:   key_pressed[6] += 4'd1; // 6
				8'h3D:   key_pressed[7] += 4'd1; // 7
				8'h3E:   key_pressed[8] += 4'd1; // 8
				8'h46:   key_pressed[9] += 4'd1; // 9
			endcase
			// load 8 x 8 character to key press
			case(PS2_code)
				8'h45:   PS2_character_address = 6'o60; // 0
				8'h16:   PS2_character_address = 6'o61; // 1
				8'h1E:   PS2_character_address = 6'o62; // 2
				8'h26:   PS2_character_address = 6'o63; // 3
				8'h25:   PS2_character_address = 6'o64; // 4
				8'h2E:   PS2_character_address = 6'o65; // 5
				8'h36:   PS2_character_address = 6'o66; // 6
				8'h3D:   PS2_character_address = 6'o67; // 7
				8'h3E:   PS2_character_address = 6'o70; // 8
				8'h46:   PS2_character_address = 6'o71; // 9
				default: PS2_character_address = 6'o40; // space
			endcase
			PS2_reg[14] <= PS2_reg[13];
			PS2_reg[13] <= PS2_reg[12];
			PS2_reg[12] <= PS2_reg[11];
			PS2_reg[11] <= PS2_reg[10];
			PS2_reg[10] <= PS2_reg[9];
			PS2_reg[9] <= PS2_reg[8];
			PS2_reg[8] <= PS2_reg[7];
			PS2_reg[7] <= PS2_reg[6];
			PS2_reg[6] <= PS2_reg[5];
			PS2_reg[5] <= PS2_reg[4];
			PS2_reg[4] <= PS2_reg[3];
			PS2_reg[3] <= PS2_reg[2];
			PS2_reg[2] <= PS2_reg[1];
			PS2_reg[1] <= PS2_reg[0];
			PS2_reg[0] <= PS2_character_address;
			data_count += 5'd1;
		end else if(data_count >= 5'd15) begin
			// end of key pressing, load max count
			if (key_pressed[0] >= max_pressed_count) begin
				max_pressed_count = key_pressed[0];
				max_pressed = 4'd0;
			end
			if (key_pressed[1] >= max_pressed_count) begin
				max_pressed_count = key_pressed[1];
				max_pressed = 4'd1;
			end
			if (key_pressed[2] >= max_pressed_count) begin
				max_pressed_count = key_pressed[2];
				max_pressed = 4'd2;
			end
			if (key_pressed[3] >= max_pressed_count) begin
				max_pressed_count = key_pressed[3];
				max_pressed = 4'd3;
			end
			if (key_pressed[4] >= max_pressed_count) begin
				max_pressed_count = key_pressed[4];
				max_pressed = 4'd4;
			end
			if (key_pressed[5] >= max_pressed_count) begin
				max_pressed_count = key_pressed[5];
				max_pressed = 4'd5;
			end
			if (key_pressed[6] >= max_pressed_count) begin
				max_pressed_count = key_pressed[6];
				max_pressed = 4'd6;
			end
			if (key_pressed[7] >= max_pressed_count) begin
				max_pressed_count = key_pressed[7];
				max_pressed = 4'd7;
			end
			if (key_pressed[8] >= max_pressed_count) begin
				max_pressed_count = key_pressed[8];
				max_pressed = 4'd8;
			end
			if (key_pressed[9] >= max_pressed_count) begin 
				max_pressed_count = key_pressed[9];
				max_pressed = 4'd9;
			end
			// load 8 x 8 character to  max pressed counter
			case(max_pressed_count)
				4'd00:   max_pressed_count_address = 12'o6060; // 0
				4'd01:   max_pressed_count_address = 12'o6061; // 1
				4'd02:   max_pressed_count_address = 12'o6062; // 2
				4'd03:   max_pressed_count_address = 12'o6063; // 3
				4'd04:   max_pressed_count_address = 12'o6064; // 4
				4'd05:   max_pressed_count_address = 12'o6065; // 5
				4'd06:   max_pressed_count_address = 12'o6066; // 6
				4'd07:   max_pressed_count_address = 12'o6067; // 7
				4'd08:   max_pressed_count_address = 12'o6070; // 8
				4'd09:   max_pressed_count_address = 12'o6071; // 9
				4'd10:   max_pressed_count_address = 12'o6160; // 0
				4'd11:   max_pressed_count_address = 12'o6161; // 11
				4'd12:   max_pressed_count_address = 12'o6162; // 12
				4'd13:   max_pressed_count_address = 12'o6163; // 13
				4'd14:   max_pressed_count_address = 12'o6164; // 14
				4'd15:   max_pressed_count_address = 12'o6165; // 15
				default: max_pressed_count_address = 12'o4040; // space
			endcase
			// load 8 x 8 character to  max key pressed
			case(max_pressed)
				4'd00:   max_pressed_address = 6'o60; // 0
				4'd01:   max_pressed_address = 6'o61; // 1
				4'd02:   max_pressed_address = 6'o62; // 2
				4'd03:   max_pressed_address = 6'o63; // 3
				4'd04:   max_pressed_address = 6'o64; // 4
				4'd05:   max_pressed_address = 6'o65; // 5
				4'd06:   max_pressed_address = 6'o66; // 6
				4'd07:   max_pressed_address = 6'o67; // 7
				4'd08:   max_pressed_address = 6'o70; // 8
				4'd09:   max_pressed_address = 6'o71; // 9
				default: max_pressed_address = 6'o40; // space
			endcase
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
	
	// 8 x 8 characters to key pressed line
	if (pixel_Y_pos[9:3] == ((DEFAULT_MESSAGE_LINE) >> 3)) begin
		// Reach the section where the text is displayed
		case (pixel_X_pos[9:3])
			(DEFAULT_MESSAGE_START_COL >> 3) +  0: character_address = PS2_reg[14]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  1: character_address = PS2_reg[13]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  2: character_address = PS2_reg[12]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  3: character_address = PS2_reg[11]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  4: character_address = PS2_reg[10]; // 	
			(DEFAULT_MESSAGE_START_COL >> 3) +  5: character_address = PS2_reg[9]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  6: character_address = PS2_reg[8]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  7: character_address = PS2_reg[7]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  8: character_address = PS2_reg[6]; //
			(DEFAULT_MESSAGE_START_COL >> 3) +  9: character_address = PS2_reg[5]; //
			(DEFAULT_MESSAGE_START_COL >> 3) + 10: character_address = PS2_reg[4]; //
			(DEFAULT_MESSAGE_START_COL >> 3) + 11: character_address = PS2_reg[3]; //
			(DEFAULT_MESSAGE_START_COL >> 3) + 12: character_address = PS2_reg[2]; //
			(DEFAULT_MESSAGE_START_COL >> 3) + 13: character_address = PS2_reg[1]; //
			(DEFAULT_MESSAGE_START_COL >> 3) + 14: character_address = PS2_reg[0]; //
			default: character_address = 6'o40; // space
		endcase
	end

	// 8 x 8 characters to displayed message
	if (pixel_Y_pos[9:3] == ((KEYBOARD_MESSAGE_LINE) >> 3)) begin
		// Reach the section where the text is displayed
		if(max_pressed[3:0] > 4'd0) begin 
			case (pixel_X_pos[9:3])
				(DEFAULT_MESSAGE_START_COL >> 3) +  0:   character_address = 6'o13; // K
				(DEFAULT_MESSAGE_START_COL >> 3) +  1:   character_address = 6'o05; // E
				(DEFAULT_MESSAGE_START_COL >> 3) +  2:   character_address = 6'o31; // Y
				(DEFAULT_MESSAGE_START_COL >> 3) +  3:   character_address = 6'o40; // 
				(DEFAULT_MESSAGE_START_COL >> 3) +  4:   character_address = max_pressed_address; // X
				(DEFAULT_MESSAGE_START_COL >> 3) +  5:   character_address = 6'o40; // 
				(DEFAULT_MESSAGE_START_COL >> 3) +  6:   character_address = 6'o20; // P
				(DEFAULT_MESSAGE_START_COL >> 3) +  7:   character_address = 6'o22; // R
				(DEFAULT_MESSAGE_START_COL >> 3) +  8:   character_address = 6'o05; // E
				(DEFAULT_MESSAGE_START_COL >> 3) +  9:   character_address = 6'o23; // S
				(DEFAULT_MESSAGE_START_COL >> 3) +  10:   character_address = 6'o23; // S
				(DEFAULT_MESSAGE_START_COL >> 3) +  11:   character_address = 6'o05; // E
				(DEFAULT_MESSAGE_START_COL >> 3) +  12:   character_address = 6'o04; // D
				(DEFAULT_MESSAGE_START_COL >> 3) +  13:   character_address = 6'o40; // 
				(DEFAULT_MESSAGE_START_COL >> 3) +  14:   character_address = (max_pressed_count < 4'd9) ? max_pressed_count_address[5:0] : max_pressed_count_address[11:6]; // X
				(DEFAULT_MESSAGE_START_COL >> 3) +  15:   character_address = (max_pressed_count < 4'd9) ? 6'o40 : max_pressed_count_address[5:0]; // X
				(DEFAULT_MESSAGE_START_COL >> 3) +  16:   character_address = (max_pressed_count < 4'd9) ? 6'o24 : 6'o40; // 
				(DEFAULT_MESSAGE_START_COL >> 3) +  17:   character_address = (max_pressed_count < 4'd9) ? 6'o11 : 6'o24; // T
				(DEFAULT_MESSAGE_START_COL >> 3) +  18:   character_address = (max_pressed_count < 4'd9) ? 6'o15 : 6'o11; // I
				(DEFAULT_MESSAGE_START_COL >> 3) +  19:   character_address = (max_pressed_count < 4'd9) ? 6'o05 : 6'o15; // M
				(DEFAULT_MESSAGE_START_COL >> 3) +  20:   character_address = (max_pressed_count < 4'd9) ? 6'o23 : 6'o05; // E
				(DEFAULT_MESSAGE_START_COL >> 3) +  21:   character_address = (max_pressed_count < 4'd9) ? 6'o40 : 6'o23; // S
				default: character_address = 6'o40; // 
			endcase
		end else begin
			case (pixel_X_pos[9:3])
				(DEFAULT_MESSAGE_START_COL >> 3) +  0:   character_address = 6'o16; // N
				(DEFAULT_MESSAGE_START_COL >> 3) +  1:   character_address = 6'o17; // O
				(DEFAULT_MESSAGE_START_COL >> 3) +  2:   character_address = 6'o40; // 
				(DEFAULT_MESSAGE_START_COL >> 3) +  3:   character_address = 6'o16; // N
				(DEFAULT_MESSAGE_START_COL >> 3) +  4:   character_address = 6'o25; // U
				(DEFAULT_MESSAGE_START_COL >> 3) +  5:   character_address = 6'o15; // M
				(DEFAULT_MESSAGE_START_COL >> 3) +  6:   character_address = 6'o40; // 
				(DEFAULT_MESSAGE_START_COL >> 3) +  7:   character_address = 6'o13; // k
				(DEFAULT_MESSAGE_START_COL >> 3) +  8:   character_address = 6'o05; // E
				(DEFAULT_MESSAGE_START_COL >> 3) +  9:   character_address = 6'o31; // y
				(DEFAULT_MESSAGE_START_COL >> 3) +  10:   character_address = 6'o23; // S
				(DEFAULT_MESSAGE_START_COL >> 3) +  11:   character_address = 6'o40; // 
				(DEFAULT_MESSAGE_START_COL >> 3) +  12:   character_address = 6'o20; // P
				(DEFAULT_MESSAGE_START_COL >> 3) +  13:   character_address = 6'o22; // R
				(DEFAULT_MESSAGE_START_COL >> 3) +  14:   character_address = 6'o05; // E
				(DEFAULT_MESSAGE_START_COL >> 3) +  15:   character_address = 6'o23; // S
				(DEFAULT_MESSAGE_START_COL >> 3) +  16:   character_address = 6'o23; // S
				(DEFAULT_MESSAGE_START_COL >> 3) +  17:   character_address = 6'o05; // E
				(DEFAULT_MESSAGE_START_COL >> 3) +  18:   character_address = 6'o04; // D
				default: character_address = 6'o40; // 
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

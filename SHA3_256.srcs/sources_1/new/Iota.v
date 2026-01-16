`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2025 12:03:42
// Design Name: 
// Module Name: Iota
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Iota(
    clk,
 in_data,
 in_round,
 out_data
    );
    // ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input [63:0]in_data;
input [4:0]in_round;
output [63:0]out_data;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

integer i;

parameter KC_0  = 64'h0000000000000001;
parameter KC_1  = 64'h0000000000008082;
parameter KC_2  = 64'h800000000000808a;
parameter KC_3  = 64'h8000000080008000;
parameter KC_4  = 64'h000000000000808b;
parameter KC_5  = 64'h0000000080000001;
parameter KC_6  = 64'h8000000080008081;
parameter KC_7  = 64'h8000000000008009;
parameter KC_8  = 64'h000000000000008a;
parameter KC_9  = 64'h0000000000000088;
parameter KC_10 = 64'h0000000080008009;
parameter KC_11 = 64'h000000008000000a;
parameter KC_12 = 64'h000000008000808b;
parameter KC_13 = 64'h800000000000008b;
parameter KC_14 = 64'h8000000000008089;
parameter KC_15 = 64'h8000000000008003;
parameter KC_16 = 64'h8000000000008002;
parameter KC_17 = 64'h8000000000000080;
parameter KC_18 = 64'h000000000000800a;
parameter KC_19 = 64'h800000008000000a;
parameter KC_20 = 64'h8000000080008081;
parameter KC_21 = 64'h8000000000008080;
parameter KC_22 = 64'h0000000080000001;
parameter KC_23 = 64'h8000000080008008;


//================================================================
// Wire & Reg Declaration
//================================================================
reg [63:0]sel_kc;
//================================================================
// DESIGN
//================================================================

always@(*)begin
	case(in_round)
		0: sel_kc = KC_0;
		1: sel_kc = KC_1;
		2: sel_kc = KC_2;
		3: sel_kc = KC_3;
		4: sel_kc = KC_4;
		5: sel_kc = KC_5;
		6: sel_kc = KC_6;
		7: sel_kc = KC_7;
		8: sel_kc = KC_8;
		9: sel_kc = KC_9;
		10: sel_kc = KC_10;
		11: sel_kc = KC_11;
		12: sel_kc = KC_12;
		13: sel_kc = KC_13;
		14: sel_kc = KC_14;
		15: sel_kc = KC_15;
		16: sel_kc = KC_16;
		17: sel_kc = KC_17;
		18: sel_kc = KC_18;
		19: sel_kc = KC_19;
		20: sel_kc = KC_20;
		21: sel_kc = KC_21;
		22: sel_kc = KC_22;
		23: sel_kc = KC_23;
		default sel_kc = 64'h1;
	endcase
end

assign out_data = in_data ^ sel_kc;
endmodule
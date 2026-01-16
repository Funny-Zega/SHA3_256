`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2025 12:01:59
// Design Name: 
// Module Name: Chi
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


module Chi(
//input
 in_data_0,
 in_data_1,
 in_data_2,
 in_data_3,
 in_data_4,
 in_data_5,
 in_data_6,
 in_data_7,
 in_data_8,
 in_data_9,
 in_data_10,
 in_data_11,
 in_data_12,
 in_data_13,
 in_data_14,
 in_data_15,
 in_data_16,
 in_data_17,
 in_data_18,
 in_data_19,
 in_data_20,
 in_data_21,
 in_data_22,
 in_data_23,
 in_data_24,
 //output
 out_data_0,
 out_data_1,
 out_data_2,
 out_data_3,
 out_data_4,
 out_data_5,
 out_data_6,
 out_data_7,
 out_data_8,
 out_data_9,
 out_data_10,
 out_data_11,
 out_data_12,
 out_data_13,
 out_data_14,
 out_data_15,
 out_data_16,
 out_data_17,
 out_data_18,
 out_data_19,
 out_data_20,
 out_data_21,
 out_data_22,
 out_data_23,
 out_data_24
    );
    // ===============================================================
// Input & Output Declaration
// ===============================================================
//input
input [63:0] in_data_0;
input [63:0] in_data_1;
input [63:0] in_data_2;
input [63:0] in_data_3;
input [63:0] in_data_4;
input [63:0] in_data_5;
input [63:0] in_data_6;
input [63:0] in_data_7;
input [63:0] in_data_8;
input [63:0] in_data_9;
input [63:0] in_data_10;
input [63:0] in_data_11;
input [63:0] in_data_12;
input [63:0] in_data_13;
input [63:0] in_data_14;
input [63:0] in_data_15;
input [63:0] in_data_16;
input [63:0] in_data_17;
input [63:0] in_data_18;
input [63:0] in_data_19;
input [63:0] in_data_20;
input [63:0] in_data_21;
input [63:0] in_data_22;
input [63:0] in_data_23;
input [63:0] in_data_24;
//output
output [63:0] out_data_0;
output [63:0] out_data_1;
output [63:0] out_data_2;
output [63:0] out_data_3;
output [63:0] out_data_4;
output [63:0] out_data_5;
output [63:0] out_data_6;
output [63:0] out_data_7;
output [63:0] out_data_8;
output [63:0] out_data_9;
output [63:0] out_data_10;
output [63:0] out_data_11;
output [63:0] out_data_12;
output [63:0] out_data_13;
output [63:0] out_data_14;
output [63:0] out_data_15;
output [63:0] out_data_16;
output [63:0] out_data_17;
output [63:0] out_data_18;
output [63:0] out_data_19;
output [63:0] out_data_20;
output [63:0] out_data_21;
output [63:0] out_data_22;
output [63:0] out_data_23;
output [63:0] out_data_24;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================


//================================================================
// Wire & Reg Declaration
//================================================================

 
//================================================================
// DESIGN
//================================================================

assign out_data_0 = in_data_0 ^ ~in_data_1 & in_data_2;
assign out_data_1 = in_data_1 ^ ~in_data_2 & in_data_3;
assign out_data_2 = in_data_2 ^ ~in_data_3 & in_data_4;
assign out_data_3 = in_data_3 ^ ~in_data_4 & in_data_0;
assign out_data_4 = in_data_4 ^ ~in_data_0 & in_data_1;

assign out_data_5 = in_data_5 ^ ~in_data_6 & in_data_7;
assign out_data_6 = in_data_6 ^ ~in_data_7 & in_data_8;
assign out_data_7 = in_data_7 ^ ~in_data_8 & in_data_9;
assign out_data_8 = in_data_8 ^ ~in_data_9 & in_data_5;
assign out_data_9 = in_data_9 ^ ~in_data_5 & in_data_6;

assign out_data_10 = in_data_10 ^ ~in_data_11 & in_data_12;
assign out_data_11 = in_data_11 ^ ~in_data_12 & in_data_13;
assign out_data_12 = in_data_12 ^ ~in_data_13 & in_data_14;
assign out_data_13 = in_data_13 ^ ~in_data_14 & in_data_10;
assign out_data_14 = in_data_14 ^ ~in_data_10 & in_data_11;

assign out_data_15 = in_data_15 ^ ~in_data_16 & in_data_17;
assign out_data_16 = in_data_16 ^ ~in_data_17 & in_data_18;
assign out_data_17 = in_data_17 ^ ~in_data_18 & in_data_19;
assign out_data_18 = in_data_18 ^ ~in_data_19 & in_data_15;
assign out_data_19 = in_data_19 ^ ~in_data_15 & in_data_16;

assign out_data_20 = in_data_20 ^ ~in_data_21 & in_data_22;
assign out_data_21 = in_data_21 ^ ~in_data_22 & in_data_23;
assign out_data_22 = in_data_22 ^ ~in_data_23 & in_data_24;
assign out_data_23 = in_data_23 ^ ~in_data_24 & in_data_20;
assign out_data_24 = in_data_24 ^ ~in_data_20 & in_data_21;
    
endmodule
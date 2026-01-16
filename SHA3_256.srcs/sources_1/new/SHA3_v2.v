`timescale 1ns / 1ps
module SHA3_v2(
	// Input Signal
	clk,
	rst_n,
	in_valid,
	in_data,
	in_isLast,
	// Output Signal
	out_valid,
	out_data,
	out_buffer_full
);
// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input in_valid;
input [63:0] in_data;//thanh ghi in_data 64 bit
input in_isLast;
output reg out_valid;
output reg [63:0]out_data;
output reg out_buffer_full;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

integer i;

localparam IDLE 		= 5'd0; 
localparam RD_WAIT		= 5'd1;
localparam RD 			= 5'd2; 
localparam IDLE2 		= 5'd3; 
localparam INITIAL	 	= 5'd4;  
localparam IDLE3		= 5'd5; 
localparam KC1_THETA	 	= 5'd6; 
localparam KC1_RHOPI		= 5'd7;
localparam KC1_CHI		= 5'd8;
localparam KC1_IOTA		= 5'd9;
localparam IDLE4  		= 5'd10; 
localparam PAD_OP1		= 5'd11; 
localparam PAD_OP2		= 5'd12; 
localparam IDLE5 		= 5'd13; 
localparam KC2_THETA	 	= 5'd14; 
localparam KC2_RHOPI		= 5'd15;
localparam KC2_CHI		= 5'd16;
localparam KC2_IOTA		= 5'd17;
localparam IDLE6 		= 5'd18; 
localparam DONE 		= 5'd19; 
//================================================================
// Wire & Reg Declaration
//================================================================
reg [5:0] state_cs, state_ns;

reg [63:0] data_reg[0:24]; // 25 thanh ghi data_reg 64bit

reg [4:0] counter;

reg [9:0]len_reg ;
reg in_isLast_reg;



//================================================================
// SUB MODULE
//================================================================

//theta
reg [63:0] theta_in_data_0;
reg [63:0] theta_in_data_1;
reg [63:0] theta_in_data_2;
reg [63:0] theta_in_data_3;
reg [63:0] theta_in_data_4;
reg [63:0] theta_in_data_5;
reg [63:0] theta_in_data_6;
reg [63:0] theta_in_data_7;
reg [63:0] theta_in_data_8;
reg [63:0] theta_in_data_9;
reg [63:0] theta_in_data_10;
reg [63:0] theta_in_data_11;
reg [63:0] theta_in_data_12;
reg [63:0] theta_in_data_13;
reg [63:0] theta_in_data_14;
reg [63:0] theta_in_data_15;
reg [63:0] theta_in_data_16;
reg [63:0] theta_in_data_17;
reg [63:0] theta_in_data_18;
reg [63:0] theta_in_data_19;
reg [63:0] theta_in_data_20;
reg [63:0] theta_in_data_21;
reg [63:0] theta_in_data_22;
reg [63:0] theta_in_data_23;
reg [63:0] theta_in_data_24;

wire [63:0] theta_out_data_0;
wire [63:0] theta_out_data_1;
wire [63:0] theta_out_data_2;
wire [63:0] theta_out_data_3;
wire [63:0] theta_out_data_4;
wire [63:0] theta_out_data_5;
wire [63:0] theta_out_data_6;
wire [63:0] theta_out_data_7;
wire [63:0] theta_out_data_8;
wire [63:0] theta_out_data_9;
wire [63:0] theta_out_data_10;
wire [63:0] theta_out_data_11;
wire [63:0] theta_out_data_12;
wire [63:0] theta_out_data_13;
wire [63:0] theta_out_data_14;
wire [63:0] theta_out_data_15;
wire [63:0] theta_out_data_16;
wire [63:0] theta_out_data_17;
wire [63:0] theta_out_data_18;
wire [63:0] theta_out_data_19;
wire [63:0] theta_out_data_20;
wire [63:0] theta_out_data_21;
wire [63:0] theta_out_data_22;
wire [63:0] theta_out_data_23;
wire [63:0] theta_out_data_24;


//rhopi
reg [63:0] rhopi_in_data_0;
reg [63:0] rhopi_in_data_1;
reg [63:0] rhopi_in_data_2;
reg [63:0] rhopi_in_data_3;
reg [63:0] rhopi_in_data_4;
reg [63:0] rhopi_in_data_5;
reg [63:0] rhopi_in_data_6;
reg [63:0] rhopi_in_data_7;
reg [63:0] rhopi_in_data_8;
reg [63:0] rhopi_in_data_9;
reg [63:0] rhopi_in_data_10;
reg [63:0] rhopi_in_data_11;
reg [63:0] rhopi_in_data_12;
reg [63:0] rhopi_in_data_13;
reg [63:0] rhopi_in_data_14;
reg [63:0] rhopi_in_data_15;
reg [63:0] rhopi_in_data_16;
reg [63:0] rhopi_in_data_17;
reg [63:0] rhopi_in_data_18;
reg [63:0] rhopi_in_data_19;
reg [63:0] rhopi_in_data_20;
reg [63:0] rhopi_in_data_21;
reg [63:0] rhopi_in_data_22;
reg [63:0] rhopi_in_data_23;
reg [63:0] rhopi_in_data_24;

wire [63:0] rhopi_out_data_0;
wire [63:0] rhopi_out_data_1;
wire [63:0] rhopi_out_data_2;
wire [63:0] rhopi_out_data_3;
wire [63:0] rhopi_out_data_4;
wire [63:0] rhopi_out_data_5;
wire [63:0] rhopi_out_data_6;
wire [63:0] rhopi_out_data_7;
wire [63:0] rhopi_out_data_8;
wire [63:0] rhopi_out_data_9;
wire [63:0] rhopi_out_data_10;
wire [63:0] rhopi_out_data_11;
wire [63:0] rhopi_out_data_12;
wire [63:0] rhopi_out_data_13;
wire [63:0] rhopi_out_data_14;
wire [63:0] rhopi_out_data_15;
wire [63:0] rhopi_out_data_16;
wire [63:0] rhopi_out_data_17;
wire [63:0] rhopi_out_data_18;
wire [63:0] rhopi_out_data_19;
wire [63:0] rhopi_out_data_20;
wire [63:0] rhopi_out_data_21;
wire [63:0] rhopi_out_data_22;
wire [63:0] rhopi_out_data_23;
wire [63:0] rhopi_out_data_24;


//chi
reg [63:0] chi_in_data_0;
reg [63:0] chi_in_data_1;
reg [63:0] chi_in_data_2;
reg [63:0] chi_in_data_3;
reg [63:0] chi_in_data_4;
reg [63:0] chi_in_data_5;
reg [63:0] chi_in_data_6;
reg [63:0] chi_in_data_7;
reg [63:0] chi_in_data_8;
reg [63:0] chi_in_data_9;
reg [63:0] chi_in_data_10;
reg [63:0] chi_in_data_11;
reg [63:0] chi_in_data_12;
reg [63:0] chi_in_data_13;
reg [63:0] chi_in_data_14;
reg [63:0] chi_in_data_15;
reg [63:0] chi_in_data_16;
reg [63:0] chi_in_data_17;
reg [63:0] chi_in_data_18;
reg [63:0] chi_in_data_19;
reg [63:0] chi_in_data_20;
reg [63:0] chi_in_data_21;
reg [63:0] chi_in_data_22;
reg [63:0] chi_in_data_23;
reg [63:0] chi_in_data_24;

wire [63:0] chi_out_data_0;
wire [63:0] chi_out_data_1;
wire [63:0] chi_out_data_2;
wire [63:0] chi_out_data_3;
wire [63:0] chi_out_data_4;
wire [63:0] chi_out_data_5;
wire [63:0] chi_out_data_6;
wire [63:0] chi_out_data_7;
wire [63:0] chi_out_data_8;
wire [63:0] chi_out_data_9;
wire [63:0] chi_out_data_10;
wire [63:0] chi_out_data_11;
wire [63:0] chi_out_data_12;
wire [63:0] chi_out_data_13;
wire [63:0] chi_out_data_14;
wire [63:0] chi_out_data_15;
wire [63:0] chi_out_data_16;
wire [63:0] chi_out_data_17;
wire [63:0] chi_out_data_18;
wire [63:0] chi_out_data_19;
wire [63:0] chi_out_data_20;
wire [63:0] chi_out_data_21;
wire [63:0] chi_out_data_22;
wire [63:0] chi_out_data_23;
wire [63:0] chi_out_data_24;


//iota
reg [63:0] iota_in_data_0;
reg [63:0] iota_in_data_1;
reg [63:0] iota_in_data_2;
reg [63:0] iota_in_data_3;
reg [63:0] iota_in_data_4;
reg [63:0] iota_in_data_5;
reg [63:0] iota_in_data_6;
reg [63:0] iota_in_data_7;
reg [63:0] iota_in_data_8;
reg [63:0] iota_in_data_9;
reg [63:0] iota_in_data_10;
reg [63:0] iota_in_data_11;
reg [63:0] iota_in_data_12;
reg [63:0] iota_in_data_13;
reg [63:0] iota_in_data_14;
reg [63:0] iota_in_data_15;
reg [63:0] iota_in_data_16;
reg [63:0] iota_in_data_17;
reg [63:0] iota_in_data_18;
reg [63:0] iota_in_data_19;
reg [63:0] iota_in_data_20;
reg [63:0] iota_in_data_21;
reg [63:0] iota_in_data_22;
reg [63:0] iota_in_data_23;
reg [63:0] iota_in_data_24;

wire [63:0] iota_out_data_0;
wire [63:0] iota_out_data_1;
wire [63:0] iota_out_data_2;
wire [63:0] iota_out_data_3;
wire [63:0] iota_out_data_4;
wire [63:0] iota_out_data_5;
wire [63:0] iota_out_data_6;
wire [63:0] iota_out_data_7;
wire [63:0] iota_out_data_8;
wire [63:0] iota_out_data_9;
wire [63:0] iota_out_data_10;
wire [63:0] iota_out_data_11;
wire [63:0] iota_out_data_12;
wire [63:0] iota_out_data_13;
wire [63:0] iota_out_data_14;
wire [63:0] iota_out_data_15;
wire [63:0] iota_out_data_16;
wire [63:0] iota_out_data_17;
wire [63:0] iota_out_data_18;
wire [63:0] iota_out_data_19;
wire [63:0] iota_out_data_20;
wire [63:0] iota_out_data_21;
wire [63:0] iota_out_data_22;
wire [63:0] iota_out_data_23;
wire [63:0] iota_out_data_24;

Theta u_Theta
(
//input
 .in_data_0(theta_in_data_0),
 .in_data_1(theta_in_data_1),
 .in_data_2(theta_in_data_2),
 .in_data_3(theta_in_data_3),
 .in_data_4(theta_in_data_4),
 .in_data_5(theta_in_data_5),
 .in_data_6(theta_in_data_6),
 .in_data_7(theta_in_data_7),
 .in_data_8(theta_in_data_8),
 .in_data_9(theta_in_data_9),
 .in_data_10(theta_in_data_10),
 .in_data_11(theta_in_data_11),
 .in_data_12(theta_in_data_12),
 .in_data_13(theta_in_data_13),
 .in_data_14(theta_in_data_14),
 .in_data_15(theta_in_data_15),
 .in_data_16(theta_in_data_16),
 .in_data_17(theta_in_data_17),
 .in_data_18(theta_in_data_18),
 .in_data_19(theta_in_data_19),
 .in_data_20(theta_in_data_20),
 .in_data_21(theta_in_data_21),
 .in_data_22(theta_in_data_22),
 .in_data_23(theta_in_data_23),
 .in_data_24(theta_in_data_24),
 //output
 .out_data_0(theta_out_data_0),
 .out_data_1(theta_out_data_1),
 .out_data_2(theta_out_data_2),
 .out_data_3(theta_out_data_3),
 .out_data_4(theta_out_data_4),
 .out_data_5(theta_out_data_5),
 .out_data_6(theta_out_data_6),
 .out_data_7(theta_out_data_7),
 .out_data_8(theta_out_data_8),
 .out_data_9(theta_out_data_9),
 .out_data_10(theta_out_data_10),
 .out_data_11(theta_out_data_11),
 .out_data_12(theta_out_data_12),
 .out_data_13(theta_out_data_13),
 .out_data_14(theta_out_data_14),
 .out_data_15(theta_out_data_15),
 .out_data_16(theta_out_data_16),
 .out_data_17(theta_out_data_17),
 .out_data_18(theta_out_data_18),
 .out_data_19(theta_out_data_19),
 .out_data_20(theta_out_data_20),
 .out_data_21(theta_out_data_21),
 .out_data_22(theta_out_data_22),
 .out_data_23(theta_out_data_23),
 .out_data_24(theta_out_data_24)
);

RhoPi u_RhoPi
(
//input
 .in_data_0(rhopi_in_data_0),
 .in_data_1(rhopi_in_data_1),
 .in_data_2(rhopi_in_data_2),
 .in_data_3(rhopi_in_data_3),
 .in_data_4(rhopi_in_data_4),
 .in_data_5(rhopi_in_data_5),
 .in_data_6(rhopi_in_data_6),
 .in_data_7(rhopi_in_data_7),
 .in_data_8(rhopi_in_data_8),
 .in_data_9(rhopi_in_data_9),
 .in_data_10(rhopi_in_data_10),
 .in_data_11(rhopi_in_data_11),
 .in_data_12(rhopi_in_data_12),
 .in_data_13(rhopi_in_data_13),
 .in_data_14(rhopi_in_data_14),
 .in_data_15(rhopi_in_data_15),
 .in_data_16(rhopi_in_data_16),
 .in_data_17(rhopi_in_data_17),
 .in_data_18(rhopi_in_data_18),
 .in_data_19(rhopi_in_data_19),
 .in_data_20(rhopi_in_data_20),
 .in_data_21(rhopi_in_data_21),
 .in_data_22(rhopi_in_data_22),
 .in_data_23(rhopi_in_data_23),
 .in_data_24(rhopi_in_data_24),
 //output
 .out_data_0(rhopi_out_data_0),
 .out_data_1(rhopi_out_data_1),
 .out_data_2(rhopi_out_data_2),
 .out_data_3(rhopi_out_data_3),
 .out_data_4(rhopi_out_data_4),
 .out_data_5(rhopi_out_data_5),
 .out_data_6(rhopi_out_data_6),
 .out_data_7(rhopi_out_data_7),
 .out_data_8(rhopi_out_data_8),
 .out_data_9(rhopi_out_data_9),
 .out_data_10(rhopi_out_data_10),
 .out_data_11(rhopi_out_data_11),
 .out_data_12(rhopi_out_data_12),
 .out_data_13(rhopi_out_data_13),
 .out_data_14(rhopi_out_data_14),
 .out_data_15(rhopi_out_data_15),
 .out_data_16(rhopi_out_data_16),
 .out_data_17(rhopi_out_data_17),
 .out_data_18(rhopi_out_data_18),
 .out_data_19(rhopi_out_data_19),
 .out_data_20(rhopi_out_data_20),
 .out_data_21(rhopi_out_data_21),
 .out_data_22(rhopi_out_data_22),
 .out_data_23(rhopi_out_data_23),
 .out_data_24(rhopi_out_data_24)
);

Chi u_Chi
(
//input
 .in_data_0(chi_in_data_0),
 .in_data_1(chi_in_data_1),
 .in_data_2(chi_in_data_2),
 .in_data_3(chi_in_data_3),
 .in_data_4(chi_in_data_4),
 .in_data_5(chi_in_data_5),
 .in_data_6(chi_in_data_6),
 .in_data_7(chi_in_data_7),
 .in_data_8(chi_in_data_8),
 .in_data_9(chi_in_data_9),
 .in_data_10(chi_in_data_10),
 .in_data_11(chi_in_data_11),
 .in_data_12(chi_in_data_12),
 .in_data_13(chi_in_data_13),
 .in_data_14(chi_in_data_14),
 .in_data_15(chi_in_data_15),
 .in_data_16(chi_in_data_16),
 .in_data_17(chi_in_data_17),
 .in_data_18(chi_in_data_18),
 .in_data_19(chi_in_data_19),
 .in_data_20(chi_in_data_20),
 .in_data_21(chi_in_data_21),
 .in_data_22(chi_in_data_22),
 .in_data_23(chi_in_data_23),
 .in_data_24(chi_in_data_24),
 //output
 .out_data_0(chi_out_data_0),
 .out_data_1(chi_out_data_1),
 .out_data_2(chi_out_data_2),
 .out_data_3(chi_out_data_3),
 .out_data_4(chi_out_data_4),
 .out_data_5(chi_out_data_5),
 .out_data_6(chi_out_data_6),
 .out_data_7(chi_out_data_7),
 .out_data_8(chi_out_data_8),
 .out_data_9(chi_out_data_9),
 .out_data_10(chi_out_data_10),
 .out_data_11(chi_out_data_11),
 .out_data_12(chi_out_data_12),
 .out_data_13(chi_out_data_13),
 .out_data_14(chi_out_data_14),
 .out_data_15(chi_out_data_15),
 .out_data_16(chi_out_data_16),
 .out_data_17(chi_out_data_17),
 .out_data_18(chi_out_data_18),
 .out_data_19(chi_out_data_19),
 .out_data_20(chi_out_data_20),
 .out_data_21(chi_out_data_21),
 .out_data_22(chi_out_data_22),
 .out_data_23(chi_out_data_23),
 .out_data_24(chi_out_data_24)
);

Iota u_Iota
(
 .clk(clk),
 .in_data(iota_in_data_0),
 .in_round(counter),
 .out_data(iota_out_data_0)

);

// bước nạp xuất data vào các state thông qua data_reg
always@(*)begin
	if(state_cs==KC1_THETA || state_cs==KC2_THETA)begin
		theta_in_data_0 = data_reg[0];
		theta_in_data_1 = data_reg[1];
		theta_in_data_2 = data_reg[2];
		theta_in_data_3 = data_reg[3];
		theta_in_data_4 = data_reg[4];
		theta_in_data_5 = data_reg[5];
		theta_in_data_6 = data_reg[6];
		theta_in_data_7 = data_reg[7];
		theta_in_data_8 = data_reg[8];
		theta_in_data_9 = data_reg[9];
		theta_in_data_10 = data_reg[10];
		theta_in_data_11 = data_reg[11];
		theta_in_data_12 = data_reg[12];
		theta_in_data_13 = data_reg[13];
		theta_in_data_14 = data_reg[14];
		theta_in_data_15 = data_reg[15];
		theta_in_data_16 = data_reg[16];
		theta_in_data_17 = data_reg[17];
		theta_in_data_18 = data_reg[18];
		theta_in_data_19 = data_reg[19];
		theta_in_data_20 = data_reg[20];
		theta_in_data_21 = data_reg[21];
		theta_in_data_22 = data_reg[22];
		theta_in_data_23 = data_reg[23];
		theta_in_data_24 = data_reg[24];
	end
	else begin
		theta_in_data_0 = 0;
		theta_in_data_1 = 0;
		theta_in_data_2 = 0;
		theta_in_data_3 = 0;
		theta_in_data_4 = 0;
		theta_in_data_5 = 0;
		theta_in_data_6 = 0;
		theta_in_data_7 = 0;
		theta_in_data_8 = 0;
		theta_in_data_9 = 0;
		theta_in_data_10 = 0;
		theta_in_data_11 = 0;
		theta_in_data_12 = 0;
		theta_in_data_13 = 0;
		theta_in_data_14 = 0;
		theta_in_data_15 = 0;
		theta_in_data_16 = 0;
		theta_in_data_17 = 0;
		theta_in_data_18 = 0;
		theta_in_data_19 = 0;
		theta_in_data_20 = 0;
		theta_in_data_21 = 0;
		theta_in_data_22 = 0;
		theta_in_data_23 = 0;
		theta_in_data_24 = 0;
	end
end

always@(*)begin
	if(state_cs==KC1_RHOPI || state_cs==KC2_RHOPI)begin
		rhopi_in_data_0 = data_reg[0];
		rhopi_in_data_1 = data_reg[1];
		rhopi_in_data_2 = data_reg[2];
		rhopi_in_data_3 = data_reg[3];
		rhopi_in_data_4 = data_reg[4];
		rhopi_in_data_5 = data_reg[5];
		rhopi_in_data_6 = data_reg[6];
		rhopi_in_data_7 = data_reg[7];
		rhopi_in_data_8 = data_reg[8];
		rhopi_in_data_9 = data_reg[9];
		rhopi_in_data_10 = data_reg[10];
		rhopi_in_data_11 = data_reg[11];
		rhopi_in_data_12 = data_reg[12];
		rhopi_in_data_13 = data_reg[13];
		rhopi_in_data_14 = data_reg[14];
		rhopi_in_data_15 = data_reg[15];
		rhopi_in_data_16 = data_reg[16];
		rhopi_in_data_17 = data_reg[17];
		rhopi_in_data_18 = data_reg[18];
		rhopi_in_data_19 = data_reg[19];
		rhopi_in_data_20 = data_reg[20];
		rhopi_in_data_21 = data_reg[21];
		rhopi_in_data_22 = data_reg[22];
		rhopi_in_data_23 = data_reg[23];
		rhopi_in_data_24 = data_reg[24];
	end
	else begin
		rhopi_in_data_0 = 0;
		rhopi_in_data_1 = 0;
		rhopi_in_data_2 = 0;
		rhopi_in_data_3 = 0;
		rhopi_in_data_4 = 0;
		rhopi_in_data_5 = 0;
		rhopi_in_data_6 = 0;
		rhopi_in_data_7 = 0;
		rhopi_in_data_8 = 0;
		rhopi_in_data_9 = 0;
		rhopi_in_data_10 = 0;
		rhopi_in_data_11 = 0;
		rhopi_in_data_12 = 0;
		rhopi_in_data_13 = 0;
		rhopi_in_data_14 = 0;
		rhopi_in_data_15 = 0;
		rhopi_in_data_16 = 0;
		rhopi_in_data_17 = 0;
		rhopi_in_data_18 = 0;
		rhopi_in_data_19 = 0;
		rhopi_in_data_20 = 0;
		rhopi_in_data_21 = 0;
		rhopi_in_data_22 = 0;
		rhopi_in_data_23 = 0;
		rhopi_in_data_24 = 0;
	end
end

always@(*)begin
	if(state_cs==KC1_CHI || state_cs==KC2_CHI)begin
		chi_in_data_0 = data_reg[0];
		chi_in_data_1 = data_reg[1];
		chi_in_data_2 = data_reg[2];
		chi_in_data_3 = data_reg[3];
		chi_in_data_4 = data_reg[4];
		chi_in_data_5 = data_reg[5];
		chi_in_data_6 = data_reg[6];
		chi_in_data_7 = data_reg[7];
		chi_in_data_8 = data_reg[8];
		chi_in_data_9 = data_reg[9];
		chi_in_data_10 = data_reg[10];
		chi_in_data_11 = data_reg[11];
		chi_in_data_12 = data_reg[12];
		chi_in_data_13 = data_reg[13];
		chi_in_data_14 = data_reg[14];
		chi_in_data_15 = data_reg[15];
		chi_in_data_16 = data_reg[16];
		chi_in_data_17 = data_reg[17];
		chi_in_data_18 = data_reg[18];
		chi_in_data_19 = data_reg[19];
		chi_in_data_20 = data_reg[20];
		chi_in_data_21 = data_reg[21];
		chi_in_data_22 = data_reg[22];
		chi_in_data_23 = data_reg[23];
		chi_in_data_24 = data_reg[24];
	end
	else begin
		chi_in_data_0 = 0;
		chi_in_data_1 = 0;
		chi_in_data_2 = 0;
		chi_in_data_3 = 0;
		chi_in_data_4 = 0;
		chi_in_data_5 = 0;
		chi_in_data_6 = 0;
		chi_in_data_7 = 0;
		chi_in_data_8 = 0;
		chi_in_data_9 = 0;
		chi_in_data_10 = 0;
		chi_in_data_11 = 0;
		chi_in_data_12 = 0;
		chi_in_data_13 = 0;
		chi_in_data_14 = 0;
		chi_in_data_15 = 0;
		chi_in_data_16 = 0;
		chi_in_data_17 = 0;
		chi_in_data_18 = 0;
		chi_in_data_19 = 0;
		chi_in_data_20 = 0;
		chi_in_data_21 = 0;
		chi_in_data_22 = 0;
		chi_in_data_23 = 0;
		chi_in_data_24 = 0;
	end
end

always@(*)begin
	if(state_cs==KC1_IOTA || state_cs==KC2_IOTA)begin
		iota_in_data_0 = data_reg[0];
		iota_in_data_1 = data_reg[1];
		iota_in_data_2 = data_reg[2];
		iota_in_data_3 = data_reg[3];
		iota_in_data_4 = data_reg[4];
		iota_in_data_5 = data_reg[5];
		iota_in_data_6 = data_reg[6];
		iota_in_data_7 = data_reg[7];
		iota_in_data_8 = data_reg[8];
		iota_in_data_9 = data_reg[9];
		iota_in_data_10 = data_reg[10];
		iota_in_data_11 = data_reg[11];
		iota_in_data_12 = data_reg[12];
		iota_in_data_13 = data_reg[13];
		iota_in_data_14 = data_reg[14];
		iota_in_data_15 = data_reg[15];
		iota_in_data_16 = data_reg[16];
		iota_in_data_17 = data_reg[17];
		iota_in_data_18 = data_reg[18];
		iota_in_data_19 = data_reg[19];
		iota_in_data_20 = data_reg[20];
		iota_in_data_21 = data_reg[21];
		iota_in_data_22 = data_reg[22];
		iota_in_data_23 = data_reg[23];
		iota_in_data_24 = data_reg[24];
	end
	else begin
		iota_in_data_0 = 0;
		iota_in_data_1 = 0;
		iota_in_data_2 = 0;
		iota_in_data_3 = 0;
		iota_in_data_4 = 0;
		iota_in_data_5 = 0;
		iota_in_data_6 = 0;
		iota_in_data_7 = 0;
		iota_in_data_8 = 0;
		iota_in_data_9 = 0;
		iota_in_data_10 = 0;
		iota_in_data_11 = 0;
		iota_in_data_12 = 0;
		iota_in_data_13 = 0;
		iota_in_data_14 = 0;
		iota_in_data_15 = 0;
		iota_in_data_16 = 0;
		iota_in_data_17 = 0;
		iota_in_data_18 = 0;
		iota_in_data_19 = 0;
		iota_in_data_20 = 0;
		iota_in_data_21 = 0;
		iota_in_data_22 = 0;
		iota_in_data_23 = 0;
		iota_in_data_24 = 0;
	end
end


//=======================
// SUB MODULE DESIGN
//=======================

//================================================================
// MAIN DESIGN
//================================================================

//FSM
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<=IDLE; // khuc nay la quay lai trang thai ban dau
	else
		state_cs<=state_ns;
end

// main fsm
always@(*)begin
	case(state_cs)
		IDLE: 		state_ns = (in_valid)? RD:IDLE; // neu in_valid -> qua buoc RD
		RD: 		begin // RD la kiem coi read con doc khong hay dung roi
				if(in_isLast_reg || counter==17)
					state_ns = IDLE2;// ngung doc
				else
					state_ns = RD_WAIT; // con doc tiep nhung doi du lieu tu in_valid
		end
		RD_WAIT:	begin
					if(in_valid)
						state_ns = RD;
					else if(in_isLast_reg)
						state_ns = IDLE2;
					else
						state_ns = RD_WAIT;
				end
		IDLE2:		state_ns = INITIAL;
		INITIAL: begin
            if (counter == 17 || in_isLast_reg) 
            state_ns = IDLE3;
        else 
            state_ns = INITIAL;
        end
		IDLE3:		begin // buoc nay quyet dinh xem fsm se di pad hay bat dau cho vo keccak1
					if(in_isLast_reg)begin
						if(len_reg==136)begin
							state_ns = KC1_THETA;
						end
						else begin
							state_ns = PAD_OP1;
						end
					end
					else begin
						state_ns = KC1_THETA;
					end
				end
		KC1_THETA:	state_ns = KC1_RHOPI;
		KC1_RHOPI:	state_ns = KC1_CHI;
		KC1_CHI:	state_ns = KC1_IOTA;
		KC1_IOTA:	state_ns = (counter==23)? IDLE4 : KC1_THETA;
		IDLE4:		begin
					if(in_isLast_reg)begin
						state_ns = PAD_OP1; // ở phần này, khi đã đọc tới được batch cuối cùng
					end
					else if(in_valid)begin
						state_ns = RD; // ở nhánh này, đọc dữ liệu 17 word tiếp theo. 
					end
					else begin
						state_ns = IDLE4; //chờ
					end
				end
		PAD_OP1:	state_ns = PAD_OP2;
		PAD_OP2:	state_ns = IDLE5;
		IDLE5:		state_ns = KC2_THETA;
		KC2_THETA:	state_ns = KC2_RHOPI; // keccak core lần cuối cho đống 17word mới pad
		KC2_RHOPI:	state_ns = KC2_CHI;
		KC2_CHI:	state_ns = KC2_IOTA;
		KC2_IOTA:	state_ns = (counter==23)? IDLE6 : KC2_THETA;
		IDLE6:		state_ns = DONE;
		DONE: 		state_ns = (counter==4)?IDLE:DONE; // xuất đủ 4 word là xong, vì 4x64 bằng 256bit output
		default: 	state_ns = state_cs;
	endcase	
end



// counter
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		counter<=0;
	else if(state_ns==IDLE)
		counter<=0;
	else if(state_ns==IDLE2 || state_ns==IDLE3 || state_ns==IDLE4 || state_ns==IDLE5 || state_ns==IDLE6) // dùng counter cho nhiều việc khác nhau
		counter<=0;
	else if(state_ns==RD || state_ns==INITIAL || state_ns==DONE)//việc 1:
		counter<=counter+1;
	else if(state_cs==KC1_IOTA && state_ns==KC1_THETA)// việc 2:
		counter<=counter+1;
	else if(state_cs==KC2_IOTA && state_ns==KC2_THETA)// việc 3:
		counter<=counter+1;
end

//phần xác định độ dài thanh ghi hợp lệ
// lưu ý quan trọng: len_reg và sel_block chỉ có ý nghĩa khi phục vụ cho padding, có nghĩa là cờ isLast_reg đã được bật
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		len_reg<=0;
	else if(state_ns==IDLE)
		len_reg<=0;
	else if(state_ns==IDLE4)
		len_reg<=0;
	else if(state_ns==RD)begin
		begin // in_data là 64 bit 8 byte 1 word
			if (in_data == 64'h0) // len reg là độ dài của số byte hợp lệ
				len_reg<=len_reg;
			else if(in_data>>8 == 64'h0) // là chỉ có 8 bit thứ nhất khác 0
				len_reg<=len_reg+1; // cộng thêm độ dài 1 byte khác 0
			else if(in_data>>16 == 64'h0)
				len_reg<=len_reg+2;
			else if(in_data>>>24 == 64'h0)
				len_reg<=len_reg+3;
			else if(in_data>>32 == 64'h0)
				len_reg<=len_reg+4;
			else if(in_data>>40 == 64'h0)
				len_reg<=len_reg+5;
			else if(in_data>>48 == 64'h0)
				len_reg<=len_reg+6;
			else if(in_data>>56 == 64'h0) // 56
				len_reg<=len_reg+7; // vì 7byte in_data khác 0 
			else  // 64 bit đều khác 0, 8byte đều cho khác 0
				len_reg<=len_reg+8;
		end
	end
end


//in_isLast_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        in_isLast_reg <= 0;
    else if(in_isLast)   
        in_isLast_reg <= 1;
    else if(state_ns == IDLE) 
        in_isLast_reg <= 0;
end

reg [63:0] sel_block;

always@(*)begin
	case(len_reg[7:3]) // len_reg[2:0] là byte của word nên không cần quan tâm -> xét case len_reg này là để tìm cái word cuối cùng mà in_data có ý nghĩa
	// track được word cuối cùng của data_reg
		0: sel_block = data_reg[0];
		1: sel_block = data_reg[1];
		2: sel_block = data_reg[2];
		3: sel_block = data_reg[3];
		4: sel_block = data_reg[4];
		5: sel_block = data_reg[5];
		6: sel_block = data_reg[6];
		7: sel_block = data_reg[7];
		8: sel_block = data_reg[8];
		9: sel_block = data_reg[9];
		10:sel_block = data_reg[10];
		11:sel_block = data_reg[11];
		12:sel_block = data_reg[12];
		13:sel_block = data_reg[13];
		14:sel_block = data_reg[14];
		15:sel_block = data_reg[15];
		16:sel_block = data_reg[16];
		17:sel_block = data_reg[17]; // thật ra chỉ chọn tối đa được đến đây... mấy cái sau để phòng ngừa tránh lỗi thôi
		18:sel_block = data_reg[18];
		19:sel_block = data_reg[19];
		20:sel_block = data_reg[20];
		21:sel_block = data_reg[21];
		22:sel_block = data_reg[22];
		23:sel_block = data_reg[23];
		24:sel_block = data_reg[24];
		default: sel_block = 0;
	endcase
end

// data_reg đọc dữ liệu xor vào và pad dữ liệu
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin // reset 25 thanh ghi ve 0
		for(i=0;i<25;i=i+1)begin
			data_reg[i]<=0;
		end
	end
	else if(state_ns==IDLE)begin // idle o trang thai rỗi nên cũng reset
		for(i=0;i<25;i=i+1)begin
			data_reg[i]<=0;
		end
	end
	else if(state_ns==RD)begin
		data_reg[counter]<=data_reg[counter] ^ in_data; // reg = 64 bit, data_reg la loai du lieu dùng để trộn trong keccak
		// trong một lần nạp dữ liệu vô keccak sẽ nạp 17 word, và xor 17 lần vô 17 thanh ghi đầu của data reg, 
	end
	else if(state_ns==PAD_OP1)begin
		if(len_reg==135)begin//136 byte
			data_reg[len_reg[7:3]] <= sel_block ^ 64'h8600000000000000;
		end
		else if(len_reg==134)begin
			data_reg[len_reg[7:3]] <= sel_block ^ 64'h8006000000000000;
		end
		else begin 

			// hành động padding
			case(len_reg[2:0])
				0:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0000000000000006;
				1:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0000000000000600;
				2:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0000000000060000;
				3:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0000000006000000;
				4:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0000000600000000;
				5:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0000060000000000;
				6:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0006000000000000;
				7:data_reg[len_reg[7:3]]<= sel_block ^ 64'h0600000000000000;
			endcase
		end
	end
	else if(state_ns==PAD_OP2 && !(len_reg ==135 || len_reg ==134) )begin
		data_reg[16]<= data_reg[16] ^ 64'h8000000000000000;
	end	
	else if(state_cs== KC1_THETA || state_cs==KC2_THETA)begin
		data_reg[0] <= theta_out_data_0;
		data_reg[1] <= theta_out_data_1;
		data_reg[2] <= theta_out_data_2;
		data_reg[3] <= theta_out_data_3;
		data_reg[4] <= theta_out_data_4;
		data_reg[5] <= theta_out_data_5;
		data_reg[6] <= theta_out_data_6;
		data_reg[7] <= theta_out_data_7;
		data_reg[8] <= theta_out_data_8;
		data_reg[9] <= theta_out_data_9;
		data_reg[10] <= theta_out_data_10;
		data_reg[11] <= theta_out_data_11;
		data_reg[12] <= theta_out_data_12;
		data_reg[13] <= theta_out_data_13;
		data_reg[14] <= theta_out_data_14;
		data_reg[15] <= theta_out_data_15;
		data_reg[16] <= theta_out_data_16;
		data_reg[17] <= theta_out_data_17;
		data_reg[18] <= theta_out_data_18;
		data_reg[19] <= theta_out_data_19;
		data_reg[20] <= theta_out_data_20;
		data_reg[21] <= theta_out_data_21;
		data_reg[22] <= theta_out_data_22;
		data_reg[23] <= theta_out_data_23;
		data_reg[24] <= theta_out_data_24;
	end
		else if(state_cs== KC1_RHOPI || state_cs==KC2_RHOPI)begin
		data_reg[0] <= rhopi_out_data_0;
		data_reg[1] <= rhopi_out_data_1;
		data_reg[2] <= rhopi_out_data_2;
		data_reg[3] <= rhopi_out_data_3;
		data_reg[4] <= rhopi_out_data_4;
		data_reg[5] <= rhopi_out_data_5;
		data_reg[6] <= rhopi_out_data_6;
		data_reg[7] <= rhopi_out_data_7;
		data_reg[8] <= rhopi_out_data_8;
		data_reg[9] <= rhopi_out_data_9;
		data_reg[10] <= rhopi_out_data_10;
		data_reg[11] <= rhopi_out_data_11;
		data_reg[12] <= rhopi_out_data_12;
		data_reg[13] <= rhopi_out_data_13;
		data_reg[14] <= rhopi_out_data_14;
		data_reg[15] <= rhopi_out_data_15;
		data_reg[16] <= rhopi_out_data_16;
		data_reg[17] <= rhopi_out_data_17;
		data_reg[18] <= rhopi_out_data_18;
		data_reg[19] <= rhopi_out_data_19;
		data_reg[20] <= rhopi_out_data_20;
		data_reg[21] <= rhopi_out_data_21;
		data_reg[22] <= rhopi_out_data_22;
		data_reg[23] <= rhopi_out_data_23;
		data_reg[24] <= rhopi_out_data_24;
	end
	else if(state_cs== KC1_CHI || state_cs==KC2_CHI)begin
		data_reg[0] <= chi_out_data_0;
		data_reg[1] <= chi_out_data_1;
		data_reg[2] <= chi_out_data_2;
		data_reg[3] <= chi_out_data_3;
		data_reg[4] <= chi_out_data_4;
		data_reg[5] <= chi_out_data_5;
		data_reg[6] <= chi_out_data_6;
		data_reg[7] <= chi_out_data_7;
		data_reg[8] <= chi_out_data_8;
		data_reg[9] <= chi_out_data_9;
		data_reg[10] <= chi_out_data_10;
		data_reg[11] <= chi_out_data_11;
		data_reg[12] <= chi_out_data_12;
		data_reg[13] <= chi_out_data_13;
		data_reg[14] <= chi_out_data_14;
		data_reg[15] <= chi_out_data_15;
		data_reg[16] <= chi_out_data_16;
		data_reg[17] <= chi_out_data_17;
		data_reg[18] <= chi_out_data_18;
		data_reg[19] <= chi_out_data_19;
		data_reg[20] <= chi_out_data_20;
		data_reg[21] <= chi_out_data_21;
		data_reg[22] <= chi_out_data_22;
		data_reg[23] <= chi_out_data_23;
		data_reg[24] <= chi_out_data_24;
	end
	else if(state_cs== KC1_IOTA|| state_cs==KC2_IOTA)begin
		data_reg[0] <= iota_out_data_0;

	end

end


// out_valid
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		out_valid<=0;
	else if(state_ns==IDLE)
		out_valid<=0;
	else if(state_ns==DONE)
		out_valid<=1;
end
//out_data
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		out_data<=0;
	else if(state_ns==IDLE)
		out_data<=0;
	else if(state_ns==DONE)
		out_data<=data_reg[counter];
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		out_buffer_full<=0;
	else if(state_ns==IDLE)
		out_buffer_full<=0;
	else if(state_ns==IDLE2 && counter==17)
		out_buffer_full<=1;
	else if(state_cs==KC1_IOTA && state_ns==IDLE4) //kc_out_valid
		out_buffer_full<=0;
end


endmodule
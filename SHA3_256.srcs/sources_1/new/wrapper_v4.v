`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2025 12:10:31
// Design Name: 
// Module Name: wrapper_v4
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


module wrapper_v4(
clk,
 rst_n,
 in_ready,
 in_valid,
 in_data,
 in_done,
 out_ready,
 out_valid,
 out_data,
 busy
    );
    // ===============================================================
// Input & Output Declaration
// ===============================================================
input 			clk;
input 			rst_n;
input 			in_valid;
input			out_ready;
input 	[31:0]  	in_data;
input 			in_done;
output	reg		in_ready;
output 	reg		out_valid;
output 	reg [31:0]	out_data;
output 			busy;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
integer i;

localparam IDLE 	= 4'd0;
localparam RD		= 4'd1;
localparam RD_WAIT	= 4'd2;
localparam IDLE2	= 4'd3;
localparam SHA3_INPUT 	= 4'd4;
localparam SHA3_WAIT  	= 4'd5;
localparam SHA3_DONE 	= 4'd6;
localparam IDLE3	= 4'd7;
localparam DONE		= 4'd8;
localparam DONE_WAIT	= 4'd9;
//================================================================
// Wire & Reg Declaration
//================================================================

reg [3:0] state_cs,state_ns;

reg [63:0] data_reg;
reg [63:0] out_data_reg[0:3];
reg in_done_reg;
reg [5:0]counter;
//sha3 signal
reg [63:0] 	sha3_in_data;
reg 		sha3_in_valid;
wire 		sha3_in_isLast;
wire 		sha3_out_valid;
wire [63:0]	sha3_out_data;
wire 		sha3_out_buffer_full;

reg [31:0] input_buffer;

//================================================================
// SUB MODULE
//================================================================
SHA3_v2 u_SHA3_v2(
	.clk(clk),
	.rst_n(rst_n),
	.in_valid(sha3_in_valid),
	.in_data(sha3_in_data),
	.in_isLast(sha3_in_isLast),
	.out_valid(sha3_out_valid),
	.out_data(sha3_out_data),
	.out_buffer_full(sha3_out_buffer_full)
);

always@(*)begin //Phong
    if(in_valid && counter[0])
		sha3_in_valid = 1;
	else if(in_done && !counter[0])
        sha3_in_valid = 1;	
	// Kích hoạt khi ở RD_WAIT, thấy in_done, VÀ counter[0] LÀ 1
	// (nghĩa là đã có 1 word 32-bit trong buffer)
	else if (state_cs == RD_WAIT && in_done && counter[0])
		sha3_in_valid = 1;
	else if(state_cs==SHA3_INPUT)
		sha3_in_valid = 1;
	else 
		sha3_in_valid = 0;
end

always@(*)begin 
    if(in_valid && counter[0])
		sha3_in_data = {in_data, input_buffer};
	// gửi word trong buffer (với 32 bit 0) khi counter[0] LÀ 1
//	else if(in_valid && in_done && !counter[0])
//        sha3_in_data = {32'h0, in_data};
    else if(in_done && !counter[0])
        sha3_in_data = {32'h0, in_data  };
	else if (state_cs == RD_WAIT && in_done && counter[0]) // <--- Sửa !counter[0] thành counter[0]
		sha3_in_data = {32'h0, input_buffer};
	else
		sha3_in_data = 0;
end

assign sha3_in_isLast = in_done;
//================================================================
// DESIGN
//================================================================

//assign in_ready = state_cs == IDLE;
assign busy = state_cs!=IDLE;
//assign out_valid = sha3_out_valid;
//FSM 
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<=IDLE;
	else
		state_cs<=state_ns;
end



always@(*)begin
	case(state_cs)
		IDLE:		state_ns = (in_valid)? RD : IDLE;
		RD:		begin
					if(counter==34)
						state_ns = IDLE2;
					else
						state_ns = RD_WAIT;
				end
		RD_WAIT:	begin  //Phong
//					if(in_done)
//						state_ns = IDLE2;
//					else if(in_valid)
//						state_ns = RD;
//					else
//						state_ns = RD_WAIT;
            if(in_valid)
				state_ns = RD;
			else if(in_done)
				state_ns = IDLE2;
			else
				state_ns = RD_WAIT;
				end
		IDLE2:		state_ns = SHA3_WAIT;
		//SHA3_INPUT:	state_ns =  (counter==17)? SHA3_WAIT : SHA3_INPUT;//handle the case input < 17
		//SHA3_WAIT:	state_ns = (sha3_out_valid)? SHA3_DONE: SHA3_WAIT;
		SHA3_WAIT:	begin
					if(!sha3_out_buffer_full && !in_done_reg)
						state_ns = RD_WAIT;
					else if(sha3_out_valid)
						state_ns = SHA3_DONE;
					else
						state_ns = SHA3_WAIT;
				end
		SHA3_DONE:	state_ns = (!sha3_out_valid)? IDLE3: SHA3_DONE; //obtain all output data save in out_data_reg[0] ~ out_data_reg[3]
		IDLE3:		state_ns = DONE_WAIT;
		DONE:		begin
					if(counter==8)
						state_ns = IDLE;
					else
						state_ns = DONE_WAIT;
				end
		DONE_WAIT:	state_ns = (out_ready)? DONE: DONE_WAIT; 
		default:	state_ns = state_cs;
	endcase
end

//counter
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		counter<=0;
	else if(state_ns==IDLE || state_ns==IDLE3 || state_ns==IDLE2)
		counter<=0;
	else if(state_ns==SHA3_INPUT || state_ns==RD || state_ns==SHA3_DONE || state_ns==DONE)
		counter<=counter+1;
end


// in_done_reg
// cant ensure in_done be active forever using register to keep it while in_valid
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		in_done_reg<=0;
	end
	else if(state_ns==IDLE)
		in_done_reg<=0;
	else if(state_ns==IDLE2)
		in_done_reg<=in_done;
end

always@(*)begin
	if(state_cs==DONE || state_cs==DONE_WAIT)
		out_valid = 1;
	else 
		out_valid = 0;
end

// in_ready
always@(*)begin
	if(state_cs==IDLE || state_cs==RD_WAIT)
		in_ready = 1;
	else
		in_ready = 0;

end

// data_reg // direct connect
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		data_reg<=0;
	end
end

// input_buffer
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		input_buffer<=0;
	else if(in_valid && !counter[0])
		input_buffer <= in_data;
end

// out_data_reg
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(i=0;i<4;i=i+1)begin
			out_data_reg[i]<=0;
		end
	end
	else if(state_ns==IDLE)begin
		for(i=0;i<4;i=i+1)begin
			out_data_reg[i]<=0;
		end
	end
	else if(state_ns==SHA3_DONE)begin
		out_data_reg[counter]<=sha3_out_data;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		out_data<=0;
	else if(state_ns==IDLE)
		out_data<=0;
	else if(state_ns==DONE || state_ns==DONE_WAIT)
		out_data<= (counter[0]==0) ? out_data_reg[counter>>1][31:0] : out_data_reg[counter>>1][63:32];
end
endmodule
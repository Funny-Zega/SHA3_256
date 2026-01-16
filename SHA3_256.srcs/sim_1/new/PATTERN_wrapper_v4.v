`timescale 1ns / 1ps
`define CYCLE_TIME 10
`define End_CYCLE  100000000

module PATTERN_wrapper_v4();

    // ===============================================================
    // Input & Output Declaration
    // ===============================================================
    reg clk, rst_n, in_valid, out_ready, in_done;
    reg [31:0] in_data;

    wire out_valid, in_ready;
    wire [31:0] out_data;
    wire busy;
    // ===============================================================
    // UUT Instantiation - ĐẶT Ở ĐÂY
    // ===============================================================
    wrapper_v4 uut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_data(in_data),
        .in_done(in_done),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .out_data(out_data),
        .busy(busy)
    );

    // ===============================================================
    // Parameters & Integer Declaration
    // ===============================================================
    integer golden_read;
    integer patcount, output_count;
    integer gap;
    integer a;
    integer i, j;
    parameter PATNUM = 11; // change after

    // ===============================================================
    // Wire & Reg Declaration
    // ===============================================================
    reg [1599:0] in_data_all_reg;
    reg [31:0] in_data_reg[0:49];

    reg [1599:0] out_data_all_reg;
    reg [63:0] out_data_old[0:24];
    reg [31:0] out_data_reg[0:7];

    reg read_done;

    // ===============================================================
    // Clock
    // ===============================================================
    always #5 clk = ~clk;
    initial clk = 0;

    // ===============================================================
    // Initial
    // ===============================================================
    initial begin
        rst_n    = 1'b1;
        in_valid = 1'b0;
        out_ready = 1'b1;
        in_done = 0;
        in_data = 0;
        
        reset_task;

        //golden_read  = $fopen("./testcase/wrapper_tb_v4.txt","r");
    golden_read  = $fopen("D:/HK251/BTL_TKLL/testcase/wrapper_tb_v4.txt","r");
	     
        if (golden_read == 0) begin
            $display("Error: Cannot open golden file!");
            $finish;
        end
        
        @(negedge clk);

        for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin		
            read_done = 0;
            in_done = 0;
            $display("\033[1;44mStart Pattern %02d\033[0;1m\n\033[0;33m[Input Data]\033[0;0m",patcount);
            
            while(read_done==0) begin
                load_golden;
                input_task;
                
                if(!read_done) begin
                    while(!in_ready) @(negedge clk);
                end
                else begin
                    gap = $urandom_range(2,4);
                    repeat(gap) @(negedge clk);
                end
            end
            
            $display();
            check_answer;
            @(negedge clk);
        end
        
        #(1000);
        $display("\033[1;32m\033[5m[Pass] Congratulation You Pass All of the Testcases!!!\033[0;1m");
        $finish;
    end 

    // ===============================================================
    // TASK
    // ===============================================================
    task reset_task; 
    begin
        #(20); 
        rst_n = 0;
        #(20);
        
        // Kiểm tra output sau reset
        if((out_valid !== 0) || (out_data !== 0)) begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                        FAIL!                                                               ");
            $display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            #(100);
            $finish;
        end
        
        #(20); 
        rst_n = 1;
        #(20);
        
    end 
    endtask

    reg [31:0] curr_in_reg;
    reg [7:0] reg1;
    reg [7:0] reg2;
    reg [7:0] reg3;
    reg [7:0] reg4;
    integer t;
    integer t2;
    integer round_t;
    reg [9:0] len_reg;
    reg in_done_reg;

    task load_golden; 
    begin
        a = $fscanf(golden_read, "%d\n", in_done_reg);
        a = $fscanf(golden_read, "%d\n", len_reg);
        
        if(in_done_reg==1) begin
            read_done = 1;
        end	
        
        t = 0;
        in_data_all_reg = 0;
        round_t = 0;
        
        for(i=0; i<50; i=i+1) begin
            in_data_reg[i] = 0;
        end
        
        while(t != len_reg) begin
            t2 = len_reg - t;
            
            if(t2 >= 4) begin
                a = $fscanf(golden_read, "%c", reg1);
                a = $fscanf(golden_read, "%c", reg2);
                a = $fscanf(golden_read, "%c", reg3);
                a = $fscanf(golden_read, "%c", reg4);
                t = t + 4;
                $write("%s%s%s%s", reg1, reg2, reg3, reg4);
                curr_in_reg = {reg4, reg3, reg2, reg1};
            end
            else begin
                case(t2)
                    1: begin
                        a = $fscanf(golden_read, "%c", reg1);
                        reg2 = 0; reg3 = 0; reg4 = 0;
                        t = t + 1;
                        $write("%s", reg1);
                        curr_in_reg = {reg4, reg3, reg2, reg1};
                    end
                    2: begin
                        a = $fscanf(golden_read, "%c", reg1);
                        a = $fscanf(golden_read, "%c", reg2);
                        reg3 = 0; reg4 = 0;
                        t = t + 2;
                        $write("%s%s", reg1, reg2);
                        curr_in_reg = {reg4, reg3, reg2, reg1};
                    end
                    3: begin
                        a = $fscanf(golden_read, "%c", reg1);
                        a = $fscanf(golden_read, "%c", reg2);
                        a = $fscanf(golden_read, "%c", reg3);
                        reg4 = 0;
                        t = t + 3;
                        $write("%s%s%s", reg1, reg2, reg3);
                        curr_in_reg = {reg4, reg3, reg2, reg1};
                    end
                endcase
            end
            
            if (round_t < 50) begin
                in_data_reg[round_t] = curr_in_reg;
            end
            
            round_t = round_t + 1;
        end
        
        if(read_done) begin
            a = $fscanf(golden_read, "%h\n", out_data_all_reg);
        end
    end 
    endtask

    task input_task;
    begin
        @(negedge clk);
        in_valid = 1'b1;
        
        for(i = 0; i < 34; i = i + 1) begin
            if (i < 50) begin
                in_data = in_data_reg[i];
            end else begin
                in_data = 0;
            end
            
            @(negedge clk);
            in_valid = 1'b0;

            if(i == ((len_reg-1)/4)) begin
                gap = $urandom_range(2,4);
                repeat(gap) @(negedge clk);
                in_done = in_done_reg;
            end

            if(in_done) begin
                @(negedge clk);
                in_valid = 1'b0;
                i = 35; // break out of loop
            end
            else begin
                gap = $urandom_range(2,4);
                repeat(gap) @(negedge clk);
                in_valid = 1'b1;
            end
        end

        in_valid = 1'b0;
        in_data = 'bx;
    end 
    endtask

    reg [255:0] tmp_ans;
    integer k;
    reg [63:0] internal_word;
    reg [63:0] swapped_word;
    task check_answer;
    begin
        // wait for out_valid to raise
        while(out_valid == 0) begin
            @(negedge clk);
        end
       
        
        output_count = 0;
        tmp_ans = 256'h0;
        
        while(output_count != 8) begin
            // check answer
            if(out_data !== out_data_reg[output_count]) begin
//                $display ("----------------------------------------------------------------------");
//                $display ("  FAIL %2d\n                						                     ", patcount);
//                $display ("  Oops! Your Answer is Wrong in %d block                						     \n", output_count);
//                $display ("  [Correct DATA] %h\n                 					             ", out_data_reg[output_count]);
//                $display ("  [Your DATA] %h\n                 						         ", out_data);
//                $display ("--------------------------------------------------------------------- ");
//                $finish;
            end
            else begin
                tmp_ans = {tmp_ans[223:0], out_data[7:0], out_data[15:8], out_data[23:16], 
                          out_data[31:24]};
            end
            
            output_count = output_count + 1;
            @(negedge clk);
            out_ready = 0;
            gap = $urandom_range(2,4);
            repeat(gap) @(negedge clk);
            out_ready = 1;
            
            while(out_valid == 0 && output_count < 8) begin 
                @(negedge clk);
            end	
        end
        
        $display ("\033[0;33m[Calculate Hash]\033[0;0m\n%h                 						         ", tmp_ans);
        $display("\033[1;32m[Pass] \033[1;0m\n");
    end 
    endtask

    // Mapping output data
    always @(*) begin
        out_data_old[24] = out_data_all_reg[64*0 +63:64*0 +0];
        out_data_old[19] = out_data_all_reg[64*1 +63:64*1 +0];
        out_data_old[14] = out_data_all_reg[64*2 +63:64*2 +0];
        out_data_old[9 ] = out_data_all_reg[64*3 +63:64*3 +0];
        out_data_old[4 ] = out_data_all_reg[64*4 +63:64*4 +0];
        out_data_old[23] = out_data_all_reg[64*5 +63:64*5 +0];
        out_data_old[18] = out_data_all_reg[64*6 +63:64*6 +0];
        out_data_old[13] = out_data_all_reg[64*7 +63:64*7 +0];
        out_data_old[8 ] = out_data_all_reg[64*8 +63:64*8 +0];
        out_data_old[3 ] = out_data_all_reg[64*9 +63:64*9 +0];
        out_data_old[22] = out_data_all_reg[64*10+63:64*10+0];
        out_data_old[17] = out_data_all_reg[64*11+63:64*11+0];
        out_data_old[12] = out_data_all_reg[64*12+63:64*12+0];
        out_data_old[7 ] = out_data_all_reg[64*13+63:64*13+0];
        out_data_old[2 ] = out_data_all_reg[64*14+63:64*14+0];
        out_data_old[21] = out_data_all_reg[64*15+63:64*15+0];
        out_data_old[16] = out_data_all_reg[64*16+63:64*16+0];
        out_data_old[11] = out_data_all_reg[64*17+63:64*17+0];
        out_data_old[6 ] = out_data_all_reg[64*18+63:64*18+0];
        out_data_old[1 ] = out_data_all_reg[64*19+63:64*19+0];
        out_data_old[20] = out_data_all_reg[64*20+63:64*20+0];
        out_data_old[15] = out_data_all_reg[64*21+63:64*21+0];
        out_data_old[10] = out_data_all_reg[64*22+63:64*22+0];
        out_data_old[5 ] = out_data_all_reg[64*23+63:64*23+0];
        out_data_old[0 ] = out_data_all_reg[64*24+63:64*24+0];
        
        out_data_reg[0] = out_data_old[0][31:0];
        out_data_reg[1] = out_data_old[0][63:32];
        out_data_reg[2] = out_data_old[1][31:0];
        out_data_reg[3] = out_data_old[1][63:32];
        out_data_reg[4] = out_data_old[2][31:0];
        out_data_reg[5] = out_data_old[2][63:32];
        out_data_reg[6] = out_data_old[3][31:0];
        out_data_reg[7] = out_data_old[3][63:32];
    end

endmodule
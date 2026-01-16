`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/10/2026 02:20:56 PM
// Design Name: 
// Module Name: tb_top_system_v3
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
module tb_top_system_v3;

    // ============================================================
    // 1. CẤU HÌNH
    // ============================================================
    parameter CLK_FREQ = 125_000_000; 
    parameter BAUD     = 1_562_500;   
//    parameter BAUD     = 115200;
    localparam BIT_PERIOD = 1_000_000_000 / BAUD;

    // ============================================================
    // 2. TÍN HIỆU
    // ============================================================
    reg clk;
    reg rst_btn;
    reg uart_rx_i;
    wire uart_tx_o;

    // Biến hỗ trợ tạo chuỗi dài
    reg [8*256-1:0] long_str_135;
    reg [8*256-1:0] long_str_136;
    reg [8*256-1:0] long_str_137;
    integer j;

    // ============================================================
    // 3. DUT
    // ============================================================
    top_system #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) u_top (
        .clk(clk), .rst_btn(rst_btn), .uart_rx_i(uart_rx_i), .uart_tx_o(uart_tx_o)
    );

    // ============================================================
    // 4. CLOCK
    // ============================================================
    initial begin
        clk = 0; forever #4 clk = ~clk;
    end

    // ============================================================
    // 5. TEST SCENARIOS
    // ============================================================
    initial begin
        // --- CHUẨN BỊ DỮ LIỆU TEST ---
        // Tạo chuỗi 135 ký tự 'a'
        for(j=0; j<135; j=j+1) long_str_135[j*8 +: 8] = "a";
        
        // Tạo chuỗi 136 ký tự 'a'
        for(j=0; j<136; j=j+1) long_str_136[j*8 +: 8] = "a";
        
        // Tạo chuỗi 137 ký tự 'a'
        for(j=0; j<137; j=j+1) long_str_137[j*8 +: 8] = "a";

        // --- RESET ---
        rst_btn = 1; uart_rx_i = 1; #200;
        rst_btn = 0; #200;
        
        $display("\n=======================================================");
        $display("          STRESS TEST SHA3-256 (BOUNDARY CHECK)");
        $display("=======================================================\n");

        // CASE 1-4: Các case cơ bản (Giữ nguyên để regression test)
        run_test_case(1, "EMPTY STRING", "", 0, 256'ha7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a);
        run_test_case(2, "NIST 'abc'", "abc", 3, 256'h3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532);
        run_test_case(3, "STRING 'hello'", "hello", 5, 256'h3338be694f50c5f338814986cdf0686453a888b84f424d792af4b9202398f392);
        run_test_case(4, "LONG STRING (43 chars)", "The quick brown fox jumps over the lazy dog", 43, 256'h69070dda01975c8c120c3aada1b282394e7f032fa9cf32f4cb2259a0897dfc04);

        // CASE 5: 135 chars (Block Size - 1)
        // Hash: 0c63a75b845e4f7d01107d852e4c24386a203775c77053e34a726791334c4146
        run_test_case(5, "BOUNDARY - 1 (135 'a')", long_str_135, 135, 
                      256'h0c63a75b845e4f7d01107d852e4c24386a203775c77053e34a726791334c4146);

        // CASE 6: 136 chars (Exact Block Size)
        // Hash: b3876932a39316499696226e116035091732f72a91262f556950275244321633
        run_test_case(6, "EXACT BOUNDARY (136 'a')", long_str_136, 136, 
                      256'hb3876932a39316499696226e116035091732f72a91262f556950275244321633);

        // CASE 7: 137 chars (Block Size + 1) -> Phải xử lý 2 Block
        // Hash: 9cacc66133993d0c242e7d7d3d3a81745d625505546e09e25712c75a6c37e96a
        run_test_case(7, "BOUNDARY + 1 (137 'a')", long_str_137, 137, 
                      256'h9cacc66133993d0c242e7d7d3d3a81745d625505546e09e25712c75a6c37e96a);

        $display("\n=======================================================");
        $display("          CHÚC MỪNG! HỆ THỐNG ĐÃ QUA MỌI BÀI TEST");
        $display("=======================================================");
        $finish;
    end

    // ============================================================
    // TASK: TEST ENGINE (Đã nâng cấp buffer lên 256 bytes)
    // ============================================================
    task run_test_case;
        input integer case_num;
        input [255:0] case_name; 
        input [8*256-1:0] str_data; 
        input integer str_len;
        input [255:0] expected_hash;
        
        reg [255:0] received_hash;
        reg [7:0] temp_byte;
        integer i;
        begin
            $display("-------------------------------------------------------");
            $display("TEST CASE %0d: %0s", case_num, case_name);
            $display("-> Input Length: %0d chars", str_len);

            // Gửi chuỗi
            if (str_len > 0) begin
                for (i = 0; i < str_len; i = i + 1) begin
                    // --- SỬA LẠI DÒNG NÀY (Dùng logic của V2) ---
                    // Lấy byte từ MSB xuống LSB để đúng thứ tự chuỗi "abc"
                    temp_byte = str_data[(str_len - 1 - i) * 8 +: 8];
                    
                    uart_send_byte(temp_byte);
                    
                    // Delay nhỏ (giữ nguyên logic nhanh của V3)
                    #(BIT_PERIOD * 20); 
                end
            end

            $display("-> Sending ENTER...");
            uart_send_byte(8'h0A); 

            $display("-> Waiting for Result...");
            for (i = 0; i < 32; i = i + 1) begin
                uart_recv_byte(temp_byte);
                received_hash[(31 - i) * 8 +: 8] = temp_byte;
            end

            if (received_hash == expected_hash) begin
                $display("Result: [ PASS ] \033[1;32mOK\033[0m");
            end else begin
                $display("Result: [ FAIL ] X");
                $display("   Got: %h", received_hash);
                $display("   Exp: %h", expected_hash);
                $stop; 
            end
            #1000;
        end
    endtask

    // UART PHY TASKS (Giữ nguyên)
    task uart_send_byte;
        input [7:0] data;
        integer k;
        begin
            uart_rx_i = 0; #(BIT_PERIOD);
            for (k = 0; k < 8; k = k + 1) begin
                uart_rx_i = data[k]; #(BIT_PERIOD);
            end
            uart_rx_i = 1; #(BIT_PERIOD);
        end
    endtask

    task uart_recv_byte;
        output [7:0] data;
        integer k, timeout;
        begin
            timeout = 0;
            while (uart_tx_o == 1 && timeout < 600000) begin // Tăng timeout cho chuỗi dài
                #(BIT_PERIOD/10); timeout = timeout + 1;
            end
            if (timeout >= 600000) begin
                 $display("[FAIL] Timeout!"); data = 8'hFF; 
            end else begin
                #(BIT_PERIOD / 2); #(BIT_PERIOD);
                for (k = 0; k < 8; k = k + 1) begin
                    data[k] = uart_tx_o; #(BIT_PERIOD);
                end
                wait(uart_tx_o == 1);
            end
        end
    endtask

endmodule
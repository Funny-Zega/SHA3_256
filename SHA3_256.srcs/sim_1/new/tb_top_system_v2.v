`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/10/2026 12:51:46 PM
// Design Name: 
// Module Name: tb_top_system_v2
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
module tb_top_system_v2;

    // ============================================================
    // 1. CẤU HÌNH
    // ============================================================
    parameter CLK_FREQ = 125_000_000; 
//    param?eter BAUD     = 1_562_500;   // Tốc độ "vàng" cho mô phỏng (125MHz / 80)?
    parameter BAUD     = 115200;
    localparam BIT_PERIOD = 1_000_000_000 / BAUD;

    // ============================================================
    // 2. TÍN HIỆU
    // ============================================================
    reg clk;
    reg rst_btn;
    reg uart_rx_i;
    wire uart_tx_o;

    // ============================================================
    // 3. KHỞI TẠO DUT (Device Under Test)
    // ============================================================
    top_system #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_top (
        .clk(clk),
        .rst_btn(rst_btn),
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(uart_tx_o)
    );

    // ============================================================
    // 4. CLOCK GENERATION
    // ============================================================
    initial begin
        clk = 0;
        forever #4 clk = ~clk; // 125MHz (8ns chu kỳ)
    end

    // ============================================================
    // 5. KỊCH BẢN KIỂM TRA (MAIN TEST)
    // ============================================================
    initial begin
        // --- Setup ban đầu ---
        rst_btn = 1;   // Đang reset
        uart_rx_i = 1; // Idle line
        #200;
        rst_btn = 0;   // Thả reset
        #200;
        
        $display("\n=======================================================");
        $display("          BẮT ĐẦU KIỂM TRA SHA3-256 TOÀN DIỆN");
        $display("=======================================================\n");

        // ----------------------------------------------------------------
        // CASE 1: CHUỖI RỖNG (Empty String)
        // ----------------------------------------------------------------
        run_test_case(
            1, "EMPTY STRING", 
            "", 0, 
            256'ha7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a
        );

        // ----------------------------------------------------------------
        // CASE 2: CHUỖI "abc" (Standard NIST)
        // ----------------------------------------------------------------
        run_test_case(
            2, "NIST 'abc'", 
            "abc", 3, 
            256'h3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532
        );

        // ----------------------------------------------------------------
        // CASE 3: CHUỖI "hello"
        // ----------------------------------------------------------------
        run_test_case(
            3, "STRING 'hello'", 
            "hello", 5, 
            256'h3338be694f50c5f338814986cdf0686453a888b84f424d792af4b9202398f392
        );

        // ----------------------------------------------------------------
        // CASE 4: CHUỖI DÀI
        // ----------------------------------------------------------------
        run_test_case(
            4, "LONG STRING (43 chars)", 
            "The quick brown fox jumps over the lazy dog", 43, 
            256'h69070dda01975c8c120c3aada1b282394e7f032fa9cf32f4cb2259a0897dfc04
        );

        $display("\n=======================================================");
        $display("          HOÀN THÀNH TẤT CẢ BÀI TEST");
        $display("=======================================================");
        $finish;
    end

    // ============================================================
    // TASK: TỰ ĐỘNG CHẠY VÀ KIỂM TRA (TEST ENGINE)
    // ============================================================
    task run_test_case;
        input integer case_num;
        input [255:0] case_name; 
        input [8*100-1:0] str_data; // Dữ liệu chuỗi (tối đa 100 ký tự)
        input integer str_len;      // Độ dài chuỗi
        input [255:0] expected_hash;
        
        reg [255:0] received_hash;
        reg [7:0] temp_byte;
        integer i;
        begin
            $display("-------------------------------------------------------");
            $display("TEST CASE %0d: %0s", case_num, case_name);
            
            // --- FIX LỖI Ở ĐÂY: In trực tiếp chuỗi, không cắt gọt ---
            if (str_len > 0)
                $display("-> Input: \"%0s\"", str_data);
            else
                $display("-> Input: (Empty)");

            // 1. Gửi chuỗi ký tự
            if (str_len > 0) begin
                for (i = 0; i < str_len; i = i + 1) begin
                    // Lấy từng byte từ phải qua trái (do cách Verilog lưu string)
                    // Part-select [base +: width] với width cố định là HỢP LỆ
                    temp_byte = str_data[(str_len - 1 - i) * 8 +: 8];
                    
                    uart_send_byte(temp_byte);
                    # (BIT_PERIOD * 2); 
                end
            end

            // 2. Gửi phím Enter (0x0A) để kích hoạt Hash
            $display("-> Sending ENTER to trigger...");
            uart_send_byte(8'h0A); 

            // 3. Nhận kết quả (32 bytes)
            $display("-> Waiting for Hash Result...");
            for (i = 0; i < 32; i = i + 1) begin
                uart_recv_byte(temp_byte);
                // Ghép byte (Byte 0 là cao nhất - Big Endian hiển thị)
                received_hash[(31 - i) * 8 +: 8] = temp_byte;
            end

            // 4. So sánh và báo cáo
            $display("-> Received Hash: %h", received_hash);
            // $display("-> Expected Hash: %h", expected_hash);

            if (received_hash == expected_hash) begin
                $display("Result: [ PASS ] \033[1;32mOK\033[0m"); // In chữ OK màu xanh (nếu terminal hỗ trợ)
            end else begin
                $display("Result: [ FAIL ] X");
                $display("Expected: %h", expected_hash);
                $display("ERROR: Hash mismatch!");
                $stop; 
            end
            
            #5000; // Nghỉ giữa các test case
        end
    endtask

    // ============================================================
    // UART PHY TASKS
    // ============================================================
    task uart_send_byte;
        input [7:0] data;
        integer k;
        begin
            uart_rx_i = 0; // Start Bit
            #(BIT_PERIOD);
            for (k = 0; k < 8; k = k + 1) begin
                uart_rx_i = data[k];
                #(BIT_PERIOD);
            end
            uart_rx_i = 1; // Stop Bit
            #(BIT_PERIOD);
        end
    endtask

    task uart_recv_byte;
        output [7:0] data;
        integer k;
        integer timeout;
        begin
            timeout = 0;
            // Chờ cạnh xuống (Start bit)
            while (uart_tx_o == 1 && timeout < 500000) begin 
                #(BIT_PERIOD/10);
                timeout = timeout + 1;
            end
            
            if (timeout >= 500000) begin
                 $display("[FAIL] Timeout waiting for TX byte!");
                 data = 8'hFF; 
            end else begin
                #(BIT_PERIOD / 2); // Vào giữa start bit
                #(BIT_PERIOD);     // Vào bit 0
                for (k = 0; k < 8; k = k + 1) begin
                    data[k] = uart_tx_o;
                    #(BIT_PERIOD);
                end
                wait(uart_tx_o == 1); // Chờ Stop bit xong
            end
        end
    endtask

endmodule
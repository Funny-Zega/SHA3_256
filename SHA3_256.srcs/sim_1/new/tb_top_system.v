`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/10/2026 12:08:02 AM
// Design Name: 
// Module Name: tb_top_system
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
module tb_top_system;

    // ============================================================
    // 1. CẤU HÌNH
    // ============================================================
    // Để mô phỏng nhanh hơn, ta có thể "ăn gian" bằng cách tăng BAUD
    // Nhưng để chắc chắn, ta giữ nguyên thông số thực tế.
    parameter CLK_FREQ = 125_000_000; // 125 MHz
    parameter BAUD     = 115200;      // 115200 bps
//    parameter BAUD     = 1_562_500;   
    // Tính toán thời gian 1 bit (dùng để delay trong testbench)
    localparam BIT_PERIOD = 1_000_000_000 / BAUD; // ns

    // ============================================================
    // 2. TÍN HIỆU
    // ============================================================
    reg clk;
    reg rst_btn;    // Nút reset (Active High trên Arty Z7)
    reg uart_rx_i;  // Đường PC gửi -> FPGA nhận
    wire uart_tx_o; // Đường FPGA gửi -> PC nhận

    // Biến hỗ trợ test
    reg [7:0] captured_data [0:31]; // Mảng lưu 32 byte kết quả
    integer i;

    // ============================================================
    // 3. INSTANTIATE (KẾT NỐI MODULE CHÍNH)
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
    // 4. TẠO CLOCK
    // ============================================================
    initial begin
        clk = 0;
        forever #4 clk = ~clk; // 125MHz -> chu kỳ 8ns -> nửa chu kỳ 4ns
    end

    // ============================================================
    // 5. CHƯƠNG TRÌNH KIỂM TRA
    // ============================================================
    initial begin
        $display("=================================================");
        $display("   STARTING SYSTEM SIMULATION (SHA3-256)         ");
        $display("=================================================");

        // --- A. Khởi tạo & Reset ---
        rst_btn = 1;     // Đang giữ nút Reset
        uart_rx_i = 1;   // Đường UART IDLE luôn mức cao
        
        #200;            // Giữ reset một lúc
        rst_btn = 0;     // Thả nút Reset
        #200;            // Chờ ổn định

        // --- B. Gửi dữ liệu đầu vào: "abc" + \n ---
//        $display("[PC] Sending input string: 'abc'...");
        
//        uart_send_byte(8'h61); // 'a'
//        #1000; // Nghỉ tí
//        uart_send_byte(8'h62); // 'b'
//        #1000;
//        uart_send_byte(8'h63); // 'c'
//        #1000;
// --- B. Gửi dữ liệu đầu vào: "Le Ngoc Uy Phong" + \n ---
$display("[PC] Sending input string: 'Le Ngoc Uy Phong'...");

uart_send_byte(8'h4C); // 'L'
#1000;
uart_send_byte(8'h65); // 'e'
#1000;
uart_send_byte(8'h20); // ' '
#1000;
uart_send_byte(8'h4E); // 'N'
#1000;
uart_send_byte(8'h67); // 'g'
#1000;
uart_send_byte(8'h6F); // 'o'
#1000;
uart_send_byte(8'h63); // 'c'
#1000;
uart_send_byte(8'h20); // ' '
#1000;
uart_send_byte(8'h55); // 'U'
#1000;
uart_send_byte(8'h79); // 'y'
#1000;
uart_send_byte(8'h20); // ' '
#1000;
uart_send_byte(8'h50); // 'P'
#1000;
uart_send_byte(8'h68); // 'h'
#1000;
uart_send_byte(8'h6F); // 'o'
#1000;
uart_send_byte(8'h6E); // 'n'
#1000;
uart_send_byte(8'h67); // 'g'
#1000;
uart_send_byte(8'h0A); // '\n'
#1000;
        
        $display("[PC] Sending ENTER (0x0A) to trigger HASH...");
        uart_send_byte(8'h0A); // '\n' (Line Feed)

        // --- C. Chờ & Thu thập kết quả ---
        $display("[PC] Waiting for Hash Result (32 bytes)...");

        for (i = 0; i < 32; i = i + 1) begin
            uart_recv_byte(captured_data[i]);
            $display("   -> Byte %0d received: %h", i, captured_data[i]);
        end

        // --- D. Hiển thị kết quả cuối cùng ---
        $display("=================================================");
        $display("   HASH RESULT (HEX):");
        $write("   0x");
        for (i = 0; i < 32; i = i + 1) begin
            $write("%h", captured_data[i]);
            if (i == 15) $write("\n     "); // Xuống dòng cho đẹp
        end
        $write("\n");
        $display("=================================================");
        
        // So sánh sơ bộ (Optional manual check)
        $display("EXPECTED (Standard SHA3-256 'abc'):");
        $display("   3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532");

        #1000;
        $finish;
    end

    // ============================================================
    // 6. TASKS HỖ TRỢ (UART PHY MODEL)
    // ============================================================

    // Task: Giả lập PC gửi 1 byte xuống FPGA
    task uart_send_byte;
        input [7:0] data;
        integer k;
        begin
            // Start Bit (0)
            uart_rx_i = 0;
            #(BIT_PERIOD);
            
            // Data Bits (LSB First)
            for (k = 0; k < 8; k = k + 1) begin
                uart_rx_i = data[k];
                #(BIT_PERIOD);
            end
            
            // Stop Bit (1)
            uart_rx_i = 1;
            #(BIT_PERIOD);
        end
    endtask

    // Task: Giả lập PC nhận 1 byte từ FPGA
    task uart_recv_byte;
        output [7:0] data;
        integer k;
        integer timeout; // Thêm biến timeout
        begin
            timeout = 0;
            // Chờ cạnh xuống (Start bit) có giới hạn thời gian
            while (uart_tx_o == 1 && timeout < 100000) begin
                #(BIT_PERIOD/10);
                timeout = timeout + 1;
            end
            
            if (timeout >= 100000) begin
                 $display("[FAIL] Timeout waiting for TX byte!");
                 // Gán giá trị giả để không bị XX
                 data = 8'hFF; 
            end else begin
                // Có Start bit, đọc dữ liệu như bình thường
                #(BIT_PERIOD / 2); // Vào giữa start bit
                #(BIT_PERIOD);     // Vào bit 0
                for (k = 0; k < 8; k = k + 1) begin
                    data[k] = uart_tx_o;
                    #(BIT_PERIOD);
                end
                wait(uart_tx_o == 1);
            end
        end
    endtask

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/09/2026 07:00:58 PM
// Design Name: 
// Module Name: tb_uart
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
module tb_uart;

    // ============================================================
    // 1. CẤU HÌNH THAM SỐ (PARAMETERS)
    // ============================================================
    // Lưu ý: Để mô phỏng chạy nhanh hơn, bạn có thể giảm CLK_FREQ
    // hoặc tăng BAUD. Nhưng ở đây ta giữ nguyên để test đúng thực tế.
    parameter integer CLK_FREQ = 125_000_000; // 125 MHz
    parameter integer BAUD     = 115200;      // 115200 bps

    // ============================================================
    // 2. KHAI BÁO TÍN HIỆU
    // ============================================================
    reg clk;
    reg resetn;

    // --- Tín hiệu cho TX (Gửi) ---
    reg  [7:0] tx_data_in;
    reg        tx_valid_in;   // Master báo có dữ liệu
    wire       tx_ready_out;  // Slave (TX Module) báo rảnh
    wire       uart_line;     // Dây vật lý nối TX -> RX

    // --- Tín hiệu cho RX (Nhận) ---
    wire [7:0] rx_data_out;
    wire       rx_ready_out;  // RX Module báo có dữ liệu
    reg        rx_ack_in;     // Master (Testbench) báo đã đọc
    wire       err_frame;
    wire       err_overrun;

    // ============================================================
    // 3. TẠO CLOCK (125MHz -> Chu kỳ 8ns)
    // ============================================================
    initial begin
        clk = 0;
        forever #4 clk = ~clk; // Đảo trạng thái mỗi 4ns
    end

    // ============================================================
    // 4. KẾT NỐI MODULE (DUT - Design Under Test)
    // ============================================================
    
    // --- Module Gửi (Industrial Version) ---
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) inst_tx (
        .clk(clk),
        .resetn(resetn),
        .tx_data(tx_data_in),
        .tx_valid(tx_valid_in),  // Handshake Valid
        .tx_ready(tx_ready_out), // Handshake Ready
        .tx(uart_line)           // Output ra dây
    );

    // --- Module Nhận (Industrial Version with Oversampling) ---
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) inst_rx (
        .clk(clk),
        .resetn(resetn),
        .rx(uart_line),          // <--- LOOPBACK: Nối dây TX vào RX
        .rx_data(rx_data_out),
        .rx_ready(rx_ready_out),
        .rx_ack(rx_ack_in),
        .err_frame(err_frame),
        .err_overrun(err_overrun)
    );

    // ============================================================
    // 5. KỊCH BẢN TEST (TEST SCENARIO)
    // ============================================================
    initial begin
        // --- A. Khởi tạo ---
        $display("========================================");
        $display("   STARTING UART INDUSTRIAL TESTBENCH   ");
        $display("========================================");
        
        resetn = 0;
        tx_valid_in = 0;
        tx_data_in  = 0;
        rx_ack_in   = 0;
        
        #100; // Giữ Reset 100ns
        resetn = 1;
        #100; // Chờ hệ thống ổn định

        // --- B. Test Case 1: Gửi 1 Byte đơn lẻ (0x55) ---
        // 0x55 = 01010101 (Pattern dễ kiểm tra nhất)
        $display("[TIME %t] TEST CASE 1: Sending Single Byte 0x55...", $time);
        send_byte(8'h55);
        check_received_byte(8'h55);
        $display("[PASS] Test Case 1 Completed.");

        #2000; // Nghỉ một chút giữa các lần gửi

        // --- C. Test Case 2: Gửi Byte bất kỳ (0xA3) ---
        $display("[TIME %t] TEST CASE 2: Sending Random Byte 0xA3...", $time);
        send_byte(8'hA3);
        check_received_byte(8'hA3);
        $display("[PASS] Test Case 2 Completed.");

        #2000;

        // --- D. Test Case 3: Stress Test (Gửi liên tục 2 Byte) ---
        // Test khả năng buffer và handshake nhanh
        $display("[TIME %t] TEST CASE 3: Stress Test (Back-to-Back)...", $time);
        
        // -- Gửi Byte 1 (0x12) --
        wait(tx_ready_out); // Chờ TX rảnh
        @(posedge clk);
        tx_data_in <= 8'h12;
        tx_valid_in <= 1;
        @(posedge clk);
        while (!tx_ready_out) @(posedge clk); // Chờ TX nhận (Ready hạ xuống)
        tx_valid_in <= 0;

        // -- Gửi Byte 2 (0x34) NGAY LẬP TỨC --
        wait(tx_ready_out);
        @(posedge clk);
        tx_data_in <= 8'h34;
        tx_valid_in <= 1;
        @(posedge clk);
        while (!tx_ready_out) @(posedge clk);
        tx_valid_in <= 0;

        $display("[INFO] Sent 0x12 and 0x34. Waiting for reception...");

        // -- Kiểm tra nhận (Phải đúng thứ tự) --
        check_received_byte(8'h12);
        check_received_byte(8'h34);
        
        $display("[PASS] Test Case 3 Completed.");
        
        // --- KẾT THÚC ---
        $display("========================================");
        $display("   ALL TESTS PASSED SUCCESSFULLY!       ");
        $display("========================================");
        $finish;
    end

    // ============================================================
    // 6. TASKS (HÀM HỖ TRỢ ĐỂ CODE GỌN HƠN)
    // ============================================================

    // --- Task gửi 1 byte (Mô phỏng giao thức AXI-Stream/FIFO) ---
    task send_byte;
        input [7:0] data;
        begin
            wait(tx_ready_out == 1); // 1. Chờ TX báo rảnh
            @(posedge clk);
            
            tx_data_in  <= data;     // 2. Đặt dữ liệu
            tx_valid_in <= 1;        // 3. Báo Valid
            
            // 4. Giữ Valid cho đến khi TX phản hồi (Ready hạ xuống 0)
            @(posedge clk);
            while (tx_ready_out == 1) @(posedge clk); 
            
            tx_valid_in <= 0;        // 5. Rút Valid về
        end
    endtask

    // --- Task kiểm tra dữ liệu nhận được ---
    task check_received_byte;
        input [7:0] expected;
        integer i; // Biến đếm timeout
        begin
            // 1. Chờ RX báo có dữ liệu (Timeout sau ~200us)
            // Thay vì dùng fork, ta dùng vòng lặp while để chờ
            i = 0;
            while (rx_ready_out == 0 && i < 20000) begin
                #10; // Chờ 10ns mỗi lần kiểm tra
                i = i + 1;
            end

            // Kiểm tra xem lý do thoát vòng lặp là gì?
            if (rx_ready_out == 0) begin
                $display("[FAIL] Timeout! RX did not receive data.");
                $stop;
            end

            // 2. So sánh dữ liệu
            if (rx_data_out === expected) begin
                $display("       -> [RX OK] Received: 0x%h", rx_data_out);
            end else begin
                $display("       -> [RX FAIL] Expected: 0x%h, Got: 0x%h", expected, rx_data_out);
                $stop;
            end
            
            // 3. Check lỗi phần cứng
            if (err_frame || err_overrun) begin
                 $display("       -> [RX FAIL] Hardware Error Detected (Frame/Overrun)!");
            end

            // 4. Gửi ACK để xác nhận đã đọc (Handshake)
            @(posedge clk);
            rx_ack_in <= 1;
            @(posedge clk);
            rx_ack_in <= 0;
            
            // 5. Chờ RX xóa cờ ready (đảm bảo không đọc trùng)
            wait(rx_ready_out == 0);
        end
    endtask
endmodule
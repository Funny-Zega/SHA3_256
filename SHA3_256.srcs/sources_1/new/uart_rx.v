module uart_rx #(
    parameter integer CLK_FREQ = 125_000_000,
    parameter integer BAUD     = 115200
)(
    input  wire        clk,
    input  wire        resetn,
    input  wire        rx,          //từ ngoài vào

    //Data
    output wire [7:0]  rx_data,     // Byte dữ liệu nhận được
    output wire        rx_ready,    // Có dữ liệu hợp lệ
    input  wire        rx_ack,      // Đã đọc xong

    output reg         err_frame,   // Lỗi khung (Stop bit != 1)
    output reg         err_overrun  // Lỗi tràn (CPU không đọc kịp)
);

    // oversampling 16 lan
    localparam integer BAUD_X16_VAL = CLK_FREQ / (BAUD * 16);
    
    reg [15:0] tick_cnt;
    wire       s_tick; // xung tick kích hoạt 16 lần trong 1 bit

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tick_cnt <= 0;
        end else begin
            if (tick_cnt >= BAUD_X16_VAL - 1) 
                tick_cnt <= 0;
            else 
                tick_cnt <= tick_cnt + 1;
        end
    end
    assign s_tick = (tick_cnt == BAUD_X16_VAL - 1);

    reg rx_sync0, rx_sync1;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end else begin
            rx_sync0 <= rx;
            rx_sync1 <= rx_sync0; 
        end
    end

    localparam [1:0] S_IDLE  = 2'b00;
    localparam [1:0] S_START = 2'b01;
    localparam [1:0] S_DATA  = 2'b10;
    localparam [1:0] S_STOP  = 2'b11;

    reg [1:0] state;
    reg [3:0] os_cnt;   // Oversampling Counter 0-15
    reg [2:0] n_bits;   // count bit
    reg [7:0] rx_shift;
    
    reg [1:0] vote_sum; //3 time sampling
    reg       final_bit; // Kết quả cuối cùng (0 hoặc 1)

    reg [7:0] buf0, buf1;
    reg       buf0_valid, buf1_valid;
    reg       rx_ready_r;

    assign rx_data  = buf0;
    assign rx_ready = rx_ready_r;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state       <= S_IDLE;
            os_cnt      <= 0;
            n_bits      <= 0;
            rx_shift    <= 0;
            err_frame   <= 0;
            err_overrun <= 0;
            
            buf0        <= 0;
            buf1        <= 0;
            buf0_valid  <= 0;
            buf1_valid  <= 0;
            rx_ready_r  <= 0;
        end else begin
            if (rx_ack && buf0_valid) begin
                if (buf1_valid) begin
                    buf0       <= buf1;
                    buf1_valid <= 0;
                    buf0_valid <= 1; 
                end else begin
                    buf0_valid <= 0;
                end
                err_overrun <= 0; 
            end
            
            case (state)
                S_IDLE: begin
                    if (rx_sync1 == 1'b0) begin // Phát hiện cạnh xuống
                        state  <= S_START;
                        os_cnt <= 0; // Reset bộ đếm lấy mẫu
                    end
                end
                S_START: begin
                    if (s_tick) begin                        
                        // Tại tick giữa (ví dụ 7), kiểm tra xem có đúng là Start Bit (0) không
                        if (os_cnt == 7 && rx_sync1 != 1'b0) begin
                            state <= S_IDLE; // Nhiễu 
                        end 
                        else if (os_cnt == 15) begin
                            state  <= S_DATA;
                            os_cnt <= 0;
                            n_bits <= 0;
                        end 
                        else begin
                            os_cnt <= os_cnt + 1;
                        end
                    end
                end
                S_DATA: begin
                    if (s_tick) begin
                        if (os_cnt < 15) 
                            os_cnt <= os_cnt + 1;
                        else 
                            os_cnt <= 0;
                        if (os_cnt == 7) vote_sum <= {1'b0, rx_sync1};      // Mẫu 1
                        if (os_cnt == 8) vote_sum <= vote_sum + rx_sync1;   // Mẫu 2
                        if (os_cnt == 9) begin
                            vote_sum <= vote_sum + rx_sync1;   // Mẫu 3
                            // Nếu tổng >= 2 thì là bit 1, ngược lại là 0
                        end
                        
                        // Tại cuối chu kỳ bit (Tick 15), lưu kết quả
                        if (os_cnt == 15) begin
                            rx_shift <= { (vote_sum >= 2), rx_shift[7:1] }; // Shift bit mới vào (LSB First)
                            
                            if (n_bits < 7) begin
                                n_bits <= n_bits + 1;
                            end else begin
                                state <= S_STOP;
                            end
                        end
                    end
                end

                S_STOP: begin
                    if (s_tick) begin
                        if (os_cnt < 15) 
                            os_cnt <= os_cnt + 1;
                        else begin
                            if (rx_sync1 == 1'b0) begin
                                err_frame <= 1'b1; // LỖI: Stop bit phải là 1
                            end else begin
                                err_frame <= 1'b0; // Khung truyền sạch
                            end

                            // Đẩy dữ liệu vào Double Buffer
                            if (!buf0_valid) begin
                                buf0       <= rx_shift;
                                buf0_valid <= 1;
                            end else if (!buf1_valid) begin
                                buf1       <= rx_shift;
                                buf1_valid <= 1;
                            end else begin
                                err_overrun <= 1'b1; // LỖI: Tràn bộ đệm (mất dữ liệu này)
                            end

                            state <= S_IDLE; 
                        end
                    end
                end
                
                default: state <= S_IDLE;
            endcase

            // Cập nhật tín hiệu rx_ready cho logic bên ngoài
            rx_ready_r <= buf0_valid;
        end
    end
endmodule
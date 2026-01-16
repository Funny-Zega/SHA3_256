`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2025 05:16:54 PM
// Design Name: 
// Module Name: bridge_uart_sha3
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
module bridge_uart_sha3 (
    input wire clk,
    input wire rst_n,

    // --- UART RX ---
    input wire [7:0] rx_data,
    input wire       rx_ready,
    output reg       rx_ack,

    // --- UART TX ---
    output reg [7:0] tx_data,
    output reg       tx_valid,
    input wire       tx_ready,

    // --- SHA3 Wrapper ---
    output reg [31:0] sha3_in_data,
    output reg        sha3_in_valid,
    output reg        sha3_in_done,
    input wire        sha3_in_ready,

    input wire [31:0] sha3_out_data,
    input wire        sha3_out_valid,
    output reg        sha3_out_ready
);

    // =================================================================
    // States
    // =================================================================
    localparam S_RX_IDLE        = 4'd0;
    localparam S_RX_WAIT        = 4'd1; 
    localparam S_SEND_FULL_WORD = 4'd2;
    localparam S_SEND_LAST_WORD = 4'd3;
    localparam S_WAIT_READY     = 4'd4;
    localparam S_HOLD_DONE      = 4'd5;
    localparam S_WAIT_HASH      = 4'd6;
    localparam S_TX_BYTE        = 4'd7;

    reg [3:0] state;
    
    // Buffers
    reg [31:0] in_buffer;
    reg [1:0]  in_byte_count;
    reg [31:0] out_buffer;
    reg [1:0]  out_byte_count;
    reg [3:0]  word_count;

    // =================================================================
    // Logic
    // =================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= S_RX_IDLE;
            rx_ack          <= 0;
            sha3_in_data    <= 0;
            sha3_in_valid   <= 0;
            sha3_in_done    <= 0;
            sha3_out_ready  <= 0;
            tx_valid        <= 0;
            tx_data         <= 0;
            in_buffer       <= 0;
            in_byte_count   <= 0;
            out_buffer      <= 0;
            out_byte_count  <= 0;
            word_count      <= 0; 
        end else begin
            
            // Default signals
            rx_ack        <= 0;

            case (state)
                    S_RX_IDLE: begin
                        sha3_out_ready <= 0;
                        sha3_in_done   <= 0;
                        sha3_in_valid  <= 0;
                        word_count     <= 0;
                        tx_valid       <= 0;
                        rx_ack         <= 0; // Luôn tắt Ack khi chờ
                    
                        if (rx_ready) begin
                            // Có dữ liệu mới! Xử lý ngay
                            rx_ack <= 1; // Bật Ack
                            
                            if (rx_data == 8'h0D || rx_data == 8'h0A) begin
                                 state <= S_SEND_LAST_WORD;
                            end
                            else begin
                                // Nạp vào Buffer (Logic xóa rác cũ)
                                case (in_byte_count)
                                    2'd0: in_buffer <= {24'd0, rx_data}; // Xóa sạch rác ở byte đầu
                                    2'd1: in_buffer[15:8]  <= rx_data;
                                    2'd2: in_buffer[23:16] <= rx_data;
                                    2'd3: in_buffer[31:24] <= rx_data;
                                endcase
                                
                                // Chuyển sang chờ UART nhả tín hiệu Ready
                                state <= S_RX_WAIT;
                            end
                        end
                    end
                    
                    // -----------------------------------------------------
                    // 1.5. TRẠNG THÁI CHỜ UART NHẢ READY (FIX DOUBLE READ)
                    // -----------------------------------------------------
                    S_RX_WAIT: begin
                        // Giữ Ack cho đến khi UART tắt Ready
                        if (rx_ready) begin
                            rx_ack <= 1; 
                        end
                        else begin
                            rx_ack <= 0; // UART đã tắt Ready -> Xong handshake
                            
                            // Bây giờ mới quyết định đi tiếp hay gửi đi
                            if (in_byte_count == 3) begin
                                state <= S_SEND_FULL_WORD; // Đủ 4 byte -> Gửi
                                in_byte_count <= 0;
                            end else begin
                                in_byte_count <= in_byte_count + 1; // Chưa đủ -> Tăng đếm
                                state <= S_RX_IDLE; // Quay lại chờ byte tiếp theo
                            end
                        end
                    end
                // -----------------------------------------------------
                // 2. GỬI DATA FULL
                // -----------------------------------------------------
                S_SEND_FULL_WORD: begin
                    if (sha3_in_ready) begin
                        sha3_in_data  <= in_buffer;
                        sha3_in_valid <= 1;
                        sha3_in_done  <= 0;
                        in_buffer     <= 0;
                        state         <= S_RX_IDLE;
                    end
                end

                // -----------------------------------------------------
                // 3. GỬI GÓI CUỐI (CRITICAL FIX)
                // -----------------------------------------------------
                S_SEND_LAST_WORD: begin
                    if (sha3_in_ready) begin
                    sha3_in_data  <= in_buffer;
                    sha3_in_valid <= 1; 
                    sha3_in_done  <= 1; 
                    
                    in_buffer     <= 0; 
                    in_byte_count <= 0;
                    state         <= S_HOLD_DONE;
                end
                end 
    
                S_HOLD_DONE: begin
                    sha3_in_valid <= 0;
                    sha3_in_done  <= 1; // Giữ Done
                    
                    // Dùng in_byte_count làm bộ đếm delay (đếm đến 2)
                    // Để đảm bảo Wrapper đã kịp chuyển sang trạng thái bận (Ready=0)
                    if (in_byte_count < 2) begin
                        in_byte_count <= in_byte_count + 1;
                    end 
                    else begin
                        // Sau khi đã delay đủ, mới bắt đầu kiểm tra Ready
                        if (sha3_in_ready == 1) begin 
                            state <= S_WAIT_HASH;
                            in_byte_count <= 0; // Reset lại cho lần sau
                        end
                    end
                end     

                // -----------------------------------------------------
                // 4. CHỜ KẾT QUẢ SHA3
                // -----------------------------------------------------
                S_WAIT_HASH: begin
                    sha3_in_valid  <= 0;
                    sha3_in_done   <= 0;
                    
                    // Logic mới: Tách biệt hoàn toàn việc BẬT và TẮT ready
                    if (sha3_out_ready == 0) begin
                        // Nhịp 1: Bật Ready lên
                        sha3_out_ready <= 1;
                    end
                    else begin
                        // Nhịp 2: Ready đã là 1 ở nhịp trước -> Wrapper chắc chắn đã thấy
                        // Bây giờ ta mới đọc dữ liệu và tắt Ready
                        if (sha3_out_valid) begin
                            out_buffer     <= sha3_out_data;
                            sha3_out_ready <= 0; // Tắt Ready (Ack)
                            out_byte_count <= 0;
                            state          <= S_TX_BYTE;
                        end
                    end
                end 
            
                // -----------------------------------------------------
                // 5. GỬI UART TX
                // -----------------------------------------------------
                S_TX_BYTE: begin
                    case (out_byte_count)
                        2'd0: tx_data <= out_buffer[7:0];
                        2'd1: tx_data <= out_buffer[15:8];
                        2'd2: tx_data <= out_buffer[23:16];
                        2'd3: tx_data <= out_buffer[31:24];
                    endcase
                    
                    // 2. Logic Handshake CHUẨN (Chỉ giữ lại 1 khối if-else này thôi)
                    if (tx_valid == 0) begin
                        tx_valid <= 1; // Bắt đầu gửi
                    end 
                    else if (tx_ready) begin 
                        tx_valid <= 0; // Xong, tắt valid
                        
                        // Logic chuyển byte tiếp theo
                        if (out_byte_count == 3) begin
                            if (word_count == 7) begin
                                state <= S_RX_IDLE;
                            end else begin
                                word_count <= word_count + 1;
                                state      <= S_WAIT_HASH;
                            end
                        end else begin
                            out_byte_count <= out_byte_count + 1;
                            state <= S_TX_BYTE;
                        end
                    end
                end
                                            
                default: state <= S_RX_IDLE;
            endcase
        end
    end
endmodule
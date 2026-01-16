module uart_tx #(
    parameter integer CLK_FREQ = 125_000_000,
    parameter integer BAUD     = 115200
)(
    input  wire       clk,
    input  wire       resetn,

    input  wire [7:0] tx_data,      // Dữ liệu cần gửi
    input  wire       tx_valid,     // = 1 khi có dữ liệu (Input Valid)
    output reg        tx_ready,     // = 1 khi module sẵn sàng nhận (Output Ready)

    output reg        tx            // Chân truyền dữ liệu
);
    localparam integer BAUD_CNT_MAX = CLK_FREQ / BAUD;
    localparam integer CNT_WIDTH    = $clog2(BAUD_CNT_MAX); 


    localparam [1:0] S_IDLE  = 2'b00;
    localparam [1:0] S_START = 2'b01;
    localparam [1:0] S_DATA  = 2'b10;
    localparam [1:0] S_STOP  = 2'b11;

    reg [1:0] state;

    reg [CNT_WIDTH-1:0] baud_cnt; 
    reg [2:0]           bit_idx;  // 0..7
    reg [7:0]           data_reg; // Lưu dữ liệu để gửi ổn định

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tx       <= 1'b1; // Idle line is HIGH
            tx_ready <= 1'b0; // Reset thì chưa nhận được
            state    <= S_IDLE;
            baud_cnt <= 0;
            bit_idx  <= 0;
            data_reg <= 0;
        end else begin
            
            case (state)
                S_IDLE: begin
                    tx       <= 1'b1;
                    tx_ready <= 1'b1;
                    // Handshake: Khi cả 2 cùng gật đầu (Valid=1, Ready=1)
                    if (tx_valid && tx_ready) begin
                        data_reg <= tx_data; 
                        tx_ready <= 1'b0; 
                        state    <= S_START;
                        baud_cnt <= BAUD_CNT_MAX - 1;
                    end
                end

                S_START: begin
                    tx <= 1'b0; // Start bit

                    if (baud_cnt > 0) begin
                        baud_cnt <= baud_cnt - 1;
                    end else begin
                        state    <= S_DATA;
                        baud_cnt <= BAUD_CNT_MAX - 1;
                        bit_idx  <= 0;
                    end
                end
                S_DATA: begin
                    tx <= data_reg[bit_idx];
                    if (baud_cnt > 0) begin
                        baud_cnt <= baud_cnt - 1;
                    end else begin
                        baud_cnt <= BAUD_CNT_MAX - 1;
                        
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            state   <= S_STOP; 
                        end
                    end
                end

                S_STOP: begin
                    tx <= 1'b1; // Stop bit

                    if (baud_cnt > 0) begin
                        baud_cnt <= baud_cnt - 1;
                    end else begin
                        state <= S_IDLE; 
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
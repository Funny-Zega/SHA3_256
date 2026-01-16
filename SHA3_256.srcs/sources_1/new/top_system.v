module top_system #(
    parameter integer CLK_FREQ = 125_000_000,
    parameter integer BAUD     = 115200
)(
    input clk,          // Clock 100MHz hoặc 125MHz từ board
    input rst_btn,        // Nút reset
    input uart_rx_i,    // Chân nhận USB-UART
    output uart_tx_o    // Chân gửi USB-UART
);
    
    wire rst_n;
    assign rst_n = ~rst_btn;
    
    wire [7:0] rx_data;
    wire rx_ready;
    wire rx_ack;
    wire rx_err_frame;
    wire rx_err_overrun;

    wire [7:0] tx_data;
    wire tx_valid;   
    wire tx_ready;

    wire [31:0] sha3_in;
    wire sha3_in_valid, sha3_in_done, sha3_in_ready;
    wire [31:0] sha3_out;
    wire sha3_out_valid, sha3_out_ready, sha3_busy;

    // 1. UART RX
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) u_rx (
        .clk(clk), 
        .resetn(rst_n),
        .rx(uart_rx_i),
        .rx_data(rx_data), 
        .rx_ready(rx_ready), 
        .rx_ack(rx_ack),        
        .err_frame(rx_err_frame),     
        .err_overrun(rx_err_overrun) 
    );

    bridge_uart_sha3 u_bridge (
        .clk(clk), 
        .rst_n(rst_n),
        .rx_data(rx_data), 
        .rx_ready(rx_ready), 
        .rx_ack(rx_ack),
        
        .tx_data(tx_data), 
        .tx_valid(tx_valid),    // Valid -> TX
        .tx_ready(tx_ready),    // Ready <- TX
        
        .sha3_in_data(sha3_in), 
        .sha3_in_valid(sha3_in_valid),
        .sha3_in_done(sha3_in_done), 
        .sha3_in_ready(sha3_in_ready),
        
        .sha3_out_data(sha3_out), 
        .sha3_out_valid(sha3_out_valid),
        .sha3_out_ready(sha3_out_ready)
    );

    // 3. SHA3 WRAPPER
    wrapper_v4 u_sha3 (
        .clk(clk), 
        .rst_n(rst_n),
        .in_data(sha3_in), 
        .in_valid(sha3_in_valid),
        .in_done(sha3_in_done), 
        .in_ready(sha3_in_ready),
        .out_data(sha3_out), 
        .out_valid(sha3_out_valid),
        .out_ready(sha3_out_ready),
        .busy(sha3_busy)
    );

    // 4. UART TX
    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) u_tx (
        .clk(clk), 
        .resetn(rst_n),
        .tx_data(tx_data),
        .tx_valid(tx_valid),    
        .tx_ready(tx_ready), 
        .tx(uart_tx_o)
    );

endmodule
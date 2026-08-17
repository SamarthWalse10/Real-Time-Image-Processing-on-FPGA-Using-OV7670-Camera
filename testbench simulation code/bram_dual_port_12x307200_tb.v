`timescale 1ns / 1ps


module bram_dual_port_12x307200_tb();
reg wclk,wr_en,rclk,rd_en;
reg [18:0]wr_addr,rd_addr;
reg [11:0]din;
wire [11:0]dout;   

bram_dual_port_12x307200 uut (wclk,wr_en,wr_addr,rclk,rd_en,rd_addr,din,dout);

initial begin
    wclk = 0;
    rclk = 0;
    
    wr_addr = 0;
    rd_addr = 0;
    
    din = 0;
    
    wr_en = 1;
    rd_en = 1;
    #500
    wr_en = 0;
    rd_en = 0;
end

always #5 wclk = ~wclk;
always #4 rclk = ~rclk;

always #20 wr_addr = wr_addr + 1;
always #20 rd_addr = rd_addr + 1;

always #30 din = din + 10;

endmodule

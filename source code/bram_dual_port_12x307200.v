`timescale 1ns / 1ps


module bram_dual_port_12x307200 (wclk,wr_en,wr_addr,rclk,rd_en,rd_addr,din,dout);
input wclk,wr_en,rclk,rd_en;
input [18:0]wr_addr,rd_addr;
input [11:0]din;
output reg [11:0]dout;

reg [11:0]mem [0:307199]; 
    
always @(posedge wclk) if(wr_en) mem[wr_addr] <= din;
always @(posedge rclk) if(rd_en) dout <= mem[rd_addr]; 

endmodule

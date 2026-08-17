`timescale 1ns / 1ps


module line_buffer #(parameter WIDTH = 16, parameter SIZE = 640) (clk,wr_en,wr_addr,rd_en,rd_addr,line_buff_din,line_buff_dout);
input clk,wr_en,rd_en;
input [$clog2(SIZE)-1:0]wr_addr;
input [$clog2(SIZE)-1:0]rd_addr;
input [WIDTH-1:0]line_buff_din;
output reg [(WIDTH*3)-1:0]line_buff_dout;

reg [WIDTH-1:0]line_mem [SIZE-1:0]; 

always @(posedge clk) if(wr_en) line_mem[wr_addr] <= line_buff_din;
//assign line_buff_dout = (rd_en) ? {line_mem[rd_addr-2], line_mem[rd_addr-1], line_mem[rd_addr]} : line_buff_dout;
//always @(*) if(rd_en) line_buff_dout <= {line_mem[rd_addr-2], line_mem[rd_addr-1], line_mem[rd_addr]};
always @(posedge clk) if(rd_en) line_buff_dout <= {line_mem[rd_addr-2], line_mem[rd_addr-1], line_mem[rd_addr]};

endmodule

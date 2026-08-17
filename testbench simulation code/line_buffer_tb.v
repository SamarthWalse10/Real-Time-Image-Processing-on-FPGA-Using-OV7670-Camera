`timescale 1ns / 1ps


module line_buffer_tb #(parameter WIDTH = 16, parameter SIZE = 640) ();
reg clk,wr_en,rd_en;
reg [$clog2(SIZE)-1:0]wr_addr;
reg [$clog2(SIZE)-1:0]rd_addr;
reg [WIDTH-1:0]line_buff_din;
wire [(WIDTH*3)-1:0]line_buff_dout;

line_buffer uut (clk,wr_en,wr_addr,rd_en,rd_addr,line_buff_din,line_buff_dout);

initial begin
    wr_en=1; rd_en=1;
    clk=0; 
    forever #5 clk = ~clk;
end

initial begin 
    wr_addr=0; #5
    forever #10 wr_addr <= (wr_addr==639) ? 0 : wr_addr+1;
end

initial begin 
    rd_addr=0; #55
    forever #10 rd_addr <= (rd_addr==639) ? 0 : rd_addr+1;
end

initial begin 
    line_buff_din=16'habcd; #5
    forever #10 line_buff_din <= line_buff_din + 1;
end

endmodule

`timescale 1ns / 1ps


module rgb444_processing_pipelined_tb();
reg rst,clk;
reg signed [4:0]offset;
reg [1:0]mode;
reg [18:0]in_wr_addr;
reg [11:0]in_pixel_data;
wire [18:0]out_wr_addr;
wire [11:0]out_pixel_data;
wire output_start;

rgb444_processing_pipelined_bram_linebuffer uut (rst,clk,offset,mode,in_wr_addr,in_pixel_data,out_wr_addr,out_pixel_data,output_start);

initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

initial begin
    rst=1; mode=2'b00; in_wr_addr=0; in_pixel_data=12'habc; offset=0;
    #10000000
    rst=0;
    
    #50000000
    offset=5;
    #50000000
    mode=2'b01;
    #50000000
    offset=2;
    #50000000
    mode=2'b10;
    #50000000
    offset=-1;
    #50000000
    mode=2'b11;
    #50000000
    offset=-4;
end

always @(posedge clk) begin
    in_wr_addr <= in_wr_addr + 1;
    in_pixel_data <= in_pixel_data + 1;
end

endmodule

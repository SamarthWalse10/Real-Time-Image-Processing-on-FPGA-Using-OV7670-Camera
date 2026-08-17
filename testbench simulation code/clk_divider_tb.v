`timescale 1ns / 1ps


module clk_divider_tb();
reg clk_in;
wire clk_out;

clk_divider dut (clk_in,clk_out);

initial begin
    clk_in = 0;
    forever #5 clk_in = ~ clk_in;
end

endmodule

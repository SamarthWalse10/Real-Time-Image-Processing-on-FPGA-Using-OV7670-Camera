`timescale 1ns / 1ps


module debounce_tb #(parameter MAX_COUNT = 50) ();
reg rst,clk,in;
wire out,rise;

debounce #(.MAX_COUNT(MAX_COUNT)) uut (rst,clk,in,out,rise);

initial begin 
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst=1; in=0;
    #1000
    rst=0;
    #100;

    forever begin
        repeat(15) #16 in = ~in;
        in = 1;
        #1000;
        in = 0;
        #1000;
    end
end

endmodule

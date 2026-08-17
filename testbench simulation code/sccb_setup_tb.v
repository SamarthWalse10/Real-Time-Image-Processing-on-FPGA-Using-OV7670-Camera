`timescale 1ns / 1ps


module sccb_setup_tb();
reg rst,clk;
wire sioc;
wire siod;
wire sccb_done;

sccb_setup #(.CLK_FREQ(100000000), .I2C_FREQ(400000)) dut(.rst(rst), .clk(clk), .siod(siod), .sioc(sioc), .sccb_done(sccb_done));

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst=1;
    #100;
    rst=0;
end

endmodule

`timescale 1ns / 1ps


module sccb_write_tb();
reg rst,clk,start;
reg [6:0]slave_addr;
reg [7:0]reg_addr;
reg [7:0]data_tx;
wire ready,error;
wire sioc;
wire siod;

sccb_write #(.CLK_FREQ(100000000), .I2C_FREQ(400000)) dut(.rst(rst), .clk(clk), .start(start), .slave_addr(slave_addr), .reg_addr(reg_addr), .data_tx(data_tx), .ready(ready), .error(error), .siod(siod), .sioc(sioc));

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

reg siod_slave_ack;
assign siod = siod_slave_ack ? 1'b0 : 1'bz;

initial begin
    rst=1; start=0; 
    slave_addr=7'h42;    //   100 0010
    reg_addr=8'hac;      //  1010 1100
    data_tx=8'h9b;       //  1001 1011
    siod_slave_ack=0;
    #5000;
    rst=0;
    #10000;

    start = 1; 
    #8;
    start = 0;

    wait(ready);
    #100;
end

integer bit_counter = 0;
integer byte_counter = 0;

always @(posedge sioc) begin
    if (!rst) begin
        if (bit_counter < 8) begin
            bit_counter <= bit_counter + 1;
        end
        else begin
            bit_counter <= 0;
            byte_counter <= byte_counter + 1;
            siod_slave_ack <= 1;
            #1000;
            siod_slave_ack <= 0;
        end
    end
end

endmodule

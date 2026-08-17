`timescale 1ns/1ps


module ov7670_capture_tb();
reg rst,pclk,vsync,href;
reg [7:0]data_in;
wire [11:0]pixel_data;
wire [18:0]pixel_addr;
wire [9:0]row_num,col_num;
wire row_done,frame_done;

ov7670_capture dut(rst,pclk,vsync,href,data_in,pixel_data,pixel_addr,row_num,col_num,row_done,frame_done);

integer i = 0;
localparam TPLCK = 40;  // 25Mhz
localparam TP = 2*TPLCK;
localparam TLINE = 784*TP;

initial begin
    pclk = 0;
    forever #(TPLCK/2) pclk = ~pclk;
end

initial begin
    rst=1;
    #5000000;
    rst=0;
end

initial begin
    vsync = 1;
    forever begin
        #(3*TLINE);
        vsync=0;
        #(507*TLINE);
        vsync=1;
    end
end

initial begin
    href = 0;
    forever begin
        #(20*TLINE);
        for (i=0; i<479; i=i+1) begin
            href=1; #(640*TP);            
            href=0; #(144*TP);            
        end
        href=1; #(640*TP);
        href=0; #(10*TLINE);
    end
end

always @(negedge pclk) begin
    if (href) data_in <= data_in + 1;
    else data_in <= 0;
end

endmodule

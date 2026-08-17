`timescale 1ns / 1ps


module top_tb #(parameter CLK_FREQ = 32'd100000000, parameter I2C_FREQ = 19'd400000, parameter DIVISOR = 32'd4, parameter MAX_COUNT = 50) ();
reg rst;
reg clk;
reg incr_bright;
reg decr_bright;
reg rst_bright;
reg [1:0]mode;
reg pclk;
reg cam_vsync;
reg cam_href;
reg [7:0]data_in;
wire xclk;
wire ov7670_rst;
wire ov7670_pwdn;
wire sioc;
wire siod;
wire vga_hsync;
wire vga_vsync;
wire [3:0]vga_red;
wire [3:0]vga_blue;
wire [3:0]vga_green;
wire sccb_config_done;

integer i=0, j=0;
localparam TPLCK = 40;  // 25Mhz
localparam TP = 2*TPLCK;
localparam TLINE = 784*TP;

top uut (
    rst,
    clk,
    incr_bright,
    decr_bright,
    rst_bright,
    mode,
    pclk,
    cam_vsync,
    cam_href,
    data_in,
    xclk,
    ov7670_rst,
    ov7670_pwdn,
    sioc,
    siod,
    vga_hsync,
    vga_vsync,
    vga_red,
    vga_blue,
    vga_green,
    sccb_config_done
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    pclk = 0;
    forever #(TPLCK/2) pclk = ~pclk;
end

initial begin
    rst=1; mode=2'b00; incr_bright=0; decr_bright=0; rst_bright=0;
    #10000000
    rst=0;
    
    #50000000
    for (j=0; j<5; j=j+1) begin
        incr_bright=1;
        #1000000            
        incr_bright=0;            
    end
    #50000000
    mode=2'b01;
    #50000000
    for (j=0; j<3; j=j+1) begin
        decr_bright=1;
        #1000000            
        decr_bright=0;            
    end
    #50000000
    mode=2'b10;
    #50000000
    for (j=0; j<3; j=j+1) begin
        decr_bright=1;
        #1000000            
        decr_bright=0;            
    end
    #50000000
    mode=2'b11;
    #50000000
    for (j=0; j<3; j=j+1) begin
        decr_bright=1;
        #1000000            
        decr_bright=0;            
    end
end

initial begin
    cam_vsync = 1;
    forever begin
        #(3*TLINE);
        cam_vsync=0;
        #(507*TLINE);
        cam_vsync=1;
    end
end

initial begin
    cam_href = 0;
    forever begin
        #(20*TLINE);
        for (i=0; i<479; i=i+1) begin
            cam_href=1; #(640*TP);            
            cam_href=0; #(144*TP);            
        end
        cam_href=1; #(640*TP);
        cam_href=0; #(10*TLINE);
    end
end

always @(negedge pclk) begin
    if (cam_href) data_in <= data_in + 1;
    else data_in <= 0;
end

endmodule

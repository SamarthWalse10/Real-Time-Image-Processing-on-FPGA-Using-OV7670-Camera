`timescale 1ns / 1ps


module vga_controller_tb();
reg vga_clk,rst;
reg [3:0]red_in,blue_in,green_in;
wire hsync,vsync;
wire [3:0]red_out,blue_out,green_out;
wire video_on;
wire [18:0]pixel_ptr;

vga_controller uut(.vga_clk(vga_clk), .rst(rst), .red_in(red_in), .blue_in(blue_in), .green_in(green_in), .hsync(hsync), .vsync(vsync), .red_out(red_out), .blue_out(blue_out), .green_out(green_out), .video_on(video_on), .pixel_ptr(pixel_ptr));

always begin
    vga_clk = 0;
    forever #20 vga_clk = ~vga_clk;
end

initial begin
    rst = 1;
    #10000000;
    rst = 0;
end

always begin
    red_in = 0;
    forever #10 red_in = red_in + 1;
end

always begin
    blue_in = 0;
    forever #15 blue_in = blue_in + 1;
end

always begin
    green_in = 0;
    forever #20 green_in = green_in + 1;
end

endmodule

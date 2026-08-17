`timescale 1ns / 1ps


module top #(parameter CLK_FREQ = 32'd100000000, parameter I2C_FREQ = 19'd400000, parameter DIVISOR = 32'd4, parameter MAX_COUNT = 500000) (rst,clk,incr_bright,decr_bright,rst_bright,mode,pclk,cam_vsync,cam_href,data_in,xclk,ov7670_rst,ov7670_pwdn,sioc,siod,vga_hsync,vga_vsync,vga_red,vga_blue,vga_green,sccb_config_done);
// inputs
input rst;
input clk;
input incr_bright;
input decr_bright;
input rst_bright;
input [1:0]mode;
// camera interface
input pclk;
input cam_vsync;
input cam_href;
input [7:0]data_in;
output xclk;
output ov7670_rst;
output ov7670_pwdn;
output sioc;
inout wire siod;
// vga interface
output vga_hsync;
output vga_vsync;
output [3:0]vga_red;
output [3:0]vga_blue;
output [3:0]vga_green;
// debug outputs
output sccb_config_done;


// wires and control logic
assign ov7670_rst = 1'b1;
assign ov7670_pwdn = 1'b0;

wire clk_25Mhz;
wire vga_clk;
wire [11:0]ov7670_pixel_data;
wire [18:0]ov7670_pixel_addr;
wire [18:0]bram_wr_addr;
wire [18:0]bram_rd_addr;
wire [11:0]bram_din;
wire [11:0]bram_dout;
wire vga_video_on;
wire incr_bright_db;
wire decr_bright_db;
wire rst_bright_db;
reg signed [4:0]offset;

assign xclk = clk_25Mhz;
assign vga_clk = clk_25Mhz;


// brightness control logic
always @(posedge rst or posedge clk) begin
    if (rst) begin
        offset <= 0;
    end
    else begin
        if (incr_bright_db) offset <= offset==15 ? 15 : offset+1;
        else if (decr_bright_db) offset <= offset<=-15 ? -15 : offset-1;
        else if (rst_bright_db) offset <= 0;
    end
end


// module instantiations
clk_divider #(.DIVISOR(DIVISOR)) clkdiv_25Mhz (
    .clk_in(clk),
    .clk_out(clk_25Mhz)
);

sccb_setup #(.CLK_FREQ(CLK_FREQ), .I2C_FREQ(I2C_FREQ)) sccb (
    .rst(rst),
    .clk(clk),
    .sioc(sioc),
    .siod(siod),
    .sccb_done(sccb_config_done)
);

bram_dual_port_12x307200 bram (
    .wclk(pclk),
    .wr_en(1'b1), // cam_href/1'b1
    .wr_addr(bram_wr_addr),
    .rclk(vga_clk),
    .rd_en(1'b1), // 1'b1/vga_video_on
    .rd_addr(bram_rd_addr),
    .din(bram_din),
    .dout(bram_dout)
);

ov7670_capture ov7670_camera_capture (
    .pclk(pclk),
    .rst(rst),
    .vsync(cam_vsync),
    .href(cam_href),
    .data_in(data_in),
    .pixel_data(ov7670_pixel_data),
    .pixel_addr(ov7670_pixel_addr),
    .row_num(),
    .col_num(),
    .row_done(),
    .frame_done()
);

rgb444_processing_pipelined_bram_linebuffer rgb444_procss (
    .clk(pclk),
    .rst(rst),
    .mode(mode),
    .in_wr_addr(ov7670_pixel_addr),
    .in_pixel_data(ov7670_pixel_data),
    .out_wr_addr(bram_wr_addr),
    .out_pixel_data(bram_din),
    .offset(offset),
    .output_start()
);

vga_controller vga (
    .vga_clk(vga_clk), 
    .rst(rst), 
    .red_in(bram_dout[11:8]), 
    .blue_in(bram_dout[3:0]), 
    .green_in(bram_dout[7:4]), 
    .vsync(vga_vsync),
    .hsync(vga_hsync),
    .red_out(vga_red), 
    .blue_out(vga_blue), 
    .green_out(vga_green),  
    .pixel_ptr(bram_rd_addr),
    .video_on(vga_video_on)
);

debounce #(.MAX_COUNT(MAX_COUNT)) btn_debouncer_up (
    .rst(rst),
    .clk(clk),
    .in(incr_bright),
    .rise(incr_bright_db),
    .out()
);

debounce #(.MAX_COUNT(MAX_COUNT)) btn_debouncer_down (
    .rst(rst),
    .clk(clk),
    .in(decr_bright),
    .rise(decr_bright_db),
    .out()
);

debounce #(.MAX_COUNT(MAX_COUNT)) btn_debouncer_center (
    .rst(rst),
    .clk(clk),
    .in(rst_bright),
    .rise(rst_bright_db),
    .out()
);

endmodule

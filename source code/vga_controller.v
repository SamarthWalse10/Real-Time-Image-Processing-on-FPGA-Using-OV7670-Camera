`timescale 1ns / 1ps


module vga_controller (vga_clk,rst,red_in,blue_in,green_in,hsync,vsync,red_out,blue_out,green_out,video_on,pixel_ptr);
input vga_clk,rst;
input [3:0]red_in,blue_in,green_in;
output reg hsync,vsync;
output reg [3:0]red_out,blue_out,green_out;
output reg video_on;
output reg [18:0]pixel_ptr;

localparam H_ACTIVE = 640;
localparam H_FRONT_PORCH = 16;
localparam H_RETRACE = 96;
localparam H_BACK_PORCH = 48;
localparam H_TOTAL = 800;
localparam V_ACTIVE = 480;
localparam V_FRONT_PORCH = 10;
localparam V_RETRACE = 2;
localparam V_BACK_PORCH = 33;
localparam V_TOTAL = 525;

reg [9:0]hcnt,vcnt;

always @(posedge rst or posedge vga_clk) begin
    if (rst) begin
        hcnt <= H_TOTAL - 1;
        vcnt <= V_TOTAL - 1;
    end
    else begin
        if (hcnt == H_TOTAL-1) begin
            hcnt <= 0;
            if (vcnt == V_TOTAL-1) vcnt <= 0;
            else vcnt <= vcnt + 1;
        end
        else hcnt <= hcnt + 1;
    end
end

always @(posedge rst or posedge vga_clk) begin
    if (rst) pixel_ptr <= 0;
    else if (vsync==0) pixel_ptr <= 0;
    else if (video_on) pixel_ptr <= pixel_ptr + 1; 
end

always @(*) begin
    hsync = ~((hcnt >= H_ACTIVE + H_FRONT_PORCH) && (hcnt < H_ACTIVE + H_FRONT_PORCH + H_RETRACE));
    vsync = ~((vcnt >= V_ACTIVE + V_FRONT_PORCH) && (vcnt < V_ACTIVE + V_FRONT_PORCH + V_RETRACE));
    video_on = (hcnt < H_ACTIVE) && (vcnt < V_ACTIVE) && (!rst);
end

always @(*) begin
    if (rst) {red_out, green_out, blue_out} <= 12'b0;
    else begin
        if (video_on) {red_out, green_out, blue_out} <= {red_in, green_in, blue_in};
        else {red_out, green_out, blue_out} <= 12'b0;
    end
end

endmodule

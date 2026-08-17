`timescale 1ns / 1ps


module ov7670_capture (rst,pclk,vsync,href,data_in,pixel_data,pixel_addr,row_num,col_num,row_done,frame_done);
input rst,pclk,vsync,href;
input [7:0]data_in;
output reg [11:0]pixel_data;
output reg [18:0]pixel_addr;
output reg [9:0]row_num,col_num;
output reg row_done,frame_done;

reg [1:0]state;
localparam START = 2'b10;
localparam IDLE = 2'b00;
localparam FRAME_CAPTURE = 2'b01;

reg [9:0]row_count,col_count;
reg row_over,frame_over;
reg [7:0]first_byte;
reg byte_toggle;

always @(posedge rst or posedge pclk) begin
    if (rst) begin
        row_over <= 0;
        frame_over  <= 0;
        pixel_addr  <= 19'd524287;
        row_count <= 0;
        col_count <= 0;
        state <= START;
    end
    else begin
        row_over <= 0;
        frame_over  <= 0;
        case (state)
            START: begin
                if (vsync==0) state <= START;
                else state <= IDLE;
            end
            IDLE: begin
                pixel_addr <= 19'd524287;
                row_count <= 0;
                col_count <= 0;
                byte_toggle <= 0;
                if (!vsync) state <= FRAME_CAPTURE;
                else state <= IDLE;
            end
            FRAME_CAPTURE: begin
                if (vsync) state <= IDLE;
                else if (href) begin
                    if (byte_toggle) begin
                        pixel_data <= {first_byte[3:0],data_in};
                        pixel_addr <= pixel_addr + 1;
                        byte_toggle <= 0;
                        if (col_count == 10'd639) begin
                            col_count <= 0;
                            row_over <= 1;
                            if (row_count == 10'd479) begin
                                frame_over <= 1;
                                if (vsync) state <= IDLE;
                            end 
                            else row_count <= row_count + 1;
                        end 
                        else col_count <= col_count + 1;
                    end 
                    else begin
                        first_byte <= data_in;
                        byte_toggle <= 1;
                    end
                end
            end
        endcase
    end
end

always @(posedge rst or posedge pclk) begin
    if (rst) begin
        row_num <= 0;
        col_num <= 0;
    end
    else begin
        row_num <= row_count;
        col_num <= col_count;
    end
end

always @(posedge rst or posedge pclk) begin
    if (rst) begin
        row_done <= 0;
        frame_done <= 0;
    end
    else begin
        row_done <= row_over;
        frame_done <= frame_over;
    end
end

endmodule

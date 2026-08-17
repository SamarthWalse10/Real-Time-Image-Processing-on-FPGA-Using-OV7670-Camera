`timescale 1ns / 1ps


module clk_divider #(parameter DIVISOR = 32'd4)(clk_in,clk_out);   // frequency = 100MHz/DIVISOR
input clk_in;
output reg clk_out;
 
reg [31:0]cnt = 32'd0;

always @(posedge clk_in) begin
    if(cnt == (DIVISOR-1)) cnt <= 32'd0;
    else cnt <= cnt + 32'd1;
    clk_out <= (cnt < DIVISOR/2) ? 1'b1:1'b0;
end

endmodule

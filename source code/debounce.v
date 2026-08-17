`timescale 1ns / 1ps


module debounce #(parameter MAX_COUNT = 2000000) (rst,clk,in,out,rise);   // debounce_time = MAX_COUNT/freq = 2000000/100000000 = 20ms
input rst,clk,in;
output reg out,rise;

reg [$clog2(MAX_COUNT)-1:0] counter;
wire w_rise;

always @(posedge rst or posedge clk) begin
    if (rst) begin
        counter <= 0;
        out <= 0;
        rise <= 0;
    end
    else begin
        counter <= 0;
        rise <= 0;
        if (counter == MAX_COUNT-1) begin
            out <= in;
            rise <= w_rise;
        end
        else if (in != out) counter <= counter + 1;
    end
end

assign w_rise = in & ~out;

endmodule

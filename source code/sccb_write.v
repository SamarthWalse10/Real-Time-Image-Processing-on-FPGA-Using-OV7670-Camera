`timescale 1ns / 1ps


module sccb_write #(parameter CLK_FREQ = 32'd100000000, parameter I2C_FREQ = 19'd400000) (rst,clk,start,slave_addr,reg_addr,data_tx,ready,error,siod,sioc);
input rst,clk,start;
input [6:0]slave_addr;
input [7:0]reg_addr;
input [7:0]data_tx;
output reg ready,error;
output reg sioc;
inout wire siod;

reg [3:0]state;
localparam IDLE = 4'd0;
localparam START = 4'd1;
localparam WRITE_SLAVEADDR = 4'd2;
localparam ACK_SLAVEADDR = 4'd3;
localparam WRITE_REGADDR = 4'd4;
localparam ACK_REGADDR = 4'd5;
localparam WRITE_DATA = 4'd6;
localparam ACK_DATA = 4'd7;
localparam STOP = 4'd8;

localparam CLKS_PER_T = CLK_FREQ/I2C_FREQ;   // 100000000/100000 = 1000
reg [9:0]counter;

reg [7:0]addr_rw;
reg [7:0]regaddr;
reg [7:0]datatx;

reg [5:0]bit_idx;
reg free_siod;
reg temp_siod;

always @(posedge rst or posedge clk) begin
    if (rst) begin
        state <= IDLE;
        counter <= 0;
        bit_idx <= 0;
        free_siod <= 0;
        temp_siod <= 1;
        sioc <= 1;
        addr_rw <= 8'd0;
        regaddr <= 8'd0;
        datatx <= 8'd0;
        ready <= 0;
        error <= 0;
    end
    else begin
        case (state)
            IDLE: begin         
                counter <= 0;
                bit_idx <= 0;
                free_siod <= 0;
                temp_siod <= 1;
                sioc <= 1;
                if (start) begin
                    state <= START;
                    ready <= 0;
                    error <= 0;
                    addr_rw <= {1'b0, slave_addr[0], slave_addr[1], slave_addr[2], slave_addr[3], slave_addr[4], slave_addr[5], slave_addr[6]};   // {slave_addr, 1'b0}
                    regaddr <= {reg_addr[0], reg_addr[1], reg_addr[2], reg_addr[3], reg_addr[4], reg_addr[5], reg_addr[6], reg_addr[7]};   // reg_addr
                    datatx <= {data_tx[0], data_tx[1], data_tx[2], data_tx[3], data_tx[4], data_tx[5], data_tx[6], data_tx[7]};   // data_tx
                end
                else ready <= 1;
            end
            START: begin
                if (counter < ((CLKS_PER_T*3)/4)-1) begin
                    temp_siod <= 0;
                    counter <= counter + 1;
                    if (counter >= (CLKS_PER_T/2)-1) sioc <= 0;
                    else sioc <= 1;
                end
                else begin
                    state <= WRITE_SLAVEADDR;
                    counter <= 0;
                end
            end
            WRITE_SLAVEADDR: begin
                if (counter < CLKS_PER_T-1 && bit_idx < 8) begin
                    temp_siod <= addr_rw[bit_idx];
                    counter <= counter + 1;
                    if (counter > ((CLKS_PER_T/4)-1) && counter < (((CLKS_PER_T*3)/4)+1)) sioc <= 1;
                    else sioc <= 0;
                end
                else begin
                    counter <= 0;
                    if (bit_idx == 7) begin
                        bit_idx <= 0;
                        state <= ACK_SLAVEADDR;
                    end
                    else bit_idx <= bit_idx + 1;
                end
            end
            ACK_SLAVEADDR: begin
                if (counter < CLKS_PER_T-1) begin
                    free_siod <= 1;
                    counter <= counter + 1;
                    if (counter > ((CLKS_PER_T/4)-1) && counter < (((CLKS_PER_T*3)/4)+1)) begin
                        sioc <= 1;
                        if (counter == ((CLKS_PER_T/4)+1) && siod) error <= 1;
                    end
                    else sioc <= 0;
                end
                else begin
                    free_siod <= 0;
                    temp_siod <= regaddr[bit_idx];
                    counter <= 0;
                    state <= WRITE_REGADDR;
                end
            end
            WRITE_REGADDR: begin
                if (counter < CLKS_PER_T-1 && bit_idx < 8) begin
                    temp_siod <= regaddr[bit_idx];
                    counter <= counter + 1;
                    if (counter > ((CLKS_PER_T/4)-1) && counter < (((CLKS_PER_T*3)/4)+1)) sioc <= 1;
                    else sioc <= 0;
                end
                else begin
                    counter <= 0;
                    if (bit_idx == 7) begin
                        bit_idx <= 0;
                        state <= ACK_REGADDR;
                    end
                    else bit_idx <= bit_idx + 1;
                end
            end
            ACK_REGADDR: begin
                if (counter < CLKS_PER_T-1) begin
                    free_siod <= 1;
                    counter <= counter + 1;
                    if (counter > ((CLKS_PER_T/4)-1) && counter < (((CLKS_PER_T*3)/4)+1)) begin
                        sioc <= 1;
                        if (counter == ((CLKS_PER_T/4)+1) && siod) error <= 1;
                    end
                    else sioc <= 0;
                end
                else begin
                    free_siod <= 0;
                    temp_siod <= datatx[bit_idx];
                    counter <= 0;
                    state <= WRITE_DATA;
                end
            end
            WRITE_DATA: begin
                if (counter < CLKS_PER_T-1 && bit_idx < 8) begin
                    temp_siod <= datatx[bit_idx];
                    counter <= counter + 1;
                    if (counter > ((CLKS_PER_T/4)-1) && counter < (((CLKS_PER_T*3)/4)+1)) sioc <= 1;
                    else sioc <= 0;
                end
                else begin
                    counter <= 0;
                    if (bit_idx == 7) begin
                        bit_idx <= 0;
                        state <= ACK_DATA;
                    end
                    else bit_idx <= bit_idx + 1;
                end
            end
            ACK_DATA: begin
                if (counter < CLKS_PER_T-1) begin
                    free_siod <= 1;
                    counter <= counter + 1;
                    if (counter > ((CLKS_PER_T/4)-1) && counter < (((CLKS_PER_T*3)/4)+1)) begin
                        sioc <= 1;
                        if (counter == ((CLKS_PER_T/4)+1) && siod) error <= 1;
                    end
                    else sioc <= 0;
                end
                else begin
                    free_siod <= 0;
                    temp_siod <= 0;
                    counter <= 0;
                    state <= STOP;
                end
            end
            STOP: begin
                if (counter < ((CLKS_PER_T*3)/4)-1) begin
                    counter <= counter + 1;
                    if (counter >= (CLKS_PER_T/2)-1) temp_siod <= 1;
                    else temp_siod <= 0;
                    if (counter >= (CLKS_PER_T/4)-1) sioc <= 1;
                    else sioc <= 0;
                end
                else begin
                    state <= IDLE;
                    counter <= 0;
                end
            end
        endcase
    end
end

assign siod = free_siod ? 1'b1 : temp_siod;   // assign siod = free_siod ? 1'bz : temp_siod;

endmodule

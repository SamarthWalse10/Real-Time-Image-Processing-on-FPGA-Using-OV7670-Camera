`timescale 1ns / 1ps


module sccb_setup #(parameter CLK_FREQ = 32'd100000000, parameter I2C_FREQ = 19'd400000) (rst,clk,sioc,siod,sccb_done);
input rst,clk;
output sioc;
inout wire siod;
output reg sccb_done;

reg [15:0]regaddr_datatx_mem [78:0];

initial begin   
    regaddr_datatx_mem[0]  <= 16'h12_80;  // COM7, Reset SCCB registers
    regaddr_datatx_mem[1]  <= 16'h12_04;  // COM7, Set RGB color output
    regaddr_datatx_mem[2]  <= 16'h11_00;  // CLKRC, Internal PLL matches input clock (24 MHz). 
    regaddr_datatx_mem[3]  <= 16'h0C_00;  // COM3, *Leave as default.
    regaddr_datatx_mem[4]  <= 16'h3E_00;  // COM14, *Leave as default. No scaling, normal pclock
    regaddr_datatx_mem[5]  <= 16'h04_00;  // COM1, *Leave as default. Disable CCIR656
    regaddr_datatx_mem[6]  <= 16'h8C_02;  // RGB444, nable RGB444 mode with xR GB.
    regaddr_datatx_mem[7]  <= 16'h40_D0;  // COM15, Output full range for RGB 444. 
    regaddr_datatx_mem[8]  <= 16'h3a_04;  // TSLB, set correct output data sequence (magic)
    regaddr_datatx_mem[9]  <= 16'h14_18;  // COM9, MAX AGC value x4
    regaddr_datatx_mem[10] <= 16'h4F_B3;  // MTX1, all of these are magical matrix coefficients
    regaddr_datatx_mem[11] <= 16'h50_B3;  // MTX2
    regaddr_datatx_mem[12] <= 16'h51_00;  // MTX3
    regaddr_datatx_mem[13] <= 16'h52_3d;  // MTX4
    regaddr_datatx_mem[14] <= 16'h53_A7;  // MTX5
    regaddr_datatx_mem[15] <= 16'h54_E4;  // MTX6
    regaddr_datatx_mem[16] <= 16'h58_9E;  // MTXS
    regaddr_datatx_mem[17] <= 16'h3D_C0;  // COM13, sets gamma enable, does not preserve reserved bits, may be wrong?
    regaddr_datatx_mem[18] <= 16'h17_14;  // HSTART, start high 8 bits
    regaddr_datatx_mem[19] <= 16'h18_02;  // HSTOP, stop high 8 bits //these kill the odd colored line
    regaddr_datatx_mem[20] <= 16'h32_80;  // HREF, edge offset
    regaddr_datatx_mem[21] <= 16'h19_03;  // VSTART, start high 8 bits
    regaddr_datatx_mem[22] <= 16'h1A_7B;  // VSTOP, stop high 8 bits
    regaddr_datatx_mem[23] <= 16'h03_0A;  // VREF, vsync edge offset
    regaddr_datatx_mem[24] <= 16'h0F_41;  // COM6, reset timings
    regaddr_datatx_mem[25] <= 16'h1E_00;  // MVFP, disable mirror / flip //might have magic value of 03
    regaddr_datatx_mem[26] <= 16'h33_0B;  // CHLF, magic value from the internet
    regaddr_datatx_mem[27] <= 16'h3C_78;  // COM12, no HREF when VSYNC low
    regaddr_datatx_mem[28] <= 16'h69_00;  // GFIX, fix gain control
    regaddr_datatx_mem[29] <= 16'h74_00;  // REG74, Digital gain control
    regaddr_datatx_mem[30] <= 16'hB0_84;  // RSVD, magic value from the internet *required* for good color
    regaddr_datatx_mem[31] <= 16'hB1_0c;  // ABLC1
    regaddr_datatx_mem[32] <= 16'hB2_0e;  // RSVD, more magic internet values
    regaddr_datatx_mem[33] <= 16'hB3_80;  // THL_ST
    regaddr_datatx_mem[34] <= 16'h70_3a;  // SCALING_XSC, *Leave as default. No test pattern output. 
    regaddr_datatx_mem[35] <= 16'h71_35;  // SCALING_YSC, *Leave as default. No test pattern output.
    regaddr_datatx_mem[36] <= 16'h72_11;  // SCALING DCWCTR, *Leave as default. Vertical down sample by 2. Horizontal down sample by 2.
    regaddr_datatx_mem[37] <= 16'h73_f0;  // SCALING PCLK_DIV 
    regaddr_datatx_mem[38] <= 16'ha2_02;  // SCALING PCLK DELAY, *Leave as deafult. 
    regaddr_datatx_mem[39] <= 16'h7a_20;  // SLOP
    regaddr_datatx_mem[40] <= 16'h7b_10;  // GAM1
    regaddr_datatx_mem[41] <= 16'h7c_1e;  // GAM2
    regaddr_datatx_mem[42] <= 16'h7d_35;  // GAM3
    regaddr_datatx_mem[43] <= 16'h7e_5a;  // GAM4
    regaddr_datatx_mem[44] <= 16'h7f_69;  // GAM5
    regaddr_datatx_mem[45] <= 16'h80_76;  // GAM6
    regaddr_datatx_mem[46] <= 16'h81_80;  // GAM7
    regaddr_datatx_mem[47] <= 16'h82_88;  // GAM8
    regaddr_datatx_mem[48] <= 16'h83_8f;  // GAM9
    regaddr_datatx_mem[49] <= 16'h84_96;  // GAM10
    regaddr_datatx_mem[50] <= 16'h85_a3;  // GAM11
    regaddr_datatx_mem[51] <= 16'h86_af;  // GAM12
    regaddr_datatx_mem[52] <= 16'h87_c4;  // GAM13
    regaddr_datatx_mem[53] <= 16'h88_d7;  // GAM14
    regaddr_datatx_mem[54] <= 16'h89_e8;  // GAM15
    regaddr_datatx_mem[55] <= 16'h13_e0;  // COM8, disable AGC / AEC
    regaddr_datatx_mem[56] <= 16'h00_00;  // set gain reg to 0 for AGC
    regaddr_datatx_mem[57] <= 16'h10_00;  // set ARCJ reg to 0
    regaddr_datatx_mem[58] <= 16'h0d_40;  // magic reserved bit for COM4
    regaddr_datatx_mem[59] <= 16'h14_18;  // COM9, 4x gain + magic bit
    regaddr_datatx_mem[60] <= 16'ha5_05;  // BD50MAX
    regaddr_datatx_mem[61] <= 16'hab_07;  // DB60MAX
    regaddr_datatx_mem[62] <= 16'h24_95;  // AGC upper limit
    regaddr_datatx_mem[63] <= 16'h25_33;  // AGC lower limit
    regaddr_datatx_mem[64] <= 16'h26_e3;  // AGC/AEC fast mode op region
    regaddr_datatx_mem[65] <= 16'h9f_78;  // HAECC1
    regaddr_datatx_mem[66] <= 16'ha0_68;  // HAECC2
    regaddr_datatx_mem[67] <= 16'ha1_03;  // magic
    regaddr_datatx_mem[68] <= 16'ha6_d8;  // HAECC3
    regaddr_datatx_mem[69] <= 16'ha7_d8;  // HAECC4
    regaddr_datatx_mem[70] <= 16'ha8_f0;  // HAECC5
    regaddr_datatx_mem[71] <= 16'ha9_90;  // HAECC6
    regaddr_datatx_mem[72] <= 16'haa_94;  // HAECC7
    regaddr_datatx_mem[73] <= 16'h13_a7;  // COM8, enable AGC / AEC
    regaddr_datatx_mem[74] <= 16'h69_06;  // GFIX, fix gain control
end

reg state;
localparam START = 1'b0;
localparam WRITE = 1'b1;

localparam [7:0]NO_OF_WRITES = 8'd75; 
localparam CLKS_PER_WRITE = (CLK_FREQ/I2C_FREQ)*30;   // (100000000/100000)*30 = 1000*30 = 30000
localparam CLKS_FOR_11ms = 1100000;                   // 11ms

reg start_i;
reg [7:0]data_cnt;
wire [6:0]slave_addr = 7'h21;
wire [7:0]reg_addr = regaddr_datatx_mem[data_cnt][15:8];
wire [7:0]data_tx = regaddr_datatx_mem[data_cnt][7:0];
wire ready,error;
reg [$clog2(CLKS_FOR_11ms)-1:0]counter;
reg [$clog2(CLKS_FOR_11ms)-1:0]WAIT_CLKS;

always @(*) WAIT_CLKS = (data_cnt==8'd0) ? CLKS_FOR_11ms : CLKS_PER_WRITE;

sccb_write #(.CLK_FREQ(CLK_FREQ), .I2C_FREQ(I2C_FREQ)) sccb (
    .rst(rst), 
    .clk(clk), 
    .start(start_i), 
    .slave_addr(slave_addr), 
    .reg_addr(reg_addr), 
    .data_tx(data_tx), 
    .ready(ready), 
    .error(error), 
    .siod(siod), 
    .sioc(sioc)
);

always @(posedge rst or posedge clk) begin
    if (rst) begin
        data_cnt <= 0;
        counter <= 0;
        start_i <= 0;
        sccb_done <= 0;
        state <= START;
    end
    else begin
        case (state)
            START: begin
                if (data_cnt == NO_OF_WRITES) begin
                    start_i <= 0;
                    sccb_done <= 1;
                    state <= START;
                end
                else begin
                    start_i <= 1;   // {reg_addr, data_tx} <= regaddr_datatx_mem[data_cnt];
                    state <= WRITE;
                end
            end
            WRITE: begin
                start_i <= 0;
                if (counter==WAIT_CLKS-1 && ready) begin
                    counter <= 0;
                    data_cnt <= data_cnt + 1;
                    state <= START;
                 end
                else begin
                    counter <= counter + 1;
                    state <= WRITE;
                end
            end
        endcase
    end
end

endmodule

`timescale 1ns / 1ps


module rgb444_processing_pipelined_bram_linebuffer #(parameter WIDTH = 16, parameter SIZE = 640) (rst,clk,offset,mode,in_wr_addr,in_pixel_data,out_wr_addr,out_pixel_data,output_start);
input rst,clk;
input signed [4:0]offset;
input [1:0]mode;
input [18:0]in_wr_addr;
input [11:0]in_pixel_data;
output reg [18:0]out_wr_addr;
output reg [11:0]out_pixel_data;
output reg output_start;

// sqrt_mem to store upto (4bit) square root values
reg [3:0]sqrt_mem [0:255];
initial begin
    sqrt_mem[0] = 0;
    sqrt_mem[1] = 1;
    sqrt_mem[2] = 1;
    sqrt_mem[3] = 1;
    sqrt_mem[4] = 2;
    sqrt_mem[5] = 2;
    sqrt_mem[6] = 2;
    sqrt_mem[7] = 2;
    sqrt_mem[8] = 2;
    sqrt_mem[9] = 3;
    sqrt_mem[10] = 3;
    sqrt_mem[11] = 3;
    sqrt_mem[12] = 3;
    sqrt_mem[13] = 3;
    sqrt_mem[14] = 3;
    sqrt_mem[15] = 3;
    sqrt_mem[16] = 4;
    sqrt_mem[17] = 4;
    sqrt_mem[18] = 4;
    sqrt_mem[19] = 4;
    sqrt_mem[20] = 4;
    sqrt_mem[21] = 4;
    sqrt_mem[22] = 4;
    sqrt_mem[23] = 4;
    sqrt_mem[24] = 4;
    sqrt_mem[25] = 5;
    sqrt_mem[26] = 5;
    sqrt_mem[27] = 5;
    sqrt_mem[28] = 5;
    sqrt_mem[29] = 5;
    sqrt_mem[30] = 5;
    sqrt_mem[31] = 5;
    sqrt_mem[32] = 5;
    sqrt_mem[33] = 5;
    sqrt_mem[34] = 5;
    sqrt_mem[35] = 5;
    sqrt_mem[36] = 6;
    sqrt_mem[37] = 6;
    sqrt_mem[38] = 6;
    sqrt_mem[39] = 6;
    sqrt_mem[40] = 6;
    sqrt_mem[41] = 6;
    sqrt_mem[42] = 6;
    sqrt_mem[43] = 6;
    sqrt_mem[44] = 6;
    sqrt_mem[45] = 6;
    sqrt_mem[46] = 6;
    sqrt_mem[47] = 6;
    sqrt_mem[48] = 6;
    sqrt_mem[49] = 7;
    sqrt_mem[50] = 7;
    sqrt_mem[51] = 7;
    sqrt_mem[52] = 7;
    sqrt_mem[53] = 7;
    sqrt_mem[54] = 7;
    sqrt_mem[55] = 7;
    sqrt_mem[56] = 7;
    sqrt_mem[57] = 7;
    sqrt_mem[58] = 7;
    sqrt_mem[59] = 7;
    sqrt_mem[60] = 7;
    sqrt_mem[61] = 7;
    sqrt_mem[62] = 7;
    sqrt_mem[63] = 7;
    sqrt_mem[64] = 8;
    sqrt_mem[65] = 8;
    sqrt_mem[66] = 8;
    sqrt_mem[67] = 8;
    sqrt_mem[68] = 8;
    sqrt_mem[69] = 8;
    sqrt_mem[70] = 8;
    sqrt_mem[71] = 8;
    sqrt_mem[72] = 8;
    sqrt_mem[73] = 8;
    sqrt_mem[74] = 8;
    sqrt_mem[75] = 8;
    sqrt_mem[76] = 8;
    sqrt_mem[77] = 8;
    sqrt_mem[78] = 8;
    sqrt_mem[79] = 8;
    sqrt_mem[80] = 8;
    sqrt_mem[81] = 9;
    sqrt_mem[82] = 9;
    sqrt_mem[83] = 9;
    sqrt_mem[84] = 9;
    sqrt_mem[85] = 9;
    sqrt_mem[86] = 9;
    sqrt_mem[87] = 9;
    sqrt_mem[88] = 9;
    sqrt_mem[89] = 9;
    sqrt_mem[90] = 9;
    sqrt_mem[91] = 9;
    sqrt_mem[92] = 9;
    sqrt_mem[93] = 9;
    sqrt_mem[94] = 9;
    sqrt_mem[95] = 9;
    sqrt_mem[96] = 9;
    sqrt_mem[97] = 9;
    sqrt_mem[98] = 9;
    sqrt_mem[99] = 9;
    sqrt_mem[100] = 10;
    sqrt_mem[101] = 10;
    sqrt_mem[102] = 10;
    sqrt_mem[103] = 10;
    sqrt_mem[104] = 10;
    sqrt_mem[105] = 10;
    sqrt_mem[106] = 10;
    sqrt_mem[107] = 10;
    sqrt_mem[108] = 10;
    sqrt_mem[109] = 10;
    sqrt_mem[110] = 10;
    sqrt_mem[111] = 10;
    sqrt_mem[112] = 10;
    sqrt_mem[113] = 10;
    sqrt_mem[114] = 10;
    sqrt_mem[115] = 10;
    sqrt_mem[116] = 10;
    sqrt_mem[117] = 10;
    sqrt_mem[118] = 10;
    sqrt_mem[119] = 10;
    sqrt_mem[120] = 10;
    sqrt_mem[121] = 11;
    sqrt_mem[122] = 11;
    sqrt_mem[123] = 11;
    sqrt_mem[124] = 11;
    sqrt_mem[125] = 11;
    sqrt_mem[126] = 11;
    sqrt_mem[127] = 11;
    sqrt_mem[128] = 11;
    sqrt_mem[129] = 11;
    sqrt_mem[130] = 11;
    sqrt_mem[131] = 11;
    sqrt_mem[132] = 11;
    sqrt_mem[133] = 11;
    sqrt_mem[134] = 11;
    sqrt_mem[135] = 11;
    sqrt_mem[136] = 11;
    sqrt_mem[137] = 11;
    sqrt_mem[138] = 11;
    sqrt_mem[139] = 11;
    sqrt_mem[140] = 11;
    sqrt_mem[141] = 11;
    sqrt_mem[142] = 11;
    sqrt_mem[143] = 11;
    sqrt_mem[144] = 12;
    sqrt_mem[145] = 12;
    sqrt_mem[146] = 12;
    sqrt_mem[147] = 12;
    sqrt_mem[148] = 12;
    sqrt_mem[149] = 12;
    sqrt_mem[150] = 12;
    sqrt_mem[151] = 12;
    sqrt_mem[152] = 12;
    sqrt_mem[153] = 12;
    sqrt_mem[154] = 12;
    sqrt_mem[155] = 12;
    sqrt_mem[156] = 12;
    sqrt_mem[157] = 12;
    sqrt_mem[158] = 12;
    sqrt_mem[159] = 12;
    sqrt_mem[160] = 12;
    sqrt_mem[161] = 12;
    sqrt_mem[162] = 12;
    sqrt_mem[163] = 12;
    sqrt_mem[164] = 12;
    sqrt_mem[165] = 12;
    sqrt_mem[166] = 12;
    sqrt_mem[167] = 12;
    sqrt_mem[168] = 12;
    sqrt_mem[169] = 13;
    sqrt_mem[170] = 13;
    sqrt_mem[171] = 13;
    sqrt_mem[172] = 13;
    sqrt_mem[173] = 13;
    sqrt_mem[174] = 13;
    sqrt_mem[175] = 13;
    sqrt_mem[176] = 13;
    sqrt_mem[177] = 13;
    sqrt_mem[178] = 13;
    sqrt_mem[179] = 13;
    sqrt_mem[180] = 13;
    sqrt_mem[181] = 13;
    sqrt_mem[182] = 13;
    sqrt_mem[183] = 13;
    sqrt_mem[184] = 13;
    sqrt_mem[185] = 13;
    sqrt_mem[186] = 13;
    sqrt_mem[187] = 13;
    sqrt_mem[188] = 13;
    sqrt_mem[189] = 13;
    sqrt_mem[190] = 13;
    sqrt_mem[191] = 13;
    sqrt_mem[192] = 13;
    sqrt_mem[193] = 13;
    sqrt_mem[194] = 13;
    sqrt_mem[195] = 13;
    sqrt_mem[196] = 14;
    sqrt_mem[197] = 14;
    sqrt_mem[198] = 14;
    sqrt_mem[199] = 14;
    sqrt_mem[200] = 14;
    sqrt_mem[201] = 14;
    sqrt_mem[202] = 14;
    sqrt_mem[203] = 14;
    sqrt_mem[204] = 14;
    sqrt_mem[205] = 14;
    sqrt_mem[206] = 14;
    sqrt_mem[207] = 14;
    sqrt_mem[208] = 14;
    sqrt_mem[209] = 14;
    sqrt_mem[210] = 14;
    sqrt_mem[211] = 14;
    sqrt_mem[212] = 14;
    sqrt_mem[213] = 14;
    sqrt_mem[214] = 14;
    sqrt_mem[215] = 14;
    sqrt_mem[216] = 14;
    sqrt_mem[217] = 14;
    sqrt_mem[218] = 14;
    sqrt_mem[219] = 14;
    sqrt_mem[220] = 14;
    sqrt_mem[221] = 14;
    sqrt_mem[222] = 14;
    sqrt_mem[223] = 14;
    sqrt_mem[224] = 14;
    sqrt_mem[225] = 15;
    sqrt_mem[226] = 15;
    sqrt_mem[227] = 15;
    sqrt_mem[228] = 15;
    sqrt_mem[229] = 15;
    sqrt_mem[230] = 15;
    sqrt_mem[231] = 15;
    sqrt_mem[232] = 15;
    sqrt_mem[233] = 15;
    sqrt_mem[234] = 15;
    sqrt_mem[235] = 15;
    sqrt_mem[236] = 15;
    sqrt_mem[237] = 15;
    sqrt_mem[238] = 15;
    sqrt_mem[239] = 15;
    sqrt_mem[240] = 15;
    sqrt_mem[241] = 15;
    sqrt_mem[242] = 15;
    sqrt_mem[243] = 15;
    sqrt_mem[244] = 15;
    sqrt_mem[245] = 15;
    sqrt_mem[246] = 15;
    sqrt_mem[247] = 15;
    sqrt_mem[248] = 15;
    sqrt_mem[249] = 15;
    sqrt_mem[250] = 15;
    sqrt_mem[251] = 15;
    sqrt_mem[252] = 15;
    sqrt_mem[253] = 15;
    sqrt_mem[254] = 15;
    sqrt_mem[255] = 15;
end

// RGB coefficients for RGB to grayscale conversion
localparam [3:0]R_COEFF = 4'd5;
localparam [3:0]G_COEFF = 4'd9;
localparam [3:0]B_COEFF = 4'd2;

// custom and sobel kernels for image processing
reg signed [3:0]custom_kernel [8:0];
initial begin
    custom_kernel[0] =  0; custom_kernel[1] = -1; custom_kernel[2] =  0;
    custom_kernel[3] = -1; custom_kernel[4] =  5; custom_kernel[5] = -1;
    custom_kernel[6] =  0; custom_kernel[7] = -1; custom_kernel[8] =  0;
end
reg signed [3:0]sobel_x [8:0];
initial begin
    sobel_x[0] = -1; sobel_x[1] = 0; sobel_x[2] = 1;
    sobel_x[3] = -2; sobel_x[4] = 0; sobel_x[5] = 2;
    sobel_x[6] = -1; sobel_x[7] = 0; sobel_x[8] = 1;
end
reg signed [3:0]sobel_y [8:0];
initial begin
    sobel_y[0] = -1; sobel_y[1] = -2; sobel_y[2] = -1;
    sobel_y[3] =  0; sobel_y[4] =  0; sobel_y[5] = 0;
    sobel_y[6] =  1; sobel_y[7] =  2; sobel_y[8] = 1;
end

// column idx, row idx calculation and temp_data to store respective pixel_datas for convolution
wire [9:0]col_num = in_wr_addr % 640;
wire [9:0]row_num = in_wr_addr / 640;
reg [15:0]temp_data [8:0];

// pipeline registers
reg [18:0]wr_addr_stage1, wr_addr_stage2, wr_addr_stage3, wr_addr_stage4, wr_addr_stage5, wr_addr_stage6, wr_addr_stage7, wr_addr_stage8, wr_addr_stage9;
reg [1:0]row_linebuff_stage1, row_linebuff_stage2, row_linebuff_stage3;
reg [9:0]row_stage1, row_stage2;
reg [9:0]col_stage1, col_stage2, col_stage3;
reg [7:0]partial_sum_stage1, partial_sum_stage2;
reg [11:0]rgb_stage1, rgb_stage2, rgb_stage3, rgb_stage4, rgb_stage5, rgb_stage6, rgb_stage7, rgb_stage8, rgb_stage9;
reg [3:0]grayscale_stage3, grayscale_stage4, grayscale_stage5, grayscale_stage6, grayscale_stage7, grayscale_stage8, grayscale_stage9;
reg signed [7:0]mult_data_r [8:0];
reg signed [7:0]mult_data_g [8:0];
reg signed [7:0]mult_data_b [8:0];
reg signed [7:0]mult_data_sobel_x [8:0];
reg signed [7:0]mult_data_sobel_y [8:0];
reg signed [8:0]add_mult_data_r, add_mult_data_g, add_mult_data_b, add_mult_data_sobel_x, add_mult_data_sobel_y;
reg [3:0]mac_o_data_r, mac_o_data_g, mac_o_data_b;
reg [11:0]mac_o_data_stage8, mac_o_data_stage9;
reg signed [17:0]add_mult_data_sobel_x2, add_mult_data_sobel_y2;
reg [17:0]mac_o_data_sobel_x2_y2;
reg [3:0]mac_o_data_sobel;
reg valid_stage1, valid_stage2, valid_stage3, valid_stage4, valid_stage5, valid_stage6, valid_stage7, valid_stage8, valid_stage9, valid_stage10;

// adjusted red, green, blue pixel_data values for brightness control
wire [3:0]in_pixel_data_red_adj = ($signed({1'b0,in_pixel_data[11:8]})+offset < 0) ? 0 : (($signed({1'b0,in_pixel_data[11:8]})+offset > 15) ? 15 : $signed({1'b0,in_pixel_data[11:8]})+offset);
wire [3:0]in_pixel_data_green_adj = ($signed({1'b0,in_pixel_data[7:4]})+offset < 0) ? 0 : (($signed({1'b0,in_pixel_data[7:4]})+offset > 15) ? 15 : $signed({1'b0,in_pixel_data[7:4]})+offset);
wire [3:0]in_pixel_data_blue_adj = ($signed({1'b0,in_pixel_data[3:0]})+offset < 0) ? 0 : (($signed({1'b0,in_pixel_data[3:0]})+offset > 15) ? 15 : $signed({1'b0,in_pixel_data[3:0]})+offset);


// line_buffer instantiations and their signals
reg line_buff0_wr_en, line_buff1_wr_en, line_buff2_wr_en;
wire [(WIDTH*3)-1:0]line_buff0_dout, line_buff1_dout, line_buff2_dout;
line_buffer #(.WIDTH(WIDTH), .SIZE(SIZE)) line_buff0 (
    .clk(clk),
    .wr_en(line_buff0_wr_en),
    .wr_addr(col_stage2),
    .rd_en(valid_stage3),
    .rd_addr(col_stage3),   // col_stage2
    .line_buff_din({partial_sum_stage2[7:4], rgb_stage2}),
    .line_buff_dout(line_buff0_dout)
);
line_buffer #(.WIDTH(WIDTH), .SIZE(SIZE)) line_buff1 (
    .clk(clk),
    .wr_en(line_buff1_wr_en),
    .wr_addr(col_stage2),
    .rd_en(valid_stage3),
    .rd_addr(col_stage3),   // col_stage2
    .line_buff_din({partial_sum_stage2[7:4], rgb_stage2}),
    .line_buff_dout(line_buff1_dout)
);
line_buffer #(.WIDTH(WIDTH), .SIZE(SIZE)) line_buff2 (
    .clk(clk),
    .wr_en(line_buff2_wr_en),
    .wr_addr(col_stage2),
    .rd_en(valid_stage3),
    .rd_addr(col_stage3),   // col_stage2
    .line_buff_din({partial_sum_stage2[7:4], rgb_stage2}),
    .line_buff_dout(line_buff2_dout)
);


// Stage 1: Read RGB444 and compute R*5 + G*9
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage1 <= 0;
        wr_addr_stage1 <= 0;
        rgb_stage1 <= 0;
        partial_sum_stage1 <= 0;
        row_linebuff_stage1 <= 0;
        row_stage1 <= 0;
        col_stage1 <= 0;
    end 
    else begin
        valid_stage1 <= 1;
        rgb_stage1 <= {in_pixel_data_red_adj, in_pixel_data_green_adj, in_pixel_data_blue_adj};
        partial_sum_stage1 <= (in_pixel_data_red_adj * R_COEFF) + (in_pixel_data_green_adj * G_COEFF);
        row_linebuff_stage1 <= row_num%3;
        row_stage1 <= row_num;
        col_stage1 <= col_num;
        wr_addr_stage1 <= in_wr_addr;
    end
end

// Stage 2: Add B*2 to partial sum
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage2 <= 0;
        wr_addr_stage2 <= 0;
        rgb_stage2 <= 0;
        partial_sum_stage2 <= 0;        
        row_linebuff_stage2 <= 0;
        row_stage2 <= 0;
        col_stage2 <= 0;
    end 
    else begin
        valid_stage2 <= valid_stage1 ? valid_stage1 : 0;
        partial_sum_stage2 <= partial_sum_stage1 + (rgb_stage1[3:0] * B_COEFF);
        rgb_stage2 <= rgb_stage1;
        row_linebuff_stage2 <= row_linebuff_stage1;
        row_stage2 <= row_stage1;
        col_stage2 <= col_stage1;
        wr_addr_stage2 <= wr_addr_stage1;
    end
end

// Stage 3: Read grayscale 4bit data and store it along with rgb444 in line buffer {grayscale_4bit, rgb444_12bit}
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage3 <= 0;
        wr_addr_stage3 <= 0;
        rgb_stage3 <= 0;
        grayscale_stage3 <= 0;
        row_linebuff_stage3 <= 0;
        col_stage3 <= 0;
        {line_buff0_wr_en, line_buff1_wr_en, line_buff2_wr_en} <= 3'b000;
    end
    else begin
        valid_stage3 <= (row_stage2==0 || row_stage2==1 || (row_stage2==2 && col_stage2<2) || col_stage2<2) ? 0 : 1;
        case (row_linebuff_stage2)
            0: {line_buff0_wr_en, line_buff1_wr_en, line_buff2_wr_en} <= 3'b100;
            1: {line_buff0_wr_en, line_buff1_wr_en, line_buff2_wr_en} <= 3'b010;
            2: {line_buff0_wr_en, line_buff1_wr_en, line_buff2_wr_en} <= 3'b001;
        endcase
        rgb_stage3 <= rgb_stage2;
        grayscale_stage3 <= partial_sum_stage2[7:4];
        row_linebuff_stage3 <= row_linebuff_stage2;
        col_stage3 <= col_stage2;
        wr_addr_stage3 <= wr_addr_stage2;
    end
end

// Stage 4: assign temp_data for further convolution 
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage4 <= 0;
        wr_addr_stage4 <= 0;
        rgb_stage4 <= 0;
        grayscale_stage4 <= 0;
    end 
    else begin
        wr_addr_stage4 <= wr_addr_stage3;
        rgb_stage4 <= rgb_stage3;
        grayscale_stage4 <= grayscale_stage3;
        if (valid_stage3) begin
            case (row_linebuff_stage3)
                0: begin
                    {temp_data[0], temp_data[1], temp_data[2]}  <= line_buff1_dout;
                    {temp_data[3], temp_data[4], temp_data[5]}  <= line_buff2_dout;
                    {temp_data[6], temp_data[7], temp_data[8]}  <= line_buff0_dout;
                end
                1: begin
                    {temp_data[0], temp_data[1], temp_data[2]}  <= line_buff2_dout;
                    {temp_data[3], temp_data[4], temp_data[5]}  <= line_buff0_dout;
                    {temp_data[6], temp_data[7], temp_data[8]}  <= line_buff1_dout;
                end
                2: begin
                    {temp_data[0], temp_data[1], temp_data[2]}  <= line_buff0_dout;
                    {temp_data[3], temp_data[4], temp_data[5]}  <= line_buff1_dout;
                    {temp_data[6], temp_data[7], temp_data[8]}  <= line_buff2_dout;
                end
            endcase
            valid_stage4 <= valid_stage3;
        end 
        else valid_stage4 <= 0;
    end
end

// Stage 5: perform convolution of temp_data[rgb444] with custom_kernel, convolution of temp_data[grayscale] with sobel_x and sobel_y kernels
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage5 <= 0;
        wr_addr_stage5 <= 0;
        rgb_stage5 <= 0;
        grayscale_stage5 <= 0;
        {mult_data_r[0], mult_data_r[1], mult_data_r[2], mult_data_r[3], mult_data_r[4], mult_data_r[5], mult_data_r[6], mult_data_r[7], mult_data_r[8]} <= 0;
        {mult_data_g[0], mult_data_g[1], mult_data_g[2], mult_data_g[3], mult_data_g[4], mult_data_g[5], mult_data_g[6], mult_data_g[7], mult_data_g[8]} <= 0;
        {mult_data_b[0], mult_data_b[1], mult_data_b[2], mult_data_b[3], mult_data_b[4], mult_data_b[5], mult_data_b[6], mult_data_b[7], mult_data_b[8]} <= 0;
        {mult_data_sobel_x[0], mult_data_sobel_x[1], mult_data_sobel_x[2], mult_data_sobel_x[3], mult_data_sobel_x[4], mult_data_sobel_x[5], mult_data_sobel_x[6], mult_data_sobel_x[7], mult_data_sobel_x[8]} <= 0;
        {mult_data_sobel_y[0], mult_data_sobel_y[1], mult_data_sobel_y[2], mult_data_sobel_y[3], mult_data_sobel_y[4], mult_data_sobel_y[5], mult_data_sobel_y[6], mult_data_sobel_y[7], mult_data_sobel_y[8]} <= 0;
    end 
    else begin
        wr_addr_stage5 <= wr_addr_stage4;
        rgb_stage5 <= rgb_stage4;
        grayscale_stage5 <= grayscale_stage4;
        if (valid_stage4) begin
            // custom kernel convolution with rgb444 pixel data
            mult_data_r[0] <= $signed({1'b0, temp_data[0][11:8]}) * $signed(custom_kernel[0]);
            mult_data_r[1] <= $signed({1'b0, temp_data[1][11:8]}) * $signed(custom_kernel[1]);
            mult_data_r[2] <= $signed({1'b0, temp_data[2][11:8]}) * $signed(custom_kernel[2]);
            mult_data_r[3] <= $signed({1'b0, temp_data[3][11:8]}) * $signed(custom_kernel[3]);
            mult_data_r[4] <= $signed({1'b0, temp_data[4][11:8]}) * $signed(custom_kernel[4]);
            mult_data_r[5] <= $signed({1'b0, temp_data[5][11:8]}) * $signed(custom_kernel[5]);
            mult_data_r[6] <= $signed({1'b0, temp_data[6][11:8]}) * $signed(custom_kernel[6]);
            mult_data_r[7] <= $signed({1'b0, temp_data[7][11:8]}) * $signed(custom_kernel[7]);
            mult_data_r[8] <= $signed({1'b0, temp_data[8][11:8]}) * $signed(custom_kernel[8]);
            
            mult_data_g[0] <= $signed({1'b0, temp_data[0][7:4]}) * $signed(custom_kernel[0]);
            mult_data_g[1] <= $signed({1'b0, temp_data[1][7:4]}) * $signed(custom_kernel[1]);
            mult_data_g[2] <= $signed({1'b0, temp_data[2][7:4]}) * $signed(custom_kernel[2]);
            mult_data_g[3] <= $signed({1'b0, temp_data[3][7:4]}) * $signed(custom_kernel[3]);
            mult_data_g[4] <= $signed({1'b0, temp_data[4][7:4]}) * $signed(custom_kernel[4]);
            mult_data_g[5] <= $signed({1'b0, temp_data[5][7:4]}) * $signed(custom_kernel[5]);
            mult_data_g[6] <= $signed({1'b0, temp_data[6][7:4]}) * $signed(custom_kernel[6]);
            mult_data_g[7] <= $signed({1'b0, temp_data[7][7:4]}) * $signed(custom_kernel[7]);
            mult_data_g[8] <= $signed({1'b0, temp_data[8][7:4]}) * $signed(custom_kernel[8]);
            
            mult_data_b[0] <= $signed({1'b0, temp_data[0][3:0]}) * $signed(custom_kernel[0]);
            mult_data_b[1] <= $signed({1'b0, temp_data[1][3:0]}) * $signed(custom_kernel[1]);
            mult_data_b[2] <= $signed({1'b0, temp_data[2][3:0]}) * $signed(custom_kernel[2]);
            mult_data_b[3] <= $signed({1'b0, temp_data[3][3:0]}) * $signed(custom_kernel[3]);
            mult_data_b[4] <= $signed({1'b0, temp_data[4][3:0]}) * $signed(custom_kernel[4]);
            mult_data_b[5] <= $signed({1'b0, temp_data[5][3:0]}) * $signed(custom_kernel[5]);
            mult_data_b[6] <= $signed({1'b0, temp_data[6][3:0]}) * $signed(custom_kernel[6]);
            mult_data_b[7] <= $signed({1'b0, temp_data[7][3:0]}) * $signed(custom_kernel[7]);
            mult_data_b[8] <= $signed({1'b0, temp_data[8][3:0]}) * $signed(custom_kernel[8]);
            
            // sobel_x and sobel_y kernel convolution with grayscale pixel data
            mult_data_sobel_x[0] <= $signed({1'b0, temp_data[0][15:12]}) * $signed(sobel_x[0]);
            mult_data_sobel_x[1] <= $signed({1'b0, temp_data[1][15:12]}) * $signed(sobel_x[1]);
            mult_data_sobel_x[2] <= $signed({1'b0, temp_data[2][15:12]}) * $signed(sobel_x[2]);
            mult_data_sobel_x[3] <= $signed({1'b0, temp_data[3][15:12]}) * $signed(sobel_x[3]);
            mult_data_sobel_x[4] <= $signed({1'b0, temp_data[4][15:12]}) * $signed(sobel_x[4]);
            mult_data_sobel_x[5] <= $signed({1'b0, temp_data[5][15:12]}) * $signed(sobel_x[5]);
            mult_data_sobel_x[6] <= $signed({1'b0, temp_data[6][15:12]}) * $signed(sobel_x[6]);
            mult_data_sobel_x[7] <= $signed({1'b0, temp_data[7][15:12]}) * $signed(sobel_x[7]);
            mult_data_sobel_x[8] <= $signed({1'b0, temp_data[8][15:12]}) * $signed(sobel_x[8]);
            
            mult_data_sobel_y[0] <= $signed({1'b0, temp_data[0][15:12]}) * $signed(sobel_y[0]);
            mult_data_sobel_y[1] <= $signed({1'b0, temp_data[1][15:12]}) * $signed(sobel_y[1]);
            mult_data_sobel_y[2] <= $signed({1'b0, temp_data[2][15:12]}) * $signed(sobel_y[2]);
            mult_data_sobel_y[3] <= $signed({1'b0, temp_data[3][15:12]}) * $signed(sobel_y[3]);
            mult_data_sobel_y[4] <= $signed({1'b0, temp_data[4][15:12]}) * $signed(sobel_y[4]);
            mult_data_sobel_y[5] <= $signed({1'b0, temp_data[5][15:12]}) * $signed(sobel_y[5]);
            mult_data_sobel_y[6] <= $signed({1'b0, temp_data[6][15:12]}) * $signed(sobel_y[6]);
            mult_data_sobel_y[7] <= $signed({1'b0, temp_data[7][15:12]}) * $signed(sobel_y[7]);
            mult_data_sobel_y[8] <= $signed({1'b0, temp_data[8][15:12]}) * $signed(sobel_y[8]);
            
            valid_stage5 <= valid_stage4;
        end 
        else valid_stage5 <= 0;
    end
end

// Stage 6: accumulate the partial products of convolution multiplication and store them in respective variables 
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage6 <= 0;
        wr_addr_stage6 <= 0;
        rgb_stage6 <= 0;
        grayscale_stage6 <= 0;
        {add_mult_data_r, add_mult_data_g, add_mult_data_b} <= 0;
        add_mult_data_sobel_x <= 0;
        add_mult_data_sobel_y <= 0;
    end 
    else begin
        wr_addr_stage6 <= wr_addr_stage5;
        rgb_stage6 <= rgb_stage5;
        grayscale_stage6 <= grayscale_stage5;
        if (valid_stage5) begin
            add_mult_data_r <= mult_data_r[0] + mult_data_r[1] + mult_data_r[2] + mult_data_r[3] + mult_data_r[4] + mult_data_r[5] + mult_data_r[6] + mult_data_r[7] + mult_data_r[8];
            add_mult_data_g <= mult_data_g[0] + mult_data_g[1] + mult_data_g[2] + mult_data_g[3] + mult_data_g[4] + mult_data_g[5] + mult_data_g[6] + mult_data_g[7] + mult_data_g[8];
            add_mult_data_b <= mult_data_b[0] + mult_data_b[1] + mult_data_b[2] + mult_data_b[3] + mult_data_b[4] + mult_data_b[5] + mult_data_b[6] + mult_data_b[7] + mult_data_b[8];
            add_mult_data_sobel_x <= mult_data_sobel_x[0] + mult_data_sobel_x[1] + mult_data_sobel_x[2] + mult_data_sobel_x[3] + mult_data_sobel_x[4] + mult_data_sobel_x[5] + mult_data_sobel_x[6] + mult_data_sobel_x[7] + mult_data_sobel_x[8];
            add_mult_data_sobel_y <= mult_data_sobel_y[0] + mult_data_sobel_y[1] + mult_data_sobel_y[2] + mult_data_sobel_y[3] + mult_data_sobel_y[4] + mult_data_sobel_y[5] + mult_data_sobel_y[6] + mult_data_sobel_y[7] + mult_data_sobel_y[8];
            valid_stage6 <= valid_stage5;
        end 
        else valid_stage6 <= 0;
    end
end

// Stage 7: check for over flow and under flow of each colors custom_kernel convolution and square the sobel_x convolution and sobel_y convolution
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage7 <= 0;
        wr_addr_stage7 <= 0;
        rgb_stage7 <= 0;
        grayscale_stage7 <= 0;
        {mac_o_data_r, mac_o_data_g, mac_o_data_b} <= 0;        
        add_mult_data_sobel_x2 <= 0;
        add_mult_data_sobel_y2 <= 0;
    end 
    else begin
        wr_addr_stage7 <= wr_addr_stage6;
        rgb_stage7 <= rgb_stage6;
        grayscale_stage7 <= grayscale_stage6;
        if (valid_stage6) begin
            if (add_mult_data_r[8]) mac_o_data_r <= 4'h0;
            else if (add_mult_data_r > 15) mac_o_data_r <= 4'hf;
            else mac_o_data_r <= add_mult_data_r[3:0];
            
            if (add_mult_data_g[8]) mac_o_data_g <= 4'h0;
            else if (add_mult_data_g > 15) mac_o_data_g <= 4'hf;
            else mac_o_data_g <= add_mult_data_g[3:0];
            
            if (add_mult_data_b[8]) mac_o_data_b <= 4'h0;
            else if (add_mult_data_b > 15) mac_o_data_b <= 4'hf;
            else mac_o_data_b <= add_mult_data_b[3:0];
            
            add_mult_data_sobel_x2 <= add_mult_data_sobel_x * add_mult_data_sobel_x;
            add_mult_data_sobel_y2 <= add_mult_data_sobel_y * add_mult_data_sobel_y;
            
            valid_stage7 <= valid_stage6;
        end 
        else valid_stage7 <= 0;
    end
end

// Stage 8: combine all 3 colors custom_kernel convolution into final custom_kernel convolution result, add the squared sobel_x convolution and sobel_y convolution outputs 
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage8 <= 0;
        wr_addr_stage8 <= 0;
        rgb_stage8 <= 0;
        grayscale_stage8 <= 0;
        mac_o_data_stage8 <= 0;
        mac_o_data_sobel_x2_y2 <= 0;
    end 
    else begin
        wr_addr_stage8 <= wr_addr_stage7;
        rgb_stage8 <= rgb_stage7;
        grayscale_stage8 <= grayscale_stage7;
        if (valid_stage7) begin
            mac_o_data_stage8 <= {mac_o_data_r, mac_o_data_g, mac_o_data_b};
            mac_o_data_sobel_x2_y2 <= add_mult_data_sobel_x2 + add_mult_data_sobel_y2;
            valid_stage8 <= valid_stage7;
        end 
        else valid_stage8 <= 0;
    end
end

// Stage 9: take square root of the sum of squares and check for over flow and under flow of sobel convolution
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage9 <= 0;
        wr_addr_stage9 <= 0;
        rgb_stage9 <= 0;
        grayscale_stage9 <= 0;
        mac_o_data_stage9 <= 0;
    end 
    else begin
        wr_addr_stage9 <= wr_addr_stage8;
        rgb_stage9 <= rgb_stage8;
        grayscale_stage9 <= grayscale_stage8;
        if (valid_stage8) begin
            mac_o_data_stage9 <= mac_o_data_stage8;
            mac_o_data_sobel <= (mac_o_data_sobel_x2_y2 > 255) ? 4'hf : sqrt_mem[mac_o_data_sobel_x2_y2];
            valid_stage9 <= valid_stage8;
        end 
        else valid_stage9 <= 0;
    end
end

// Stage 10: with mode value multiplex [RGB, grayscale, sobel convolution, custom_kernel convolution] result to output
always @(posedge rst or posedge clk) begin
    if (rst) begin
        valid_stage10 <= 0;
        out_pixel_data <= 0;
        output_start <= 0;
        out_wr_addr <= 0;
    end 
    else begin
        case ({mode,valid_stage9})   // rgb_stage9 (rgb444 12bit)  |  grayscale_stage9 (gray 4bit)  |  mac_o_data_stage9 (conv_output 12bit)  |  mac_o_data_sobel (sobel_output 4bit)
            3'b000: out_pixel_data <= rgb_stage9;
            3'b001: out_pixel_data <= rgb_stage9;
            3'b010: out_pixel_data <= {3{grayscale_stage9}};
            3'b011: out_pixel_data <= {3{grayscale_stage9}};
            3'b101: out_pixel_data <= {3{mac_o_data_sobel}};
            3'b111: out_pixel_data <= mac_o_data_stage9;
            default: out_pixel_data <= out_pixel_data;
        endcase
        out_wr_addr <= (mode==2'b00 || mode==2'b01 || valid_stage9) ? wr_addr_stage9 : out_wr_addr;
        valid_stage10 <= valid_stage9 ? valid_stage9 : 0;
        output_start <= valid_stage10;
    end
end

endmodule

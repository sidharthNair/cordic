module cordic_clocked(
    input wire clk,
    input wire rst,
    input wire signed [31:0] theta,
    output wire signed [31:0] cos_out,
    output wire signed [31:0] sin_out,
    output wire done
);
    `define TERMS 15

    wire signed [31:0] atan [0:`TERMS-1];
    assign atan[0]  = 32'h3243f6c0;
    assign atan[1]  = 32'h1dac6700;
    assign atan[2]  = 32'h0fadbb00;
    assign atan[3]  = 32'h07f56ea8;
    assign atan[4]  = 32'h03feab78;
    assign atan[5]  = 32'h01ffd55c;
    assign atan[6]  = 32'h00fffaab;
    assign atan[7]  = 32'h007fff55;
    assign atan[8]  = 32'h003fffea;
    assign atan[9]  = 32'h001ffffd;
    assign atan[10] = 32'h000fffff;
    assign atan[11] = 32'h0007ffff;
    assign atan[12] = 32'h00040000;
    assign atan[13] = 32'h00020000;
    assign atan[14] = 32'h00010000;

    wire signed [31:0] gain;
    assign gain = 32'h26dd3b80;

    reg [31:0] x_curr, y_curr, theta_curr, atan_curr;
    reg [4:0] i;

    wire [31:0] x_new, y_new, theta_new;

    cordic_block cordic(.x_in(x_curr),
                        .y_in(y_curr),
                        .theta_in(theta_curr),
                        .atan(atan_curr),
                        .i(i),
                        .x_out(x_new),
                        .y_out(y_new),
                        .theta_out(theta_new));

    assign done = (i == (`TERMS - 1));

    always @(posedge clk or posedge rst) begin
    if (rst) begin
        x_curr <= gain;
        y_curr <= 32'b0;
        theta_curr <= theta;
        atan_curr <= atan[0];
        i <= 5'b0;
    end else if (!done) begin
        x_curr <= x_new;
        y_curr <= y_new;
        theta_curr <= theta_new;
        atan_curr <= atan[i + 1];
        i <= i + 1;
    end
end

assign cos_out = done ? x_new : 32'bz;
assign sin_out = done ? y_new : 32'bz;

endmodule

module cordic_comb(
    input wire signed [31:0] theta,
    output wire signed [31:0] cos_out,
    output wire signed [31:0] sin_out
);
    `define TERMS 15

    wire signed [31:0] atan [0:`TERMS-1];
    assign atan[0]  = 32'h3243f6c0;
    assign atan[1]  = 32'h1dac6700;
    assign atan[2]  = 32'h0fadbb00;
    assign atan[3]  = 32'h07f56ea8;
    assign atan[4]  = 32'h03feab78;
    assign atan[5]  = 32'h01ffd55c;
    assign atan[6]  = 32'h00fffaab;
    assign atan[7]  = 32'h007fff55;
    assign atan[8]  = 32'h003fffea;
    assign atan[9]  = 32'h001ffffd;
    assign atan[10] = 32'h000fffff;
    assign atan[11] = 32'h0007ffff;
    assign atan[12] = 32'h00040000;
    assign atan[13] = 32'h00020000;
    assign atan[14] = 32'h00010000;

    wire signed [31:0] x [0:`TERMS-1];
    wire signed [31:0] y [0:`TERMS-1];
    wire signed [31:0] t [0:`TERMS];

    assign x[0] = 32'h26dd3b80;
    assign y[0] = 32'b0;
    assign t[0] = theta;

    cordic_block c0(.x_in(x[0]), .y_in(y[0]), .theta_in(t[0]), .atan(atan[0]), .i(5'b00000), .x_out(x[1]), .y_out(y[1]), .theta_out(t[1]));
    cordic_block c1(.x_in(x[1]), .y_in(y[1]), .theta_in(t[1]), .atan(atan[1]), .i(5'b00001), .x_out(x[2]), .y_out(y[2]), .theta_out(t[2]));
    cordic_block c2(.x_in(x[2]), .y_in(y[2]), .theta_in(t[2]), .atan(atan[2]), .i(5'b00010), .x_out(x[3]), .y_out(y[3]), .theta_out(t[3]));
    cordic_block c3(.x_in(x[3]), .y_in(y[3]), .theta_in(t[3]), .atan(atan[3]), .i(5'b00011), .x_out(x[4]), .y_out(y[4]), .theta_out(t[4]));
    cordic_block c4(.x_in(x[4]), .y_in(y[4]), .theta_in(t[4]), .atan(atan[4]), .i(5'b00100), .x_out(x[5]), .y_out(y[5]), .theta_out(t[5]));
    cordic_block c5(.x_in(x[5]), .y_in(y[5]), .theta_in(t[5]), .atan(atan[5]), .i(5'b00101), .x_out(x[6]), .y_out(y[6]), .theta_out(t[6]));
    cordic_block c6(.x_in(x[6]), .y_in(y[6]), .theta_in(t[6]), .atan(atan[6]), .i(5'b00110), .x_out(x[7]), .y_out(y[7]), .theta_out(t[7]));
    cordic_block c7(.x_in(x[7]), .y_in(y[7]), .theta_in(t[7]), .atan(atan[7]), .i(5'b00111), .x_out(x[8]), .y_out(y[8]), .theta_out(t[8]));
    cordic_block c8(.x_in(x[8]), .y_in(y[8]), .theta_in(t[8]), .atan(atan[8]), .i(5'b01000), .x_out(x[9]), .y_out(y[9]), .theta_out(t[9]));
    cordic_block c9(.x_in(x[9]), .y_in(y[9]), .theta_in(t[9]), .atan(atan[9]), .i(5'b01001), .x_out(x[10]), .y_out(y[10]), .theta_out(t[10]));
    cordic_block c10(.x_in(x[10]), .y_in(y[10]), .theta_in(t[10]), .atan(atan[10]), .i(5'b01010), .x_out(x[11]), .y_out(y[11]), .theta_out(t[11]));
    cordic_block c11(.x_in(x[11]), .y_in(y[11]), .theta_in(t[11]), .atan(atan[11]), .i(5'b01011), .x_out(x[12]), .y_out(y[12]), .theta_out(t[12]));
    cordic_block c12(.x_in(x[12]), .y_in(y[12]), .theta_in(t[12]), .atan(atan[12]), .i(5'b01100), .x_out(x[13]), .y_out(y[13]), .theta_out(t[13]));
    cordic_block c13(.x_in(x[13]), .y_in(y[13]), .theta_in(t[13]), .atan(atan[13]), .i(5'b01101), .x_out(x[14]), .y_out(y[14]), .theta_out(t[14]));
    cordic_block c14(.x_in(x[14]), .y_in(y[14]), .theta_in(t[14]), .atan(atan[14]), .i(5'b01110), .x_out(cos_out), .y_out(sin_out), .theta_out(t[15]));

endmodule
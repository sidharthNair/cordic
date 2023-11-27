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
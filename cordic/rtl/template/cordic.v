module cordic_clocked(
    input wire clk,
    input wire rst,
    input wire signed [31:0] theta,
    output wire signed [31:0] cos_out,
    output wire signed [31:0] sin_out,
    output wire done
);
    `define TERMS __TERMS__

    wire signed [31:0] atan [0:`TERMS-1];
__ASSIGN_ATAN__

    wire signed [31:0] gain;
    assign gain = __GAIN__;

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
    `define TERMS __TERMS__

    wire signed [31:0] atan [0:`TERMS-1];
__ASSIGN_ATAN__

    wire signed [31:0] x [0:`TERMS-1];
    wire signed [31:0] y [0:`TERMS-1];
    wire signed [31:0] t [0:`TERMS];

    assign x[0] = __GAIN__;
    assign y[0] = 32'b0;
    assign t[0] = theta;

__CORDIC_BLOCKS__

endmodule

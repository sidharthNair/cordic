module cordic_block(
    input wire signed [31:0] x_in,
    input wire signed [31:0] y_in,
    input wire signed [31:0] theta_in,
    input wire signed [31:0] atan,
    input wire [4:0] i,
    output wire signed [31:0] x_out,
    output wire signed [31:0] y_out,
    output wire signed [31:0] theta_out
);

wire theta_neg;
assign theta_neg = theta_in[31];

assign x_out = theta_neg ? x_in + (y_in >> i) : x_in - (y_in >> i);
assign y_out = theta_neg ? y_in - (x_in >> i) : y_in + (x_in >> i);
assign theta_out = theta_neg ? theta_in + atan : theta_in - atan;

endmodule;

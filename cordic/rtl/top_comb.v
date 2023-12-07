module top (
    input wire clk,
    input wire signed [31:0] theta,
    output wire signed [31:0] cos_comb_out,
    output wire signed [31:0] sin_comb_out
);

    cordic_comb cordic2(.theta(theta),
                        .cos_out(cos_comb_out),
                        .sin_out(sin_comb_out));

endmodule

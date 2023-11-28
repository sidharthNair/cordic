module top;

    wire signed [31:0] theta, cos_comb_out, sin_comb_out;

    cordic_comb cordic2(.theta(theta),
                        .cos_out(cos_comb_out),
                        .sin_out(sin_comb_out));

endmodule

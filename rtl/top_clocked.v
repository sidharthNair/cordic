module top;

    reg clk, rst;
    wire signed [31:0] theta, cos_clocked_out, sin_clocked_out;
    wire done;

    cordic_clocked cordic1(.clk(clk),
                            .rst(rst),
                            .theta(theta),
                            .cos_out(cos_clocked_out),
                            .sin_out(sin_clocked_out),
                            .done(done));

endmodule

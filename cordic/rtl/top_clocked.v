module top (
    input wire clk,
    input wire rst,
    input wire signed [31:0] theta,
    output wire signed [31:0] cos_clocked_out,
    output wire signed [31:0] sin_clocked_out,
    output wire done
);

    cordic_clocked cordic1(.clk(clk),
                            .rst(rst),
                            .theta(theta),
                            .cos_out(cos_clocked_out),
                            .sin_out(sin_clocked_out),
                            .done(done));

endmodule

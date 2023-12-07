module top;

    reg clk, rst;
    reg [31:0] theta;
    wire signed [31:0] theta, cos_clocked_out, sin_clocked_out, cos_comb_out, sin_comb_out, cos_hybrid_out, sin_hybrid_out;
    wire done1, done2;

    cordic_clocked cordic1(.clk(clk),
                            .rst(rst),
                            .theta(theta),
                            .cos_out(cos_clocked_out),
                            .sin_out(sin_clocked_out),
                            .done(done1));

    cordic_comb cordic2(.theta(theta),
                        .cos_out(cos_comb_out),
                        .sin_out(sin_comb_out));

    cordic_hybrid cordic3(.clk(clk),
                            .rst(rst),
                            .theta(theta),
                            .cos_out(cos_hybrid_out),
                            .sin_out(sin_hybrid_out),
                            .done(done2));

    initial begin
        clk = 0;
        theta = 32'h00000000;
    end

    always begin
        #5 clk = 1;
        #5 clk = 0;
    end

    initial begin
        rst = 1;
        @(posedge clk); #1
        theta = 32'h2cae3080;
        @(posedge clk); #1
        rst = 0;
	end

endmodule

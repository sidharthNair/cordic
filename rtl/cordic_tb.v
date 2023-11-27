module top;

    reg clk, rst;
    wire signed [31:0] theta, cos_clocked_out, sin_clocked_out, cos_comb_out, sin_comb_out;
    wire done;

    assign theta = 32'h2cae3080;

    cordic_clocked cordic1(.clk(clk),
                            .rst(rst),
                            .theta(theta),
                            .cos_out(cos_clocked_out),
                            .sin_out(sin_clocked_out),
                            .done(done));

    cordic_comb cordic2(.theta(theta),
                        .cos_out(cos_comb_out),
                        .sin_out(sin_comb_out));

    initial begin
        clk = 0;
    end

    always begin
        #5 clk = 1;
        #5 clk = 0;
    end

    initial begin
        rst = 1;
        @(posedge clk); #1
        @(posedge clk); #1
        rst = 0;
	end

endmodule
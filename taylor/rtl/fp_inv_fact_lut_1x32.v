module fp_inv_fact_lut_2x1_s (
    input [1:0] base,
    output [31:0] result
);

    always @(*) begin
        case (base)
            2'b00: result = 32'h3f800000;   // 1*1/0! = 1
            2'b01: result = 32'hbf000000;   // -1*1/2! = -.5
            2'b10: result = 32'h3d2aaaab;   // 1*1/4! = 0.04166667
            2'b11: result = 32'hbab60b61;   // -1*1/6! = -0.00138889
        endcase
    end

endmodule
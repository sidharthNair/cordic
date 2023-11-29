module tb_cos_taylor();

    // Test cos_taylor.v

    reg clk;
    reg rst;
    reg [31:0] rad;
    wire [31:0] cosine;
    wire cosine_stb;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        rad = 32'h0;
        #10 rst = 1'b0;
        #50 rad = 32'h00000000; // 0 => 1
        #200 
        #50 rad = 32'h40490fdb; // pi => -1
        #200
        #50 rad = 32'h3fc90fdb; // pi/2 => 0
        #200
        $finish; 
    end

endmodule
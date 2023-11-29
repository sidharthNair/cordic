module tb_cos_taylor();

    // Test cos_taylor.v

    reg clk;
    reg rst;
    reg [31:0] rad;
    wire [31:0] cosine;
    wire cosine_stb;

    cos_taylor cos_taylor_inst(
        .clk(clk),
        .rst(rst),
        .rad(rad),
        .cosine(cosine),
        .cosine_stb(cosine_stb));
        
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;        
        rst = 1'b1;
        rad = 32'h0;
        #10 rst = 1'b0;
        #50 rad = 32'h00000000; // 0 => 1 
        #400 
        #50 rad = 32'h40490fdb; // pi => -1, -1.21135258675
        #1000
        #50 rad = 32'h3fc90fdb; // pi/2 => 0, -0.000894546508789
        #1000
        #50 rad = 32'h3f490fdb; // pi/4 => 0.707106781187 (actual is 0.707103252410888671875)
        #1000
        #50 rad = 32'h4016cbe4; // 3pi/4 => −0.707106781187
        #1000
        $finish; 
    end

endmodule
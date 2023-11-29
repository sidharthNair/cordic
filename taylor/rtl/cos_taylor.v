module cos_taylor (
        input clk,
        input rst,
        input [31:0] rad,
        output [31:0] cosine,
        output cosine_stb); 

    wire [31:0] x_squared_out;
    wire x_squared_out_stb;

    wire [31:0] x_fourth_out;
    wire x_fourth_out_stb;

    wire [31:0] second_term_out;
    wire second_term_out_stb;

    wire [31:0] third_term_out;
    wire third_term_out_stb;

    wire [31:0] fourth_term_partial_out;
    wire fourth_term_partial_out_stb;

    wire [31:0] fourth_term_out;
    wire fourth_term_out_stb;

    wire [31:0] outer_half_out;
    wire outer_half_out_stb;

    wire [31:0] inner_half_out;
    wire inner_half_out_stb;

    reg [31:0] prev_rad;
    always @(posedge clk) begin
        if (rst) begin
            prev_rad <= 32'h0;
        end else begin
            prev_rad <= rad;
        end
    end

    // generate x^2
    fp_mult2x32 x_squared(        
		.input_a(rad),
        .input_b(rad),
        .input_a_stb(1'b1),
        .input_b_stb(1'b1),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(x_squared_out),
        .output_z_stb(x_squared_out_stb),
        .input_a_ack(),
        .input_b_ack());

    // generate x^4
    fp_mult2x32 x_fourth(        
		.input_a(x_squared_out),
        .input_b(x_squared_out),
        .input_a_stb(x_squared_out_stb),
        .input_b_stb(x_squared_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(x_fourth_out),
        .output_z_stb(x_fourth_out_stb),
        .input_a_ack(),
        .input_b_ack());


    // second term
    // x^2 * -1/2!
    fp_mult2x32 second_term(        
		.input_a(32'hbf000000),
        .input_b(x_squared_out),
        .input_a_stb(1'b1),
        .input_b_stb(x_squared_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(second_term_out),
        .output_z_stb(second_term_out_stb),
        .input_a_ack(),
        .input_b_ack());

    // third term
    // (x^2 * x^2) * 1/4!
    fp_mult2x32 third_term(   
		.input_a(32'h3d2aaaab),
        .input_b(x_fourth_out),
        .input_a_stb(1'b1),
        .input_b_stb(x_fourth_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(third_term_out),
        .output_z_stb(third_term_out_stb),
        .input_a_ack(),
        .input_b_ack());

    // fourth term
    // (x^2 * x^2) * (x^2 * -1/6)!
    fp_mult2x32 fourth_term_partial(        
		.input_a(32'hbab60b61),
        .input_b(x_squared_out),
        .input_a_stb(1'b1),
        .input_b_stb(x_squared_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(fourth_term_partial_out),
        .output_z_stb(fourth_term_partial_out_stb),
        .input_a_ack(),
        .input_b_ack());

    fp_mult2x32 fourth_term(        
		.input_a(x_fourth_out),
        .input_b(fourth_term_partial_out),
        .input_a_stb(x_fourth_out_stb),
        .input_b_stb(fourth_term_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(fourth_term_out),
        .output_z_stb(fourth_term_out_stb),
        .input_a_ack(),
        .input_b_ack());

    // add outer two terms
    // add (1) + (x^2 * x^2 * x^2 * -1/6!)
    fp_adder_2x32 outer_half(
        .input_a(32'h3f800000),
        .input_b(fourth_term_out),
        .input_a_stb(1'b1),
        .input_b_stb(fourth_term_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(outer_half_out),
        .output_z_stb(outer_half_out_stb),
        .input_a_ack(),
        .input_b_ack());

    // add inner two terms
    // add (x^2 * -1/2!) + (x^2 * x^2 * x^2 * -1/6!)
    fp_adder_2x32 inner_half(
        .input_a(second_term_out),
        .input_b(third_term_out),
        .input_a_stb(second_term_out_stb),
        .input_b_stb(third_term_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(inner_half_out),
        .output_z_stb(inner_half_out_stb),
        .input_a_ack(),
        .input_b_ack());

    // result
    // add halves
    fp_adder_2x32 outer_half(
        .input_a(inner_half_out),
        .input_b(outer_half_out),
        .input_a_stb(inner_half_out_stb),
        .input_b_stb(outer_half_out_stb),
        .output_z_ack(rad != prev_rad),
        .clk(clk),
        .rst(rst),
        .output_z(cosine),
        .output_z_stb(cosine_stb),
        .input_a_ack(),
        .input_b_ack());

endmodule
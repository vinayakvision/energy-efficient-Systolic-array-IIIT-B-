
module systolic_top (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic        mem_we,
    input  logic [3:0]  mem_addr,
    input  logic [31:0] weight_din,
    input  logic [31:0] act_din,
    input  logic [31:0] layer_scale,
    output logic        done,
    output logic [63:0] Re1, Re2, Re3, Re4
);
    logic [31:0]  inP1, inP5, inP9, inP13;
    logic [511:0] weight_flat_out;

    systolic_control CTRL (
        .clk(clk), .rst(rst), .start(start),
        .mem_we(mem_we), .mem_addr(mem_addr),
        .weight_din(weight_din), .act_din(act_din),
        .layer_scale(layer_scale),
        .inP1(inP1), .inP5(inP5), .inP9(inP9), .inP13(inP13),
        .weight_flat_out(weight_flat_out),
        .done(done)
    );

    systolic_core CORE (
        .clk(clk), .rst(rst),
        .inP1(inP1), .inP5(inP5), .inP9(inP9), .inP13(inP13),
        .weight_flat(weight_flat_out),
        .Re1(Re1), .Re2(Re2), .Re3(Re3), .Re4(Re4)
    );
endmodule

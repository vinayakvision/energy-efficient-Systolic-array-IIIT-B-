
module systolic_core (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] inP1, inP5, inP9, inP13,
    input  logic [511:0] weight_flat,
    output logic [63:0] Re1, Re2, Re3, Re4
);
    logic [31:0] w [16];
    logic [63:0] C [4][4];
    logic [31:0] E [4][4];

    for (genvar gi = 0; gi < 16; gi++)
        assign w[gi] = weight_flat[gi*32 +: 32];

    block P1  (64'd0,   w[0],  inP1,    clk, rst, E[0][0], C[0][0]);
    block P2  (64'd0,   w[1],  E[0][0], clk, rst, E[0][1], C[0][1]);
    block P3  (64'd0,   w[2],  E[0][1], clk, rst, E[0][2], C[0][2]);
    block P4  (64'd0,   w[3],  E[0][2], clk, rst, E[0][3], C[0][3]);

    block P5  (C[0][0], w[4],  inP5,    clk, rst, E[1][0], C[1][0]);
    block P6  (C[0][1], w[5],  E[1][0], clk, rst, E[1][1], C[1][1]);
    block P7  (C[0][2], w[6],  E[1][1], clk, rst, E[1][2], C[1][2]);
    block P8  (C[0][3], w[7],  E[1][2], clk, rst, E[1][3], C[1][3]);

    block P9  (C[1][0], w[8],  inP9,    clk, rst, E[2][0], C[2][0]);
    block P10 (C[1][1], w[9],  E[2][0], clk, rst, E[2][1], C[2][1]);
    block P11 (C[1][2], w[10], E[2][1], clk, rst, E[2][2], C[2][2]);
    block P12 (C[1][3], w[11], E[2][2], clk, rst, E[2][3], C[2][3]);

    block P13 (C[2][0], w[12], inP13,   clk, rst, E[3][0], Re1);
    block P14 (C[2][1], w[13], E[3][0], clk, rst, E[3][1], Re2);
    block P15 (C[2][2], w[14], E[3][1], clk, rst, E[3][2], Re3);
    block P16 (C[2][3], w[15], E[3][2], clk, rst, E[3][3], Re4);
endmodule



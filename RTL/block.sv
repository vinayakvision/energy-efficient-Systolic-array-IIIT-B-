`timescale 1ns / 1ps

module block (
    input  logic signed [63:0] p_sum,
    input  logic signed [31:0] w_b,
    input  logic signed [31:0] inp_west,
    input  logic               clk,
    input  logic               rst,
    output logic signed [31:0] outp_east,
    output logic signed [63:0] result
);
    logic signed [63:0] mult;
    assign mult = inp_west * w_b;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            result    <= 64'sd0;
            outp_east <= 32'sd0;
        end else begin
            result    <= p_sum + mult;
            outp_east <= inp_west;
        end
    end
endmodule

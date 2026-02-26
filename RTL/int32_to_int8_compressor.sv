module int32_to_int8_compressor (
    input  logic signed [31:0] in_w,
    input  logic [31:0]        scale,
    output logic signed [7:0]  out_w
);
    logic [4:0] sh;
    logic signed [31:0] q;

    // Extended addition to avoid overflow
    logic signed [32:0] sum_ext;
    logic signed [32:0] round_ext;

    always_comb begin
        if      (scale[16]) sh = 5'd16;
        else if (scale[8])  sh = 5'd8;
        else if (scale[4])  sh = 5'd4;
        else if (scale[2])  sh = 5'd2;
        else if (scale[1])  sh = 5'd1;
        else                sh = 5'd0;
    end

    assign round_ext =
        (sh > 0) ? (33'sd1 <<< (sh-1)) : 33'sd0;

    assign sum_ext =
        $signed({in_w[31], in_w}) + round_ext;

    assign q = sum_ext >>> sh;

    always_comb begin
        if      (q > 32'sd127)  out_w = 8'sd127;
        else if (q < -32'sd128) out_w = -8'sd128;
        else                    out_w = q[7:0];
    end
endmodule

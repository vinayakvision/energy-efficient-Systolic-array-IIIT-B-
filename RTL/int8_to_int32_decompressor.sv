module int8_to_int32_decompressor (
    input  logic signed [7:0]   in_w,
    input  logic [31:0]         scale,
    output logic signed [31:0]  out_w
);
    logic [4:0] sh;

    always_comb begin
        if      (scale[16]) sh = 5'd16;
        else if (scale[8])  sh = 5'd8;
        else if (scale[4])  sh = 5'd4;
        else if (scale[2])  sh = 5'd2;
        else if (scale[1])  sh = 5'd1;
        else                sh = 5'd0;
    end

    always_comb begin
        out_w = 32'(signed'(in_w)) <<< sh;
    end
endmodule




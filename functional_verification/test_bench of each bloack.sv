/////////////////// BLOCK ////////////////////
`timescale 1ns/1ps

module tb_block;

    // DUT signals
    logic signed [63:0] p_sum;
    logic signed [31:0] w_b;
    logic signed [31:0] inp_west;
    logic              clk;
    logic              rst;
    logic signed [31:0] outp_east;
    logic signed [63:0] result;

    // Instantiate DUT
    block dut (
        .p_sum     (p_sum),
        .w_b       (w_b),
        .inp_west  (inp_west),
        .clk       (clk),
        .rst       (rst),
        .outp_east (outp_east),
        .result    (result)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    // Dumpfile for waveform
    initial begin
        $dumpfile("block_tb.vcd");
        $dumpvars(0, tb_block);
    end

    // Test procedure
    initial begin
        // Initialize
        clk       = 0;
        rst       = 1;
        p_sum     = 0;
        w_b       = 0;
        inp_west  = 0;

        // Apply reset
        #12;
        rst = 0;

        // -------------------------
        // Test case 1
        // -------------------------
        @(posedge clk);
        p_sum    = 64'sd10;
        w_b      = 32'sd3;
        inp_west = 32'sd4;

        @(posedge clk);
        $display("TC1 -> result=%0d outp_east=%0d", result, outp_east);

        // -------------------------
        // Test case 2 (negative)
        // -------------------------
        @(posedge clk);
        p_sum    = -64'sd20;
        w_b      = 32'sd5;
        inp_west = -32'sd6;

        @(posedge clk);
        $display("TC2 -> result=%0d outp_east=%0d", result, outp_east);

        // -------------------------
        // Test case 3
        // -------------------------
        @(posedge clk);
        p_sum    = 64'sd100;
        w_b      = 32'sd0;
        inp_west = 32'sd25;

        @(posedge clk);
        $display("TC3 -> result=%0d outp_east=%0d", result, outp_east);

        #20;
        $finish;
    end
endmodule



/////////////////// 2.ASIC_SRAM_MACRO ////////////////////////////////////////////
module tb_asic_sram_macro;

    // Parameters
    localparam int DATA_W = 32;
    localparam int ADDR_W = 4;

    // DUT signals
    logic               clk;
    logic               cs;
    logic               we;
    logic [ADDR_W-1:0]  addr;
    logic [DATA_W-1:0]  din;
    logic [DATA_W-1:0]  dout;

    // Instantiate DUT
    asic_sram_macro #(
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) dut (
        .clk  (clk),
        .cs   (cs),
        .we   (we),
        .addr (addr),
        .din  (din),
        .dout (dout)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    // Dumpfile for waveform
    initial begin
        $dumpfile("asic_sram_tb.vcd");
        $dumpvars(0, tb_asic_sram_macro);
    end

    // Test sequence
    initial begin
        // Init
        clk  = 0;
        cs   = 0;
        we   = 0;
        addr = '0;
        din  = '0;

        // -------------------------
        // WRITE OPERATION
        // -------------------------
        @(posedge clk);
        cs   = 1;
        we   = 1;
        addr = 4'd3;
        din  = 32'hDEADBEEF;

        @(posedge clk); // write happens here

        // -------------------------
        // READ SAME ADDRESS
        // -------------------------
        we   = 0;   // read mode
        addr = 4'd3;

        @(posedge clk); // data appears after this clock

        $display("READ @ addr=3 -> dout = 0x%08h (EXPECTED: DEADBEEF)", dout);

        // -------------------------
        // WRITE ANOTHER LOCATION
        // -------------------------
        @(posedge clk);
        we   = 1;
        addr = 4'd7;
        din  = 32'hCAFEBABE;

        @(posedge clk);

        // -------------------------
        // READ BACK
        // -------------------------
        we   = 0;
        addr = 4'd7;

        @(posedge clk);
        $display("READ @ addr=7 -> dout = 0x%08h (EXPECTED: CAFEBABE)", dout);

        // -------------------------
        // CHIP SELECT LOW (HOLD)
        // -------------------------
        @(posedge clk);
        cs   = 0;
        addr = 4'd3;

        @(posedge clk);
        $display("CS LOW -> dout should HOLD previous value: 0x%08h", dout);

        #20;
        $finish;
    end
endmodule

 

////////////////////// 3. INT32_TO_INT8_COMPRESSOR //////////////////////////////////////

module tb_int32_to_int8_compressor;

    // DUT signals
    logic signed [31:0] in_w;
    logic [31:0]        scale;
    logic signed [7:0]  out_w;

    // Instantiate DUT
    int32_to_int8_compressor dut (
        .in_w  (in_w),
        .scale (scale),
        .out_w (out_w)
    );

    // Dump waveform
    initial begin
        $dumpfile("int32_to_int8_compressor.vcd");
        $dumpvars(0, tb_int32_to_int8_compressor);
    end

    // Task to apply one test
    task run_test(
        input signed [31:0] iw,
        input [31:0]        sc
    );
        begin
            in_w  = iw;
            scale = sc;
            #1; // allow combinational settle

            $display("in_w=%0d scale=0x%08h -> out_w=%0d",
                     in_w, scale, out_w);
        end
    endtask

    initial begin
        // -------------------------
        // No scaling (sh = 0)
        // -------------------------
        run_test(32'sd50,   32'h0);   // expect 50
        run_test(-32'sd50,  32'h0);   // expect -50

        // -------------------------
        // Scale = 1 (>>1)
        // -------------------------
        run_test(32'sd5,    32'h2);   // (5+1)>>1 = 3
        run_test(-32'sd5,   32'h2);   // (-5+1)>>1 = -2

        // -------------------------
        // Scale = 2 (>>2)
        // -------------------------
        run_test(32'sd15,   32'h4);   // (15+2)>>2 = 4
        run_test(-32'sd15,  32'h4);   // (-15+2)>>2 = -4

        // -------------------------
        // Scale = 4 (>>4)
        // -------------------------
        run_test(32'sd1300, 32'h10);  // rounding check

        // -------------------------
        // Scale = 8 (>>8)
        // -------------------------
        run_test(32'sd32767, 32'h100);

        // -------------------------
        // Scale = 16 (>>16)
        // -------------------------
        run_test(32'sd12345678, 32'h10000);

        // -------------------------
        // Saturation (positive)
        // -------------------------
        run_test(32'sd100000, 32'h0); // expect +127

        // -------------------------
        // Saturation (negative)
        // -------------------------
        run_test(-32'sd100000, 32'h0); // expect -128

        #10;
        $finish;
    end
endmodule

///////////////// 4. INT8_TO_INT32_DECOMPRESSOR ////////////////////////////////////////

module tb_int8_to_int32_decompressor;

    // DUT signals
    logic signed [7:0]   in_w;
    logic [31:0]         scale;
    logic signed [31:0]  out_w;

    // Instantiate DUT
    int8_to_int32_decompressor dut (
        .in_w  (in_w),
        .scale (scale),
        .out_w (out_w)
    );

    // Dump waveform
    initial begin
        $dumpfile("int8_to_int32_decompressor.vcd");
        $dumpvars(0, tb_int8_to_int32_decompressor);
    end

    // Task for one test
    task run_test(
        input signed [7:0] iw,
        input [31:0]       sc
    );
        begin
            in_w  = iw;
            scale = sc;
            #1; // combinational settle

            $display("in_w=%0d scale=0x%08h -> out_w=%0d",
                     in_w, scale, out_w);
        end
    endtask

    initial begin
        // -------------------------
        // No scaling
        // -------------------------
        run_test(8'sd10, 32'h0);     // 10
        run_test(-8'sd10, 32'h0);    // -10

        // -------------------------
        // Scale = 1 (<<1)
        // -------------------------
        run_test(8'sd5,  32'h2);     // 10
        run_test(-8'sd5, 32'h2);     // -10

        // -------------------------
        // Scale = 2 (<<2)
        // -------------------------
        run_test(8'sd7,  32'h4);     // 28
        run_test(-8'sd7, 32'h4);     // -28

        // -------------------------
        // Scale = 4 (<<4)
        // -------------------------
        run_test(8'sd12, 32'h10);    // 192

        // -------------------------
        // Scale = 8 (<<8)
        // -------------------------
        run_test(8'sd20, 32'h100);   // 5120

        // -------------------------
        // Scale = 16 (<<16)
        // -------------------------
        run_test(8'sd1,  32'h10000); // 65536
        run_test(-8'sd1, 32'h10000); // -65536

        // -------------------------
        // Boundary values
        // -------------------------
        run_test(8'sd127, 32'h100);  // max positive
        run_test(-8'sd128,32'h100);  // min negative

        #10;
        $finish;
    end
endmodule

//////////////// 5. SYSTOLIC_CORE //////////////////////////////////////////////

module tb_systolic_core;

    // Clock & reset
    logic clk;
    logic rst;

    // Inputs
    logic [31:0] inP1, inP5, inP9, inP13;
    logic [511:0] weight_flat;

    // Outputs
    logic [63:0] Re1, Re2, Re3, Re4;

    // DUT
    systolic_core dut (
        .clk(clk),
        .rst(rst),
        .inP1(inP1),
        .inP5(inP5),
        .inP9(inP9),
        .inP13(inP13),
        .weight_flat(weight_flat),
        .Re1(Re1),
        .Re2(Re2),
        .Re3(Re3),
        .Re4(Re4)
    );

    // Clock generation (10ns)
    always #5 clk = ~clk;

    // Dumpfile (works in most simulators)
    initial begin
        $dumpfile("systolic_core.vcd");
        $dumpvars(0, tb_systolic_core);
    end

    initial begin
        // -------------------------
        // Init
        // -------------------------
        clk = 0;
        rst = 1;
        inP1 = 0;
        inP5 = 0;
        inP9 = 0;
        inP13 = 0;
        weight_flat = '0;

        // Load weights w0..w15 = 1..16
        for (int i = 0; i < 16; i++)
            weight_flat[i*32 +: 32] = i + 1;

        // Release reset
        #15 rst = 0;

        // -------------------------
        // Apply inputs
        // -------------------------
        @(posedge clk);
        inP1  = 32'd1;
        inP5  = 32'd2;
        inP9  = 32'd3;
        inP13 = 32'd4;

        // Wait for systolic pipeline to fill
        repeat (8) @(posedge clk);

        // -------------------------
        // Observe results
        // -------------------------
        $display("Re1 = %0d", Re1);
        $display("Re2 = %0d", Re2);
        $display("Re3 = %0d", Re3);
        $display("Re4 = %0d", Re4);

        #20;
        $finish;
    end

endmodule

//////////////////////////// 6. SYSTOLIC_CONTROL /////////////////////////////////////////////////

module tb_systolic_control;

    // -------------------------
    // Clock & reset
    // -------------------------
    logic clk;
    logic rst;
    logic start;

    // -------------------------
    // Memory interface
    // -------------------------
    logic        mem_we;
    logic [3:0]  mem_addr;
    logic [31:0] weight_din;
    logic [31:0] act_din;
    logic [31:0] layer_scale;

    // -------------------------
    // Outputs
    // -------------------------
    logic [31:0] inP1, inP5, inP9, inP13;
    logic [511:0] weight_flat_out;
    logic done;

    // -------------------------
    // DUT
    // -------------------------
    systolic_control dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .weight_din(weight_din),
        .act_din(act_din),
        .layer_scale(layer_scale),
        .inP1(inP1),
        .inP5(inP5),
        .inP9(inP9),
        .inP13(inP13),
        .weight_flat_out(weight_flat_out),
        .done(done)
    );

    // -------------------------
    // Clock generation (10 ns)
    // -------------------------
    always #5 clk = ~clk;

    // -------------------------
    // Test sequence
    // -------------------------
    initial begin
        // Init
        clk = 0;
        rst = 1;
        start = 0;
        mem_we = 0;
        mem_addr = 0;
        weight_din = 0;
        act_din = 0;

        // Power-of-two scale = 1 (no shift)
        layer_scale = 32'h1;

        // Apply reset
        #20 rst = 0;

        // -------------------------
        // Write WEIGHTS + ACTIVATIONS
        // -------------------------
        mem_we = 1;
        for (int i = 0; i < 16; i++) begin
            @(posedge clk);
            mem_addr  = i[3:0];
            weight_din = i + 1;        // weights = 1..16
            act_din    = (i + 1) * 2;  // activations = 2,4,6,...
        end

        @(posedge clk);
        mem_we = 0;

        // -------------------------
        // Start computation
        // -------------------------
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // -------------------------
        // Wait for DONE
        // -------------------------
        wait (done == 1'b1);
        $display("DONE asserted");

        // Observe streamed inputs (EXECUTE phase)
        $display("inP1  = %0d", inP1);
        $display("inP5  = %0d", inP5);
        $display("inP9  = %0d", inP9);
        $display("inP13 = %0d", inP13);

        // Optional: show packed weights
        $display("weight_flat_out = %h", weight_flat_out);

        #20;
        $finish;
    end

endmodule



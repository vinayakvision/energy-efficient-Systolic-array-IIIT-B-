`timescale 1ns / 1ps

module tb_systolic_top;

    // -------------------------
    // DUT signals
    // -------------------------
    reg clk;
    reg rst;
    reg start;
    reg mem_we;
    reg [3:0] mem_addr;
    reg [31:0] weight_din;
    reg [31:0] act_din;
    reg [31:0] layer_scale;

    wire done;
    wire [63:0] Re1, Re2, Re3, Re4;

    // -------------------------
    // DUT
    // -------------------------
    systolic_top DUT (
        .clk(clk), .rst(rst), .start(start),
        .mem_we(mem_we), .mem_addr(mem_addr),
        .weight_din(weight_din), .act_din(act_din),
        .layer_scale(layer_scale),
        .done(done),
        .Re1(Re1), .Re2(Re2), .Re3(Re3), .Re4(Re4)
    );

    // -------------------------
    // Clock
    // -------------------------
    always #5 clk = ~clk;

    integer i;

    reg signed [31:0] W [0:15];
    reg signed [31:0] A [0:15];

    // -------------------------
    // MAIN STIMULUS
    // -------------------------
    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        mem_we = 0;

        // one-hot scale → shift right by 1
      layer_scale = (32'd1 << 0);

        // -------------------------
        // Test data
        // -----------------------
      W[0]=1;  W[1]=0;   W[2]=0;    W[3]=0;
      W[4]=0;  W[5]=1;  W[6]=0;    W[7]=0;
      W[8]=0;  W[9]=0;   W[10]=1; W[11]=0;
      W[12]=0; W[13]=0;  W[14]=0;   W[15]=1;

        A[0]=1;  A[1]=126; A[2]=123; A[3]=178;
        A[4]=256; A[5]=142; A[6]=187; A[7]=432;
        A[8]=521; A[9]=153; A[10]=123;A[11]=156;
        A[12]=121;A[13]=175;A[14]=135;A[15]=142;

        #30 rst = 0;

        // -------------------------
        // WRITE PHASE (SRAM PACKING)
        // -------------------------
        mem_we = 1;
        for (i = 0; i < 16; i = i + 1) begin
            mem_addr   = i[3:0];
            weight_din = W[i];
            act_din    = A[i];
            #10;
        end
        mem_we = 0;

        // -------------------------
        // EXECUTE
        // -------------------------
        #20;
        start = 1; #10; start = 0;
        wait(done);

        // -------------------------
        // FINAL OUTPUT
        // -------------------------
        $display("\n==== SYSTOLIC OUTPUT ====");
        $display("Re1 = %0d", Re1);
        $display("Re2 = %0d", Re2);
        $display("Re3 = %0d", Re3);
        $display("Re4 = %0d", Re4);

// -------------------------
// FINAL SRAM CONTENT (COMPACT FORMAT)
// -------------------------
$display("\n=========== FINAL WEIGHT SRAM CONTENT ===========");
for (i = 0; i < 8; i = i + 1) begin
    $display(
      "mem[%0d]: %0d%0d",
      i,
      $signed(DUT.CTRL.W_SRAM.mem[i][15:8]),
      $signed(DUT.CTRL.W_SRAM.mem[i][7:0])
    );
end
$display("=================================================\n");


        #50 $finish;
    end

    // -------------------------------------------------
    // LIVE PACKING / UNPACKING LOGIC DISPLAY
    // -------------------------------------------------
    always @(posedge clk) begin

        // -------- WRITE (PACKING) --------
        if (mem_we) begin
            if (mem_addr[0] == 1'b0)
                $display("WRITE : mem[%0d][7:0]  | comp_in=%0d | comp_out=%0d",
                         mem_addr >> 1,
                         weight_din,
                         DUT.CTRL.w8);
            else
                $display("WRITE : mem[%0d][15:8] | comp_in=%0d | comp_out=%0d",
                         mem_addr >> 1,
                         weight_din,
                         DUT.CTRL.w8);
        end

        // -------- READ (UNPACKING) --------
        else if (!mem_we && DUT.CTRL.state == DUT.CTRL.FETCH_DATA) begin
            if (DUT.CTRL.addr[0] == 1'b0)
                $display("READ  : mem[%0d][7:0]  | decomp_in=%0d | decomp_out=%0d",
                         DUT.CTRL.addr >> 1,
                         DUT.CTRL.w8_sram[7:0],
                         DUT.CTRL.w32);
            else
                $display("READ  : mem[%0d][15:8] | decomp_in=%0d | decomp_out=%0d",
                         DUT.CTRL.addr >> 1,
                         DUT.CTRL.w8_sram[15:8],
                         DUT.CTRL.w32);
        end
    end

    // -------------------------
    // Waveform
    // -------------------------
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_systolic_top);
    end

endmodule

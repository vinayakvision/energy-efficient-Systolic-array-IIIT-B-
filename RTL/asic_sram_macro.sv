module asic_sram_macro #(
    parameter int DATA_W = 32,
    parameter int ADDR_W = 4
)(
    input  logic               clk,
    input  logic               cs,
    input  logic               we,
    input  logic [ADDR_W-1:0]  addr,
    input  logic [DATA_W-1:0]  din,
    output logic [DATA_W-1:0]  dout
);

    logic [DATA_W-1:0] mem [0:(1<<ADDR_W)-1];

    generate
        /* ================================
           Special case: DATA_W == 16
           ================================ */
        if (DATA_W == 16) begin : GEN_16BIT_PACKING

            logic word_sel;                 // selects low/high byte
            logic [ADDR_W-2:0] word_addr;   // actual SRAM address

            assign word_sel  = addr[0];
            assign word_addr = addr[ADDR_W-1:1];

            always_ff @(posedge clk) begin
                if (cs) begin
                    if (we) begin
                        if (word_sel == 1'b0)
                            mem[word_addr][7:0]  <= din[7:0];
                        else
                            mem[word_addr][15:8] <= din[7:0];
                    end
                    dout <= mem[word_addr];
                end
            end
        end

        /* ================================
           Default behavior (original logic)
           ================================ */
        else begin : GEN_DEFAULT

            always_ff @(posedge clk) begin
                if (cs) begin
                    if (we)
                        mem[addr] <= din;
                    dout <= mem[addr];
                end
            end
        end
    endgenerate

endmodule

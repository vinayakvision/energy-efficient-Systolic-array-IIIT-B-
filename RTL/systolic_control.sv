
module systolic_control (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic        mem_we,
    input  logic [3:0]  mem_addr,
    input  logic [31:0] weight_din,
    input  logic [31:0] act_din,
    input  logic [31:0] layer_scale,

    output logic [31:0] inP1, inP5, inP9, inP13,
    output logic [511:0] weight_flat_out,
    output logic        done
);

    typedef enum logic [2:0] {IDLE, FETCH_ADDR, FETCH_DATA, EXECUTE, CAPTURE, DONE} state_t;
    state_t state;

    logic [3:0] addr, count;

    logic [31:0] weight_reg [16];
    logic [31:0] act_reg    [16];

    for (genvar i = 0; i < 16; i++)
        assign weight_flat_out[i*32 +: 32] = weight_reg[i];

    logic signed [7:0]  w8;
    logic signed [15:0] w8_ext;
    logic signed [15:0] w8_sram;
    logic signed [31:0] w32;
    logic [31:0]        act_out;
    logic signed [7:0] w8_sel;


    assign w8_ext = {{8{w8[7]}}, w8};
  
    always_comb begin
    if (addr[0] == 1'b0)
        w8_sel = w8_sram[7:0];
    else
        w8_sel = w8_sram[15:8];
    end

    int32_to_int8_compressor  COMP  (weight_din, layer_scale, w8);
    int8_to_int32_decompressor DECOMP (w8_sel,layer_scale,w32);

    asic_sram_macro #(16,4) W_SRAM (
        .clk(clk), .cs(1'b1), .we(mem_we),
        .addr(mem_we ? mem_addr : addr),
        .din(w8_ext),
        .dout(w8_sram)
    );

    asic_sram_macro #(32,4) A_SRAM (
        .clk(clk), .cs(1'b1), .we(mem_we),
        .addr(mem_we ? mem_addr : addr),
        .din(act_din),
        .dout(act_out)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            addr  <= 0;
            count <= 0;
            done  <= 0;
            {inP1,inP5,inP9,inP13} <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin addr <= 0; state <= FETCH_ADDR; end
                end

                FETCH_ADDR: state <= FETCH_DATA;

                FETCH_DATA: begin
                    weight_reg[addr] <= w32;
                    act_reg[addr]    <= act_out;
                    if (addr == 15) begin addr <= 0; count <= 0; state <= EXECUTE; end
                    else begin addr <= addr + 1; state <= FETCH_ADDR; end
                end

                EXECUTE: begin
                    case (count)
                        0: inP1 <= act_reg[0];
                        1: begin inP1 <= act_reg[4];  inP5 <= act_reg[1]; end
                        2: begin inP1 <= act_reg[8];  inP5 <= act_reg[5];  inP9 <= act_reg[2]; end
                        3: begin inP1 <= act_reg[12]; inP5 <= act_reg[9];  inP9 <= act_reg[6];  inP13 <= act_reg[3]; end
                        4: begin inP1 <= 0; inP5 <= act_reg[13]; inP9 <= act_reg[10]; inP13 <= act_reg[7]; end
                        5: begin inP5 <= 0; inP9 <= act_reg[14]; inP13 <= act_reg[11]; end
                        6: begin inP9 <= 0; inP13 <= act_reg[15]; end
                        7: begin inP13 <= 0; state <= CAPTURE; end
                    endcase
                    if (count != 7) count <= count + 1;
                end

                CAPTURE: state <= DONE;
                DONE:    begin done <= 1'b1; state <= IDLE; end
            endcase
        end
    end
endmodule

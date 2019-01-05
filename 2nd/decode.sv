import inst_package::*;

module decode (
    input  wire         interlock,

    // input
    //
    gpr_if                     gpr,
    input  wire        [31:0]  pc,
    input  wire        [63:0]  inst,

    // output
    //
    output reg                  branch_flag,
    output reg         [31:0]   branch_pc,

    output reg         [31:0]   pc_to_the_next,
    output reg         [63:0]   inst_to_the_next,
    // Upper
    output reg  signed [31:0]   u_srca,
    output reg  signed [31:0]   u_srcb,
    output reg  signed [31:0]   u_srcs,
    output reg         [3:0]    u_e_type,
    output reg         [4:0]    u_rt,
    output reg                  u_rt_flag,

    // Lower
    output reg  signed [31:0]   l_srca,
    output reg  signed [31:0]   l_srcb,
    output reg  signed [31:0]   l_srcs,
    output reg         [3:0]    l_e_type,
    output reg         [4:0]    l_rt,
    output reg                  l_rt_flag,

    // Memory
    output reg         [31:0]   addr,
    output reg         [63:0]   dina,
    output reg         [7:0]    wea,

    input  wire         clk,
    input  wire         rstn);

    reg eq;
    reg less;

    wire        [4:0]   u_target= inst[57:53];
    wire        [4:0]   l_target= inst[25:21];
    wire signed [31:0]  u_reg_s = gpr.gpr[inst[57:53]];
    wire signed [31:0]  l_reg_s = gpr.gpr[inst[25:21]];
    wire signed [31:0]  u_reg_a = gpr.gpr[inst[52:48]];
    wire signed [31:0]  l_reg_a = gpr.gpr[inst[20:16]];
    wire signed [31:0]  u_reg_b = gpr.gpr[inst[47:43]];
    wire signed [31:0]  l_reg_b = gpr.gpr[inst[15:11]];
    wire signed [31:0]  u_si    = $signed({{16{inst[47]}}, inst[47:32]});
    wire signed [31:0]  l_si    = $signed({{16{inst[15]}}, inst[15:0]});
    wire        [31:0]  u_li    = {6'b0, inst[57:32]};
    wire        [31:0]  l_li    = {6'b0, inst[25:0]};


    wire                u_fless_result;
    wire                l_fless_result;

    fless u_fless(  .srca(u_reg_a),
                    .srcb(u_reg_b),
                    .result(u_fless_result));
    fless l_fless(  .srca(l_reg_a),
                    .srcb(l_reg_b),
                    .result(l_fless_result));


    always@(posedge clk) begin
        if (~rstn) begin
            pc_to_the_next <= 32'b0;
            inst_to_the_next <= {Nop, 26'b0, Nop, 26'b0};
            u_rt_flag <= 0;
            l_rt_flag <= 0;
            eq <= 0;
            less <= 0;
            branch_flag <= 0;
        end else if (~branch_flag && ~interlock) begin
            pc_to_the_next <= pc;
            inst_to_the_next[63:32] <= inst[63:32];
            if (inst[63:58] == Liw
                || inst[63:58] == Jump
                || inst[63:58] == Blr
                || inst[63:58] == Bl
                || inst[63:58] == Blrr
                || inst[63:58] == Beq
                || inst[63:58] == Ble
                || inst[63:58] == Blt) inst_to_the_next[31:0] <= {Nop, 26'b0}; // Nop
            else inst_to_the_next[31:0] <= inst[31:0];

            // SrcA
            u_srca <= u_reg_a;
            l_srca <= l_reg_a;

            // SrcB
            case (inst[63:58])
                Addi    : u_srcb <= u_si;
                Subi    : u_srcb <= u_si;
                Add     : u_srcb <= u_reg_b;
                Sub     : u_srcb <= u_reg_b;
                Srawi   : u_srcb <= u_si;
                Slawi   : u_srcb <= u_si;
                Fadd    : u_srcb <= u_reg_b;
                Fsub    : u_srcb <= u_reg_b;
                Fmul    : u_srcb <= u_reg_b;
                Fdiv    : u_srcb <= u_reg_b;
                Fsqrt   : u_srcb <= u_reg_b;
                Ftoi    : u_srcb <= u_reg_b;
                Itof    : u_srcb <= u_reg_b;
                Load    : u_srcb <= u_si;
                Store   : u_srcb <= u_si;
                Li      : u_srcb <= u_si;
                Liw     : u_srcb <= $signed(inst[31:0]);
                Bl      : u_srcb <= pc + 1;
                Blrr    : u_srcb <= pc + 1;
                default : u_srcb <= u_si;
            endcase
            case (inst[31:26])
                Addi    : l_srcb <= l_si;
                Subi    : l_srcb <= l_si;
                Add     : l_srcb <= l_reg_b;
                Sub     : l_srcb <= l_reg_b;
                Srawi   : l_srcb <= l_si;
                Slawi   : l_srcb <= l_si;
                Fadd    : u_srcb <= u_reg_b;
                Fsub    : u_srcb <= u_reg_b;
                Fmul    : u_srcb <= u_reg_b;
                Fdiv    : u_srcb <= u_reg_b;
                Fsqrt   : u_srcb <= u_reg_b;
                Ftoi    : u_srcb <= u_reg_b;
                Itof    : u_srcb <= u_reg_b;
                Load    : l_srcb <= l_si;
                Store   : l_srcb <= l_si;
                Li      : l_srcb <= l_si;
                default : l_srcb <= l_si;
            endcase

            // SrcS
            u_srcs <= u_reg_s;
            l_srcs <= l_reg_s;

            // ExecType
            case (inst[63:58])
                Addi    : u_e_type <= EAdd;
                Subi    : u_e_type <= ESub;
                Add     : u_e_type <= EAdd;
                Sub     : u_e_type <= ESub;
                Srawi   : u_e_type <= ERshift;
                Slawi   : u_e_type <= ELshift;
                Fadd    : u_e_type <= EFadd;
                Fsub    : u_e_type <= EFsub;
                Fmul    : u_e_type <= EFmul;
                Fdiv    : u_e_type <= EFdiv;
                Fsqrt   : u_e_type <= EFsqrt;
                Ftoi    : u_e_type <= EFtoi;
                Itof    : u_e_type <= EItof;
                default : u_e_type <= ENop;
            endcase
            case (inst[31:26])
                Addi    : l_e_type <= EAdd;
                Subi    : l_e_type <= ESub;
                Add     : l_e_type <= EAdd;
                Sub     : l_e_type <= ESub;
                Srawi   : l_e_type <= ERshift;
                Slawi   : l_e_type <= ELshift;
                Fadd    : u_e_type <= EFadd;
                Fsub    : u_e_type <= EFsub;
                Fmul    : u_e_type <= EFmul;
                Fdiv    : u_e_type <= EFdiv;
                Fsqrt   : u_e_type <= EFsqrt;
                Ftoi    : u_e_type <= EFtoi;
                Itof    : u_e_type <= EItof;
                default : l_e_type <= ENop;
            endcase

            // RT
            case (inst[63:58])
                Bl      : u_rt <= 5'b11111;
                Blrr    : u_rt <= 5'b11111;
                default : u_rt <= u_target;
            endcase
            case (inst[31:26])
                Bl      : l_rt <= 5'b11111;
                Blrr    : l_rt <= 5'b11111;
                default : l_rt <= l_target;
            endcase

            // RT flag
            // note that rt flag is 0 when inst is Load. in such a case rt
            // flag is turned on at Memory2 stage.
            case (inst[63:58])
                Addi    : u_rt_flag <= 1;
                Subi    : u_rt_flag <= 1;
                Add     : u_rt_flag <= 1;
                Sub     : u_rt_flag <= 1;
                Srawi   : u_rt_flag <= 1;
                Slawi   : u_rt_flag <= 1;
                Li      : u_rt_flag <= 1;
                Liw     : u_rt_flag <= 1;
                Bl      : u_rt_flag <= 1;
                Blrr    : u_rt_flag <= 1;
                Inll    : u_rt_flag <= 1;
                Inlh    : u_rt_flag <= 1;
                Inul    : u_rt_flag <= 1;
                Inuh    : u_rt_flag <= 1;
                default : u_rt_flag <= 0;
            endcase
            if (inst[63:58] == Liw
                || inst[63:58] == Jump
                || inst[63:58] == Blr
                || inst[63:58] == Bl
                || inst[63:58] == Blrr
                || inst[63:58] == Beq
                || inst[63:58] == Ble
                || inst[63:58] == Blt
                || inst[63:58] == Inll
                || inst[63:58] == Inlh
                || inst[63:58] == Inul
                || inst[63:58] == Inuh
                || inst[63:58] == Outll) l_rt_flag <= 0;
            else begin
                case (inst[31:26])
                    Addi    : l_rt_flag <= 1;
                    Subi    : l_rt_flag <= 1;
                    Add     : l_rt_flag <= 1;
                    Sub     : l_rt_flag <= 1;
                    Srawi   : l_rt_flag <= 1;
                    Slawi   : l_rt_flag <= 1;
                    Li      : l_rt_flag <= 1;
                    // Liw     : l_rt_flag <= 1;    // Liw doesn't appear in lower inst
                    Bl      : l_rt_flag <= 1;
                    Blrr    : l_rt_flag <= 1;
                    default : l_rt_flag <= 0;
                endcase
            end

            // Comparison Regs
            if (inst[63:58] == Cmpd) begin
                eq <= (u_reg_a == u_reg_b);
                less <= (u_reg_a < u_reg_b);
            end else if (inst[31:26] == Cmpd) begin
                eq <= (l_reg_a == l_reg_b);
                less <= (l_reg_a < l_reg_b);
            end else if (inst[63:58] == Cmpf) begin
                eq <= (u_reg_a == u_reg_b) || (u_reg_a[30:23] == 8'b0 && u_reg_b[30:23] == 8'b0);
                less <= u_fless_result;
            end else if (inst[31:26] == Cmpf) begin
                eq <= (l_reg_a == l_reg_b) || (l_reg_a[30:23] == 8'b0 && l_reg_b[30:23] == 8'b0);
                less <= l_fless_result;
            end else if (inst[63:58] == Cmpdi) begin
                eq <= (u_reg_a == u_si);
                less <= (u_reg_a < u_si);
            end else if (inst[31:26] == Cmpdi) begin
                eq <= (l_reg_a == l_si);
                less <= (l_reg_a < l_si);
            end

            // Branch operation
            case (inst[63:58])
                Jump    : branch_flag <= 1;
                Blr     : branch_flag <= 1;
                Bl      : branch_flag <= 1;
                Blrr    : branch_flag <= 1;
                Beq     : branch_flag <= (eq) ? 1 : 0;
                Ble     : branch_flag <= (eq || less) ? 1 : 0;
                Blt     : branch_flag <= (less) ? 1 : 0;
                Bne     : branch_flag <= (~eq) ? 1 : 0;
                Bge     : branch_flag <= (~less) ? 1 : 0;
                Bgt     : branch_flag <= (~(less && eq)) ? 1 : 0;
                default : branch_flag <= 0;
            endcase

            case (inst[63:58])
                Jump    : branch_pc <= u_li;
                Blr     : branch_pc <= gpr.gpr[5'b11111];
                Bl      : branch_pc <= u_li;
                Blrr    : branch_pc <= u_reg_s;
                Beq     : branch_pc <= u_li;
                Ble     : branch_pc <= u_li;
                Blt     : branch_pc <= u_li;
                Bne     : branch_pc <= u_li;
                Bgt     : branch_pc <= u_li;
                Bge     : branch_pc <= u_li;
                default : branch_pc <= 32'b0;
            endcase

            // Memory address
            addr <= u_reg_a + u_si;
            dina <= {u_reg_s, l_reg_s};
            wea[3:0] <= (inst[31:26] == Store) ? 4'b1111 : 4'b0000;     // upper Store
            wea[7:4] <= (inst[63:58] == Store) ? 4'b1111 : 4'b0000;     // lower Store

        end else if (branch_flag) begin
            branch_flag <= 0;
            pc_to_the_next <= 32'b0;
            inst_to_the_next <= {Nop, 26'b0, Nop, 26'b0};
            u_rt_flag <= 0;
            l_rt_flag <= 0;
            eq <= 0;
            less <= 0;
            branch_flag <= 0;
        end
    end
endmodule

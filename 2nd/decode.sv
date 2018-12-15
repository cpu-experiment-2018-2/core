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

    typedef enum logic [3:0] {
        ENop = 4'b0000,
        EAdd = 4'b0001,
        ESub = 4'b0010, 
        ERshift = 4'b0011,
        ELshift = 4'b0100,
        EFadd = 4'b0101,
        EFsub = 4'b0110,
        EFmul = 4'b0111,
        EFdiv = 4'b1000,
        EFsqrt = 4'b1001,
        EFtoi = 4'b1010,
        EItof = 4'b1011
    } exec_type;


    localparam Addi = 6'b000000;
    localparam Subi = 6'b000001;
    localparam Add  = 6'b000010;
    localparam Sub  = 6'b000011;
    localparam Srawi= 6'b000100;
    localparam Slawi= 6'b000101;
    
    localparam Fadd = 6'b001000;
    localparam Fsub = 6'b001001;
    localparam Fmul = 6'b001010;
    localparam Fdiv = 6'b001011;
    localparam Ftoi = 6'b001100;
    localparam Itof = 6'b001101;
    localparam Fsqrt= 6'b001110;

    localparam Load = 6'b010000;
    localparam Store= 6'b010001;
    localparam Li   = 6'b010010;
    localparam Liw  = 6'b010011;

    localparam Jump = 6'b011000;
    localparam Blr  = 6'b011001;
    localparam Bl   = 6'b011010;
    localparam Blrr = 6'b011011;
    localparam Cmpd = 6'b011100;
    localparam Cmpf = 6'b011101;
    localparam Cmpdi= 6'b011110;

    localparam Beq  = 6'b100000;
    localparam Ble  = 6'b100001;
    localparam Blt  = 6'b100010;
    localparam Bne  = 6'b100011;
    localparam Bge  = 6'b100100;
    localparam Bgt  = 6'b100101;

    localparam Inll = 6'b101000;
    localparam Inlh = 6'b101001;
    localparam Inul = 6'b101010;
    localparam Inuh = 6'b101011;
    localparam Outll= 6'b101100;

    /*
    function [31:0] SRCA (
        input [31:0] dform,
        input [31:0] xform,
        input [31:0] sform
    );
        case (inst[63:58])
                Addi    : SRCA = gpr.gpr[dform.ra];
                Subi    : SRCA = gpr.gpr[dform.ra];
                Add     : SRCA = gpr.gpr[xform.ra];
                Sub     : SRCA = gpr.gpr[xform.ra];
                Srawi   : SRCA = gpr.gpr[dform.ra];
                Slawi   : SRCA = gpr.gpr[dform.ra];
                Fadd    : SRCA = gpr.gpr[xform.ra];
                Fsub    : SRCA = gpr.gpr[xform.ra];
                Fmul    : SRCA = gpr.gpr[xform.ra];
                Fdiv    : SRCA = gpr.gpr[xform.ra];
                Load    : SRCA = gpr.gpr[dform.ra];
                Store   : SRCA = gpr.gpr[sform.ra];
                Li      : SRCA = dform.si;
                Liw     : SRCA = dform.si;
                default : SRCA = dform.si;
        endcase
    endfunction */


    always@(posedge clk) begin
        if (~rstn) begin
            pc_to_the_next <= 32'b0;
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
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
                || inst[63:58] == Blt) inst_to_the_next[31:0] <= {3'b111, 29'b0}; // Nop
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
                || inst[63:58] == Blt) l_rt_flag <= 0;
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
                    Inll    : l_rt_flag <= 1;
                    Inlh    : l_rt_flag <= 1;
                    Inul    : l_rt_flag <= 1;
                    Inuh    : l_rt_flag <= 1;
                    default : l_rt_flag <= 0;
                endcase
            end

            // Comparison Regs
            if (inst[63:58] == 6'b011100) begin // Compd
                eq <= (u_reg_a == u_reg_b);
                less <= (u_reg_a < u_reg_b);
            end else if (inst[31:26] == 6'b011100) begin
                eq <= (l_reg_a == l_reg_b);
                less <= (l_reg_a < l_reg_b);
            end /*else if (inst[63:58] == 6'b011101) begin // Compf
                eq <= (gpr.gpr[u_xform.ra] == gpr.gpr[u_xform.rb])
                        || (gpr.gpr[u_xform.ra][30:0] == 31'b0 && gpr.gpr[u_xform.rb][30:0] == 31'b0);
                less <= (gpr.gpr[u_xform.ra][31] == 1 && gpr.gpr[u_xform.rb][31] == 1) ?
                            (gpr.gpr[u_xform.ra] > gpr.gpr[u_xform.rb]) : (gpr.gpr[u_xform.ra] < gpr.gpr[u_xform.rb]);
            end else if (inst[31:26] == 6'b011101) begin
                eq <= (gpr.gpr[l_xform.ra] == gpr.gpr[l_xform.rb])
                        || (gpr.gpr[l_xform.ra][30:0] == 31'b0 && gpr.gpr[l_xform.rb][30:0] == 31'b0);
                less <= (gpr.gpr[l_xform.ra][31] == 1 && gpr.gpr[l_xform.rb][31] == 1) ?
                            (gpr.gpr[l_xform.ra] > gpr.gpr[l_xform.rb]) : (gpr.gpr[l_xform.ra] < gpr.gpr[l_xform.rb]);
            end*/ else if (inst[63:58] == 6'b011110) begin // Compdi
                eq <= (u_reg_a == u_si);
                less <= (u_reg_a < u_si);
            end else if (inst[31:26] == 6'b011110) begin
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
            wea[3:0] <= (inst[31:26] == 6'b010001) ? 4'b1111 : 4'b0000;     // upper Store
            wea[7:4] <= (inst[63:58] == 6'b010001) ? 4'b1111 : 4'b0000;     // lower Store

        end else begin
            pc_to_the_next <= 32'b0;
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
            u_rt_flag <= 0;
            l_rt_flag <= 0;
            wea <= 7'b0;
            branch_flag <= 0;
        end
    end
endmodule

module decode (
    input  wire         interlock,
    input  wire         decode_stall,

    // input
    //
    gpr_if                     gpr,
    input  wire        [63:0]  inst,

    // output
    //
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

    typedef enum logic [3:0] {
        ENop = 4'b0000,
        EAdd = 4'b0001,
        ESub = 4'b0010, 
        ERshift = 4'b0011,
        ELshift = 4'b0100
    } exec_type;

    // Dform
    typedef struct packed {
        bit [4:0] rt;
        bit [4:0] ra;
        bit [15:0] si;
    } Dform;
    Dform u_dform;
    Dform l_dform;
    assign u_dform = inst[57:32];
    assign l_dform = inst[25:0];

    // Sform
    typedef struct packed {
        bit [4:0] rs;
        bit [4:0] ra;
        bit [15:0] si;
    } Sform;
    Sform u_sform;
    Sform l_sform;
    assign u_sform = inst[57:32];
    assign l_sform = inst[25:0];

    // Xform
    typedef struct packed {
        bit [4:0] rt;
        bit [4:0] ra;
        bit [4:0] rb;
        bit [10:0] dummy;
    } Xform;
    Xform u_xform;
    Xform l_xform;
    assign u_xform = inst[57:32];
    assign l_xform = inst[25:0];

    // Iform
    typedef struct packed {
        bit [25:0] li;
    } Iform;
    Iform u_iform;
    Iform l_iform;
    assign u_iform = inst[57:32];
    assign l_iform = inst[25:0];


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

    localparam Load = 6'b010000;
    localparam Store= 6'b010001;
    localparam Li   = 6'b010010;
    localparam Liw  = 6'b010011;

    localparam Jump = 6'b011000;
    localparam Blr  = 6'b011001;
    localparam Bl   = 6'b011010;
    localparam Blrr = 6'b011011;

    localparam Beq  = 6'b100000;
    localparam Ble  = 6'b100000;
    localparam Blt  = 6'b100000;
    localparam Cmpd = 6'b100000;
    localparam Cmpf = 6'b100000;
    localparam Cmpdi= 6'b100000;

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
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
            u_rt_flag <= 0;
            l_rt_flag <= 0;
        end else if (~decode_stall && ~interlock) begin
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
            u_srca <= gpr.gpr[u_dform.ra];
            l_srca <= gpr.gpr[l_dform.ra];

            // SrcB
            case (inst[63:58])
                Addi    : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
                Subi    : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
                Add     : u_srcb <= gpr.gpr[u_xform.rb];
                Sub     : u_srcb <= gpr.gpr[u_xform.rb];
                Srawi   : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
                Slawi   : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
                Fadd    : u_srcb <= gpr.gpr[u_xform.rb];
                Fsub    : u_srcb <= gpr.gpr[u_xform.rb];
                Fmul    : u_srcb <= gpr.gpr[u_xform.rb];
                Fdiv    : u_srcb <= gpr.gpr[u_xform.rb];
                Load    : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
                Store   : u_srcb <= $signed({{16{u_sform.si[15]}}, u_sform.si});
                Li      : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
                Liw     : u_srcb <= $signed(inst[31:0]);
                Jump    : u_srcb <= $signed({6'b0, u_iform.li});
                Bl      : u_srcb <= $signed({6'b0, u_iform.li});
                Beq     : u_srcb <= $signed({6'b0, u_iform.li});
                Ble     : u_srcb <= $signed({6'b0, u_iform.li});
                Blt     : u_srcb <= $signed({6'b0, u_iform.li});
                Cmpd    : u_srcb <= gpr.gpr[u_xform.rb];
                Cmpf    : u_srcb <= gpr.gpr[u_xform.rb];
                Cmpdi   : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
                default : u_srcb <= $signed({{16{u_dform.si[15]}}, u_dform.si});
            endcase
            case (inst[31:26])
                Addi    : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
                Subi    : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
                Add     : l_srcb <= gpr.gpr[l_xform.rb];
                Sub     : l_srcb <= gpr.gpr[l_xform.rb];
                Srawi   : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
                Slawi   : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
                Fadd    : l_srcb <= gpr.gpr[l_xform.rb];
                Fsub    : l_srcb <= gpr.gpr[l_xform.rb];
                Fmul    : l_srcb <= gpr.gpr[l_xform.rb];
                Fdiv    : l_srcb <= gpr.gpr[l_xform.rb];
                Load    : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
                Store   : l_srcb <= $signed({{16{l_sform.si[15]}}, l_sform.si});
                Li      : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
                Cmpd    : l_srcb <= gpr.gpr[l_xform.rb];
                Cmpf    : l_srcb <= gpr.gpr[l_xform.rb];
                Cmpdi   : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
                default : l_srcb <= $signed({{16{l_dform.si[15]}}, l_dform.si});
            endcase

            // SrcS
            u_srcs <= gpr.gpr[u_sform.rs];
            l_srcs <= gpr.gpr[l_sform.rs];

            // ExecType
            case (inst[63:58])
                Addi    : u_e_type <= EAdd;
                Subi    : u_e_type <= ESub;
                Add     : u_e_type <= EAdd;
                Sub     : u_e_type <= ESub;
                Srawi   : u_e_type <= ERshift;
                Slawi   : u_e_type <= ELshift;
                Load    : u_e_type <= EAdd;
                Store   : u_e_type <= EAdd;
                default : u_e_type <= ENop;
            endcase
            case (inst[31:26])
                Addi    : l_e_type <= EAdd;
                Subi    : l_e_type <= ESub;
                Add     : l_e_type <= EAdd;
                Sub     : l_e_type <= ESub;
                Srawi   : l_e_type <= ERshift;
                Slawi   : l_e_type <= ELshift;
                Load    : l_e_type <= EAdd;
                Store   : l_e_type <= EAdd;
                default : l_e_type <= ENop;
            endcase

            // RT
            case (inst[63:58])
                Bl      : u_rt <= 5'b11111;
                Blrr    : u_rt <= 5'b11111;
                default : u_rt <= u_dform.rt;
            endcase
            case (inst[31:26])
                Bl      : l_rt <= 5'b11111;
                Blrr    : l_rt <= 5'b11111;
                default : l_rt <= l_dform.rt;
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

            addr <= gpr.gpr[u_dform.ra] + $signed({{16{u_dform.si[15]}}, u_dform.si});
            dina <= {gpr.gpr[u_sform.rs], gpr.gpr[l_sform.rs]};
            wea[3:0] <= (inst[31:26] == 6'b010001) ? 4'b1111 : 4'b0000;
            wea[7:4] <= (inst[63:58] == 6'b010001) ? 4'b1111 : 4'b0000;
        end else begin
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
            u_rt_flag <= 0;
            l_rt_flag <= 0;
            wea <= 7'b0;
        end
    end
endmodule

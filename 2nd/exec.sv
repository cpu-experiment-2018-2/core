import inst_package::*;

module exec (
    input  wire         interlock,

    // input
    //
    input  wire        [31:0]   pc,
    input  wire        [63:0]   inst,
    // Upper ([63:32])
    input  wire signed [31:0]   u_srca,
    input  wire signed [31:0]   u_srcb,
    input  wire signed [31:0]   u_srcs,
    input  wire        [3:0]    u_e_type,
    input  wire        [4:0]    u_rt,
    input  wire                 u_rt_flag,

    // Lower ([31:0])
    input  wire signed [31:0]   l_srca,
    input  wire signed [31:0]   l_srcb,
    input  wire signed [31:0]   l_srcs,
    input  wire        [3:0]    l_e_type,
    input  wire        [4:0]    l_rt,
    input  wire                 l_rt_flag,

    // output
    //
    output reg         [31:0]   pc_to_the_next,
    output reg         [63:0]   inst_to_the_next,
    // Upper
    output reg  signed [31:0]   u_tdata,
    output reg         [4:0]    u_rt_to_the_next,
    output reg                  u_rt_flag_to_the_next,

    // Lower
    output reg  signed [31:0]   l_tdata,
    output reg         [4:0]    l_rt_to_the_next,
    output reg                  l_rt_flag_to_the_next,

    // FPU
    fpu_in_if           u_fadd_in,
    fpu_in_if           l_fadd_in,
    fpu_in_if           u_fsub_in,
    fpu_in_if           l_fsub_in,
    fpu_in_if           u_fmul_in,
    fpu_in_if           l_fmul_in,
    fpu_in_if           u_fdiv_in,
    fpu_in_if           l_fdiv_in,
    fpu_in_if           u_fsqrt_in,
    fpu_in_if           l_fsqrt_in,
    fpu_in_if           u_ftoi_in,
    fpu_in_if           l_ftoi_in,
    fpu_in_if           u_itof_in,
    fpu_in_if           l_itof_in,

    input  wire [7:0]   uart_rdata,

    input  wire         clk,
    input  wire         rstn);

    function [31:0] EXEC (
        input [31:0] SRCA,
        input [31:0] SRCB,
        input [3:0]  TYPE
    );
        case (TYPE)
            ENop    : EXEC = SRCB;
            EAdd    : EXEC = $signed(SRCA) + $signed(SRCB);
            ESub    : EXEC = $signed(SRCA) - $signed(SRCB);
            ERshift : EXEC = SRCA >>> $signed(SRCB);
            ELshift : EXEC = SRCA <<< $signed(SRCB);
            default : EXEC = SRCB;
        endcase
    endfunction

    always@(posedge clk) begin
        if (~rstn) begin
            pc_to_the_next <= 32'b0;
            inst_to_the_next <= {Nop, 26'b0, Nop, 26'b0};

            u_rt_flag_to_the_next <= 0;
            l_rt_flag_to_the_next <= 0;

            u_fadd_in.rt_flag <= 0;
            l_fadd_in.rt_flag <= 0;
            u_fsub_in.rt_flag <= 0;
            l_fsub_in.rt_flag <= 0;
            u_fmul_in.rt_flag <= 0;
            l_fmul_in.rt_flag <= 0;
            u_fdiv_in.rt_flag <= 0;
            l_fdiv_in.rt_flag <= 0;
            u_fsqrt_in.rt_flag <= 0;
            l_fsqrt_in.rt_flag <= 0;
            u_ftoi_in.rt_flag <= 0;
            l_ftoi_in.rt_flag <= 0;
            u_itof_in.rt_flag <= 0;
            l_itof_in.rt_flag <= 0;
        end else if (~interlock) begin
            pc_to_the_next <= pc;
            inst_to_the_next <= inst;

            case (inst[63:58])
                Inll    : u_tdata <= {u_srcs[31:8], uart_rdata};
                Inlh    : u_tdata <= {u_srcs[31:16], uart_rdata, u_srcs[7:0]};
                Inul    : u_tdata <= {u_srcs[31:24], uart_rdata, u_srcs[15:0]};
                Inuh    : u_tdata <= {uart_rdata, u_srcs[23:0]};
                default : u_tdata <= EXEC(u_srca, u_srcb, u_e_type);
            endcase
            u_rt_to_the_next <= u_rt;
            u_rt_flag_to_the_next <= u_rt_flag;

            l_tdata <= EXEC(l_srca, l_srcb, l_e_type);
            l_rt_to_the_next <= l_rt;
            l_rt_flag_to_the_next <= l_rt_flag;


            // FPU
            // fadd
            u_fadd_in.srca <= u_srca;
            u_fadd_in.srcb <= u_srcb;
            u_fadd_in.rt <= u_rt;
            if (u_e_type == EFadd) u_fadd_in.rt_flag <= 1;
            else u_fadd_in.rt_flag <= 0;
            l_fadd_in.srca <= l_srca;
            l_fadd_in.srcb <= l_srcb;
            l_fadd_in.rt <= l_rt;
            if (l_e_type == EFadd) l_fadd_in.rt_flag <= 1;
            else l_fadd_in.rt_flag <= 0;

            // fsub
            u_fsub_in.srca <= u_srca;
            u_fsub_in.srcb <= u_srcb;
            u_fsub_in.rt <= u_rt;
            if (u_e_type == EFsub) u_fsub_in.rt_flag <= 1;
            else u_fsub_in.rt_flag <= 0;
            l_fsub_in.srca <= l_srca;
            l_fsub_in.srcb <= l_srcb;
            l_fsub_in.rt <= l_rt;
            if (l_e_type == EFsub) l_fsub_in.rt_flag <= 1;
            else l_fsub_in.rt_flag <= 0;

            // fmul
            u_fmul_in.srca <= u_srca;
            u_fmul_in.srcb <= u_srcb;
            u_fmul_in.rt <= u_rt;
            if (u_e_type == EFmul) u_fmul_in.rt_flag <= 1;
            else u_fmul_in.rt_flag <= 0;
            l_fmul_in.srca <= l_srca;
            l_fmul_in.srcb <= l_srcb;
            l_fmul_in.rt <= l_rt;
            if (l_e_type == EFmul) l_fmul_in.rt_flag <= 1;
            else l_fmul_in.rt_flag <= 0;

            // fdiv
            u_fdiv_in.srca <= u_srca;
            u_fdiv_in.srcb <= u_srcb;
            u_fdiv_in.rt <= u_rt;
            if (u_e_type == EFdiv) u_fdiv_in.rt_flag <= 1;
            else u_fdiv_in.rt_flag <= 0;
            l_fdiv_in.srca <= l_srca;
            l_fdiv_in.srcb <= l_srcb;
            l_fdiv_in.rt <= l_rt;
            if (l_e_type == EFdiv) l_fdiv_in.rt_flag <= 1;
            else l_fdiv_in.rt_flag <= 0;

            // fsqrt
            u_fsqrt_in.srca <= u_srca;
            u_fsqrt_in.srcb <= u_srcb;
            u_fsqrt_in.rt <= u_rt;
            if (u_e_type == EFsqrt) u_fsqrt_in.rt_flag <= 1;
            else u_fsqrt_in.rt_flag <= 0;
            l_fsqrt_in.srca <= l_srca;
            l_fsqrt_in.srcb <= l_srcb;
            l_fsqrt_in.rt <= l_rt;
            if (l_e_type == EFsqrt) l_fsqrt_in.rt_flag <= 1;
            else l_fsqrt_in.rt_flag <= 0;

            // ftoi
            u_ftoi_in.srca <= u_srca;
            u_ftoi_in.srcb <= u_srcb;
            u_ftoi_in.rt <= u_rt;
            if (u_e_type == EFtoi) u_ftoi_in.rt_flag <= 1;
            else u_ftoi_in.rt_flag <= 0;
            l_ftoi_in.srca <= l_srca;
            l_ftoi_in.srcb <= l_srcb;
            l_ftoi_in.rt <= l_rt;
            if (l_e_type == EFtoi) l_ftoi_in.rt_flag <= 1;
            else l_ftoi_in.rt_flag <= 0;

            // itof
            u_itof_in.srca <= u_srca;
            u_itof_in.srcb <= u_srcb;
            u_itof_in.rt <= u_rt;
            if (u_e_type == EItof) u_itof_in.rt_flag <= 1;
            else u_itof_in.rt_flag <= 0;
            l_itof_in.srca <= l_srca;
            l_itof_in.srcb <= l_srcb;
            l_itof_in.rt <= l_rt;
            if (l_e_type == EItof) l_itof_in.rt_flag <= 1;
            else l_itof_in.rt_flag <= 0;

        end else begin
        end
    end

endmodule

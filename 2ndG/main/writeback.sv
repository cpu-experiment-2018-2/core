import inst_package::*;

module writeback (
    input  wire         interlock,
    input  wire        [31:0]   fetch_result [0:SUBCORE_NUM],

    (* mark_debug = "true" *) gpr_if              gpr,

    // input
    //
    input  wire        [31:0]   pc_from_exec,
    input  wire        [63:0]   inst_from_exec,

    // From exec
    // Upper
    input  wire signed [31:0]   u_tdata_from_exec,
    input  wire        [4:0]    u_rt_from_exec,
    input  wire                 u_rt_flag_from_exec,
    // Lower
    input  wire signed [31:0]   l_tdata_from_exec,
    input  wire        [4:0]    l_rt_from_exec,
    input  wire                 l_rt_flag_from_exec,

    // From memory
    input  wire        [31:0]   pc_from_mem,
    input  wire        [63:0]   inst_from_mem,
    input  wire        [3:0]    fetch_core_from_mem,
    // Upper
    input  wire        [4:0]    u_rt_from_mem,
    // Lower
    input  wire        [4:0]    l_rt_from_mem,

    input  wire        [31:0]   mem_douta,
    input  wire        [31:0]   mem_doutb,

    // From FPU
    fpu_out_if                  u_fadd_data,
    fpu_out_if                  l_fadd_data,
    fpu_out_if                  u_fsub_data,
    fpu_out_if                  l_fsub_data,
    fpu_out_if                  u_fmul_data,
    fpu_out_if                  l_fmul_data,
    fpu_out_if                  u_fdiv_data,
    fpu_out_if                  l_fdiv_data,
    fpu_out_if                  u_fsqrt_data,
    fpu_out_if                  l_fsqrt_data,
    fpu_out_if                  u_ftoi_data,
    fpu_out_if                  l_ftoi_data,
    fpu_out_if                  u_itof_data,
    fpu_out_if                  l_itof_data,

    input  wire         clk,
    input  wire         rstn);

    (* mark_debug = "true" *) wire [4:0] u_fpu_rt_two    = (u_fadd_data.rt_flag ? u_fadd_data.rt
                                    : (u_fsub_data.rt_flag ? u_fsub_data.rt
                                        : (u_fmul_data.rt_flag ? u_fmul_data.rt
                                            : (u_fsqrt_data.rt ? u_fsqrt_data.rt
                                                : 5'b0 ))));

    (* mark_debug = "true" *) wire [31:0] u_fpu_data_two = (u_fadd_data.rt_flag ? u_fadd_data.tdata
                                    : (u_fsub_data.rt_flag ? u_fsub_data.tdata
                                        : (u_fmul_data.rt_flag ? u_fmul_data.tdata
                                            : (u_fsqrt_data.rt_flag ? u_fsqrt_data.tdata
                                                : 32'b0 ))));

    (* mark_debug = "true" *) wire [4:0] l_fpu_rt_two    = (l_fadd_data.rt_flag ? l_fadd_data.rt
                                    : (l_fsub_data.rt_flag ? l_fsub_data.rt
                                        : (l_fmul_data.rt_flag ? l_fmul_data.rt
                                            : (l_fsqrt_data.rt ? l_fsqrt_data.rt
                                                : 5'b0 ))));

    (* mark_debug = "true" *) wire [31:0] l_fpu_data_two = (l_fadd_data.rt_flag ? l_fadd_data.tdata
                                    : (l_fsub_data.rt_flag ? l_fsub_data.tdata
                                        : (l_fmul_data.rt_flag ? l_fmul_data.tdata
                                            : (l_fsqrt_data.rt_flag ? l_fsqrt_data.tdata
                                                : 32'b0 ))));

    (* mark_debug = "true" *) wire [4:0] u_fpu_rt_one    = (u_ftoi_data.rt_flag ? u_ftoi_data.rt
                                    : (u_itof_data.rt_flag ? u_itof_data.rt
                                        : 5'b0 ));

    (* mark_debug = "true" *) wire [31:0] u_fpu_data_one = (u_ftoi_data.rt_flag ? u_ftoi_data.tdata
                                    : (u_itof_data.rt_flag ? u_itof_data.tdata
                                        : 32'b0 ));

    (* mark_debug = "true" *) wire [4:0] l_fpu_rt_one    = (l_ftoi_data.rt_flag ? l_ftoi_data.rt
                                    : (l_itof_data.rt_flag ? l_itof_data.rt
                                        : 5'b0 ));

    (* mark_debug = "true" *) wire [31:0] l_fpu_data_one = (l_ftoi_data.rt_flag ? l_ftoi_data.tdata
                                    : (l_itof_data.rt_flag ? l_itof_data.tdata
                                        : 32'b0 ));

    always_ff@(posedge clk) begin
        if (~rstn) begin
        end else if (~interlock) begin
            if (inst_from_mem[63:58] == Load) gpr.gpr[u_rt_from_mem] <= mem_douta;
            else if (inst_from_mem[63:58] == Fetch) gpr.gpr[u_rt_from_mem] <= fetch_result[fetch_core_from_mem];
            if (u_rt_flag_from_exec) gpr.gpr[u_rt_from_exec] <= u_tdata_from_exec;

            if (inst_from_mem[31:26] == Load) gpr.gpr[l_rt_from_mem] <= mem_doutb;
            if (l_rt_flag_from_exec) gpr.gpr[l_rt_from_exec] <= l_tdata_from_exec;

            // 4 clk
            // fdiv
            if (u_fdiv_data.rt_flag) gpr.gpr[u_fdiv_data.rt] <= u_fdiv_data.tdata;
            if (l_fdiv_data.rt_flag) gpr.gpr[l_fdiv_data.rt] <= l_fdiv_data.tdata;

            // 2 clk
            // fadd/fsub/fmul/fsqrt
            if (u_fadd_data.rt_flag || u_fsub_data.rt_flag || u_fmul_data.rt_flag || u_fsqrt_data.rt_flag) begin
                gpr.gpr[u_fpu_rt_two] <= u_fpu_data_two;
            end
            if (l_fadd_data.rt_flag || l_fsub_data.rt_flag || l_fmul_data.rt_flag || l_fsqrt_data.rt_flag) begin
                gpr.gpr[l_fpu_rt_two] <= l_fpu_data_two;
            end

            // 1 clk
            // ftoi/itof
            if (u_ftoi_data.rt_flag || u_itof_data.rt_flag) begin
                gpr.gpr[u_fpu_rt_one] <= u_fpu_data_one;
            end
            if (l_ftoi_data.rt_flag || l_itof_data.rt_flag) begin
                gpr.gpr[l_fpu_rt_one] <= l_fpu_data_one;
            end
        end
    end

endmodule

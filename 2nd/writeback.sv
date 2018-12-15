module writeback (
    input  wire         interlock,

    gpr_if              gpr,

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
    // Upper
    input  wire        [4:0]    u_rt_from_mem,
    input  wire                 u_rt_flag_from_mem,
    // Lower
    input  wire signed [31:0]   l_tdata_from_mem,
    input  wire        [4:0]    l_rt_from_mem,
    input  wire                 l_rt_flag_from_mem,

    input  wire        [63:0]   mem_doutb,

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

    always_ff@(posedge clk) begin
        if (~rstn) begin
        end else if (~interlock) begin
            if (inst_from_mem[63:58] == 6'b010000) begin
                gpr.gpr[u_rt_from_mem] <= mem_doutb[63:32];
            end 
            if (u_rt_flag_from_exec) begin
                gpr.gpr[u_rt_from_exec] <= u_tdata_from_exec;
            end

            if (inst_from_mem[31:26] == 6'b010000) begin
                gpr.gpr[l_rt_from_mem] <= mem_doutb[31:0];
            end else if (l_rt_flag_from_mem) gpr.gpr[l_rt_from_mem] <= l_tdata_from_mem;
            if (l_rt_flag_from_exec) gpr.gpr[l_rt_from_exec] <= l_tdata_from_exec;

            // fdiv
            if (u_fdiv_data.rt_flag) gpr.gpr[u_fdiv_data.rt] <= u_fdiv_data.tdata;
            if (l_fdiv_data.rt_flag) gpr.gpr[l_fdiv_data.rt] <= l_fdiv_data.tdata;

            // fsqrt
            // 2 clk
            // fadd/fsub/fmul/fsqrt
            if (u_fadd_data.rt_flag) gpr.gpr[u_fadd_data.rt] <= u_fadd_data.tdata;
            else if (u_fsub_data.rt_flag) gpr.gpr[u_fsub_data.rt] <= u_fsub_data.tdata;
            else if (u_fmul_data.rt_flag) gpr.gpr[u_fmul_data.rt] <= u_fmul_data.tdata;
            else if (u_fsqrt_data.rt_flag) gpr.gpr[u_fsqrt_data.rt] <= u_fsqrt_data.tdata;

            if (l_fadd_data.rt_flag) gpr.gpr[l_fadd_data.rt] <= l_fadd_data.tdata;
            else if (l_fsub_data.rt_flag) gpr.gpr[l_fsub_data.rt] <= l_fsub_data.tdata;
            else if (l_fmul_data.rt_flag) gpr.gpr[l_fmul_data.rt] <= l_fmul_data.tdata;
            else if (l_fsqrt_data.rt_flag) gpr.gpr[l_fsqrt_data.rt] <= l_fsqrt_data.tdata;

            // 1 clk
            // ftoi/itof
            if (u_ftoi_data.rt_flag) gpr.gpr[u_ftoi_data.rt] <= u_ftoi_data.tdata;
            else if (u_itof_data.rt_flag) gpr.gpr[u_itof_data.rt] <= u_itof_data.tdata;

            if (l_ftoi_data.rt_flag) gpr.gpr[l_ftoi_data.rt] <= l_ftoi_data.tdata;
            else if (l_itof_data.rt_flag) gpr.gpr[l_itof_data.rt] <= l_itof_data.tdata;
        end
    end

endmodule

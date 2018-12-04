module writeback (
    input  wire         interlock,

    gpr_if              gpr,

    // input
    //
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
    input  wire        [63:0]   inst_from_mem,
    // Upper
    input  wire        [4:0]    u_rt_from_mem,
    input  wire                 u_rt_flag_from_mem,
    // Lower
    input  wire signed [31:0]   l_tdata_from_mem,
    input  wire        [4:0]    l_rt_from_mem,
    input  wire                 l_rt_flag_from_mem,

    input  wire        [63:0]   n_doutb,


    input  wire         clk,
    input  wire         rstn);

    reg  [63:0] mem_doutb;

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
        end
    end

    always_ff@(negedge clk) begin
        if (~rstn) begin
        end else if (~interlock) begin
            mem_doutb <= n_doutb;
        end
    end

endmodule

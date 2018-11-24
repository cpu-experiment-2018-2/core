module cpu (
    input  wire         clk,
    input  wire         rstn);

    reg             interlock;

    gpr_if          gpr;
    reg  [31:0]     pc;

    wire            fetch_stall;
    wire            decode_stall;
    wire            exec_stall;
    wire            memory1_stall;
    wire            memory2_stall;

    wire [63:0]     decode_inst;
    wire [63:0]     exec_inst;
    wire [63:0]     inst_from_exec;
    wire [63:0]     inst_from_mem1;
    wire [63:0]     inst_from_mem2;
    wire [63:0]     writeback_inst;

    wire            memory1_used;
    wire            memory2_used;

    // fetch, decode & exec stall flag
    // If exec_inst == Store
    assign fde_stall = memory1_stall || (~(exec_inst[63:58] == 6'b010000 || exec_inst[63:58] == 6'b010001) && (memory1_used || memory2_used));
    // memory2_used && memory1_inst == Store
    // If the inst at memory1 is Store, the output is sent to writeback
    // Otherwise, that is, if memory1 has Load inst, it is to memory2
    assign memory1_stall = memory2_used && (inst_from_exec[63:58] == 6'b010001);


    //================
    //     Fetch
    //================
    fetch fi(   .interlock(interlock),
                .fetch_stall(fde_stall),
                .inst_to_the_next(decode_inst),
                .clk(clk),
                .rstn(rstn));

    //================
    //     Decode
    //================
    wire signed [31:0]  u_srca;
    wire signed [31:0]  u_srcb;
    wire signed [31:0]  u_srcs_to_exec;
    wire        [3:0]   u_e_type;
    wire        [4:0]   u_rt_to_exec;
    wire                u_rt_flag_to_exec;

    wire signed [31:0]  l_srca;
    wire signed [31:0]  l_srcb;
    wire signed [31:0]  l_srcs_to_exec;
    wire        [3:0]   l_e_type;
    wire        [4:0]   l_rt_to_exec;
    wire                l_rt_flag_to_exec;

    decode di(  .interlock(interlock),
                .decode_stall(fde_stall),
                .gpr(gpr),
                .inst(decode_inst),
                .inst_to_the_next(exec_inst),
                .u_srca(u_srca),
                .u_srcb(u_srcb),
                .u_srcs(u_srcs_to_exec),
                .u_e_type(u_e_type),
                .u_rt(u_rt_to_exec),
                .u_rt_flag(u_rt_flag_to_exec),
                .l_srca(u_srca),
                .l_srcb(u_srcb),
                .l_srcs(u_srcs_to_exec),
                .l_e_type(u_e_type),
                .l_rt(u_rt_to_exec),
                .l_rt_flag(u_rt_flag_to_exec),
                .clk(clk),
                .rstn(rstn));

    //================
    //     Exec
    //================
    wire                ex_to_wb_ready;
    wire signed [31:0]  u_tdata_from_exec;
    wire        [4:0]   u_rt_from_exec;
    wire                u_rt_flag_from_exec;

    wire signed [31:0]  l_tdata_from_exec;
    wire        [4:0]   l_rt_from_exec;
    wire                l_rt_flag_from_exec;

    exec ex(    .interlock(interlock),
                .exec_stall(fde_stall),
                .ex_to_mem1_ready(memory1_used),
                .inst(exec_inst),
                .u_srca(u_srca),
                .u_srcb(u_srcb),
                .u_srcs(u_srcs_to_exec),
                .u_e_type(u_e_type),
                .u_rt(u_rt_to_exec),
                .u_rt_flag(u_rt_flag_to_exec),
                .l_srca(u_srca),
                .l_srcb(u_srcb),
                .l_srcs(u_srcs_to_exec),
                .l_e_type(u_e_type),
                .l_rt(u_rt_to_exec),
                .l_rt_flag(u_rt_flag_to_exec),
                .inst_to_the_next(inst_from_exec),
                .u_tdata(u_tdata_from_exec),
                .u_rt_to_the_next(u_rt_from_exec),
                .u_rt_flag_to_the_next(u_rt_flag_from_exec),
                .l_tdata(u_tdata_from_exec),
                .l_rt_to_the_next(u_rt_from_exec),
                .l_rt_flag_to_the_next(u_rt_flag_from_exec),
                .clk(clk),
                .rstn(rstn));

    //================
    //    Memory1
    //================
    /*
    wire signed [31:0]  u_tdata_from_mem1;
    wire        [4:0]   u_rt_from_mem1;
    wire                u_rt_flag_from_mem1;

    wire signed [31:0]  l_tdata_from_mem1;
    wire        [4:0]   l_rt_from_mem1;
    wire                l_rt_flag_from_mem1;
    
    memory1 mem1(   .interlock(interlock),
                    .memory1_stall(memory1_stall),
                    .memory1_used(memory1_used),
                    .inst(inst_from_exec),
                    .addra(
    */

    //================
    //    Memory2
    //================
    assign memory2_used = 0;

    //================
    //   Writeback
    //================
    wire signed [31:0] wb_u_tdata;
    wire        [4:0]  wb_u_rt;
    wire               wb_u_rt_flag;

    wire signed [31:0] wb_l_tdata;
    wire        [4:0]  wb_l_rt;
    wire               wb_l_rt_flag;

    assign writeback_inst   = ex_to_wb_ready ? inst_from_exec : inst_from_mem1;
    assign wb_u_tdata       = u_tdata_from_exec;
    assign wb_u_rt          = u_rt_from_exec;
    assign wb_u_rt_flag     = u_rt_flag_from_exec;
    assign wb_l_tdata       = l_tdata_from_exec;
    assign wb_l_rt          = l_rt_from_exec;
    assign wb_l_rt_flag     = l_rt_flag_from_exec;
    
    writeback wb(   .interlock(interlock),
                    .gpr(gpr),
                    .inst(writeback_inst),
                    .u_tdata(wb_u_tdata),
                    .u_rt(wb_u_rt),
                    .u_rt_flag(wb_u_rt_flag),
                    .l_tdata(wb_l_tdata),
                    .l_rt(wb_l_rt),
                    .l_rt_flag(wb_l_rt_flag),
                    .clk(clk),
                    .rstn(rstn));

    always@(posedge clk) begin
        if (~rstn) begin
            interlock <= 1;
            pc <= 32'b0;
        end else begin
            interlock <= 0;
            pc <= pc + 8;
        end
    end

endmodule

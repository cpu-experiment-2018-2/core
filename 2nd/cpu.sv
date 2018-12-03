interface gpr_if;
    reg signed [31:0] gpr [0:31];
endinterface

module cpu (
    output wire [7:0]   led,

    input  wire         clk,
    input  wire         rstn);

    assign red = 7'b0;

    reg             interlock;

    gpr_if          gpr();
    assign led = gpr.gpr[0][7:0];

    wire [31:0]     pc;

    wire            fde_stall;

    wire [63:0]     decode_inst;
    wire [63:0]     exec_inst;
    wire [63:0]     inst_from_exec;
    wire [63:0]     inst_from_mem;
    wire [63:0]     writeback_inst;

    wire            memory_used;

    // fetch, decode & exec stall flag
    // Instructions which need not transit to writeback stage right after exec
    // (ex. Store/Load/Branch insts)
    // can be processed continuously even when the prev is Load inst.
    assign fde_stall = ~(exec_inst[63:58] == 6'b010000 || exec_inst[63:58] == 6'b010001     // Load, Store
                        || exec_inst[63:58] == 6'b011000 || exec_inst[63:58] == 6'b011001   // Jump, Blr
                        || exec_inst[63:61] == 3'b100 || exec_inst[63:61] == 3'b111         // Comp insts, Nop
                        ) && memory_used;
    // When the inst at exec is Store, the data to be stored is directly sent to
    // BRAM and pipeline processing keeps going.
    // If exec stage has Load inst, memory stage is executed before writing back to
    // regs. In such a case, the next inst has to be stalled at exec stage
    // if it is not Load.
    // -->-->-->-->-->-->
    // F D E W
    //   F D E M W      ... Load inst
    //     F D E M W    ... the next inst is also Load
    //       F D - E
    //         F - D
    //
    //     F D - E W    ... otherwise
    //       F - D E W
    //         - F D E


    //================
    //     Fetch
    //================
    fetch fi(   .interlock(interlock),
                .fetch_stall(fde_stall),
                .pc(pc),
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
                .l_srca(l_srca),
                .l_srcb(l_srcb),
                .l_srcs(l_srcs_to_exec),
                .l_e_type(l_e_type),
                .l_rt(l_rt_to_exec),
                .l_rt_flag(l_rt_flag_to_exec),
                .clk(clk),
                .rstn(rstn));

    //================
    //     Exec
    //================
    wire signed [31:0]  u_tdata_from_exec;
    wire        [4:0]   u_rt_from_exec;
    wire                u_rt_flag_from_exec;

    wire signed [31:0]  l_tdata_from_exec;
    wire        [4:0]   l_rt_from_exec;
    wire                l_rt_flag_from_exec;
    wire        [63:0]  dina;

    exec ex(    .interlock(interlock),
                .exec_stall(fde_stall),
                .ex_to_mem_ready(memory_used),
                .inst(exec_inst),
                .u_srca(u_srca),
                .u_srcb(u_srcb),
                .u_srcs(u_srcs_to_exec),
                .u_e_type(u_e_type),
                .u_rt(u_rt_to_exec),
                .u_rt_flag(u_rt_flag_to_exec),
                .l_srca(l_srca),
                .l_srcb(l_srcb),
                .l_srcs(l_srcs_to_exec),
                .l_e_type(l_e_type),
                .l_rt(l_rt_to_exec),
                .l_rt_flag(l_rt_flag_to_exec),
                .inst_to_the_next(inst_from_exec),
                .u_tdata(u_tdata_from_exec),
                .u_rt_to_the_next(u_rt_from_exec),
                .u_rt_flag_to_the_next(u_rt_flag_from_exec),
                .l_tdata(l_tdata_from_exec),
                .l_rt_to_the_next(l_rt_from_exec),
                .l_rt_flag_to_the_next(l_rt_flag_from_exec),
                .dina(dina),
                .clk(clk),
                .rstn(rstn));

    //================
    //    Memory
    //================
    wire        [4:0]   u_rt_from_mem;
    wire                u_rt_flag_from_mem;
    wire signed [31:0]  l_tdata_from_mem;
    wire        [4:0]   l_rt_from_mem;
    wire                l_rt_flag_from_mem;
    wire        [63:0]  mem_doutb;
    
    memory mem( .interlock(interlock),
                .memory_used(memory_used),
                .inst(inst_from_exec),
                .addra(u_tdata_from_exec),
                .dina(dina),
                .addrb(u_tdata_from_exec),
                .u_rt(u_rt_from_exec),
                .u_rt_flag(u_rt_flag_from_exec),
                .l_tdata(l_tdata_from_exec),
                .l_rt(l_rt_from_exec),
                .l_rt_flag(l_rt_flag_from_exec),
                .inst_to_the_next(inst_from_mem),
                .u_rt_to_the_next(u_rt_from_mem),
                .u_rt_flag_to_the_next(u_rt_flag_from_mem),
                .l_tdata_to_the_next(l_tdata_from_mem),
                .l_rt_to_the_next(l_rt_from_mem),
                .l_rt_flag_to_the_next(l_rt_flag_from_mem),
                .mem_doutb(mem_doutb),
                .clk(clk),
                .rstn(rstn));

    //================
    //   Writeback
    //================
    wire signed [31:0] ex_to_wb_u_tdata;
    wire        [4:0]  ex_to_wb_u_rt;
    wire               ex_to_wb_u_rt_flag;

    wire signed [31:0] ex_to_wb_l_tdata;
    wire        [4:0]  ex_to_wb_l_rt;
    wire               ex_to_wb_l_rt_flag;

    assign ex_to_wb_u_tdata       = u_tdata_from_exec;
    assign ex_to_wb_u_rt          = u_rt_from_exec;
    assign ex_to_wb_u_rt_flag     = u_rt_flag_from_exec;
    assign ex_to_wb_l_tdata       = l_tdata_from_exec;
    assign ex_to_wb_l_rt          = l_rt_from_exec;
    assign ex_to_wb_l_rt_flag     = l_rt_flag_from_exec;
    
    writeback wb(.*);

    always@(posedge clk) begin
        if (~rstn) begin
            interlock <= 1;
        end else begin
            interlock <= 0;
        end
    end

endmodule

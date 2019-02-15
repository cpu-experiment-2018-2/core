import inst_package::*;

interface gpr_if;
    reg signed [31:0] gpr [0:31];
endinterface

interface fpu_in_if;
    reg     [31:0]  srca;
    reg     [31:0]  srcb;
    reg     [4:0]   rt;
    reg             rt_flag;
endinterface

interface fpu_out_if;
    wire    [31:0]  tdata;
    wire    [4:0]   rt;
    wire            rt_flag;
endinterface

interface mem_in_if;
    reg     [31:0]  addr;
    reg     [31:0]  din;
    reg     [4:0]   we;
endinterface


module sub (
    input  wire         exec_requested,
    input  wire  [31:0] requested_pc,
    input  wire  [31:0] fetch_addr,
    input  data_in      u_n_in_from_main,
    input  data_in      l_n_in_from_main,
    output reg          ended,
    output wire  [31:0] fetch_result,

    input  wire         clk,
    input  wire         rstn);

    reg             interlock;

    gpr_if          gpr();
    assign led = gpr.gpr[0][7:0];

    wire [31:0]     decode_pc;
    wire [31:0]     exec_pc;
    wire [31:0]     pc_from_exec;
    wire [31:0]     pc_from_mem;


    wire [63:0]     decode_inst;
    wire [63:0]     exec_inst;
    wire [63:0]     inst_from_exec;
    wire [63:0]     inst_from_mem;


    //================
    //     Fetch
    //================
    wire                branch_flag;
    wire        [31:0]  branch_pc;

    fetch fi(   .interlock(interlock),
                .branch_flag(branch_flag),
                .branch_pc(branch_pc),
                .exec_requested(exec_requested),
                .requested_pc(requested_pc),
                .pc_to_the_next(decode_pc),
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
    wire        [4:0]   u_rt_from_decode;
    wire                u_rt_flag_from_decode;

    wire signed [31:0]  l_srca;
    wire signed [31:0]  l_srcb;
    wire signed [31:0]  l_srcs_to_exec;
    wire        [3:0]   l_e_type;
    wire        [4:0]   l_rt_from_decode;
    wire                l_rt_flag_from_decode;

    mem_in_if   u_mem_in();
    mem_in_if   l_mem_in();

    decode di(  .interlock(interlock),
                .gpr(gpr),
                .pc(decode_pc),
                .inst(decode_inst),
                .branch_flag(branch_flag),
                .branch_pc(branch_pc),
                .pc_to_the_next(exec_pc),
                .inst_to_the_next(exec_inst),
                .u_srca(u_srca),
                .u_srcb(u_srcb),
                .u_srcs(u_srcs_to_exec),
                .u_e_type(u_e_type),
                .u_rt(u_rt_from_decode),
                .u_rt_flag(u_rt_flag_from_decode),
                .l_srca(l_srca),
                .l_srcb(l_srcb),
                .l_srcs(l_srcs_to_exec),
                .l_e_type(l_e_type),
                .l_rt(l_rt_from_decode),
                .l_rt_flag(l_rt_flag_from_decode),
                .u_mem_in(u_mem_in),
                .l_mem_in(l_mem_in),
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

    fpu_in_if   u_fadd_in();
    fpu_in_if   l_fadd_in();
    fpu_in_if   u_fsub_in();
    fpu_in_if   l_fsub_in();
    fpu_in_if   u_fmul_in();
    fpu_in_if   l_fmul_in();
    fpu_in_if   u_fdiv_in();
    fpu_in_if   l_fdiv_in();
    fpu_in_if   u_fsqrt_in();
    fpu_in_if   l_fsqrt_in();
    fpu_in_if   u_ftoi_in();
    fpu_in_if   l_ftoi_in();
    fpu_in_if   u_itof_in();
    fpu_in_if   l_itof_in();

    exec ex(    .interlock(interlock),
                .pc(exec_pc),
                .inst(exec_inst),
                .u_srca(u_srca),
                .u_srcb(u_srcb),
                .u_srcs(u_srcs_to_exec),
                .u_e_type(u_e_type),
                .u_rt(u_rt_from_decode),
                .u_rt_flag(u_rt_flag_from_decode),
                .l_srca(l_srca),
                .l_srcb(l_srcb),
                .l_srcs(l_srcs_to_exec),
                .l_e_type(l_e_type),
                .l_rt(l_rt_from_decode),
                .l_rt_flag(l_rt_flag_from_decode),
                .pc_to_the_next(pc_from_exec),
                .inst_to_the_next(inst_from_exec),
                .u_tdata(u_tdata_from_exec),
                .u_rt_to_the_next(u_rt_from_exec),
                .u_rt_flag_to_the_next(u_rt_flag_from_exec),
                .l_tdata(l_tdata_from_exec),
                .l_rt_to_the_next(l_rt_from_exec),
                .l_rt_flag_to_the_next(l_rt_flag_from_exec),
                .u_fadd_in(u_fadd_in),
                .l_fadd_in(l_fadd_in),
                .u_fsub_in(u_fsub_in),
                .l_fsub_in(l_fsub_in),
                .u_fmul_in(u_fmul_in),
                .l_fmul_in(l_fmul_in),
                .u_fdiv_in(u_fdiv_in),
                .l_fdiv_in(l_fdiv_in),
                .u_fsqrt_in(u_fsqrt_in),
                .l_fsqrt_in(l_fsqrt_in),
                .u_ftoi_in(u_ftoi_in),
                .l_ftoi_in(l_ftoi_in),
                .u_itof_in(u_itof_in),
                .l_itof_in(l_itof_in),
                .clk(clk),
                .rstn(rstn));

    //================
    //    Memory
    //================
    wire        [4:0]   u_rt_from_mem;
    wire        [4:0]   l_rt_from_mem;
    wire        [31:0]  mem_douta;
    wire        [31:0]  mem_doutb;
    
    memory mem( .interlock(interlock),
                .pc(pc_from_exec),
                .inst(inst_from_exec),
                .u_mem_in(u_mem_in),
                .l_mem_in(l_mem_in),
                .u_rt(u_rt_from_exec),
                .l_rt(l_rt_from_exec),
                .pc_to_the_next(pc_from_mem),
                .inst_to_the_next(inst_from_mem),
                .u_rt_to_the_next(u_rt_from_mem),
                .l_rt_to_the_next(l_rt_from_mem),
                .mem_douta(mem_douta),
                .mem_doutb(mem_doutb),
                .fetch_result(fetch_result),
                .u_n_in_from_main(u_n_in_from_main),
                .l_n_in_from_main(l_n_in_from_main),
                .clk(clk),
                .rstn(rstn));


    //================
    //      FPU
    //================
    //   fadd
    fpu_out_if   u_fadd_data();
    fpu_out_if   l_fadd_data();

    fadd u_fadd(    .adata(u_fadd_in.srca),
                    .bdata(u_fadd_in.srcb),
                    .result(u_fadd_data.tdata),
                    .clk(clk),
                    .flag_in(u_fadd_in.rt_flag),
                    .address_in(u_fadd_in.rt),
                    .flag_out(u_fadd_data.rt_flag),
                    .address_out(u_fadd_data.rt));

    fadd l_fadd(    .adata(l_fadd_in.srca),
                    .bdata(l_fadd_in.srcb),
                    .result(l_fadd_data.tdata),
                    .clk(clk),
                    .flag_in(l_fadd_in.rt_flag),
                    .address_in(l_fadd_in.rt),
                    .flag_out(l_fadd_data.rt_flag),
                    .address_out(l_fadd_data.rt));


    //   fsub
    fpu_out_if   u_fsub_data();
    fpu_out_if   l_fsub_data();

    fsub u_fsub(    .adata(u_fsub_in.srca),
                    .bdata(u_fsub_in.srcb),
                    .result(u_fsub_data.tdata),
                    .clk(clk),
                    .flag_in(u_fsub_in.rt_flag),
                    .address_in(u_fsub_in.rt),
                    .flag_out(u_fsub_data.rt_flag),
                    .address_out(u_fsub_data.rt));

    fsub l_fsub(    .adata(l_fsub_in.srca),
                    .bdata(l_fsub_in.srcb),
                    .result(l_fsub_data.tdata),
                    .clk(clk),
                    .flag_in(l_fsub_in.rt_flag),
                    .address_in(l_fsub_in.rt),
                    .flag_out(l_fsub_data.rt_flag),
                    .address_out(l_fsub_data.rt));


    //   fmul
    fpu_out_if   u_fmul_data();
    fpu_out_if   l_fmul_data();

    fmul u_fmul(    .adata(u_fmul_in.srca),
                    .bdata(u_fmul_in.srcb),
                    .result(u_fmul_data.tdata),
                    .clk(clk),
                    .flag_in(u_fmul_in.rt_flag),
                    .address_in(u_fmul_in.rt),
                    .flag_out(u_fmul_data.rt_flag),
                    .address_out(u_fmul_data.rt));

    fmul l_fmul(    .adata(l_fmul_in.srca),
                    .bdata(l_fmul_in.srcb),
                    .result(l_fmul_data.tdata),
                    .clk(clk),
                    .flag_in(l_fmul_in.rt_flag),
                    .address_in(l_fmul_in.rt),
                    .flag_out(l_fmul_data.rt_flag),
                    .address_out(l_fmul_data.rt));


    //   fdiv
    fpu_out_if   u_fdiv_data();
    fpu_out_if   l_fdiv_data();

    fdiv u_fdiv(    .adata(u_fdiv_in.srca),
                    .bdata(u_fdiv_in.srcb),
                    .result(u_fdiv_data.tdata),
                    .clk(clk),
                    .flag_in(u_fdiv_in.rt_flag),
                    .address_in(u_fdiv_in.rt),
                    .flag_out(u_fdiv_data.rt_flag),
                    .address_out(u_fdiv_data.rt));

    fdiv l_fdiv(    .adata(l_fdiv_in.srca),
                    .bdata(l_fdiv_in.srcb),
                    .result(l_fdiv_data.tdata),
                    .clk(clk),
                    .flag_in(l_fdiv_in.rt_flag),
                    .address_in(l_fdiv_in.rt),
                    .flag_out(l_fdiv_data.rt_flag),
                    .address_out(l_fdiv_data.rt));


    //   fsqrt
    fpu_out_if   u_fsqrt_data();
    fpu_out_if   l_fsqrt_data();

    fsqrt u_fsqrt(  .adata(u_fsqrt_in.srca),
                    .result(u_fsqrt_data.tdata),
                    .clk(clk),
                    .flag_in(u_fsqrt_in.rt_flag),
                    .address_in(u_fsqrt_in.rt),
                    .flag_out(u_fsqrt_data.rt_flag),
                    .address_out(u_fsqrt_data.rt));

    fsqrt l_fsqrt(  .adata(l_fsqrt_in.srca),
                    .result(l_fsqrt_data.tdata),
                    .clk(clk),
                    .flag_in(l_fsqrt_in.rt_flag),
                    .address_in(l_fsqrt_in.rt),
                    .flag_out(l_fsqrt_data.rt_flag),
                    .address_out(l_fsqrt_data.rt));


    //   ftoi
    fpu_out_if   u_ftoi_data();
    fpu_out_if   l_ftoi_data();

    ftoi u_ftoi(    .adata(u_ftoi_in.srca),
                    .result(u_ftoi_data.tdata),
                    .clk(clk),
                    .flag_in(u_ftoi_in.rt_flag),
                    .address_in(u_ftoi_in.rt),
                    .flag_out(u_ftoi_data.rt_flag),
                    .address_out(u_ftoi_data.rt));

    ftoi l_ftoi(    .adata(l_ftoi_in.srca),
                    .result(l_ftoi_data.tdata),
                    .clk(clk),
                    .flag_in(l_ftoi_in.rt_flag),
                    .address_in(l_ftoi_in.rt),
                    .flag_out(l_ftoi_data.rt_flag),
                    .address_out(l_ftoi_data.rt));


    //   itof
    fpu_out_if   u_itof_data();
    fpu_out_if   l_itof_data();

    itof u_itof(    .adata(u_itof_in.srca),
                    .result(u_itof_data.tdata),
                    .clk(clk),
                    .flag_in(u_itof_in.rt_flag),
                    .address_in(u_itof_in.rt),
                    .flag_out(u_itof_data.rt_flag),
                    .address_out(u_itof_data.rt));

    itof l_itof(    .adata(l_itof_in.srca),
                    .result(l_itof_data.tdata),
                    .clk(clk),
                    .flag_in(l_itof_in.rt_flag),
                    .address_in(l_itof_in.rt),
                    .flag_out(l_itof_data.rt_flag),
                    .address_out(l_itof_data.rt));


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


    typedef enum logic [2:0] {
        RUN_ST, PRE_READ_ST, READ_ST, PRE_WRITE_ST, WRITE_ST
    } state_type;

    state_type state;

    always@(posedge clk) begin
        if (~rstn) begin
            interlock <= 0;
            ended <= 0;

            io_ren <= 0;
            io_wen <= 0;

            state <= RUN_ST;
        end else begin
            if (interlock == 0 && branch_flag == 0) begin
                if (exec_inst[63:58] == End) begin
                    interlock <= 1;
                    ended <= 1;
                end
            end else begin
                if (exec_requested) begin
                    interlock <= 0;
                    ended <= 0;
                end
            end
        end
    end

endmodule

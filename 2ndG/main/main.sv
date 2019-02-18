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
    reg     [3:0]   we;
endinterface

module main (
    (* mark_debug = "true" *)input  wire         subcore_ended   [0:SUBCORE_NUM-1],
    (* mark_debug = "true" *)input  wire [31:0]  fetch_result    [0:SUBCORE_NUM-1],

    (* mark_debug = "true" *)output data_in      u_n_in_to_sub   [0:SUBCORE_NUM-1],
    (* mark_debug = "true" *)output data_in      l_n_in_to_sub   [0:SUBCORE_NUM-1],

    (* mark_debug = "true" *)output reg          exec_requested  [0:SUBCORE_NUM-1],
    (* mark_debug = "true" *)output reg  [31:0]  requested_pc    [0:SUBCORE_NUM-1],
    (* mark_debug = "true" *)output wire [31:0]  fetch_addr      [0:SUBCORE_NUM-1],

    input  wire         rx,
    output wire         tx,

    input  wire         clk,
    input  wire         rstn);

    (* mark_debug = "true" *)reg             interlock;
    (* mark_debug = "true" *)reg  [3:0]      join_target;
    (* mark_debug = "true" *)reg  [3:0]      living_sub_count;

    gpr_if          gpr();

    (* mark_debug = "true" *)wire [31:0]     decode_pc;
    wire [31:0]     exec_pc;
    wire [31:0]     pc_from_exec;
    wire [31:0]     pc_from_mem;


    (* mark_debug = "true" *)wire [63:0]     decode_inst;
    wire [63:0]     exec_inst;
    wire [63:0]     inst_from_exec;
    wire [63:0]     inst_from_mem;

    wire [3:0]      fetch_core_from_exec;
    wire [3:0]      fetch_core_from_mem;


    //================
    //     Fetch
    //================
    wire                branch_flag;
    wire        [31:0]  branch_pc;

    mfetch fi(   .interlock(interlock),
                .branch_flag(branch_flag),
                .branch_pc(branch_pc),
                .pc_to_the_next(decode_pc),
                .inst_to_the_next(decode_inst),
                .clk(clk),
                .rstn(rstn));

    //================
    //     Decode
    //================
    (* mark_debug = "true" *)wire signed [31:0]  u_srca;
    (* mark_debug = "true" *)wire signed [31:0]  u_srcb;
    (* mark_debug = "true" *)wire signed [31:0]  u_srcs_to_exec;
    wire        [3:0]   u_e_type;
    wire        [4:0]   u_rt_from_decode;
    wire                u_rt_flag_from_decode;

    (* mark_debug = "true" *)wire signed [31:0]  l_srca;
    (* mark_debug = "true" *)wire signed [31:0]  l_srcb;
    (* mark_debug = "true" *)wire signed [31:0]  l_srcs_to_exec;
    wire        [3:0]   l_e_type;
    wire        [4:0]   l_rt_from_decode;
    wire                l_rt_flag_from_decode;

    wire        [7:0]   uart_wdata_from_decode;

    mem_in_if   u_mem_in();
    mem_in_if   l_mem_in();

    mdecode di( .interlock(interlock),
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
                .uart_wdata(uart_wdata_from_decode),
                .fetch_addr(fetch_addr),
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

    reg  [7:0]  uart_rdata;

    mexec ex(   .interlock(interlock),
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
                .fetch_core(fetch_core_from_exec),
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
                .uart_rdata(uart_rdata),
                .clk(clk),
                .rstn(rstn));

    //================
    //    Memory
    //================
    wire        [4:0]   u_rt_from_mem;
    wire        [4:0]   l_rt_from_mem;
    wire        [31:0]  mem_douta;
    wire        [31:0]  mem_doutb;
    
    mmemory mem(.interlock(interlock),
                .living_sub_count(living_sub_count),
                .pc(pc_from_exec),
                .inst(inst_from_exec),
                .fetch_core(fetch_core_from_exec),
                .u_mem_in(u_mem_in),
                .l_mem_in(l_mem_in),
                .u_rt(u_rt_from_exec),
                .l_rt(l_rt_from_exec),
                .pc_to_the_next(pc_from_mem),
                .inst_to_the_next(inst_from_mem),
                .fetch_core_to_the_next(fetch_core_from_mem),
                .u_rt_to_the_next(u_rt_from_mem),
                .l_rt_to_the_next(l_rt_from_mem),
                .mem_douta(mem_douta),
                .mem_doutb(mem_doutb),
                .u_n_in_to_sub(u_n_in_to_sub),
                .l_n_in_to_sub(l_n_in_to_sub),
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
    mwriteback wb(.*);



    //===============
    //      IO
    //===============

    reg         io_ren;
    wire [7:0]  io_rdata;
    wire        io_rbusy;
    wire        io_rdone;

    reg         io_wen;
    reg  [7:0]  io_wdata;
    wire        io_wbusy;
    wire        io_wdone;

    uart_io io( .ren(io_ren),
                .rdata(io_rdata),
                .rbusy(io_rbusy),
                .rdone(io_rdone),
                .wen(io_wen),
                .wdata(io_wdata),
                .wbusy(io_wbusy),
                .wdone(io_wdone),
                .rx(rx),
                .tx(tx),
                .clk(clk),
                .rstn(rstn));

    typedef enum logic [3:0] {
        RUN_ST, JOINING_ST, PRE_READ_ST, READ_ST, PRE_WRITE_ST, WRITE_ST
    } state_type;

    state_type state;

    reg  [7:0]  uart_wdata;

    always@(posedge clk) begin
        if (~rstn) begin
            interlock <= 0;
            living_sub_count <= 0;

            io_ren <= 0;
            io_wen <= 0;

            state <= RUN_ST;
        end else begin
            if (interlock == 0 && branch_flag == 0) begin
                if (exec_inst[63:58] == Fork) begin
                    living_sub_count <= living_sub_count + 1;
                    exec_requested[u_srca] <= 1;
                    for (int i = 0; i < SUBCORE_NUM; i++) requested_pc[i] <= u_srcb;
                end else begin
                    for (int i = 0; i < SUBCORE_NUM; i++) exec_requested[i] <= 0;
                end

                if (decode_inst[63:58] == Inll) begin
                    interlock <= 1;
                    state <= PRE_READ_ST;
                end else if (decode_inst[63:58] == Inlh) begin
                    interlock <= 1;
                    state <= PRE_READ_ST;
                end else if (decode_inst[63:58] == Inul) begin
                    interlock <= 1;
                    state <= PRE_READ_ST;
                end else if (decode_inst[63:58] == Inuh) begin
                    interlock <= 1;
                    state <= PRE_READ_ST;
                end else if (decode_inst[63:58] == Outll) begin
                    interlock <= 1;
                    state <= PRE_WRITE_ST;
                    uart_wdata <= uart_wdata_from_decode;
                end else if (decode_inst[63:58] == Join) begin
                    interlock <= 1;
                    join_target <= u_srca[3:0];
                    state <= JOINING_ST;
                end
            end else begin
                if (state == JOINING_ST) begin
                    if (subcore_ended[join_target] == 1) begin
                        living_sub_count <= living_sub_count - 1;
                        state <= RUN_ST;
                        interlock <= 0;
                    end
                end else if (state == PRE_READ_ST) begin
                    if (~io_rbusy) begin
                        io_ren <= 1;
                        state <= READ_ST;
                    end
                end else if (state == READ_ST) begin
                    io_ren <= 0;
                    if (io_rdone) begin
                        uart_rdata <= io_rdata;
                        state <= RUN_ST;
                        interlock <= 0;
                    end
                end else if (state == PRE_WRITE_ST) begin
                    if (~io_wbusy) begin
                        io_wen <= 1;
                        io_wdata <= uart_wdata;
                        state <= WRITE_ST;
                    end
                end else if (state == WRITE_ST) begin
                    io_wen <= 0;
                    if (io_wdone) begin
                        state <= RUN_ST;
                        interlock <= 0;
                    end
                end
            end
        end
    end

endmodule

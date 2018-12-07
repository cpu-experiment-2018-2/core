interface gpr_if;
    reg signed [31:0] gpr [0:31];
endinterface

module cpu (
    output wire [7:0]   led,

    input  wire         clk,
    input  wire         rstn);

    reg             interlock;

    gpr_if          gpr();
    assign led = gpr.gpr[0][7:0];

    wire [31:0]     pc;


    wire [63:0]     decode_inst;
    wire [63:0]     exec_inst;
    wire [63:0]     inst_from_exec;
    wire [63:0]     inst_from_mem;

    wire            memory_used;


    //================
    //     Fetch
    //================
    fetch fi(   .interlock(interlock),
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

    wire        [31:0]  addr;
    wire        [63:0]  dina;
    wire        [7:0]   wea;

    decode di(  .interlock(interlock),
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
                .addr(addr),
                .dina(dina),
                .wea(wea),
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

    exec ex(    .interlock(interlock),
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
    wire        [63:0]  n_doutb;
    
    memory mem( .interlock(interlock),
                .inst(inst_from_exec),
                .addra(addr),
                .dina(dina),
                .wea(wea),
                .addrb(addr),
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
                .n_doutb(n_doutb),
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

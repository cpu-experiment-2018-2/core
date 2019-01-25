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


module cpu (
    input  wire         rx,
    output wire         tx,
    output wire [7:0]   led,

    input  wire         clk,
    input  wire         rstn);

    (* mark_debug = "true" *) reg             interlock;

    gpr_if          gpr();
    assign led = gpr.gpr[0][7:0];

    (* mark_debug = "true" *) wire [31:0]     decode_pc;
    (* mark_debug = "true" *) wire [31:0]     exec_pc;
    (* mark_debug = "true" *) wire [31:0]     pc_from_exec;
    (* mark_debug = "true" *) wire [31:0]     pc_from_mem;


    (* mark_debug = "true" *) wire [63:0]     decode_inst;
    (* mark_debug = "true" *) wire [63:0]     exec_inst;
    (* mark_debug = "true" *) wire [63:0]     inst_from_exec;
    (* mark_debug = "true" *) wire [63:0]     inst_from_mem;


    //================
    //     Fetch
    //================
    wire                branch_flag;
    wire        [31:0]  branch_pc;

    fetch fi(   .interlock(interlock),
                .branch_flag(branch_flag),
                .branch_pc(branch_pc),
                .pc_to_the_next(decode_pc),
                .inst_to_the_next(decode_inst),
                .clk(clk),
                .rstn(rstn));

    //================
    //     Decode
    //================
    (* mark_debug = "true" *) wire signed [31:0]  u_srca;
    (* mark_debug = "true" *) wire signed [31:0]  u_srcb;
    (* mark_debug = "true" *) wire signed [31:0]  u_srcs_to_exec;
    (* mark_debug = "true" *) wire        [3:0]   u_e_type;
    (* mark_debug = "true" *) wire        [4:0]   u_rt_from_decode;
    (* mark_debug = "true" *) wire                u_rt_flag_from_decode;

    (* mark_debug = "true" *) wire signed [31:0]  l_srca;
    (* mark_debug = "true" *) wire signed [31:0]  l_srcb;
    (* mark_debug = "true" *) wire signed [31:0]  l_srcs_to_exec;
    (* mark_debug = "true" *) wire        [3:0]   l_e_type;
    (* mark_debug = "true" *) wire        [4:0]   l_rt_from_decode;
    (* mark_debug = "true" *) wire                l_rt_flag_from_decode;

    (* mark_debug = "true" *) wire        [31:0]  addr;
    (* mark_debug = "true" *) wire        [63:0]  dina;
    (* mark_debug = "true" *) wire        [7:0]   wea;

    (* mark_debug = "true" *) wire        [7:0]   uart_wdata_from_decode;

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
                .addr(addr),
                .dina(dina),
                .wea(wea),
                .uart_wdata(uart_wdata_from_decode),
                .clk(clk),
                .rstn(rstn));

    //================
    //     Exec
    //================
    (* mark_debug = "true" *) wire signed [31:0]  u_tdata_from_exec;
    (* mark_debug = "true" *) wire        [4:0]   u_rt_from_exec;
    (* mark_debug = "true" *) wire                u_rt_flag_from_exec;

    (* mark_debug = "true" *) wire signed [31:0]  l_tdata_from_exec;
    (* mark_debug = "true" *) wire        [4:0]   l_rt_from_exec;
    (* mark_debug = "true" *) wire                l_rt_flag_from_exec;

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

    (* mark_debug = "true" *) wire [7:0]  uart_rdata;

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
                .uart_rdata(uart_rdata),
                .clk(clk),
                .rstn(rstn));

    //================
    //    Memory
    //================
    (* mark_debug = "true" *) wire        [4:0]   u_rt_from_mem;
    (* mark_debug = "true" *) wire        [4:0]   l_rt_from_mem;
    (* mark_debug = "true" *) wire        [63:0]  mem_doutb;
    
    memory mem( .interlock(interlock),
                .pc(pc_from_exec),
                .inst(inst_from_exec),
                .addr(addr),
                .dina(dina),
                .wea(wea),
                .u_rt(u_rt_from_exec),
                .l_rt(l_rt_from_exec),
                .pc_to_the_next(pc_from_mem),
                .inst_to_the_next(inst_from_mem),
                .u_rt_to_the_next(u_rt_from_mem),
                .l_rt_to_the_next(l_rt_from_mem),
                .mem_doutb(mem_doutb),
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
    (* mark_debug = "true" *) wire signed [31:0] ex_to_wb_u_tdata;
    (* mark_debug = "true" *) wire        [4:0]  ex_to_wb_u_rt;
    (* mark_debug = "true" *) wire               ex_to_wb_u_rt_flag;

    (* mark_debug = "true" *) wire signed [31:0] ex_to_wb_l_tdata;
    (* mark_debug = "true" *) wire        [4:0]  ex_to_wb_l_rt;
    (* mark_debug = "true" *) wire               ex_to_wb_l_rt_flag;

    assign ex_to_wb_u_tdata       = u_tdata_from_exec;
    assign ex_to_wb_u_rt          = u_rt_from_exec;
    assign ex_to_wb_u_rt_flag     = u_rt_flag_from_exec;
    assign ex_to_wb_l_tdata       = l_tdata_from_exec;
    assign ex_to_wb_l_rt          = l_rt_from_exec;
    assign ex_to_wb_l_rt_flag     = l_rt_flag_from_exec;
    
    writeback wb(.*);


	// AXI4-lite uart interface
	// address read channel
	wire [3:0]  uart_axi_araddr;
	wire        uart_axi_arready;
	wire        uart_axi_arvalid;
	// address write channel
	wire [3:0]  uart_axi_awaddr;
	wire        uart_axi_awready;
	wire        uart_axi_awvalid;
	// response channel
	wire        uart_axi_bready;
	wire [1:0]  uart_axi_bresp;
	wire        uart_axi_bvalid;
	// read data channel
	wire [31:0] uart_axi_rdata;
	wire        uart_axi_rready;
	wire [1:0]  uart_axi_rresp;
	wire        uart_axi_rvalid;
	// data write channel
	wire [31:0] uart_axi_wdata;
	wire        uart_axi_wready;
	wire [3:0]  uart_axi_wstrb;
	wire        uart_axi_wvalid;

    axi_uartlite_0 uart(    .s_axi_aclk(clk),
                            .s_axi_aresetn(rstn),
                            .s_axi_awaddr(uart_axi_awaddr),
                            .s_axi_awvalid(uart_axi_awvalid),
                            .s_axi_awready(uart_axi_awready),
                            .s_axi_wdata(uart_axi_wdata),
                            .s_axi_wstrb(uart_axi_wstrb),
                            .s_axi_wvalid(uart_axi_wvalid),
                            .s_axi_wready(uart_axi_wready),
                            .s_axi_bresp(uart_axi_bresp),
                            .s_axi_bvalid(uart_axi_bvalid),
                            .s_axi_bready(uart_axi_bready),
                            .s_axi_araddr(uart_axi_araddr),
                            .s_axi_arvalid(uart_axi_arvalid),
                            .s_axi_arready(uart_axi_arready),
                            .s_axi_rdata(uart_axi_rdata),
                            .s_axi_rresp(uart_axi_rresp),
                            .s_axi_rvalid(uart_axi_rvalid),
                            .s_axi_rready(uart_axi_rready),
                            .rx(rx),
                            .tx(tx));

	typedef enum logic [3:0] {
		RX_FIFO = 4'h0,
		STAT_REG = 4'h8
	} raddr_type;

	typedef enum logic [3:0] {
		TX_FIFO = 4'h4,
		CTRL_REG = 4'hC
	} waddr_type;

    raddr_type  uart_raddr;
    (* mark_debug = "true" *) reg         uart_ren;
    wire        uart_rbusy;
    wire        uart_rdone;

    (* mark_debug = "true" *) reg  [7:0]  uart_wdata;
    waddr_type  uart_waddr;
    (* mark_debug = "true" *) reg         uart_wen;
    wire        uart_wbusy;
    wire        uart_wdone;

    uart_rx u_rx( .*,
                .addr(uart_raddr),
                .en(uart_ren),
                .clk(clk),
                .rstn(rstn),
                .data(uart_rdata),
                .busy(uart_rbusy),
                .done(uart_rdone));

    uart_tx u_tx( .*,
                .data(uart_wdata),
                .addr(uart_waddr),
                .en(uart_wen),
                .clk(clk),
                .rstn(rstn),
                .busy(uart_wbusy),
                .done(uart_wdone));

    typedef enum logic [2:0] {
        RUN_ST, CHECK_RX_ST, READ_ST, CHECK_TX_ST, WRITE_ST
    } state_type;

    state_type state;

    always@(posedge clk) begin
        if (~rstn) begin
            interlock <= 0;
            state <= RUN_ST;
        end else begin
            if (interlock == 0) begin
                if (decode_inst[63:58] == Inll) begin
                    interlock <= 1;
                    uart_raddr <= STAT_REG;
                    uart_ren <= 1;
                    state <= CHECK_RX_ST;
                end else if (decode_inst[63:58] == Inlh) begin
                    interlock <= 1;
                    uart_raddr <= STAT_REG;
                    uart_ren <= 1;
                    state <= CHECK_RX_ST;
                end else if (decode_inst[63:58] == Inul) begin
                    interlock <= 1;
                    uart_raddr <= STAT_REG;
                    uart_ren <= 1;
                    state <= CHECK_RX_ST;
                end else if (decode_inst[63:58] == Inuh) begin
                    interlock <= 1;
                    uart_raddr <= STAT_REG;
                    uart_ren <= 1;
                    state <= CHECK_RX_ST;
                end else if (decode_inst[63:58] == Outll) begin
                    interlock <= 1;
                    uart_wdata <= uart_wdata_from_decode;
                    uart_raddr <= STAT_REG;
                    uart_ren <= 1;
                    state <= CHECK_TX_ST;
                end
            end else begin
                if (state == CHECK_RX_ST) begin
                    if (uart_rdone) begin
                        uart_ren <= 1;
                        // Rx FIFO Valid Data flag
                        if (uart_rdata[0]) begin
                            uart_raddr <= RX_FIFO;
                            state <= READ_ST;
                        end
                    end else uart_ren <= 0;
                end else if (state == READ_ST) begin
                    if (uart_rdone) begin
                        state <= RUN_ST;
                        interlock <= 0;
                    end else uart_ren <= 0;
                end else if (state == CHECK_TX_ST) begin
                    if (uart_rdone) begin
                        // Tx FIFO Full flag
                        if (uart_rdata[3] == 0) begin
                            uart_wen <= 1;
                            uart_waddr <= TX_FIFO;
                            state <= WRITE_ST;
                        end else uart_ren <= 1;
                    end else uart_ren <= 0;
                end else if (state == WRITE_ST) begin
                    uart_wen <= 0;
                    if (uart_wdone) begin
                        state <= RUN_ST;
                        interlock <= 0;
                    end
                end
            end
        end
    end

endmodule

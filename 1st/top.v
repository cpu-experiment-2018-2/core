module top (
	// AXI4-lite uart interface
	// address read channel
	output wire [3:0]		uart_axi_araddr,
	input wire			uart_axi_arready,
	output wire			uart_axi_arvalid,
	// address write channel
	output wire [3:0]		uart_axi_awaddr,
	input wire			uart_axi_awready,
	output wire			uart_axi_awvalid,
	// response channel
	output wire			uart_axi_bready,
	input wire [1:0]		uart_axi_bresp,
	input wire			uart_axi_bvalid,
	// read data channel
	input wire [31:0]		uart_axi_rdata,
	output wire			uart_axi_rready,
	input wire [1:0]		uart_axi_rresp,
	input wire			uart_axi_rvalid,
	// data write channel
	output wire [31:0]		uart_axi_wdata,
	input wire			uart_axi_wready,
	output wire [3:0]		uart_axi_wstrb,
	output wire			uart_axi_wvalid,

	// instructoin BRAM
	// Port A
	output wire [31:0]		inst_addra,
	output wire			inst_clka,
	output wire [31:0]		inst_dina,
	output wire [3:0]		inst_wea,

	// Port B
	output wire [31:0]		inst_addrb,
	output wire			inst_clkb,
	input wire [31:0]		inst_doutb,
	output wire			inst_enb,
	output wire			inst_rstb,

	// data BRAM
	// Port A:WRITE
	output wire [31:0]		data_addra,	// WRADDR
	output wire			data_clka,
	output wire [31:0]		data_dina,	// data to be written
	output wire			data_ena,	// ENA
	output wire [3:0]		data_wea,	// WEN

	// Port B:READ
	output wire [31:0]		data_addrb,	// RDADDR
	output wire			data_clkb,
	input wire [31:0]		data_doutb,	// data from READ operation
	output wire			data_enb,	// REN
	output wire			data_rstb,

	// fadd
	output wire [31:0]		fadd_axis_a_tdata,
	input wire			fadd_axis_a_tready,
	output wire			fadd_axis_a_tvalid,

	output wire [31:0]		fadd_axis_b_tdata,
	input wire			fadd_axis_b_tready,
	output wire			fadd_axis_b_tvalid,

	input wire [31:0]		fadd_axis_result_tdata,
	output wire			fadd_axis_result_tready,
	input wire			fadd_axis_result_tvalid,

	// fsub
	output wire [31:0]		fsub_axis_a_tdata,
	input wire			fsub_axis_a_tready,
	output wire			fsub_axis_a_tvalid,

	output wire [31:0]		fsub_axis_b_tdata,
	input wire			fsub_axis_b_tready,
	output wire			fsub_axis_b_tvalid,

	input wire [31:0]		fsub_axis_result_tdata,
	output wire			fsub_axis_result_tready,
	input wire			fsub_axis_result_tvalid,

	// fmul
	output wire [31:0]		fmul_axis_a_tdata,
	input wire			fmul_axis_a_tready,
	output wire			fmul_axis_a_tvalid,

	output wire [31:0]		fmul_axis_b_tdata,
	input wire			fmul_axis_b_tready,
	output wire			fmul_axis_b_tvalid,

	input wire [31:0]		fmul_axis_result_tdata,
	output wire			fmul_axis_result_tready,
	input wire			fmul_axis_result_tvalid,

	// fdiv
	output wire [31:0]		fdiv_axis_a_tdata,
	input wire			fdiv_axis_a_tready,
	output wire			fdiv_axis_a_tvalid,

	output wire [31:0]		fdiv_axis_b_tdata,
	input wire			fdiv_axis_b_tready,
	output wire			fdiv_axis_b_tvalid,

	input wire [31:0]		fdiv_axis_result_tdata,
	output wire			fdiv_axis_result_tready,
	input wire			fdiv_axis_result_tvalid,
	
	output wire [7:0]		led,
	input wire [4:0]		btn,
	input wire			clk,
	input wire			rstn);

	assign inst_clka = clk;
	assign inst_clkb = clk;
	assign inst_rstb = ~rstn;

	assign data_clka = clk;
	assign data_clkb = clk;
	assign data_rstb = ~rstn;

	cpu c(uart_axi_araddr, uart_axi_arready, uart_axi_arvalid,
	      uart_axi_awaddr, uart_axi_awready, uart_axi_awvalid,
	      uart_axi_bready, uart_axi_bresp, uart_axi_bvalid,
	      uart_axi_rdata, uart_axi_rready, uart_axi_rresp, uart_axi_rvalid,
	      uart_axi_wdata, uart_axi_wready, uart_axi_wstrb, uart_axi_wvalid,
	      inst_addra, inst_dina, inst_wea,
	      inst_addrb, inst_doutb, inst_enb,
	      data_addra, data_dina, data_ena, data_wea,
	      data_addrb, data_doutb, data_enb,
	      fadd_axis_a_tdata, fadd_axis_a_tready, fadd_axis_a_tvalid,
	      fadd_axis_b_tdata, fadd_axis_b_tready, fadd_axis_b_tvalid,
	      fadd_axis_result_tdata, fadd_axis_result_tready, fadd_axis_result_tvalid,
	      fsub_axis_a_tdata, fsub_axis_a_tready, fsub_axis_a_tvalid,
	      fsub_axis_b_tdata, fsub_axis_b_tready, fsub_axis_b_tvalid,
	      fsub_axis_result_tdata, fsub_axis_result_tready, fsub_axis_result_tvalid,
	      fmul_axis_a_tdata, fmul_axis_a_tready, fmul_axis_a_tvalid,
	      fmul_axis_b_tdata, fmul_axis_b_tready, fmul_axis_b_tvalid,
	      fmul_axis_result_tdata, fmul_axis_result_tready, fmul_axis_result_tvalid,
	      fdiv_axis_a_tdata, fdiv_axis_a_tready, fdiv_axis_a_tvalid,
	      fdiv_axis_b_tdata, fdiv_axis_b_tready, fdiv_axis_b_tvalid,
	      fdiv_axis_result_tdata, fdiv_axis_result_tready, fdiv_axis_result_tvalid,
	      led, btn, clk, rstn);

endmodule

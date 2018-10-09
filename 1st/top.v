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
	output wire [3:0]		data_wea,	// WEN

	// Port B:READ
	output wire [31:0]		data_addrb,	// RDADDR
	output wire			data_clkb,
	input wire [31:0]		data_doutb,	// data from READ operation
	output wire			data_enb,	// REN
	output wire			data_rstb,

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
	      data_addra, data_dina, data_wea,
	      data_addrb, data_doutb, data_enb,
	      led, btn, clk, rstn);

endmodule

module uart_tx(
	// AXI4-lite uart transmitter
	// address write channel
	output wire [3:0]	uart_axi_awaddr,
	input wire		uart_axi_awready,
	output reg		uart_axi_awvalid,
	// response channel
	output reg		uart_axi_bready,
	input wire [1:0]	uart_axi_bresp,
	input wire		uart_axi_bvalid,
	// data write channel
	output wire [31:0]	uart_axi_wdata,
	input wire		uart_axi_wready,
	output reg [3:0]	uart_axi_wstrb,
	output reg		uart_axi_wvalid,

	input wire [7:0]	data,
	input wire [3:0]	addr,
	input wire		en,
	input wire 		clk,
	input wire 		rstn,
	output reg		busy,
	output reg		done);

	assign uart_axi_wdata[7:0] = data;
	assign uart_axi_wdata[31:8] = 24'b0;

	assign uart_axi_wstrb = 4'b0001;

	assign uart_axi_awaddr = addr;

	typedef enum logic [1:0] {
		WAIT_ST, WRITE_ST, END_ST
	} state_type;

	state_type state;

	always@(posedge clk) begin
		if (~rstn) begin
			uart_axi_bready <= 0;
			uart_axi_wvalid <= 0;
			uart_axi_awvalid <= 0;
			busy <= 0;
			done <= 0;
			state <= WAIT_ST;
		end else begin
			if (state == WAIT_ST) begin
				uart_axi_bready <= 0;
				done <= 0;
				if (en) begin
					uart_axi_wvalid <= 1;
					uart_axi_awvalid <= 1;
					busy <= 1;
					state <= WRITE_ST;
				end
			end else if (state == WRITE_ST) begin
				if (uart_axi_wready) uart_axi_wvalid <= 0;
				if (uart_axi_awready) uart_axi_awvalid <= 0;
				if (uart_axi_wvalid == 0 && uart_axi_awvalid == 0) state <= END_ST;
			end else if (state == END_ST) begin
				if (uart_axi_bvalid) begin
					uart_axi_bready <= 1;
					busy <= 0;
					done <= 1;
					state <= WAIT_ST;
				end
			end
		end
	end

endmodule

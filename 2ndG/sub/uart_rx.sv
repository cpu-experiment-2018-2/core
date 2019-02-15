module uart_rx(
	// AXI4-lite uart receiver
	// address read channel
	output wire [3:0]	uart_axi_araddr,
	input wire		uart_axi_arready,
	output reg		uart_axi_arvalid,
	// read data channel
	input wire [31:0]	uart_axi_rdata,
	output reg		uart_axi_rready,
	input wire [1:0]	uart_axi_rresp,
	input wire		uart_axi_rvalid,
	
	input wire [3:0]	addr,
	input wire		en,
	input wire		clk,
	input wire		rstn,
	output reg [7:0]	data,
	output reg		busy,
	output reg		done);

	assign data = uart_axi_rdata[7:0];

	assign uart_axi_araddr = addr;

	typedef enum logic [1:0] {
		WAIT_ST, ADDR_ST, READ_ST
	} state_type;

	state_type state;

	always@(posedge clk) begin
		if (~rstn) begin
			uart_axi_arvalid <= 0;
			uart_axi_rready <= 0;
			busy <= 0;
			done <= 0;
			state <= WAIT_ST;
		end else begin
			if (state == WAIT_ST) begin
				uart_axi_rready <= 0;
				done <= 0;
				if (en) begin
					uart_axi_arvalid <= 1;
					busy <= 1;
					state <= ADDR_ST;
				end
			end else if (state == ADDR_ST) begin
				if (uart_axi_arready) begin
					uart_axi_arvalid <= 0;
					state <= READ_ST;
				end
			end else if (state == READ_ST) begin
				if (uart_axi_rvalid) begin
					uart_axi_rready <= 1;
					busy <= 0;
					done <= 1;
					state <= WAIT_ST;
				end
			end
		end
	end

endmodule

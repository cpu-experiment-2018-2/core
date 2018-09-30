module cpu (
	// AXI4-lite uart interface
	// address read channel
	output wire [3:0]                uart_axi_araddr,
	input wire                       uart_axi_arready,
	output wire                      uart_axi_arvalid,
	// address write channel
	output wire [3:0]                uart_axi_awaddr,
	input wire                       uart_axi_awready,
	output wire                      uart_axi_awvalid,
	// response channel
	output wire                      uart_axi_bready,
	input wire [1:0]                 uart_axi_bresp,
	input wire                       uart_axi_bvalid,
	// read data channel
	input wire [31:0]                uart_axi_rdata,
	output wire                      uart_axi_rready,
	input wire [1:0]                 uart_axi_rresp,
	input wire                       uart_axi_rvalid,
	// data write channel
	output wire [31:0]               uart_axi_wdata,
	input wire                       uart_axi_wready,
	output wire [3:0]                uart_axi_wstrb,
	output wire                      uart_axi_wvalid,
	
	output reg [7:0]                led,
	input wire [4:0]                 btn,
	input wire                       clk,
	input wire                       rstn);
	
	typedef enum logic [3:0] {
		RX_FIFO = 4'h0,
		STAT_REG = 4'h8
	} raddr_type;

	typedef enum logic [3:0] {
		TX_FIFO = 4'h4,
		CTRL_REG = 4'hC
	} waddr_type;

	raddr_type	uart_raddr;
	reg 		uart_ren;
	wire [7:0]	uart_rdata;
	wire		uart_rdone;
	
	reg [7:0]	uart_wdata;
	waddr_type	uart_waddr;
	reg		uart_wen;
	wire		uart_wdone;

	reg [7:0]	data;
	
	uart_rx rx(.*, .addr(uart_raddr), .en(uart_ren), .clk(clk), .rstn(rstn), .data(uart_rdata), .done(uart_rdone));
	uart_tx tx(.*, .data(uart_wdata), .addr(uart_waddr), .en(uart_wen), .clk(clk), .rstn(rstn), .done(uart_wdone)); 

	typedef enum logic [2:0] {
		WAIT_ST, CHECK_RX_ST, READ_ST, CHECK_TX_ST, WRITE_ST
	} state_type;

	state_type state;
	
	always@(posedge clk) begin
		if (~rstn) begin     
			uart_raddr <= STAT_REG;
			uart_ren <= 0;
			
			uart_wdata <= 8'b0;
			uart_waddr <= TX_FIFO;
			uart_wen <= 0;

			state <= WAIT_ST;
		end else begin
			if (state == WAIT_ST) begin
				led[7:2] <= 6'b010000;
				if (btn[0]) begin
					uart_raddr <= STAT_REG;
					uart_ren <= 1;
					state <= CHECK_RX_ST;
				end
			end else if (state == CHECK_RX_ST) begin
				led[7:2] <= 6'b001000;
				if (uart_rdone) begin
					uart_ren <= 1;
					// Rx FIFO Valid Data flag
					if (uart_rdata[0]) begin
						uart_raddr <= RX_FIFO;
						state <= READ_ST;
					end
				end else uart_ren <= 0;
			end else if (state == READ_ST) begin
				led[7:2] <= 6'b101000;
				if (uart_rdone) begin
					data <= uart_rdata;
					led[1:0] <= uart_axi_rresp;

					uart_raddr <= STAT_REG;
					uart_ren <= 1;
					state <= CHECK_TX_ST;
				end else uart_ren <= 0;
			end else if (state == CHECK_TX_ST) begin
				led[7:2] <= 6'b111000;
				uart_ren <= 0;
				if (uart_rdone) begin
					// Tx FIFO Full flag
					if (uart_rdata[3] == 0) begin
						uart_waddr <= TX_FIFO;
						uart_wdata <= data;
						uart_wen <= 1;
						state <= WRITE_ST;
					end
				end
			end else if (state == WRITE_ST) begin
				uart_wen <= 0;
				if (uart_wdone) begin
					uart_raddr <= STAT_REG;
					uart_ren <= 1;
					state <= CHECK_RX_ST;
				end
			end
		end
	end

endmodule

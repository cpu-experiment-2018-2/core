module loopback(
	// AXI4-lite master memory interface
	// address read channel
	output reg [3:0]                 axi_araddr,
	input wire                       axi_arready,
	output wire                      axi_arvalid,
	// address write channel
	output wire [3:0]                axi_awaddr,
	input wire                       axi_awready,
	output wire                      axi_awvalid,
	// response channel
	output wire                      axi_bready,
	input wire [1:0]                 axi_bresp,
	input wire                       axi_bvalid,
	// read data channel
	input wire [31:0]                axi_rdata,
	output reg                       axi_rready,
	input wire [1:0]                 axi_rresp,
	input wire                       axi_rvalid,
	// data write channel
	output reg [31:0]                axi_wdata,
	input wire                       axi_wready,
	output reg [3:0]                 axi_wstrb,
	output wire                      axi_wvalid,

	output reg [7:0]                 led,
	input reg [4:0]                  btn,
	input wire                       clk,
	input wire                       rstn);


	typedef enum logic [3:0] {
		RX_FIFO = 4'h0,
		TX_FIFO = 4'h4,
		STAT_REG = 4'h8,
		CTRL_REG = 4'hC
	} addr_type;


	reg [7:0]	data;
	assign axi_wdata[7:0] = data;
	assign axi_wdata[31:8] = 24'b0;

	assign axi_wstrb = 4'b0001;

	reg bready;
	assign axi_bready = bready;

	reg arvalid;
	assign axi_arvalid = arvalid;

	reg awvalid;
	assign axi_awvalid = awvalid;

	reg [3:0] awaddr;
	assign axi_awaddr = awaddr;

	reg wvalid;
	assign axi_wvalid = wvalid;

	typedef enum logic [3:0] {
		WAIT_ST, CHECK_RX_ST, READ_ST, CHECK_TX_ST, WRITE_ST, END_ST
	} state_type;

	state_type state;

	reg clearing;
	reg chrxaddr_set;
	reg araddr_set;
	reg chtxaddr_set;

	always@(posedge clk) begin
		if (~rstn) begin
			led <= 8'b10000000;
			axi_araddr <= 32'b0;
			arvalid <= 0;
			bready <= 0;
			axi_rready <= 0;
			chrxaddr_set <= 0;
			araddr_set <= 0;
			chtxaddr_set <= 0;
			state <= WAIT_ST;

			data <= 8'b11;
			awvalid <= 1;
			wvalid <= 1;
			awaddr <= CTRL_REG;
			clearing <= 1;
		end else if (clearing) begin
			if (axi_wready) wvalid <= 0;
			if (axi_awready) awvalid <= 0;
			if (axi_bvalid) begin
				bready <= 1;
				clearing <= 0;
			end
		end else begin
			if (state == WAIT_ST) begin
				bready <= 0;
				led[7:2] <= 6'b010000;
				if (btn[0]) state <= CHECK_RX_ST;
			end else if (state == CHECK_RX_ST) begin
				bready <= 0;

				if (chrxaddr_set == 0) begin
					led[7:2] <= 6'b110000;
					axi_rready <= 0;
					if (axi_arvalid) begin
						if (axi_arready) begin
							arvalid <= 0;
							chrxaddr_set <= 1;
						end
					end else begin
						axi_araddr <= STAT_REG;
						arvalid <= 1;
					end
				end else begin
					led[7:2] <= 6'b001000;
					if (axi_rvalid) begin
						axi_rready <= 1;

						led <= axi_rdata[7:0];
						// Rx FIFO Valid Data flag
						if (axi_rdata[0]) state <= READ_ST;
						else chrxaddr_set <= 0;
					end
				end
			end else if (state == READ_ST) begin
				if (araddr_set == 0) begin
					led[7:2] <= 6'b101000;
					axi_rready <= 0;
					if (axi_arvalid) begin
						if (axi_arready) begin
							arvalid <= 0;
							araddr_set <= 1;
						end
					end else begin
						axi_araddr <= RX_FIFO;
						arvalid <= 1;
					end
				end else begin
					led[7:2] <= 6'b011000;
					if (axi_rvalid) begin
						data <= axi_rdata[7:0];
						axi_rready <= 1;
						led[1:0] <= axi_rresp;

						state <= CHECK_TX_ST;
					end
				end
			end else if (state == CHECK_TX_ST) begin
				if (chtxaddr_set == 0) begin
					led[7:2] <= 6'b111000;
					axi_rready <= 0;
					if (axi_arvalid) begin
						if (axi_arready) begin
							arvalid <= 0;
							chtxaddr_set <= 1;
						end
					end else begin
						axi_araddr <= STAT_REG;
						arvalid <= 1;
					end
				end else begin
					led[7:2] <= 6'b000100;
					if (axi_rvalid) begin
						axi_rready <= 1;

						// Tx FIFO Full flag
						if (axi_rdata[3] == 0) begin
							state <= WRITE_ST;
							wvalid <= 1;
							awvalid <= 1;
							awaddr <= TX_FIFO;
						end else chtxaddr_set <= 0;
					end
				end

			end else if (state == WRITE_ST) begin
				axi_rready <= 0;
				led[7:2] <= 6'b100100;
				if (axi_wready) wvalid <= 0;
				if (axi_awready) awvalid <= 0;
				if (awvalid == 0 && wvalid == 0) state <= END_ST;
			end else if (state == END_ST) begin
				led[7:2] <= 6'b010100;
				if (axi_bvalid) begin
					bready <= 1;
					chrxaddr_set <= 0;
					araddr_set <= 0;
					chtxaddr_set <= 0;
					state <= CHECK_RX_ST;
				end
			end
		end
	end

endmodule

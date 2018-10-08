module cpu (
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

	// instruction BRAM
	// Port A:WRITE
	(* mark_debug = "true" *) output wire [31:0]		inst_addra,	// WRADDR
	(* mark_debug = "true" *) output wire [31:0]		inst_dina,	// data to be written
	(* mark_debug = "true" *) output wire [3:0]		inst_wea,	// WEN

	// Port B:READ
	(* mark_debug = "true" *) output reg [31:0]		inst_addrb,	// RDADDR
	(* mark_debug = "true" *) input wire [31:0]		inst_doutb,	// data from READ operation
	(* mark_debug = "true" *) output reg			inst_enb,	// REN
	
	output reg [7:0]		led,
	input wire [4:0]		btn,
	input wire			clk,
	input wire			rstn);
	
	typedef enum logic [3:0] {
		RX_FIFO = 4'h0,
		STAT_REG = 4'h8
	} raddr_type;

	typedef enum logic [3:0] {
		TX_FIFO = 4'h4,
		CTRL_REG = 4'hC
	} waddr_type;

	(* mark_debug = "true" *) raddr_type	uart_raddr;
	(* mark_debug = "true" *) reg 		uart_ren;
	(* mark_debug = "true" *) wire [7:0]	uart_rdata;
	(* mark_debug = "true" *) wire		uart_rbusy;
	(* mark_debug = "true" *) wire		uart_rdone;
	
	(* mark_debug = "true" *) reg [7:0]	uart_wdata;
	(* mark_debug = "true" *) waddr_type	uart_waddr;
	(* mark_debug = "true" *) reg		uart_wen;
	(* mark_debug = "true" *) wire		uart_wbusy;
	(* mark_debug = "true" *) wire		uart_wdone;
	
	uart_rx rx(.*, .addr(uart_raddr), .en(uart_ren), .clk(clk), .rstn(rstn), .data(uart_rdata), .busy(uart_rbusy), .done(uart_rdone));
	uart_tx tx(.*, .data(uart_wdata), .addr(uart_waddr), .en(uart_wen), .clk(clk), .rstn(rstn), .busy(uart_wbusy), .done(uart_wdone)); 


	(* mark_debug = "true" *) reg [7:0]	data;
	(* mark_debug = "true" *) reg		bl_en;

	bootloader bl(.*, .data(data), .en(bl_en), .clk(clk), .rstn(rstn));

	(* mark_debug = "true" *) reg [29:0]	pc;
	assign		inst_addrb[1:0] = 2'b0;
	assign		inst_addrb[31:2] = pc;

	typedef enum logic [2:0] {
		WAIT_ST, LOAD_ST, RUN_ST, OUT_ST
	} state_type;

	(* mark_debug = "true" *) state_type state;

	typedef enum logic {
		CHECK_RX_ST, READ_ST
	} load_state_type;

	load_state_type load_state;


	(* mark_debug = "true" *) reg		cnt2;
	(* mark_debug = "true" *) reg [1:0]	cnt4;
	(* mark_debug = "true" *) reg [1:0]	fetch_wait;
	(* mark_debug = "true" *) wire [31:0]	inst;
	(* mark_debug = "true" *) reg [4:0]	rt;
	(* mark_debug = "true" *) reg signed [31:0]	srca;
	(* mark_debug = "true" *) reg signed [31:0]	srcb;
	(* mark_debug = "true" *) reg [15:0]	si;
	(* mark_debug = "true" *) reg [25:0]	li;

	assign		inst = inst_doutb;
	typedef enum logic [1:0] {
		FETCH_ST, DECODE_ST, EXEC_ST
	} cpu_state_type;

	(* mark_debug = "true" *) cpu_state_type cpu_state;
	(* mark_debug = "true" *) reg signed [31:0]	gpr [0:31];
	(* mark_debug = "true" *) reg	eq;
	(* mark_debug = "true" *) reg	le;

	(* mark_debug = "true" *) reg [31:0]	out_data;
	typedef enum logic {
		CHECK_TX_ST, WRITE_ST
	} out_state_type;
	out_state_type out_state;

	always@(posedge clk) begin
		if (~rstn) begin     
			uart_raddr <= STAT_REG;
			uart_ren <= 0;
			
			uart_wdata <= 8'b0;
			uart_waddr <= TX_FIFO;
			uart_wen <= 0;

			data <= 8'b0;
			inst_enb <= 0;
			bl_en <= 0;

			pc <= 30'b0;
			cnt2 <= 0;
			cnt4 <= 0;
			fetch_wait <= 0;

			state <= WAIT_ST;
			load_state <= CHECK_RX_ST;
			cpu_state <= FETCH_ST;
			out_state <= CHECK_TX_ST;
		end else begin
			if (state == WAIT_ST) begin
				led[7:2] <= 6'b100000;
				if (btn[0]) begin
					uart_raddr <= STAT_REG;
					uart_ren <= 1;

					state <= LOAD_ST;
					load_state <= CHECK_RX_ST;
				end
			end else if (state == LOAD_ST) begin
				led[7:2] <= 6'b010000;
				if (btn[1]) begin
					bl_en <= 0;

					if (uart_ren) uart_ren <= 0;
					state <= RUN_ST;
				end else
				if (load_state == CHECK_RX_ST) begin
					bl_en <= 0;
					if (uart_rdone) begin
						uart_ren <= 1;
						// Rx FIFO Valid Data flag
						if (uart_rdata[0]) begin
							uart_raddr <= RX_FIFO;
							load_state <= READ_ST;
						end
					end else uart_ren <= 0;
				end else if (load_state == READ_ST) begin
					if (uart_rdone) begin
						data <= uart_rdata;
						bl_en <= 1;
						
						uart_raddr <= STAT_REG;
						uart_ren <= 1;
						load_state <= CHECK_RX_ST;
					end else uart_ren <= 0;
				end
			end else if (state == RUN_ST) begin
				led[7:2] <= 6'b001000;
				if (cpu_state == FETCH_ST) begin
					fetch_wait <= fetch_wait + 1;
					if (fetch_wait == 0) begin
						inst_enb <= 1;
					end else if (fetch_wait == 2'b11) begin
						fetch_wait <= 0;
						inst_enb <= 0;
						cpu_state <= DECODE_ST;
					end
				end else if (cpu_state == DECODE_ST) begin
					cpu_state <= EXEC_ST;

					case (inst[31:29])
						3'b000:		rt <= inst[25:21];
						3'b001:		rt <= inst[25:21];
						3'b010:		rt <= inst[25:21];
						3'b011:		rt <= inst[25:21];
						3'b110:		rt <= inst[25:21];
						default:	rt <= 5'b0;
					endcase

					case (inst[31:29])
						3'b000:		srca <= gpr[inst[20:16]];
						3'b001:		srca <= gpr[inst[20:16]];
						3'b010:		srca <= gpr[inst[20:16]];
						3'b101:		srca <= gpr[inst[25:21]];
						default:	srca <= 31'b0;
					endcase

					case (inst[31:29])
						3'b001:		srcb <= gpr[inst[15:11]];
						3'b010:		srcb <= gpr[inst[15:11]];
						3'b101:		srcb <= gpr[inst[20:16]];
						default:	srcb <= 32'b0;
					endcase

					if (inst[31:29] == 3'b000) si <= inst[15:0];
					else si <= 16'b0;

					case (inst[31:29])
						3'b100:		li <= inst[25:0];
						3'b101:		li <= inst[25:0];
						default:	li <= 26'b0;
					endcase
				end else if (cpu_state == EXEC_ST) begin
					if (inst[31:29] == 3'b000) begin
						case (inst[28:26])
							3'b000:		gpr[rt] <= srca + $signed({16'b0, si}); // Addi
							3'b001:		gpr[rt] <= srca - $signed({16'b0, si}); // Subi
							3'b010:		gpr[rt] <= srca * $signed({16'b0, si}); // Muli
							default:	gpr[rt] <= srca / $signed({16'b0, si}); // Divi
						endcase
						cpu_state <= FETCH_ST;
						pc <= pc + 1;
					end else if (inst[31:29] == 3'b001) begin
						case (inst[28:26])
							3'b000:		gpr[rt] <= srca + srcb; // Add
							3'b001:		gpr[rt] <= srca - srcb; // Sub
							3'b010:		gpr[rt] <= srca * srcb; // Mul
							default:	gpr[rt] <= srca / srcb; // Div
						endcase
						cpu_state <= FETCH_ST;
						pc <= pc + 1;
					end else if (inst[31:29] == 3'b011) begin
						// Li
						if (inst[28:26] == 3'b010) begin
							gpr[rt] <= {9'b0, inst[20:0]};
							cpu_state <= FETCH_ST;
							pc <= pc + 1;
						end
					end else if (inst[31:29] == 3'b101) begin
						// Beq
						if (inst[28:26] == 3'b000) pc <= eq ? li : (pc + 1);
						else if (inst[28:26] == 3'b001) pc <= le ? li : (pc + 1); // Ble
						else if (inst[28:26] == 3'b010) begin // Cmpd
							eq <= (srca == srcb);
							le <= (srca <= srcb);
							pc <= pc + 1;
						end
						cpu_state <= FETCH_ST;
					end else if (inst[31:29] == 3'b110) begin
						// Out
						if (inst[28:26] == 3'b001) begin
							out_data <= gpr[rt];

							cpu_state <= FETCH_ST;
							pc <= pc + 1;

							uart_raddr <= STAT_REG;
							uart_ren <= 1;
							out_state <= CHECK_TX_ST;
							if (uart_rbusy == 0) state <= OUT_ST;
						end
					end
				end
			end else if (state == OUT_ST) begin
				if (out_state == CHECK_TX_ST) begin
					if (uart_rdone) begin
						// Tx FIFO Full flag
						if (uart_rdata[3] == 0) begin
							if (cnt4 == 2'b00) uart_wdata <= out_data[7:0];
							else if (cnt4 == 2'b01) uart_wdata <= out_data[15:8];
							else if (cnt4 == 2'b10) uart_wdata <= out_data[23:16];
							else if (cnt4 == 2'b11) uart_wdata <= out_data[31:24];
							uart_wen <= 1;
							out_state <= WRITE_ST;
						end else uart_ren <= 1;
					end else uart_ren <= 0;
				end else if (out_state == WRITE_ST) begin
					uart_wen <= 0;

					if (uart_wdone) begin
						cnt4 <= cnt4 + 1;
						if (cnt4 == 2'b11) begin
							state <= RUN_ST;
						end else begin
							uart_ren <= 1;
							out_state <= CHECK_TX_ST;
						end
					end
				end
			end
		end
	end

endmodule

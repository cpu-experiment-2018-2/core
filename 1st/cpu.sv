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
	output wire [31:0]		inst_addra,	// WRADDR
	output wire [31:0]		inst_dina,	// data to be written
	output wire [3:0]		inst_wea,	// WEN

	// Port B:READ
	output reg [31:0]		inst_addrb,	// RDADDR
	input wire [31:0]		inst_doutb,	// data from READ operation
	output reg			inst_enb,	// REN
	
	// data BRAM
	// Port A:WRITE
	(* mark_debug = "true" *) output wire [31:0]		data_addra,	// WRADDR
	(* mark_debug = "true" *) output reg [31:0]		data_dina,	// data to be written
	(* mark_debug = "true" *) output reg			data_ena,	// ENA
	(* mark_debug = "true" *) output reg [3:0]		data_wea,	// WEN

	// Port B:READ
	(* mark_debug = "true" *) output wire [31:0]		data_addrb,	// RDADDR
	(* mark_debug = "true" *) input wire [31:0]		data_doutb,	// data from READ operation
	(* mark_debug = "true" *) output reg			data_enb,	// REN

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

	raddr_type	uart_raddr;
	reg 		uart_ren;
	wire [7:0]	uart_rdata;
	wire		uart_rbusy;
	wire		uart_rdone;
	
	reg [7:0]	uart_wdata;
	waddr_type	uart_waddr;
	reg		uart_wen;
	wire		uart_wbusy;
	wire		uart_wdone;
	
	uart_rx rx(.*, .addr(uart_raddr), .en(uart_ren), .clk(clk), .rstn(rstn), .data(uart_rdata), .busy(uart_rbusy), .done(uart_rdone));
	uart_tx tx(.*, .data(uart_wdata), .addr(uart_waddr), .en(uart_wen), .clk(clk), .rstn(rstn), .busy(uart_wbusy), .done(uart_wdone)); 


	reg [7:0]	data;
	reg		bl_en;

	bootloader bl(.*, .data(data), .en(bl_en), .clk(clk), .rstn(rstn));

	(* mark_debug = "true" *) reg [29:0]	pc;
	assign		inst_addrb[1:0] = 2'b0;
	assign		inst_addrb[31:2] = pc;

	typedef enum logic [2:0] {
		WAIT_ST, LOAD_ST, RUN_ST, FPU_ST, IN_ST, OUT_ST, END_ST
	} state_type;

	(* mark_debug = "true" *) state_type state;

	typedef enum logic {
		CHECK_RX_ST, READ_ST
	} load_state_type;

	load_state_type load_state;

	(* mark_debug = "true" *) reg [1:0]	fetch_wait;
	(* mark_debug = "true" *) reg [1:0]	memory_wait;
	(* mark_debug = "true" *) wire [31:0]	inst;
	(* mark_debug = "true" *) reg		rt_flag;
	(* mark_debug = "true" *) reg [4:0]	rt;
	(* mark_debug = "true" *) reg signed [31:0]	tdata;
	(* mark_debug = "true" *) reg signed [31:0]	srca;
	(* mark_debug = "true" *) reg signed [31:0]	srcb;
	(* mark_debug = "true" *) reg signed [31:0]	srcs;
	(* mark_debug = "true" *) reg [15:0]	si;
	(* mark_debug = "true" *) reg [25:0]	li;
	(* mark_debug = "true" *) reg [31:0]	read_addr;
	(* mark_debug = "true" *) reg [31:0]	write_addr;
	assign		data_addra[1:0] = 0;
	assign		data_addra[31:2] = write_addr[29:0];
	assign		data_addrb[1:0] = 0;
	assign		data_addrb[31:2] = read_addr[29:0];

	assign		inst = inst_doutb;
	typedef enum logic [1:0] {
		FETCH_ST, DECODE_ST, EXEC_ST
	} cpu_state_type;

	(* mark_debug = "true" *) cpu_state_type cpu_state;
	(* mark_debug = "true" *) reg signed [31:0]	gpr [0:31];
	(* mark_debug = "true" *) reg	eq;
	(* mark_debug = "true" *) reg	le;

	reg		fadd_en;
	wire [31:0]	fadd_result;
	wire		fadd_done;
	wire		fadd_busy;
	fadd fa(.*, .en(fadd_en), .adata(srca), .bdata(srcb), .result(fadd_result), .done(fadd_done), .busy(fadd_busy), .clk(clk), .rstn(rstn));
	
	reg		fsub_en;
	wire [31:0]	fsub_result;
	wire		fsub_done;
	wire		fsub_busy;
	fsub fs(.*, .en(fsub_en), .adata(srca), .bdata(srcb), .result(fsub_result), .done(fsub_done), .busy(fsub_busy), .clk(clk), .rstn(rstn));

	reg		fmul_en;
	wire [31:0]	fmul_result;
	wire		fmul_done;
	wire		fmul_busy;
	fmul fm(.*, .en(fmul_en), .adata(srca), .bdata(srcb), .result(fmul_result), .done(fmul_done), .busy(fmul_busy), .clk(clk), .rstn(rstn));

	reg		fdiv_en;
	wire [31:0]	fdiv_result;
	wire		fdiv_done;
	wire		fdiv_busy;
	fdiv fd(.*, .en(fdiv_en), .adata(srca), .bdata(srcb), .result(fdiv_result), .done(fdiv_done), .busy(fdiv_busy), .clk(clk), .rstn(rstn));

	typedef enum logic {
		CHECK_TX_ST, WRITE_ST
	} out_state_type;
	out_state_type out_state;

	always_ff@(posedge clk) begin
		if (~rstn) begin     
			uart_raddr <= STAT_REG;
			uart_ren <= 0;
			
			uart_wdata <= 8'b0;
			uart_waddr <= TX_FIFO;
			uart_wen <= 0;

			fadd_en <= 0;
			fsub_en <= 0;
			fmul_en <= 0;
			fdiv_en <= 0;

			data <= 8'b0;
			inst_enb <= 0;
			bl_en <= 0;

			pc <= 30'b0;
			fetch_wait <= 0;
			memory_wait <= 0;
			rt_flag <= 0;
			read_addr <= 32'b0;
			write_addr <= 32'b0;
			data_ena <= 0;
			data_wea <= 4'b0;
			data_enb <= 0;

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
						if (rt_flag) begin
							gpr[rt] <= tdata;
							rt_flag <= 0;
						end
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
						3'b011:		srca <= gpr[inst[20:16]];
						3'b101:		srca <= gpr[inst[25:21]];
						default:	srca <= 31'b0;
					endcase

					case (inst[31:29])
						3'b001:		srcb <= gpr[inst[15:11]];
						3'b010:		srcb <= gpr[inst[15:11]];
						3'b101:		srcb <= gpr[inst[20:16]];
						default:	srcb <= 32'b0;
					endcase

					case (inst[31:29])
						3'b011:		srcs <= gpr[inst[25:21]];
						3'b100:		srcs <= gpr[5'b11111];
						3'b110:		srcs <= gpr[inst[25:21]];
						default:	srcs <= 32'b0;
					endcase

					case (inst[31:29])
						3'b000:		si <= inst[15:0];
						3'b010:		si <= inst[15:0];
						3'b011:		si <= inst[15:0];
						default:	si <= 16'b0;
					endcase

					case (inst[31:29])
						3'b100:		li <= inst[25:0];
						3'b101:		li <= inst[25:0];
						default:	li <= 26'b0;
					endcase
				end else if (cpu_state == EXEC_ST) begin
					if (inst[31:29] == 3'b000) begin
						case (inst[28:26])
							3'b000:		tdata <= srca + $signed({16'b0, si}); // Addi
							3'b001:		tdata <= srca - $signed({16'b0, si}); // Subi
							3'b010:		tdata <= srca * $signed({16'b0, si}); // Muli
							default:	tdata <= srca / $signed({16'b0, si}); // Divi
						endcase
						rt_flag <= 1;
						cpu_state <= FETCH_ST;
						pc <= pc + 1;
					end else if (inst[31:29] == 3'b001) begin
						if (inst[28] == 0) begin
							case (inst[27:26])
								2'b00:	tdata <= srca + srcb; // Add
								2'b01:	tdata <= srca - srcb; // Sub
								2'b10:	tdata <= srca * srcb; // Mul
								2'b11:	tdata <= srca / srcb; // Div
							endcase
							cpu_state <= FETCH_ST;
							rt_flag <= 1;
							pc <= pc + 1;
						end else begin
							// Fadd
							if (inst[27:26] == 2'b00 && ~fadd_busy) begin
								fadd_en <= 1;
								cpu_state <= FETCH_ST;
								state <= FPU_ST;

								rt_flag <= 1;
								pc <= pc + 1;
							end else if (inst[27:26] == 2'b01 && ~fsub_busy) begin // Fsub
								fsub_en <= 1;
								cpu_state <= FETCH_ST;
								state <= FPU_ST;

								rt_flag <= 1;
								pc <= pc + 1;
							end else if (inst[27:26] == 2'b10 && ~fmul_busy) begin // Fmul
								fmul_en <= 1;
								cpu_state <= FETCH_ST;
								state <= FPU_ST;

								rt_flag <= 1;
								pc <= pc + 1;
							end else if (inst[27:26] == 2'b11 && ~fdiv_busy) begin // Fdiv
								fdiv_en <= 1;
								cpu_state <= FETCH_ST;
								state <= FPU_ST;

								rt_flag <= 1;
								pc <= pc + 1;
							end
						end
					end else if (inst[31:29] == 3'b010) begin
						if (inst[28] == 0) begin
							case (inst[27:26])
								2'b00:	tdata <= $signed(srca & srcb);	// And
								2'b01:	tdata <= $signed(srca | srcb);	// Or
								2'b10:	tdata <= srca >>> $signed(si);	// Srawi
								2'b11:	tdata <= srca <<< $signed(si);	// Slawi
							endcase
						end
						rt_flag <= 1;
						cpu_state <= FETCH_ST;
						pc <= pc + 1;
					end else if (inst[31:29] == 3'b011) begin
						// Load
						if (inst[28:26] == 3'b000) begin
							memory_wait <= memory_wait + 1;
							if (memory_wait == 2'b00) begin
								read_addr <= srca + {16'b0, si};
							end else if (memory_wait == 2'b01) begin
								data_enb <= 1;
							end else if (memory_wait == 2'b11) begin
								data_enb <= 0;
								tdata <= data_doutb;
								rt_flag <= 1;

								cpu_state <= FETCH_ST;
								pc <= pc + 1;
							end
						end else if (inst[28:26] == 3'b001) begin // Store
							memory_wait <= memory_wait + 1;
							if (memory_wait == 2'b00) begin
								write_addr <= srca + {16'b0, si};
								data_dina <= srcs;
							end else if (memory_wait == 2'b01) begin
								data_ena <= 1;
								data_wea <= 4'b1111;
							end else if (memory_wait == 2'b11) begin
								data_ena <= 0;
								data_wea <= 4'b0;

								cpu_state <= FETCH_ST;
								pc <= pc + 1;
							end
						end else if (inst[28:26] == 3'b010) begin // Li
							tdata <= $signed({16'b0, si});
							rt_flag <= 1;
							cpu_state <= FETCH_ST;
							pc <= pc + 1;
						end else if (inst[28:26] == 3'b011) begin // Lis
							tdata <= $signed({si, srcb[15:0]});
							rt_flag <= 1;
							cpu_state <= FETCH_ST;
							pc <= pc + 1;
						end
					end else if (inst[31:29] == 3'b100) begin
						// Jump
						if (inst[28:26] == 3'b000) begin
							pc <= li;
						end else if (inst[28:26] == 3'b001) begin // Blr
							pc <= srcs;
						end else if (inst[28:26] == 3'b010) begin // Bl
							tdata <= pc + 1;
							rt_flag <= 1;
							rt <= 5'b11111;
							pc <= li;
						end
						cpu_state <= FETCH_ST;
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
						// Outll
						if (inst[28] == 1) begin
							case (inst[27:26])
								3'b000:	uart_wdata <= srcs[7:0]; // Outll
								3'b001:	uart_wdata <= srcs[15:8]; // Outlh
								3'b010:	uart_wdata <= srcs[23:16]; // Outul
								3'b011:	uart_wdata <= srcs[31:24]; // Outuh
							endcase


							uart_raddr <= STAT_REG;
							uart_ren <= 1;
							out_state <= CHECK_TX_ST;
							if (uart_rbusy == 0) begin
								state <= OUT_ST;
								cpu_state <= FETCH_ST;
								pc <= pc + 1;
							end
						end
					end
				end
			end else if (state == FPU_ST) begin
				fadd_en <= 0;
				fsub_en <= 0;
				fmul_en <= 0;
				fdiv_en <= 0;
				if (fadd_done) begin
					tdata <= fadd_result;
					state <= RUN_ST;
				end
				if (fsub_done) begin
					tdata <= fsub_result;
					state <= RUN_ST;
				end
				if (fmul_done) begin
					tdata <= fmul_result;
					state <= RUN_ST;
				end
				if (fdiv_done) begin
					tdata <= fdiv_result;
					state <= RUN_ST;
				end
			end else if (state == OUT_ST) begin
				if (out_state == CHECK_TX_ST) begin
					if (uart_rdone) begin
						// Tx FIFO Full flag
						if (uart_rdata[3] == 0) begin
							uart_wen <= 1;
							out_state <= WRITE_ST;
						end else uart_ren <= 1;
					end else uart_ren <= 0;
				end else if (out_state == WRITE_ST) begin
					uart_wen <= 0;

					if (uart_wdone) state <= RUN_ST;
				end
			end else if (state == END_ST) begin
				led[7:2] <= 6'b000100;
			end
		end
	end

endmodule

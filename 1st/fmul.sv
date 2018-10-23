module fmul(
	output wire [31:0]		fmul_axis_a_tdata,
	input wire			fmul_axis_a_tready,
	output reg			fmul_axis_a_tvalid,

	output wire [31:0]		fmul_axis_b_tdata,
	input wire			fmul_axis_b_tready,
	output reg			fmul_axis_b_tvalid,

	input wire [31:0]		fmul_axis_result_tdata,
	output reg			fmul_axis_result_tready,
	input wire			fmul_axis_result_tvalid,

	input wire		en,
	input wire [31:0]	adata,
	input wire [31:0]	bdata,
	output reg [31:0]	result,
	output reg		done,
	output wire		busy,
	input wire		clk,
	input wire		rstn);

	assign fmul_axis_a_tdata = adata;
	assign fmul_axis_b_tdata = bdata;

	assign busy = fmul_axis_result_tvalid | (fmul_state == SET_ST) | (fmul_state == RESULT_ST);

	typedef enum logic [1:0] {
		WAIT_ST, SET_ST, RESULT_ST
	} fmul_state_type;
	fmul_state_type fmul_state;

	always@(posedge clk) begin
		if (~rstn) begin
			result <= 32'b0;
			done <= 0;
			fmul_axis_a_tvalid <= 0;
			fmul_axis_b_tvalid <= 0;
			fmul_axis_result_tready <= 1;
			fmul_state <= WAIT_ST;
		end else begin
			if (fmul_state == WAIT_ST) begin
				fmul_axis_result_tready <= 0;
				done <= 0;
				if (en) begin
					fmul_axis_a_tvalid <= 1;
					fmul_axis_b_tvalid <= 1;
					fmul_axis_result_tready <= 0;
					fmul_state <= SET_ST;
				end
			end else if (fmul_state == SET_ST) begin
				if (fmul_axis_a_tready) fmul_axis_a_tvalid <= 0;
				if (fmul_axis_b_tready) fmul_axis_b_tvalid <= 0;
				if (fmul_axis_a_tvalid == 0 && fmul_axis_b_tvalid == 0) begin
					fmul_state <= RESULT_ST;
				end
			end else if (fmul_state == RESULT_ST) begin
				if (fmul_axis_result_tvalid) begin
					fmul_axis_result_tready <= 1;
					result <= fmul_axis_result_tdata;
					done <= 1;
					fmul_state <= WAIT_ST;
				end
			end
		end
	end
	
endmodule

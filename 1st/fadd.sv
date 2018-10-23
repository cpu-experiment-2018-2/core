module fadd(
	output wire [31:0]		fadd_axis_a_tdata,
	input wire			fadd_axis_a_tready,
	output reg			fadd_axis_a_tvalid,

	output wire [31:0]		fadd_axis_b_tdata,
	input wire			fadd_axis_b_tready,
	output reg			fadd_axis_b_tvalid,

	input wire [31:0]		fadd_axis_result_tdata,
	output reg			fadd_axis_result_tready,
	input wire			fadd_axis_result_tvalid,

	input wire		en,
	input wire [31:0]	adata,
	input wire [31:0]	bdata,
	output reg [31:0]	result,
	output reg		done,
	output wire		busy,
	input wire		clk,
	input wire		rstn);

	assign fadd_axis_a_tdata = adata;
	assign fadd_axis_b_tdata = bdata;

	assign busy = fadd_axis_result_tvalid | (fadd_state == SET_ST) | (fadd_state == RESULT_ST);

	typedef enum logic [1:0] {
		WAIT_ST, SET_ST, RESULT_ST
	} fadd_state_type;
	fadd_state_type fadd_state;

	always@(posedge clk) begin
		if (~rstn) begin
			result <= 32'b0;
			done <= 0;
			fadd_axis_a_tvalid <= 0;
			fadd_axis_b_tvalid <= 0;
			fadd_axis_result_tready <= 1;
			fadd_state <= WAIT_ST;
		end else begin
			if (fadd_state == WAIT_ST) begin
				fadd_axis_result_tready <= 0;
				done <= 0;
				if (en) begin
					fadd_axis_a_tvalid <= 1;
					fadd_axis_b_tvalid <= 1;
					fadd_axis_result_tready <= 0;
					fadd_state <= SET_ST;
				end
			end else if (fadd_state == SET_ST) begin
				if (fadd_axis_a_tready) fadd_axis_a_tvalid <= 0;
				if (fadd_axis_b_tready) fadd_axis_b_tvalid <= 0;
				if (fadd_axis_a_tvalid == 0 && fadd_axis_b_tvalid == 0) begin
					fadd_state <= RESULT_ST;
				end
			end else if (fadd_state == RESULT_ST) begin
				if (fadd_axis_result_tvalid) begin
					fadd_axis_result_tready <= 1;
					result <= fadd_axis_result_tdata;
					done <= 1;
					fadd_state <= WAIT_ST;
				end
			end
		end
	end
	
endmodule

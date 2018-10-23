module fsub(
	output wire [31:0]		fsub_axis_a_tdata,
	input wire			fsub_axis_a_tready,
	output reg			fsub_axis_a_tvalid,

	output wire [31:0]		fsub_axis_b_tdata,
	input wire			fsub_axis_b_tready,
	output reg			fsub_axis_b_tvalid,

	input wire [31:0]		fsub_axis_result_tdata,
	output reg			fsub_axis_result_tready,
	input wire			fsub_axis_result_tvalid,

	input wire		en,
	input wire [31:0]	adata,
	input wire [31:0]	bdata,
	output reg [31:0]	result,
	output reg		done,
	output wire		busy,
	input wire		clk,
	input wire		rstn);

	assign fsub_axis_a_tdata = adata;
	assign fsub_axis_b_tdata = bdata;

	assign busy = fsub_axis_result_tvalid | (fsub_state == SET_ST) | (fsub_state == RESULT_ST);

	typedef enum logic [1:0] {
		WAIT_ST, SET_ST, RESULT_ST
	} fsub_state_type;
	fsub_state_type fsub_state;

	always@(posedge clk) begin
		if (~rstn) begin
			result <= 32'b0;
			done <= 0;
			fsub_axis_a_tvalid <= 0;
			fsub_axis_b_tvalid <= 0;
			fsub_axis_result_tready <= 1;
			fsub_state <= WAIT_ST;
		end else begin
			if (fsub_state == WAIT_ST) begin
				fsub_axis_result_tready <= 0;
				done <= 0;
				if (en) begin
					fsub_axis_a_tvalid <= 1;
					fsub_axis_b_tvalid <= 1;
					fsub_axis_result_tready <= 0;
					fsub_state <= SET_ST;
				end
			end else if (fsub_state == SET_ST) begin
				if (fsub_axis_a_tready) fsub_axis_a_tvalid <= 0;
				if (fsub_axis_b_tready) fsub_axis_b_tvalid <= 0;
				if (fsub_axis_a_tvalid == 0 && fsub_axis_b_tvalid == 0) begin
					fsub_state <= RESULT_ST;
				end
			end else if (fsub_state == RESULT_ST) begin
				if (fsub_axis_result_tvalid) begin
					fsub_axis_result_tready <= 1;
					result <= fsub_axis_result_tdata;
					done <= 1;
					fsub_state <= WAIT_ST;
				end
			end
		end
	end
	
endmodule

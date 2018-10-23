module fdiv(
	output wire [31:0]		fdiv_axis_a_tdata,
	input wire			fdiv_axis_a_tready,
	output reg			fdiv_axis_a_tvalid,

	output wire [31:0]		fdiv_axis_b_tdata,
	input wire			fdiv_axis_b_tready,
	output reg			fdiv_axis_b_tvalid,

	input wire [31:0]		fdiv_axis_result_tdata,
	output reg			fdiv_axis_result_tready,
	input wire			fdiv_axis_result_tvalid,

	input wire		en,
	input wire [31:0]	adata,
	input wire [31:0]	bdata,
	output reg [31:0]	result,
	output reg		done,
	output wire		busy,
	input wire		clk,
	input wire		rstn);

	assign fdiv_axis_a_tdata = adata;
	assign fdiv_axis_b_tdata = bdata;

	assign busy = fdiv_axis_result_tvalid | (fdiv_state == SET_ST) | (fdiv_state == RESULT_ST);

	typedef enum logic [1:0] {
		WAIT_ST, SET_ST, RESULT_ST
	} fdiv_state_type;
	fdiv_state_type fdiv_state;

	always@(posedge clk) begin
		if (~rstn) begin
			result <= 32'b0;
			done <= 0;
			fdiv_axis_a_tvalid <= 0;
			fdiv_axis_b_tvalid <= 0;
			fdiv_axis_result_tready <= 1;
			fdiv_state <= WAIT_ST;
		end else begin
			if (fdiv_state == WAIT_ST) begin
				fdiv_axis_result_tready <= 0;
				done <= 0;
				if (en) begin
					fdiv_axis_a_tvalid <= 1;
					fdiv_axis_b_tvalid <= 1;
					fdiv_axis_result_tready <= 0;
					fdiv_state <= SET_ST;
				end
			end else if (fdiv_state == SET_ST) begin
				if (fdiv_axis_a_tready) fdiv_axis_a_tvalid <= 0;
				if (fdiv_axis_b_tready) fdiv_axis_b_tvalid <= 0;
				if (fdiv_axis_a_tvalid == 0 && fdiv_axis_b_tvalid == 0) begin
					fdiv_state <= RESULT_ST;
				end
			end else if (fdiv_state == RESULT_ST) begin
				if (fdiv_axis_result_tvalid) begin
					fdiv_axis_result_tready <= 1;
					result <= fdiv_axis_result_tdata;
					done <= 1;
					fdiv_state <= WAIT_ST;
				end
			end
		end
	end
	
endmodule

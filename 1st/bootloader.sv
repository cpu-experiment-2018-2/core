module bootloader(
	// instruction BRAM
	// Port A
	output reg [31:0]		inst_addra,
	output reg [31:0]		inst_dina,
	output reg [3:0]		inst_wea,
	
	input wire [7:0]		data,
	input wire			en,
	input wire			clk,
	input wire			rstn);

	reg [1:0] cnt3;
	reg [1:0] cnt4;

	always@(posedge clk) begin
		if (~rstn) begin
			cnt3 <= 0;
			cnt4 <= 0;
			inst_dina <= 32'b0;
			inst_addra <= 32'b0;
			inst_wea <= 4'b0000;
		end else begin
			if (cnt3 == 2'b0) begin
				if (en) begin
					if (cnt4 == 2'b00) begin
						inst_dina[31:24] <= data;
						inst_wea <= 4'b1000;
					end else if (cnt4 == 2'b01) begin
						inst_dina[23:16] <= data;
						inst_wea <= 4'b0100;
					end else if (cnt4 == 2'b10) begin
						inst_dina[15:8] <= data;
						inst_wea <= 4'b0010;
					end else if (cnt4 == 2'b11) begin
						inst_wea <= 4'b0001;
						inst_dina[7:0] <= data;
					end
					cnt3 <= 1;
					cnt4 <= cnt4 + 1;
				end
			end else if (cnt3 == 2'b1) begin
				cnt3 <= cnt3 + 1;
			end else if (cnt3 == 2'b10) begin
				inst_wea <= 4'b0;
				cnt3 <= 2'b0;
				if (cnt4 == 2'b00) inst_addra <= inst_addra + 4;
			end
		end
	end

endmodule

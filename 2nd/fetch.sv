import inst_package::*;

module fetch (
    input  wire         interlock,

    input  wire         branch_flag,
    input  wire [31:0]  branch_pc,

    // output
    //
    output reg  [31:0]  pc_to_the_next,
    output reg  [63:0]  inst_to_the_next,

    input  wire         clk,
    input  wire         rstn);

	reg  [31:0]		middle_pc;
    reg  [31:0]     pc;
    wire [31:0]     inst_addra;
    assign inst_addra = branch_flag ? branch_pc : pc;

    reg  [1:0]      interval;
    wire [63:0]     douta;

    blk_mem_gen_0 inst_rom(.addra({inst_addra[28:0], 3'b0}), .clka(clk), .douta(douta));

    always@(posedge clk) begin
        if (~rstn) begin
            pc <= 32'b0;
            middle_pc <= 32'b0;
            interval <= 1;
            inst_to_the_next <= {Nop, 26'b0, Nop, 26'b0};
            pc_to_the_next <= 32'b0;
        end else if (~interlock) begin
            if (interval == 0) inst_to_the_next <= (~branch_flag) ? douta : {Nop, 26'b0, Nop, 26'b0};
            else begin
                inst_to_the_next <= {Nop, 26'b0, Nop, 26'b0};
                interval <= interval - 1;
            end

            pc <= inst_addra + 1;
			middle_pc <= inst_addra;
            pc_to_the_next <= (~branch_flag) ? middle_pc : 32'b0;
        end else begin
        end
    end

endmodule

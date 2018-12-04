module fetch (
    input  wire         interlock,
    input  wire         fetch_stall,

    // output
    //

    output reg  [31:0]  pc,
    output reg  [63:0]  inst_to_the_next,

    input  wire         clk,
    input  wire         rstn);

    reg  [1:0]      interval;
    wire [63:0]     douta;

    blk_mem_gen_0 inst_rom(.addra(pc), .clka(clk), .douta(douta));

    always@(posedge clk) begin
        if (~rstn) begin
            pc <= 32'b0;
            interval <= 1;
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
        end else if (~fetch_stall && ~interlock) begin
            if (interval == 0) inst_to_the_next <= douta;
            else begin
                inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
                interval <= interval - 1;
            end

            pc <= pc + 8;
        end
    end

endmodule

module fetch (
    input  wire         interlock,
    input  wire         fetch_stall,

    // input
    //
    input  wire [31:0]  pc,

    output wire [63:0]  inst_to_the_next,

    input  wire         clk,
    input  wire         rstn);

    reg             interval;
    wire [63:0]     douta;

    assign inst_to_the_next = interval ? {3'b111, 29'b0, 3'b111, 29'b0} : douta;

    blk_mem_gen_0 inst_rom(.addra(pc), .clka(clk), .douta(douta));

    always@(posedge clk) begin
        if (~rstn) begin
            interval <= 1;
        end else if (~fetch_stall && ~interlock) begin
            interval <= 0;
        end
    end

endmodule

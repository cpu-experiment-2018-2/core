module memory2 (
    input  wire         interlock,

    input  wire         memory2_stall,
    input  wire         memory2_used,

    input  wire [63:0]  inst,
    output reg  [63:0]  inst_to_the_next,

    output wire [63:0]  doutb,

    input  wire         clk,
    input  wire         rstn);

    always@(posedge clk) begin
        if (~rstn) begin
        end else if (~memory2_stall || ~interlock) begin
            inst_to_the_next <= inst;
        end else begin
        end
    end

endmodule

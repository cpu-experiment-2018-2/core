module memory1 (
    input  wire         interlock,
    input  wire         memory1_stall,

    // input
    //
    input  wire         memory1_used,
    input  wire [63:0]  inst,
    input  wire [31:0]  addra,
    input  wire [63:0]  dina,
    input  wire [1:0]   write_flag,
    input  wire [31:0]  addrb,

    // output
    //
    output reg          memory2_used,
    output reg  [63:0]  inst_to_the_next,

    output wire [63:0]  doutb,

    input  wire         clk,
    input  wire         rstn);

    wire [7:0]  wea;
    wire        enb;

    assign wea[3:0] = write_flag[0] ? 4'b1111 : 4'b0000;
    assign wea[7:4] = write_flag[1] ? 4'b1111 : 4'b0000;
    assign enb = 1;

    always@(posedge clk) begin
        if (~rstn) begin
        end else if (memory1_used && (~memory1_stall || ~interlock)) begin
            inst_to_the_next <= inst;
        end else begin
        end
    end
endmodule

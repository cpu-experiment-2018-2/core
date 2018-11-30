module memory (
    input  wire         interlock,

    // input
    //
    input  wire                 memory_used,
    input  wire         [63:0]  inst,
    input  wire         [31:0]  addra,
    input  wire         [63:0]  dina,
    input  wire         [1:0]   write_flag,
    input  wire         [31:0]  addrb,

    input  wire         [4:0]   u_rt,
    input  wire                 u_rt_flag,

    input  wire signed  [31:0]  l_tdata,
    input  wire         [4:0]   l_rt,
    input  wire                 l_rt_flag,


    // output
    //
    output reg          [63:0]  inst_to_the_next,
    output wire         [4:0]   u_rt_to_the_next,
    output wire                 u_rt_flag_to_the_next,

    output wire signed  [31:0]  l_tdata_to_the_next,
    output wire         [4:0]   l_rt_to_the_next,
    output wire                 l_rt_flag_to_the_next,

    output wire         [63:0]  doutb,

    input  wire         clk,
    input  wire         rstn);

    wire [7:0]  wea;
    wire        enb;

    assign wea[3:0] = write_flag[0] ? 4'b1111 : 4'b0000;
    assign wea[7:4] = write_flag[1] ? 4'b1111 : 4'b0000;
    assign enb = 1;

    always@(posedge clk) begin
        if (~rstn) begin
        end else if (memory_used && (~memory_stall || ~interlock)) begin
            inst_to_the_next <= inst;
            
            u_rt_to_the_next <= u_rt;
            u_rt_flag_to_the_next <= u_rt_flag;

            l_tdata_to_the_next <= l_tdata;
            l_rt_to_the_next <= l_rt;
            l_rt_flag_to_the_next <= l_rt_flag;
        end else begin
        end
    end
endmodule

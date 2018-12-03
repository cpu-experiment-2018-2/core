module memory (
    input  wire         interlock,

    // input
    //
    input  wire                 memory_used,
    input  wire         [63:0]  inst,
    input  wire         [31:0]  addra,      // write
    input  wire         [63:0]  dina,       // write
    input  wire         [31:0]  addrb,      // read

    input  wire         [4:0]   u_rt,
    input  wire                 u_rt_flag,

    input  wire signed  [31:0]  l_tdata,
    input  wire         [4:0]   l_rt,
    input  wire                 l_rt_flag,


    // output
    //
    output reg          [63:0]  inst_to_the_next,
    output reg          [4:0]   u_rt_to_the_next,
    output reg                  u_rt_flag_to_the_next,

    output reg signed   [31:0]  l_tdata_to_the_next,
    output reg          [4:0]   l_rt_to_the_next,
    output reg                  l_rt_flag_to_the_next,

    output wire         [63:0]  mem_doutb,

    input  wire         clk,
    input  wire         rstn);

    wire        ena;
    wire [7:0]  wea;
    wire        enb;

    assign ena = 1;
    assign wea[3:0] = (inst[31:26] == 6'b010001) ? 4'b1111 : 4'b0000;
    assign wea[7:4] = (inst[63:58] == 6'b010001) ? 4'b1111 : 4'b0000;
    assign enb = 1;

    blk_mem_gen_1 data_ram( .clka(clk),
                            .ena(ena),
                            .wea(wea),
                            .addra(addra),
                            .dina(dina),
                            .clkb(clk),
                            .addrb(addrb),
                            .doutb(mem_doutb));

    always@(posedge clk) begin
        if (~rstn) begin
        end else if (memory_used && ~interlock) begin
            inst_to_the_next <= inst;
            
            u_rt_to_the_next <= u_rt;
            u_rt_flag_to_the_next <= u_rt_flag;

            l_tdata_to_the_next <= l_tdata;
            l_rt_to_the_next <= l_rt;
            l_rt_flag_to_the_next <= l_rt_flag;
        end else begin
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
            u_rt_flag_to_the_next <= 0;
            l_rt_flag_to_the_next <= 0;
        end
    end
endmodule

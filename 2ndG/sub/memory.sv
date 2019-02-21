import inst_package::*;

module memory (
    input  wire         interlock,

    // input
    //
    input  wire         [31:0]  pc,
    input  wire         [63:0]  inst,
    mem_in_if                   u_mem_in,
    mem_in_if                   l_mem_in,

    input  wire         [4:0]   u_rt,
    input  wire                 u_rt_flag,

    input  wire         [4:0]   l_rt,
    input  wire                 l_rt_flag,

    input  wire         [31:0]  fetch_addr,


    // output
    //
    output reg          [31:0]  pc_to_the_next,
    output reg          [63:0]  inst_to_the_next,
    output reg          [4:0]   u_rt_to_the_next,
    output reg          [4:0]   l_rt_to_the_next,

    output reg          [31:0]  mem_douta,
    output reg          [31:0]  mem_doutb,

    output reg          [31:0]  fetch_result,

    // from maincore
    input data_in              u_n_in_from_main,
    input data_in              l_n_in_from_main,

    input  wire         clk,
    input  wire         rstn);


    // Memory Access Process
    //           | id  | ex  | mem | mem | wb  |
    // addr      ______|^^^^^|__________________
    // n_addr    _________|^^^^^|_______________
    // BRAM                     |---->
    // n_doutb   _____________________|^^^^^|___
    // mem_doutb ________________________|^^^^^|


    data_in u_n_in;
    data_in l_n_in;
    wire [31:0] douta;
    reg  [31:0] n_douta;
    wire [31:0] doutb;
    reg  [31:0] n_doutb;

    reg  [31:0] middle_pc;
    reg  [63:0] middle_inst;
    reg  [4:0]  middle_u_rt;
    reg  [4:0]  middle_l_rt;

    wire [31:0] n_addra = (u_n_in_from_main.we == 4'b0) ? u_n_in.addr : u_n_in_from_main.addr;
    wire [31:0] n_dina = (u_n_in_from_main.we == 4'b0) ? u_n_in.din : u_n_in_from_main.din;
    wire [3:0] n_wea = (u_n_in_from_main.we == 4'b0) ? u_n_in.we : u_n_in_from_main.we;
    wire [31:0] n_addrb = (l_n_in_from_main.we == 4'b0) ? l_n_in.addr : l_n_in_from_main.addr;
    wire [31:0] n_dinb = (l_n_in_from_main.we == 4'b0) ? l_n_in.din : l_n_in_from_main.din;
    wire [3:0] n_web = (l_n_in_from_main.we == 4'b0) ? l_n_in.we : l_n_in_from_main.we;

    blk_mem_gen_0 data_ram( .addra(n_addra),
                            .clka(~clk),
                            .dina(n_dina),
                            .douta(douta),
                            .wea(n_wea),
                            .addrb(n_addrb),
                            .clkb(~clk),
                            .dinb(n_dinb),
                            .doutb(doutb),
                            .web(n_web));

    always@(posedge clk) begin
        if (~rstn) begin
        end else if (~interlock) begin
            // to the next
            middle_pc <= pc;
            pc_to_the_next <= middle_pc;
            middle_inst <= inst;
            inst_to_the_next <= middle_inst;

            middle_u_rt <= u_rt;
            middle_l_rt <= l_rt;
            u_rt_to_the_next <= middle_u_rt;
            l_rt_to_the_next <= middle_l_rt;

            mem_douta <= n_douta;
            mem_doutb <= n_doutb;
        end else begin
            fetch_result <= n_douta;
        end
    end
    
    always@(negedge clk) begin
        if (~rstn) begin
            u_n_in.we <= 4'b0;
            l_n_in.we <= 4'b0;
        end else if (~interlock) begin
            u_n_in.addr <= {13'b0, u_mem_in.addr[16:0], 2'b0};
            u_n_in.din <= u_mem_in.din;
            u_n_in.we <= u_mem_in.we;
            l_n_in.addr <= {13'b0, l_mem_in.addr[16:0], 2'b0};
            l_n_in.din <= l_mem_in.din;
            l_n_in.we <= l_mem_in.we;

            n_douta <= douta;
            n_doutb <= doutb;
        end else begin
            u_n_in.addr <= {13'b0, fetch_addr[16:0], 2'b0};
            u_n_in.we <= 0;
            l_n_in.we <= 0;

            n_douta <= douta;
            n_doutb <= doutb;
        end
    end

endmodule

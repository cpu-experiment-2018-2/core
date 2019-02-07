import inst_package::*;

module memory (
    input  wire         interlock,

    // input
    //
    input  wire                 memory_used,
    input  wire         [31:0]  pc,
    input  wire         [63:0]  inst,
    mem_in_if                   u_mem_in,
    mem_in_if                   l_mem_in,

    input  wire         [4:0]   u_rt,
    input  wire                 u_rt_flag,

    input  wire         [4:0]   l_rt,
    input  wire                 l_rt_flag,


    // output
    //
    output reg          [31:0]  pc_to_the_next,
    output reg          [63:0]  inst_to_the_next,
    output reg          [4:0]   u_rt_to_the_next,
    output reg          [4:0]   l_rt_to_the_next,

    output reg          [31:0]  mem_douta,
    output reg          [31:0]  mem_doutb,

    input  wire         clk,
    input  wire         rstn);


    // Memory Access Process
    //           | id  | ex  | mem | mem | wb  |
    // addr      ______|^^^^^|__________________
    // n_addr    _________|^^^^^|_______________
    // BRAM                     |---->
    // n_doutb   _____________________|^^^^^|___
    // mem_doutb ________________________|^^^^^|

    reg        [31:0]   middle_pc;
    reg        [63:0]   middle_inst;
    reg        [4:0]    middle_u_rt;
    reg        [4:0]    middle_l_rt;

    reg        [31:0]   u_neg_addr;
    reg        [31:0]   u_middle_n_addr;
    reg        [31:0]   u_n_addr_to_the_next;
    reg        [31:0]   l_neg_addr;
    reg        [31:0]   l_middle_n_addr;
    reg        [31:0]   l_n_addr_to_the_next;

    reg  [31:0] u_n_addr [0:7];
    reg  [31:0] n_dina  [0:7];
    reg  [3:0]  n_wea   [0:7];
    wire [31:0] douta   [0:7];
    reg  [31:0] n_douta [0:7];
    reg  [31:0] l_n_addr [0:7];
    reg  [31:0] n_dinb  [0:7];
    reg  [3:0]  n_web   [0:7];
    wire [31:0] doutb   [0:7];
    reg  [31:0] n_doutb [0:7];

    wire        ena;

    assign ena = 1;

    generate
        genvar i;
        for (i = 0; i < 8; i++) begin: data_rams
            blk_mem_gen_1 data_ram( .addra(u_n_addr[i]),
                                    .clka(~clk),
                                    .dina(n_dina[i]),
                                    .douta(douta[i]),
                                    .wea(n_wea[i]),
                                    .addrb(l_n_addr[i]),
                                    .clkb(~clk),
                                    .dinb(n_dinb[i]),
                                    .doutb(doutb[i]),
                                    .web(n_web[i]));
        end
    endgenerate

    always@(posedge clk) begin
        if (~rstn) begin
            middle_pc <= 32'b0;
            middle_inst <= {Nop, 26'b0, Nop, 26'b0};

            pc_to_the_next <= 32'b0;
            inst_to_the_next <= {Nop, 26'b0, Nop, 26'b0};
        end else if (~interlock) begin
            // middle
            middle_pc <= pc;
            middle_inst <= inst;

            middle_u_rt <= u_rt;
            middle_l_rt <= l_rt;

            // to the next
            pc_to_the_next <= middle_pc;
            inst_to_the_next <= middle_inst;
            
            u_rt_to_the_next <= middle_u_rt;
            l_rt_to_the_next <= middle_l_rt;

            mem_douta <= n_douta[u_n_addr_to_the_next[16:14]];
            mem_doutb <= n_doutb[l_n_addr_to_the_next[16:14]];
        end else begin
        end
    end

    always@(negedge clk) begin
        if (~rstn) begin
            for (int i = 0; i < 8; i++) begin
                n_wea[i] <= 4'b0;
                n_web[i] <= 4'b0;
            end
        end else if (~interlock) begin
            for (int i = 0; i < 8; i++) begin
                u_n_addr[i] <= {15'b0, u_mem_in.addr[13:0], 2'b0};
                n_dina[i] <= u_mem_in.din;
                n_douta[i] <= douta[i];
                l_n_addr[i] <= {15'b0, l_mem_in.addr[13:0], 2'b0};
                n_dinb[i] <= l_mem_in.din;
                n_doutb[i] <= doutb[i];
                if (u_mem_in.addr[16:14] == i) n_wea[i] <= u_mem_in.we;
                else n_wea[i] <= 4'b0;
                if (l_mem_in.addr[16:14] == i) n_web[i] <= l_mem_in.we;
                else n_web[i] <= 4'b0;
            end

            u_neg_addr <= u_mem_in.addr;
            u_middle_n_addr <= u_neg_addr;
            u_n_addr_to_the_next <= u_middle_n_addr;
            l_neg_addr <= l_mem_in.addr;
            l_middle_n_addr <= l_neg_addr;
            l_n_addr_to_the_next <= l_middle_n_addr;
        end else begin
        end
    end

endmodule

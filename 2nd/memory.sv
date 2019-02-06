import inst_package::*;

module memory (
    input  wire         interlock,

    // input
    //
    input  wire                 memory_used,
    input  wire         [31:0]  pc,
    input  wire         [63:0]  inst,
    input  wire         [31:0]  addr,
    input  wire         [63:0]  dina,       // write
    input  wire         [7:0]   wea,        // write

    input  wire         [4:0]   u_rt,
    input  wire                 u_rt_flag,

    input  wire signed  [31:0]  l_tdata,
    input  wire         [4:0]   l_rt,
    input  wire                 l_rt_flag,


    // output
    //
    output reg          [31:0]  pc_to_the_next,
    output reg          [63:0]  inst_to_the_next,
    output reg          [4:0]   u_rt_to_the_next,
    output reg          [4:0]   l_rt_to_the_next,

    output reg          [63:0]  mem_doutb,

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

    reg        [31:0]   middle_n_addr;
    reg        [31:0]   n_addr_to_the_next;

    reg  [31:0] n_addr [0:7];
    reg  [31:0] neg_addr;
    reg  [7:0]  n_wea   [0:7];
    reg  [63:0] n_dina  [0:7];
    wire [63:0] doutb   [0:7];
    reg  [63:0] n_doutb [0:7];

    wire        ena;

    assign ena = 1;

    generate
        genvar i;
        for (i = 0; i < 8; i++) begin: data_rams
            blk_mem_gen_1 data_ram( .clka(~clk),
                                    .ena(ena),
                                    .wea(n_wea[i]),
                                    .addra(n_addr[i]),
                                    .dina(n_dina[i]),
                                    .clkb(~clk),
                                    .addrb(n_addr[i]),
                                    .doutb(doutb[i]));
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

            mem_doutb <= n_doutb[n_addr_to_the_next[16:14]];
        end else begin
        end
    end

    always@(negedge clk) begin
        if (~rstn) begin
            for (int i = 0; i < 8; i++) begin
                n_wea[i] <= 8'b0;
            end
        end else if (~interlock) begin
            for (int i = 0; i < 8; i++) begin
                n_addr[i] <= {14'b0, addr[13:0], 3'b0};
                n_dina[i] <= dina;
                n_doutb[i] <= doutb[i];
                if (addr[16:14] == i) n_wea[i] <= wea;
                else n_wea[i] <= 8'b0;
            end

            neg_addr <= addr;
            middle_n_addr <= neg_addr;
            n_addr_to_the_next <= middle_n_addr;
        end else begin
        end
    end

endmodule

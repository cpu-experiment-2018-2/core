import inst_package::*;

module mmemory (
    input  wire         interlock,
    input  wire         [3:0]   living_sub_count,

    // input
    //
    input  wire         [31:0]  pc,
    input  wire         [63:0]  inst,
    input  wire         [3:0]   fetch_core,
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
    output reg          [3:0]   fetch_core_to_the_next,
    output reg          [4:0]   u_rt_to_the_next,
    output reg          [4:0]   l_rt_to_the_next,

    output reg          [31:0]  mem_douta,
    output reg          [31:0]  mem_doutb,

    // to sub cores
    output data_in              u_n_in_to_sub [0:SUBCORE_NUM-1],
    output data_in              l_n_in_to_sub [0:SUBCORE_NUM-1],

    input  wire         clk,
    input  wire         rstn);


    // Memory Access Process
    //           | id  | ex  | mem | wb  |
    // addr      ______|^^^^^|____________
    // n_addr    _________|^^^^^|_________
    // LUTRAM                   |---->
    // mem_doutb __________________|^^^^^|
    

    data_in u_n_in;
    data_in l_n_in;
    reg  [31:0] n_douta;
    reg  [31:0] n_doutb;

    always@(posedge clk) begin
        if (~rstn) begin
        end else if (~interlock) begin
            // to the next
            pc_to_the_next <= pc;
            inst_to_the_next <= inst;
            fetch_core_to_the_next <= fetch_core;

            u_rt_to_the_next <= u_rt;
            l_rt_to_the_next <= l_rt;

            mem_douta <= n_douta;
            mem_doutb <= n_doutb;
        end
    end
    
    always@(negedge clk) begin
        if (~rstn) begin
            u_n_in.we <= 0;
            l_n_in.we <= 0;
        end else if (~interlock) begin
            u_n_in.addr <= {13'b0, u_mem_in.addr[16:0], 2'b0};
            u_n_in.din <= u_mem_in.din;
            u_n_in.we <= u_mem_in.we;
            l_n_in.addr <= {13'b0, l_mem_in.addr[16:0], 2'b0};
            l_n_in.din <= l_mem_in.din;
            l_n_in.we <= l_mem_in.we;

            for (int i = 0; i < SUBCORE_NUM; i++) begin
                u_n_in_to_sub[i].addr <= {13'b0, u_mem_in.addr[16:0], 2'b0};
                u_n_in_to_sub[i].din <= u_mem_in.din;
                if (living_sub_count == 0) u_n_in_to_sub[i].we <= u_mem_in.we;
                l_n_in_to_sub[i].addr <= {13'b0, l_mem_in.addr[16:0], 2'b0};
                l_n_in_to_sub[i].din <= l_mem_in.din;
                if (living_sub_count == 0) l_n_in_to_sub[i].we <= l_mem_in.we;
            end
        end
    end

    // memory
    reg  [31:0] data_mem [0:DATA_MEM_DEPTH-1];

    always@(negedge clk) begin
        if (~rstn) begin
        end else begin
            if (u_n_in.we) data_mem[u_n_in.addr] <= u_n_in.din;
            if (l_n_in.we) data_mem[l_n_in.addr] <= l_n_in.din;

            n_douta <= data_mem[u_n_in.addr];
            n_doutb <= data_mem[l_n_in.addr];
        end
    end

endmodule

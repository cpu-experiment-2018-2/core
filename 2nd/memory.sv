module memory (
    input  wire         interlock,

    // input
    //
    input  wire                 memory_used,
    input  wire         [63:0]  inst,
    input  wire         [31:0]  addra,      // write
    input  wire         [63:0]  dina,       // write
    input  wire         [7:0]   wea,        // write
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

    output reg          [63:0]  mem_doutb,

    input  wire         clk,
    input  wire         rstn);


    reg        [63:0]   middle_inst;
    reg        [4:0]    middle_u_rt;
    reg                 middle_u_rt_flag;
    reg signed [31:0]   middle_l_tdata;
    reg        [4:0]    middle_l_rt;
    reg                 middle_l_rt_flag;

    reg        [31:0]   middle_n_addrb;
    reg        [31:0]   n_addrb_to_the_next;

    reg  [31:0] n_addra [0:7];
    reg  [7:0]  n_wea [0:7];
    reg  [63:0] n_dina [0:7];
    reg  [31:0] n_addrb [0:7];
    reg  [63:0] n_doutb [0:7];

    wire        ena;

    assign ena = 1;

    generate
        genvar i;
        for (i = 0; i < 8; i++) begin: data_rams
            blk_mem_gen_1 data_ram( .clka(~clk),
                                    .ena(ena),
                                    .wea(n_wea[i]),
                                    .addra(n_addra[i]),
                                    .dina(n_dina[i]),
                                    .clkb(~clk),
                                    .addrb(n_addrb[i]),
                                    .doutb(n_doutb[i]));
        end
    endgenerate

    always@(posedge clk) begin
        if (~rstn) begin
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
            u_rt_flag_to_the_next <= 0;
            l_rt_flag_to_the_next <= 0;
        end else if (~interlock) begin
            // middle
            middle_inst <= inst;

            middle_u_rt <= u_rt;
            middle_u_rt_flag <= u_rt_flag;

            middle_l_tdata <= l_tdata;
            middle_l_rt <= l_rt;
            middle_l_rt_flag <= l_rt_flag;

            // to the next
            inst_to_the_next <= middle_inst;
            
            u_rt_to_the_next <= middle_u_rt;
            u_rt_flag_to_the_next <= middle_u_rt_flag;

            l_tdata_to_the_next <= middle_l_tdata;
            l_rt_to_the_next <= middle_l_rt;
            l_rt_flag_to_the_next <= middle_l_rt_flag;
        end else begin
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
            u_rt_flag_to_the_next <= 0;
            l_rt_flag_to_the_next <= 0;
        end
    end

    always@(negedge clk) begin
        if (~rstn) begin
        end else if (~interlock) begin
            for (int i = 0; i < 8; i++) begin
                n_addra[i] <= addra;
                n_dina[i] <= dina;
                n_addrb[i] <= addrb;
                if (addra[17:15] == i) n_wea[i] <= wea;
                else n_wea[i] <= 8'b0;
            end

            middle_n_addrb <= n_addrb[0];
            n_addrb_to_the_next <= middle_n_addrb;
            mem_doutb <= n_doutb[n_addrb_to_the_next[17:15]];
        end else begin
            for (int i = 0; i < 8; i++) begin
                n_wea[i] <= 8'b0;
            end
        end
    end

endmodule

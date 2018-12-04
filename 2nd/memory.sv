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

    output wire         [63:0]  n_doutb,

    input  wire         clk,
    input  wire         rstn);


    reg        [63:0]   middle_inst;
    reg        [4:0]    middle_u_rt;
    reg                 middle_u_rt_flag;
    reg signed [31:0]   middle_l_tdata;
    reg        [4:0]    middle_l_rt;
    reg                 middle_l_rt_flag;

    reg  [31:0] n_addra;
    reg  [7:0]  n_wea;
    reg  [63:0] n_dina;
    reg  [31:0] n_addrb;

    wire        ena;
    wire        enb;

    assign ena = 1;
    assign enb = 1;

    blk_mem_gen_1 data_ram( .clka(~clk),
                            .ena(ena),
                            .wea(n_wea),
                            .addra(n_addra),
                            .dina(n_dina),
                            .clkb(~clk),
                            .addrb(n_addrb),
                            .doutb(n_doutb));

    always@(posedge clk) begin
        if (~rstn) begin
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
            n_addra <= addra;
            n_wea <= wea;
            n_dina <= dina;
            n_addrb <= addrb;
        end else begin
            n_wea <= 7'b0;
        end
    end

endmodule

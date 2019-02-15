import inst_package::*;

module cpu (
    input  wire         rx,
    output wire         tx,

    input  wire         clk,
    input  wire         rstn);

    wire        subcore_ended   [0:SUBCORE_NUM];
    wire        exec_requested  [0:SUBCORE_NUM];
    wire [31:0] requested_pc    [0:SUBCORE_NUM];
    wire [31:0] fetch_addr      [0:SUBCORE_NUM];
    data_in     u_n_in          [0:SUBCORE_NUM];
    data_in     l_n_in          [0:SUBCORE_NUM];
    wire [31:0] fetch_result    [0:SUBCORE_NUM];

    main m(subcore_ended, fetch_result, u_n_in, l_n_in, exec_requested, requested_pc, fetch_addr, rx, tx, clk, rstn);
    generate
        genvar i;
        for (i = 0; i < 8; i++) begin: sub_cores
            sub s(exec_requested[i], requested_pc[i], fetch_addr[i], u_n_in[i], l_n_in[i], subcore_ended[i], fetch_result[i], clk, rstn);
        end
    endgenerate
    
endmodule

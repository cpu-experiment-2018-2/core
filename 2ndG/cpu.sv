import inst_package::*;

module cpu (
    input  wire         rx,
    output wire         tx,

    input  wire         clk,
    input  wire         rstn);

    wire        subcore_ended   [0:SUBCORE_NUM-1];
    wire        exec_requested  [0:SUBCORE_NUM-1];
    wire [31:0] requested_pc    [0:SUBCORE_NUM-1];
    wire [31:0] fetch_addr      [0:SUBCORE_NUM-1];
    data_in     u_n_in          [0:SUBCORE_NUM-1];
    data_in     l_n_in          [0:SUBCORE_NUM-1];
    wire [31:0] fetch_result    [0:SUBCORE_NUM-1];

    main m(subcore_ended, fetch_result, u_n_in, l_n_in, exec_requested, requested_pc, fetch_addr, rx, tx, clk, rstn);
    sub #(.CORE_NUM(0), .DATA_FILE("/home/tongari/cpu/core/2ndG/child0.txt")) s (exec_requested[0], requested_pc[0], fetch_addr[0], u_n_in[0], l_n_in[0], subcore_ended[0], fetch_result[0], clk, rstn);
    sub #(.CORE_NUM(1), .DATA_FILE("/home/tongari/cpu/core/2ndG/child1.txt")) s (exec_requested[1], requested_pc[1], fetch_addr[1], u_n_in[1], l_n_in[1], subcore_ended[1], fetch_result[1], clk, rstn);
    sub #(.CORE_NUM(2), .DATA_FILE("/home/tongari/cpu/core/2ndG/child2.txt")) s (exec_requested[2], requested_pc[2], fetch_addr[2], u_n_in[2], l_n_in[2], subcore_ended[2], fetch_result[2], clk, rstn);
    sub #(.CORE_NUM(3), .DATA_FILE("/home/tongari/cpu/core/2ndG/child3.txt")) s (exec_requested[3], requested_pc[3], fetch_addr[3], u_n_in[3], l_n_in[3], subcore_ended[3], fetch_result[3], clk, rstn);
    
endmodule

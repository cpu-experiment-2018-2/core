`timescale 1ns/1ps
module top (
    input  wire         rx,
    output wire         tx,
    output wire [7:0]   led,

    input  wire         clk,
    input  wire         rstn);

    cpu c(rx, tx, clk, rstn);

endmodule

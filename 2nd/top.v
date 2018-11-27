`timescale 1ns/1ps
module top (
    output wire [7:0]   led,

    input  wire         clk,
    input  wire         rstn);

    cpu c(led, clk, rstn);

endmodule

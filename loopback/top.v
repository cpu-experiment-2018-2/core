module top (
	input wire rxd,
	output wire txd,
	input wire clk,
	input wire rstn);

	uart_loopback loopback(rxd, txd, clk, rstn);

endmodule

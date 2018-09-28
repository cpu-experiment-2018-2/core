module top (
     // AXI4-lite master memory interface
     // address read channel
     output wire [3:0]                axi_araddr,
     input wire                       axi_arready,
     output wire                      axi_arvalid,
     // address write channel
     output wire [3:0]                axi_awaddr,
     input wire                       axi_awready,
     output wire                      axi_awvalid,
     // response channel
     output wire                      axi_bready,
     input wire [1:0]                 axi_bresp,
     input wire                       axi_bvalid,
     // read data channel
     input wire [31:0]                axi_rdata,
     output wire                      axi_rready,
     input wire [1:0]                 axi_rresp,
     input wire                       axi_rvalid,
     // data write channel
     output wire [31:0]               axi_wdata,
     input wire                       axi_wready,
     output wire [3:0]                axi_wstrb,
     output wire                      axi_wvalid,

     output wire [7:0]                led,
     input wire [4:0]                 btn,
     input wire                       clk,
     input wire                       rstn);

     loopback l(axi_araddr, axi_arready, axi_arvalid,
	        axi_awaddr, axi_awready, axi_awvalid,
		axi_bready, axi_bresp, axi_bvalid,
		axi_rdata, axi_rready, axi_rresp, axi_rvalid,
		axi_wdata, axi_wready, axi_wstrb, axi_wvalid,
		led, btn, clk, rstn);

endmodule

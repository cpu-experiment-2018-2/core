module uart_sim(
    input  wire      rx,
    output wire      tx,

    input wire      clk,
    input wire      rstn);

	// AXI4-lite uart interface
	// address read channel
	wire [3:0]  uart_axi_araddr;
	wire        uart_axi_arready;
	wire        uart_axi_arvalid;
	// address write channel
	wire [3:0]  uart_axi_awaddr;
	wire        uart_axi_awready;
	wire        uart_axi_awvalid;
	// response channel
	wire        uart_axi_bready;
	wire [1:0]  uart_axi_bresp;
	wire        uart_axi_bvalid;
	// read data channel
	wire [31:0] uart_axi_rdata;
	wire        uart_axi_rready;
	wire [1:0]  uart_axi_rresp;
	wire        uart_axi_rvalid;
	// data write channel
	wire [31:0] uart_axi_wdata;
	wire        uart_axi_wready;
	wire [3:0]  uart_axi_wstrb;
	wire        uart_axi_wvalid;

    axi_uartlite_0 uart(    .s_axi_aclk(clk),
                            .s_axi_aresetn(rstn),
                            .s_axi_awaddr(uart_axi_awaddr),
                            .s_axi_awvalid(uart_axi_awvalid),
                            .s_axi_awready(uart_axi_awready),
                            .s_axi_wdata(uart_axi_wdata),
                            .s_axi_wstrb(uart_axi_wstrb),
                            .s_axi_wvalid(uart_axi_wvalid),
                            .s_axi_wready(uart_axi_wready),
                            .s_axi_bresp(uart_axi_bresp),
                            .s_axi_bvalid(uart_axi_bvalid),
                            .s_axi_bready(uart_axi_bready),
                            .s_axi_araddr(uart_axi_araddr),
                            .s_axi_arvalid(uart_axi_arvalid),
                            .s_axi_arready(uart_axi_arready),
                            .s_axi_rdata(uart_axi_rdata),
                            .s_axi_rresp(uart_axi_rresp),
                            .s_axi_rvalid(uart_axi_rvalid),
                            .s_axi_rready(uart_axi_rready),
                            .rx(rx),
                            .tx(tx));

    localparam RX_FIFO = 4'h0;
    localparam STAT_REG = 4'h8;
    reg [3:0]   uart_raddr;

    localparam TX_FIFO = 4'h4;
    localparam CTRL_REG = 4'hC;
    reg [3:0]   uart_waddr;

    reg         uart_ren;
    wire        uart_rbusy;
    wire        uart_rdone;
    wire [7:0]  uart_rdata;

    reg  [7:0]  uart_wdata;
    reg         uart_wen;
    wire        uart_wbusy;
    wire        uart_wdone;

    uart_rx u_rx(   .uart_axi_araddr(uart_axi_araddr),
                    .uart_axi_arready(uart_axi_arready),
                    .uart_axi_arvalid(uart_axi_arvalid),
                    .uart_axi_rdata(uart_axi_rdata),
                    .uart_axi_rready(uart_axi_rready),
                    .uart_axi_rresp(uart_axi_rresp),
                    .uart_axi_rvalid(uart_axi_rvalid),
                .addr(uart_raddr),
                .en(uart_ren),
                .clk(clk),
                .rstn(rstn),
                .data(uart_rdata),
                .busy(uart_rbusy),
                .done(uart_rdone));

    uart_tx u_tx(   .uart_axi_awaddr(uart_axi_awaddr),
                    .uart_axi_awready(uart_axi_awready),
                    .uart_axi_awvalid(uart_axi_awvalid),
                    .uart_axi_bready(uart_axi_bready),
                    .uart_axi_bresp(uart_axi_bresp),
                    .uart_axi_bvalid(uart_axi_bvalid),
                    .uart_axi_wdata(uart_axi_wdata),
                    .uart_axi_wready(uart_axi_wready),
                    .uart_axi_wstrb(uart_axi_wstrb),
                    .uart_axi_wvalid(uart_axi_wvalid),
                .data(uart_wdata),
                .addr(uart_waddr),
                .en(uart_wen),
                .clk(clk),
                .rstn(rstn),
                .busy(uart_wbusy),
                .done(uart_wdone));

    localparam WAIT_ST = 0;
    localparam CHECK_TX_ST = 1;
    localparam WRITE_ST = 2;
    reg [2:0]   state;

    reg [7:0]   data[0:1300];
    reg [10:0]  mem_addr;

    initial $readmemb("input.txt", data);

    always@(posedge clk) begin
        if (~rstn) begin
            mem_addr <= 11'b0;
            state <= WAIT_ST;
            uart_raddr <= STAT_REG;
            uart_ren <= 0;
        end else begin
            if (state == WAIT_ST) begin
                state <= CHECK_TX_ST;
                uart_ren <= 1;
                uart_wdata <= data[mem_addr];
            end else if (state == CHECK_TX_ST) begin
                if (uart_rdone) begin
                    // Tx FIFO Full flag
                    if (uart_rdata[3] == 0) begin
                        uart_wen <= 1;
                        uart_waddr <= TX_FIFO;
                        state <= WRITE_ST;
                    end else uart_ren <= 1;
                end else uart_ren <= 0;
            end else if (state == WRITE_ST) begin
                uart_wen <= 0;
                if (uart_wdone) begin
                    state <= WAIT_ST;
                    mem_addr = mem_addr + 1;
                end
            end
        end
    end

endmodule

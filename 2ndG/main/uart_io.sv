module uart_io (
    // read
    input  wire         ren,
    output reg  [7:0]   rdata,
    output reg          rbusy,
    output reg          rdone,

    // write
    input  wire         wen,
    input  wire [7:0]   wdata,
    output reg          wbusy,
    output reg          wdone,

    input  wire         rx,
    output wire         tx,

    input  wire         clk,
    input  wire         rstn);

    (* mark_debug = "true" *)reg  [7:0]  rfifo_din;
    (* mark_debug = "true" *)reg         rfifo_wen;
    (* mark_debug = "true" *)reg         rfifo_ren;
    (* mark_debug = "true" *)wire [7:0]  rfifo_dout;
    (* mark_debug = "true" *)wire        rfifo_full;
    (* mark_debug = "true" *)wire        rfifo_empty;

    (* mark_debug = "true" *)reg  [7:0]  wfifo_din;
    (* mark_debug = "true" *)reg         wfifo_wen;
    (* mark_debug = "true" *)reg         wfifo_ren;
    (* mark_debug = "true" *)wire [7:0]  wfifo_dout;
    (* mark_debug = "true" *)wire        wfifo_full;
    (* mark_debug = "true" *)wire        wfifo_empty;

    fifo_generator_0 rfifo( .clk(clk),
                            .srst(~rstn),
                            .din(rfifo_din),
                            .wr_en(rfifo_wen),
                            .rd_en(rfifo_ren),
                            .dout(rfifo_dout),
                            .full(rfifo_full),
                            .empty(rfifo_empty));

    fifo_generator_0 wfifo( .clk(clk),
                            .srst(~rstn),
                            .din(wfifo_din),
                            .wr_en(wfifo_wen),
                            .rd_en(wfifo_ren),
                            .dout(wfifo_dout),
                            .full(wfifo_full),
                            .empty(wfifo_empty));

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

	typedef enum logic [3:0] {
		RX_FIFO = 4'h0,
		STAT_REG = 4'h8
	} raddr_type;

	typedef enum logic [3:0] {
		TX_FIFO = 4'h4,
		CTRL_REG = 4'hC
	} waddr_type;

    (* mark_debug = "true" *)wire [7:0]  uart_rdata;
    (* mark_debug = "true" *)raddr_type  uart_raddr;
    (* mark_debug = "true" *)reg         uart_ren;
    (* mark_debug = "true" *)wire        uart_rbusy;
    (* mark_debug = "true" *)wire        uart_rdone;

    (* mark_debug = "true" *)reg  [7:0]  uart_wdata;
    (* mark_debug = "true" *)waddr_type  uart_waddr;
    (* mark_debug = "true" *)reg         uart_wen;
    (* mark_debug = "true" *)wire        uart_wbusy;
    (* mark_debug = "true" *)wire        uart_wdone;

    uart_rx u_rx( .*,
                .addr(uart_raddr),
                .en(uart_ren),
                .clk(clk),
                .rstn(rstn),
                .data(uart_rdata),
                .busy(uart_rbusy),
                .done(uart_rdone));

    uart_tx u_tx( .*,
                .data(uart_wdata),
                .addr(uart_waddr),
                .en(uart_wen),
                .clk(clk),
                .rstn(rstn),
                .busy(uart_wbusy),
                .done(uart_wdone));

    typedef enum logic [3:0] {
        WAIT_ST, CHECK_RX_ST, READ_ST, READ_END_ST, CHECK_TX_ST, WRITE_ST, WRITE_FIFO_ST, READ_FIFO_ST, READ_FIFO_RECIEVED_ST, READ_FIFO_END_ST
    } state_type;

    state_type state;

    always@(posedge clk) begin
        if (~rstn) begin
            rbusy <= 0;
            wbusy <= 0;
        end else begin
            if (ren) begin
                rbusy <= 1;
            end else if (rdone) begin
                rbusy <= 0;
            end
            if (wen) begin
                wbusy <= 1;
            end else if (wdone) begin
                wbusy <= 0;
            end
        end
    end

    always@(posedge clk) begin
        if (~rstn) begin
            state <= WAIT_ST;

            uart_ren <= 0;
            uart_raddr <= STAT_REG;
            uart_wen <= 0;
            uart_waddr <= TX_FIFO;

            wfifo_ren <= 0;
            wfifo_wen <= 0;
            rfifo_ren <= 0;
            rfifo_wen <= 0;

            rdone <= 0;
            wdone <= 0;
        end else begin
            if (state == WAIT_ST) begin
                uart_raddr <= STAT_REG;
                wfifo_wen <= 0;
                if (rbusy && ~rfifo_empty) begin
                    rfifo_ren <= 1;
                    state <= READ_FIFO_ST;
                end else if (wbusy && ~wfifo_full) begin
                    wdone <= 1;
                    state <= WRITE_FIFO_ST;
                end else if (~wfifo_empty && ~uart_rbusy) begin
                    uart_ren <= 1;
                    wfifo_ren <= 1;
                    state <= CHECK_TX_ST;
                end else if (~uart_rbusy) begin
                    uart_ren <= 1;
                    state <= CHECK_RX_ST;
                end
            end else if (state == CHECK_RX_ST) begin
                if (uart_rdone) begin
                    uart_ren <= 1;
                    // Rx FIFO Valid Data flag
                    if (uart_rdata[0]) begin
                        uart_raddr <= RX_FIFO;
                        state <= READ_ST;
                    end else state <= WAIT_ST;
                end else uart_ren <= 0;
            end else if (state == READ_ST) begin
                if (uart_rdone) begin
                    rfifo_din <= uart_rdata;
                    rfifo_wen <= 1;
                    state <= READ_END_ST;
                end else uart_ren <= 0;
            end else if (state == READ_END_ST) begin
                rfifo_wen <= 0;
                state <= WAIT_ST;
            end else if (state == CHECK_TX_ST) begin
                wfifo_ren <= 0;
                uart_wdata <= wfifo_dout;
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
                end
            end else if (state == WRITE_FIFO_ST) begin
                wdone <= 0;
                wfifo_din <= wdata;
                wfifo_wen <= 1;
                state <= WAIT_ST;
            end else if (state == READ_FIFO_ST) begin
                rfifo_ren <= 0;
                state <= READ_FIFO_RECIEVED_ST;
            end else if (state == READ_FIFO_RECIEVED_ST) begin
                rdone <= 1;
                rdata <= rfifo_dout;
                state <= READ_FIFO_END_ST;
            end else if (state == READ_FIFO_END_ST) begin
                rdone <= 0;
                state <= WAIT_ST;
            end
        end
    end
endmodule

`default_nettype none

module uart_rx #(CLK_PER_HALF_BIT = 5208) (
               output logic [7:0] rdata,
               output logic       rdata_ready,
               output logic       ferr,
               input wire         rxd,
               input wire         clk,
               input wire         rstn);

   localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;

   logic [3:0]                  status;
   logic [31:0]                 counter;
   logic                        next;
   logic                        rst_ctr;

   localparam s_idle = 0;
   localparam s_start_bit = 1;
   localparam s_bit_0 = 2;
   localparam s_bit_1 = 3;
   localparam s_bit_2 = 4;
   localparam s_bit_3 = 5;
   localparam s_bit_4 = 6;
   localparam s_bit_5 = 7;
   localparam s_bit_6 = 8;
   localparam s_bit_7 = 9;
   localparam s_stop_bit = 10;

   always @(posedge clk) begin
      if (~rstn) begin
	 counter <= 0;
      end else begin
         if (status == s_start_bit && counter == CLK_PER_HALF_BIT) begin
            status <= s_bit_0;
	    counter <= 0;
	 end else if (counter == e_clk_bit || rst_ctr) begin
            counter <= 0;
	 end else begin
	    counter <= counter + 1;
	 end
	 if (~rst_ctr && counter == e_clk_bit) begin
	    next <= 1;
         end else begin
            next <= 0;
         end
      end

      if (~rstn) begin
	 status <= s_idle;
	 rst_ctr <= 0;
         rdata <= 8'b0;
         rdata_ready <= 1'b0;
         ferr <= 1'b0;
      end else begin
	 rst_ctr <= 0;

	 if (status == s_idle) begin
            rdata_ready <= 1'b0;
            if (~rxd) begin
               status <= s_start_bit;
	       rst_ctr <= 1;
            end
	 end else if (status == s_stop_bit) begin
            if (next) begin
               if (~rxd) begin
                  ferr <= 1;
               end
	       status <= s_idle;
	       rdata_ready <= 1'b1;
            end
         end else if (next) begin
            if (status == s_bit_7) begin
               rdata[7] <= rxd;
	       status <= s_stop_bit;
            end else begin
               rdata[status-2] <= rxd;
	       status <= status + 1;
            end
         end
      end
   end
endmodule
`default_nettype wire

module writeback (
    input  wire         interlock,

    gpr_if              gpr,

    // input
    //
    input  wire        [63:0]   inst,
    // Upper
    input  wire signed [31:0]   u_tdata,
    input  wire        [4:0]    u_rt,
    input  wire                 u_rt_flag,
    // Lower
    input  wire signed [31:0]   l_tdata,
    input  wire        [4:0]    l_rt,
    input  wire                 l_rt_flag,

    input  wire         clk,
    input  wire         rstn);

    always@(posedge clk) begin
        if (~rstn) begin
        end else if (~interlock) begin
            if (u_rt_flag) gpr.gpr[u_rt] <= u_tdata;
            if (l_rt_flag) gpr.gpr[l_rt] <= l_tdata;
        end
    end

endmodule

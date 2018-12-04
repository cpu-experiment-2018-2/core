module exec (
    input  wire         interlock,
    input  wire         exec_stall,
    output reg          ex_to_mem_ready,

    // input
    //
    input  wire        [63:0]   inst,
    // Upper ([63:32])
    input  wire signed [31:0]   u_srca,
    input  wire signed [31:0]   u_srcb,
    input  wire signed [31:0]   u_srcs,
    input  wire        [3:0]    u_e_type,
    input  wire        [4:0]    u_rt,
    input  wire                 u_rt_flag,

    // Lower ([31:0])
    input  wire signed [31:0]   l_srca,
    input  wire signed [31:0]   l_srcb,
    input  wire signed [31:0]   l_srcs,
    input  wire        [3:0]    l_e_type,
    input  wire        [4:0]    l_rt,
    input  wire                 l_rt_flag,

    // output
    //
    output reg         [63:0]   inst_to_the_next,
    // Upper
    output reg  signed [31:0]   u_tdata,
    output reg         [4:0]    u_rt_to_the_next,
    output reg                  u_rt_flag_to_the_next,

    // Lower
    output reg  signed [31:0]   l_tdata,
    output reg         [4:0]    l_rt_to_the_next,
    output reg                  l_rt_flag_to_the_next,


    input  wire         clk,
    input  wire         rstn);


    typedef enum logic [3:0] {
        ENop = 4'b0000,
        EAdd = 4'b0001,
        ESub = 4'b0010, 
        ERshift = 4'b0011,
        ELshift = 4'b0100
    } exec_type;

    function [31:0] EXEC (
        input [31:0] SRCA,
        input [31:0] SRCB,
        input [3:0]  TYPE
    );
        case (TYPE)
            ENop    : EXEC = SRCB;
            EAdd    : EXEC = $signed(SRCA) + $signed(SRCB);
            ESub    : EXEC = $signed(SRCA) - $signed(SRCB);
            ERshift : EXEC = SRCA >>> $signed(SRCB);
            ELshift : EXEC = SRCA <<< $signed(SRCB);
            default : EXEC = SRCB;
        endcase
    endfunction

    always@(posedge clk) begin
        if (~rstn) begin
            ex_to_mem_ready <= 0;
            u_rt_flag_to_the_next <= 0;
            l_rt_flag_to_the_next <= 0;
        end else if (~exec_stall && ~interlock) begin
            inst_to_the_next <= inst;
            if (inst[63:58] == 6'b010000) ex_to_mem_ready <= 1; // Load
            else ex_to_mem_ready <= 0;

            u_tdata <= EXEC(u_srca, u_srcb, u_e_type);
            u_rt_to_the_next <= u_rt;
            u_rt_flag_to_the_next <= u_rt_flag;

            l_tdata <= EXEC(l_srca, l_srcb, l_e_type);
            l_rt_to_the_next <= l_rt;
            l_rt_flag_to_the_next <= l_rt_flag;

        end else begin
            ex_to_mem_ready <= 0;
            inst_to_the_next <= {3'b111, 29'b0, 3'b111, 29'b0};
            u_rt_flag_to_the_next <= 0;
            l_rt_flag_to_the_next <= 0;
        end
    end

endmodule

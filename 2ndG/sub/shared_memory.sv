module shared_memory (
    input  wire         mem_req_now     [0:3],
    input  data_in      u_data_ins      [0:3],
    input  data_in      l_data_ins      [0:3],

    output wire         mem_wait        [0:3],
    output wire [31:0]  u_data_outs     [0:3],
    output wire [31:0]  l_data_outs     [0:3],

    input  wire     clk,
    input  wire     rstn);

    // Memory Access Process
    //===========
    // Pattern 1
    //===========
    //           | id  | ex  | mem | mem | wb  |
    // Core1
    // interlock _______________________________
    // mem_req   |^^^^^|________________________
    // mem_wait  _______________________________
    // mem_waited_______________________________
    // mem_reqed |^^^^^|________________________
    // addr      ______|^^^^^|__________________
    // n_addr    _________|^^^^^|_______________
    // BRAM                     |---->
    // n_doutb   _____________________|^^^^^|___
    // mem_doutb ________________________|^^^^^|
    //
    // Core 2
    // interlock ______|^^^^^|__________________
    // mem_req   |^^^^^|________________________
    // mem_wait  |^^^^^|________________________
    // mem_waited______|^^^^^|__________________
    // mem_reqed |^^^^^^^^^^^|__________________
    // addr      ______|^^^^^^^^^^^|____________
    // n_addr    _______________|^^^^^|_________
    // BRAM                           |---->
    // n_doutb   ___________________________|^^^
    //
    // Core 3
    // interlock ______|^^^^^^^^^^^|____________
    // mem_req   |^^^^^|________________________
    // mem_wait  |^^^^^^^^^^^|__________________
    // mem_waited______|^^^^^^^^^^^|____________
    // mem_reqed |^^^^^^^^^^^^^^^^^|____________
    // addr      ______|^^^^^^^^^^^^^^^^^|______
    // n_addr    _____________________|^^^^^|___
    // BRAM                                 |---
    
    //===========
    // Pattern 2
    //===========
    // Core1
    // interlock _______________________________
    // mem_req   |^^^^^|_____|^^^^^|____________
    // mem_wait  _______________________________
    // mem_waited_______________________________
    // mem_reqed |^^^^^|_____|^^^^^|____________
    // addr      ______|^^^^^|__________________
    // n_addr    _________|^^^^^|_______________
    // BRAM                     |---->
    // n_doutb   _____________________|^^^^^|___
    // mem_doutb ________________________|^^^^^|
    //
    // Core 2
    // interlock ______|^^^^^|__________________
    // mem_req   |^^^^^|________________________
    // mem_wait  |^^^^^|________________________
    // mem_waited______|^^^^^|__________________
    // mem_reqed |^^^^^^^^^^^|__________________
    // addr      ______|^^^^^^^^^^^|____________
    // n_addr    _______________|^^^^^|_________
    // BRAM                           |---->
    // n_doutb   ___________________________|^^^
    //
    // Core 3
    // interlock ______|^^^^^^^^^^^^^^^^^|______
    // mem_req   |^^^^^|________________________
    // mem_wait  |^^^^^^^^^^^^^^^^^|____________
    // mem_waited______|^^^^^^^^^^^^^^^^^|______
    // mem_reqed |^^^^^^^^^^^^^^^^^^^^^^^|______
    // addr      ______|^^^^^^^^^^^^^^^^^^^^^^^|

    //===========
    // Pattern 3
    //===========
    // Core1
    // interlock _______________________________
    // mem_req   |^^^^^|_____|^^^^^|____________
    // mem_wait  _______________________________
    // mem_waited_______________________________
    // mem_reqed |^^^^^|_____|^^^^^|____________
    // addr      ______|^^^^^|__________________
    // n_addr    _________|^^^^^|_____|^^^^^|___
    // BRAM                     |---->      |---
    // n_doutb   _____________________|^^^^^|___
    // mem_doutb ________________________|^^^^^|
    //
    // Core 2
    //           |DDDDD|     |EEEEE|     |MMMMM|MMMMM|WWWWW|
    // interlock ______|^^^^^|_____|^^^^^|______
    // mem_req   |^^^^^|_____|^^^^^|____________
    // mem_wait  |^^^^^|_____|^^^^^|____________
    // mem_waited______|^^^^^|_____|^^^^^|______
    // mem_reqed |^^^^^^^^^^^^^^^^^^^^^^^|______
    // addr      ______|^^^^^^^^^^^|____________
    //           __________________|^^^^^^^^^^^|
    // n_addr    _______________|^^^^^|_____|^^^
    // BRAM                           |---->
    // n_doutb   ___________________________|^^^^^|
    // mem_doutb ______________________________|^^^^^|

    reg         mem_waited      [0:3];
    wire        mem_requested   [0:3];
    assign mem_requested[0] = mem_req_now[0] | mem_waited[0];
    assign mem_requested[1] = mem_req_now[1] | mem_waited[1];
    assign mem_requested[2] = mem_req_now[2] | mem_waited[2];
    assign mem_requested[3] = mem_req_now[3] | mem_waited[3];

    assign mem_wait[0] = 0;
    assign mem_wait[1] = mem_requested[1] ? mem_requested[0];
    assign mem_wait[2] = mem_requested[2] ? mem_requested[0] | mem_requested[1];
    assign mem_wait[3] = mem_requested[3] ? mem_requested[0] | mem_requested[1] | mem_requested[2];

    always@(posedge clk) begin
        if (~rstn) begin
            for (int i = 0; i < 4; i++) mem_waited[i] <= 0;
        end else begin
            for (int i = 0; i < 4; i++) mem_waited[i] <= mem_wait[i];
        end
    end


    data_in u_data_in;
    data_in l_data_in;
    wire [31:0] douta;
    wire [31:0] doutb;
    data_in n_u_data_in;
    data_in n_l_data_in;
    reg  [31:0] n_doutas [0:3];
    reg  [31:0] n_doutbs [0:3];
    reg  [1:0]  new_idx [0:3];
    reg  [3:0]  output_idx [0:3];
    reg  [3:0]  valid_idx [0:3];
    reg  [1:0]  n_core;
    reg         n_valid;
    reg  [1:0]  bram_core;

    blk_mem_gen_0 data_ram( .addra(n_u_data_in.addr),
                            .clka(~clk),
                            .dina(n_u_data_in.din),
                            .douta(douta),
                            .wea(n_u_data_in.we),
                            .addrb(n_l_data_in.addr),
                            .clkb(~clk),
                            .dinb(n_l_data_in.din),
                            
    always@(posedge clk) begin
        if (~rstn) begin
            for (int i = 0; i < 3; i++) begin
                u_data_outs[i] <= 32'b0;
                l_data_outs[i] <= 32'b0;
                n_doutas[i] <= 32'b0;
                n_doutbs[i] <= 32'b0;
                new_idx[i] <= 2'b0;
                output_idx[i] <= 4'b0;
                valid_idx[i] <= 4'b0;
            end
            new_idx <= 2'b0;
            output_idx <= 2'b0;
        end else begin
            if (mem_requested[0]) begin
                u_data_in = u_data_ins[0];
                l_data_in = l_data_ins[0];
                n_core <= 0;
                n_valid <= 1;
            end else if (mem_requested[1]) begin
                u_data_in = u_data_ins[1];
                l_data_in = l_data_ins[1];
                n_core <= 1;
                n_valid <= 1;
            end else if (mem_requested[2]) begin
                u_data_in = u_data_ins[2];
                l_data_in = l_data_ins[2];
                n_core <= 2;
                n_valid <= 1;
            end else if (mem_requested[3]) begin
                u_data_in = u_data_ins[3];
                l_data_in = l_data_ins[3];
                n_core <= 3;
                n_valid <= 1;
            end else begin
                u_data_in.we <= 0;
                l_data_in.we <= 0;
                n_valid <= 0;
            end
        end
    end

    always@(negedge clk) begin
        if (~rstn) begin
            n_u_data_in.we <= 0;
            n_l_data_in.we <= 0;
        end else begin
            n_u_data_in <= u_data_in;
            n_l_data_in <= n_data_in;
        end
    end

endmodule

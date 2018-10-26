module fsub(
  input wire        en,
  input wire [31:0] adata,
  input wire [31:0] bdata,
  output reg [31:0] result,
  output reg        done,
  output reg        busy,
  input wire        clk,
  input wire        rstn);

//WAIT_ST
reg [31:0] wadata;
reg [31:0] wbdata;

//STAGE1
reg        s1;
reg [7:0]  e1;
reg [24:0] deka;
reg [24:0] chibi;
reg tashi1hiki0;
reg whiseiki1;

//STAGE2
reg [24:0] kekka;
reg        s2;
reg [7:0]  e2;
reg whiseiki2;


typedef enum logic [2:0] {
  WAIT_ST,STAGE1,STAGE2,STAGE3
} state_type;
state_type state;

always@(posedge clk) begin
  if (~rstn) begin
    result <= 0;
    done   <= 0;
    busy   <= 0;
    state  <= WAIT_ST;
  end else if (state == WAIT_ST) begin
    done <= 0;
    if (en) begin
      state <= STAGE1;
      busy <= 1;
      wadata <= adata;
      wbdata <= {~bdata[31],bdata[30:0]};
    end
  end else if (state == STAGE1) begin
    state <= STAGE2;
    whiseiki1 <= (wadata[30:23] == 0 && wbdata[30:23] == 0) ? 1 : 0;
    if (wadata[31] == wbdata[31]) begin
      tashi1hiki0 <= 1;
    end else begin
      tashi1hiki0 <= 0;
    end
    if ((wadata[30:23] > wbdata[30:23]) || ((wadata[30:23] == wbdata[30:23]) && (wadata[22:0] >= wbdata[22:0]))) begin
      s1 <= wadata[31];
      e1 <= wadata[30:23];
      deka <= (wadata[30:23] == 0) ? {2'b0,wadata[22:0]} : {1'b0,1'b1,wadata[22:0]};
      chibi <= (wbdata[30:23] == 0) ? ({2'b0,wbdata[22:0]} >> (wadata[30:23] - wbdata[30:23])) : ({1'b0,1'b1,wbdata[22:0]} >> (wadata[30:23] - wbdata[30:23]));
    end else begin
      s1 <= wbdata[31];
      e1 <= wbdata[30:23];
      deka <= (wbdata[30:23] == 0) ? {2'b0,wbdata[22:0]} : {1'b0,1'b1,wbdata[22:0]};
      chibi <= (wadata[30:23] == 0) ? ({2'b0,wadata[22:0]} >> (wbdata[30:23] - wadata[30:23])) : ({1'b0,1'b1,wadata[22:0]} >> (wbdata[30:23] - wadata[30:23]));
    end
  end else if (state == STAGE2) begin
    state <= STAGE3;
    whiseiki2 <= whiseiki1;
    s2 <= s1;
    e2 <= e1;
    if (tashi1hiki0 == 1) begin
      kekka <= deka[24:0] + chibi[24:0];
    end else begin
      kekka <= deka[24:0] - chibi[24:0];
    end
  end else if (state == STAGE3) begin
    done <= 1;
    busy <= 0;
    state <= WAIT_ST;
    if (kekka[24] == 1) begin
      result <= {s2,e2[7:0]+8'd1,kekka[23:1]};
    end else if (kekka[23] == 1) begin
      result <= (whiseiki2 == 1) ? {s2,e2[7:0]+8'b1,kekka[22:0]} : {s2,e2[7:0],kekka[22:0]};
    end else if (kekka[22] == 1) begin
      result <= (e2 < 1) ? 0 : {s2,e2[7:0]-8'd1,kekka[21:0],1'b0};
    end else if (kekka[21] == 1) begin
      result <= (e2 < 2) ? 0 : {s2,e2[7:0]-8'd2,kekka[20:0],2'b0};
    end else if (kekka[20] == 1) begin
      result <= (e2 < 3) ? 0 : {s2,e2[7:0]-8'd3,kekka[19:0],3'b0};
    end else if (kekka[19] == 1) begin
      result <= (e2 < 4) ? 0 : {s2,e2[7:0]-8'd4,kekka[18:0],4'b0};
    end else if (kekka[18] == 1) begin
      result <= (e2 < 5) ? 0 : {s2,e2[7:0]-8'd5,kekka[17:0],5'b0};
    end else if (kekka[17] == 1) begin
      result <= (e2 < 6) ? 0 : {s2,e2[7:0]-8'd6,kekka[16:0],6'b0};
    end else if (kekka[16] == 1) begin
      result <= (e2 < 7) ? 0 : {s2,e2[7:0]-8'd7,kekka[15:0],7'b0};
    end else if (kekka[15] == 1) begin
      result <= (e2 < 8) ? 0 : {s2,e2[7:0]-8'd8,kekka[14:0],8'b0};
    end else if (kekka[14] == 1) begin
      result <= (e2 < 9) ? 0 : {s2,e2[7:0]-8'd9,kekka[13:0],9'b0};
    end else if (kekka[13] == 1) begin
      result <= (e2 < 10) ? 0 : {s2,e2[7:0]-8'd10,kekka[12:0],10'b0};
    end else if (kekka[12] == 1) begin
      result <= (e2 < 11) ? 0 : {s2,e2[7:0]-8'd11,kekka[11:0],11'b0};
    end else if (kekka[11] == 1) begin
      result <= (e2 < 12) ? 0 : {s2,e2[7:0]-8'd12,kekka[10:0],12'b0};
    end else if (kekka[10] == 1) begin
      result <= (e2 < 13) ? 0 : {s2,e2[7:0]-8'd13,kekka[9:0],13'b0};
    end else if (kekka[9] == 1) begin
      result <= (e2 < 14) ? 0 : {s2,e2[7:0]-8'd14,kekka[8:0],14'b0};
    end else if (kekka[8] == 1) begin
      result <= (e2 < 15) ? 0 : {s2,e2[7:0]-8'd15,kekka[7:0],15'b0};
    end else if (kekka[7] == 1) begin
      result <= (e2 < 16) ? 0 : {s2,e2[7:0]-8'd16,kekka[6:0],16'b0};
    end else if (kekka[6] == 1) begin
      result <= (e2 < 17) ? 0 : {s2,e2[7:0]-8'd17,kekka[5:0],17'b0};
    end else if (kekka[5] == 1) begin
      result <= (e2 < 18) ? 0 : {s2,e2[7:0]-8'd18,kekka[4:0],18'b0};
    end else if (kekka[4] == 1) begin
      result <= (e2 < 19) ? 0 : {s2,e2[7:0]-8'd19,kekka[3:0],19'b0};
    end else if (kekka[3] == 1) begin
      result <= (e2 < 20) ? 0 : {s2,e2[7:0]-8'd20,kekka[2:0],20'b0};
    end else if (kekka[2] == 1) begin
      result <= (e2 < 21) ? 0 : {s2,e2[7:0]-8'd21,kekka[1:0],21'b0};
    end else if (kekka[1] == 1) begin
      result <= (e2 < 22) ? 0 : {s2,e2[7:0]-8'd22,kekka[0:0],22'b0};
    end else if (kekka[0] == 1) begin
      result <= (e2 < 23) ? 0 : {s2,e2[7:0]-8'd23,23'b0};
    end else begin
      result <= 0;
    end
  end
end
endmodule

`default_nettype wire







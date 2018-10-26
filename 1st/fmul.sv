module fmul(
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
reg [8:0]  e1;
reg [24:0] adata1;
reg [24:0] bdata1;
reg [8:0]  esyuuseia;
reg [8:0]  esyuuseib;

//STAGE2
reg [47:0] kekka;
reg        s2;
reg [8:0]  e2;
reg underflow;

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
      wbdata <= bdata;
    end
  end else if (state == STAGE1) begin
    state <= STAGE2;
    s1 <= wadata[31] ^ wbdata[31];
    e1 <= wadata[30:23] + wbdata[30:23];
    if (wadata[30:23] == 0) begin
      if (wadata[22] == 1) begin
	esyuuseia <= 0;
	adata1 <= {wadata[22:0],1'b0};
      end else if (wadata[21] == 1) begin
	esyuuseia <= 1;
	adata1 <= {wadata[21:0],2'b0};
      end else if (wadata[20] == 1) begin
	esyuuseia <= 2;
	adata1 <= {wadata[20:0],3'b0};
      end else if (wadata[19] == 1) begin
	esyuuseia <= 3;
	adata1 <= {wadata[19:0],4'b0};
      end else if (wadata[18] == 1) begin
	esyuuseia <= 4;
	adata1 <= {wadata[18:0],5'b0};
      end else if (wadata[17] == 1) begin
	esyuuseia <= 5;
	adata1 <= {wadata[17:0],6'b0};
      end else if (wadata[16] == 1) begin
	esyuuseia <= 6;
	adata1 <= {wadata[16:0],7'b0};
      end else if (wadata[15] == 1) begin
	esyuuseia <= 7;
	adata1 <= {wadata[15:0],8'b0};
      end else if (wadata[14] == 1) begin
	esyuuseia <= 8;
	adata1 <= {wadata[14:0],9'b0};
      end else if (wadata[13] == 1) begin
	esyuuseia <= 9;
	adata1 <= {wadata[13:0],10'b0};
      end else if (wadata[12] == 1) begin
	esyuuseia <= 10;
	adata1 <= {wadata[12:0],11'b0};
      end else if (wadata[11] == 1) begin
	esyuuseia <= 11;
	adata1 <= {wadata[11:0],12'b0};
      end else if (wadata[10] == 1) begin
	esyuuseia <= 12;
	adata1 <= {wadata[10:0],13'b0};
      end else if (wadata[9] == 1) begin
	esyuuseia <= 13;
	adata1 <= {wadata[9:0],14'b0};
      end else if (wadata[8] == 1) begin
	esyuuseia <= 14;
	adata1 <= {wadata[8:0],15'b0};
      end else if (wadata[7] == 1) begin
	esyuuseia <= 15;
	adata1 <= {wadata[7:0],16'b0};
      end else if (wadata[6] == 1) begin
	esyuuseia <= 16;
	adata1 <= {wadata[6:0],17'b0};
      end else if (wadata[5] == 1) begin
	esyuuseia <= 17;
	adata1 <= {wadata[5:0],18'b0};
      end else if (wadata[4] == 1) begin
	esyuuseia <= 18;
	adata1 <= {wadata[4:0],19'b0};
      end else if (wadata[3] == 1) begin
	esyuuseia <= 19;
	adata1 <= {wadata[3:0],20'b0};
      end else if (wadata[2] == 1) begin
	esyuuseia <= 20;
	adata1 <= {wadata[2:0],21'b0};
      end else if (wadata[1] == 1) begin
	esyuuseia <= 21;
	adata1 <= {wadata[1:0],22'b0};
      end else if (wadata[0] == 1) begin
	esyuuseia <= 22;
	adata1 <= {1'b1,23'b0};
      end else begin
	esyuuseia <= 23;
	adata1 <= 0;
      end
    end else begin
      esyuuseia <= 0;
      adata1 <= {1'b1,wadata[22:0]};
    end
    if (wbdata[30:23] == 0) begin
      if (wbdata[22] == 1) begin
	esyuuseib <= 0;
	bdata1 <= {wbdata[22:0],1'b0};
      end else if (wbdata[21] == 1) begin
	esyuuseib <= 1;
	bdata1 <= {wbdata[21:0],2'b0};
      end else if (wbdata[20] == 1) begin
	esyuuseib <= 2;
	bdata1 <= {wbdata[20:0],3'b0};
      end else if (wbdata[19] == 1) begin
	esyuuseib <= 3;
	bdata1 <= {wbdata[19:0],4'b0};
      end else if (wbdata[18] == 1) begin
	esyuuseib <= 4;
	bdata1 <= {wbdata[18:0],5'b0};
      end else if (wbdata[17] == 1) begin
	esyuuseib <= 5;
	bdata1 <= {wbdata[17:0],6'b0};
      end else if (wbdata[16] == 1) begin
	esyuuseib <= 6;
	bdata1 <= {wbdata[16:0],7'b0};
      end else if (wbdata[15] == 1) begin
	esyuuseib <= 7;
	bdata1 <= {wbdata[15:0],8'b0};
      end else if (wbdata[14] == 1) begin
	esyuuseib <= 8;
	bdata1 <= {wbdata[14:0],9'b0};
      end else if (wbdata[13] == 1) begin
	esyuuseib <= 9;
	bdata1 <= {wbdata[13:0],10'b0};
      end else if (wbdata[12] == 1) begin
	esyuuseib <= 10;
	bdata1 <= {wbdata[12:0],11'b0};
      end else if (wbdata[11] == 1) begin
	esyuuseib <= 11;
	bdata1 <= {wbdata[11:0],12'b0};
      end else if (wbdata[10] == 1) begin
	esyuuseib <= 12;
	bdata1 <= {wbdata[10:0],13'b0};
      end else if (wbdata[9] == 1) begin
	esyuuseib <= 13;
	bdata1 <= {wbdata[9:0],14'b0};
      end else if (wbdata[8] == 1) begin
	esyuuseib <= 14;
	bdata1 <= {wbdata[8:0],15'b0};
      end else if (wbdata[7] == 1) begin
	esyuuseib <= 15;
	bdata1 <= {wbdata[7:0],16'b0};
      end else if (wbdata[6] == 1) begin
	esyuuseib <= 16;
	bdata1 <= {wbdata[6:0],17'b0};
      end else if (wbdata[5] == 1) begin
	esyuuseib <= 17;
	bdata1 <= {wbdata[5:0],18'b0};
      end else if (wbdata[4] == 1) begin
	esyuuseib <= 18;
	bdata1 <= {wbdata[4:0],19'b0};
      end else if (wbdata[3] == 1) begin
	esyuuseib <= 19;
	bdata1 <= {wbdata[3:0],20'b0};
      end else if (wbdata[2] == 1) begin
	esyuuseib <= 20;
	bdata1 <= {wbdata[2:0],21'b0};
      end else if (wbdata[1] == 1) begin
	esyuuseib <= 21;
	bdata1 <= {wbdata[1:0],22'b0};
      end else if (wbdata[0] == 1) begin
	esyuuseib <= 22;
	bdata1 <= {1'b1,23'b0};
      end else begin
	esyuuseib <= 23;
	bdata1 <= 0;
      end
    end else begin
      esyuuseib <= 0;
      bdata1 <= {1'b1,wbdata[22:0]};
    end





  end else if (state == STAGE2) begin
    state <= STAGE3;
    s2 <= s1;
    e2 <= e1 - 9'd127 - esyuuseia - esyuuseib;
    underflow <= (esyuuseia == 23 || esyuuseib == 23 || (e1 < (127 + esyuuseia + esyuuseib))) ? 1 : 0;
    kekka <= adata1 * bdata1;
  end else if (state == STAGE3) begin
    done <= 1;
    busy <= 0;
    state <= WAIT_ST;
    if (underflow == 1) begin
      result <= 32'b0;
    end else if (kekka[47] == 1) begin
      result <= {s2,e2[7:0]+8'd1,kekka[46:24]};
    end else begin
      result <= (e2 == 0) ? {s2,8'b0,kekka[46:24]} : {s2,e2[7:0],kekka[45:23]};
    end
  end
end
endmodule

`default_nettype wire







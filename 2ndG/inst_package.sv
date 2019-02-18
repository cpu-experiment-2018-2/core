package inst_package;
    typedef enum logic [3:0] {
        ENop = 4'b0000,
        EAdd = 4'b0001,
        ESub = 4'b0010, 
        ERshift = 4'b0011,
        ELshift = 4'b0100,
        EXor = 4'b0101,
        EAnd = 4'b0110,
        EFadd = 4'b0111,
        EFsub = 4'b1000,
        EFmul = 4'b1001,
        EFdiv = 4'b1010,
        EFsqrt = 4'b1011,
        EFtoi = 4'b1100,
        EItof = 4'b1101
    } exec_type;

    parameter Addi = 6'b000000;
    parameter Subi = 6'b000001;
    parameter Add  = 6'b000010;
    parameter Sub  = 6'b000011;
    parameter Srawi= 6'b000100;
    parameter Slawi= 6'b000101;
    parameter Xor  = 6'b000110;
    parameter And  = 6'b000111;

    parameter Fadd = 6'b001000;
    parameter Fsub = 6'b001001;
    parameter Fmul = 6'b001010;
    parameter Fdiv = 6'b001011;
    parameter Ftoi = 6'b001100;
    parameter Itof = 6'b001101;
    parameter Fsqrt= 6'b001110;

    parameter Load = 6'b010000;
    parameter Store= 6'b010001;
    parameter Li   = 6'b010010;
    parameter Liw  = 6'b010011;

    parameter Jump = 6'b011000;
    parameter Blr  = 6'b011001;
    parameter Bl   = 6'b011010;
    parameter Blrr = 6'b011011;
    parameter Cmpd = 6'b011100;
    parameter Cmpf = 6'b011101;
    parameter Cmpdi= 6'b011110;

    parameter Beq  = 6'b100000;
    parameter Ble  = 6'b100001;
    parameter Blt  = 6'b100010;
    parameter Bne  = 6'b100011;
    parameter Bge  = 6'b100100;
    parameter Bgt  = 6'b100101;

    parameter Inll = 6'b101000;
    parameter Inlh = 6'b101001;
    parameter Inul = 6'b101010;
    parameter Inuh = 6'b101011;
    parameter Outll= 6'b101100;

    parameter Nop  = 6'b111000;
    parameter End  = 6'b111001;
    parameter Fork = 6'b111010;
    parameter Join = 6'b111011;
    parameter Fetch= 6'b111100;


    parameter DATA_MEM_DEPTH = 120000;
    parameter INST_MAIN_DEPTH = 32768;
    parameter INST_SUB_DEPTH = 8192;
    parameter SUBCORE_NUM = 4;


    typedef struct {
        logic [31:0] addr;
        logic [31:0] din;
        logic [3:0]  we;
    } data_in;
endpackage

`timescale 1ns/1ns

module datapath_tb();
// ... (Khai báo tất cả logic/signal như bạn đã làm, đã sửa 'logic Data_Writeback' thành 'logic [31:0] Data_Writeback')
logic i_clk;
logic i_reset;
logic PCSel;
logic [3:0] ImmSel;
logic RegWen;
logic BrUn;
logic BSel;
logic ASel;
logic [1:0] ALU_op;
logic [3:0] LoadType;
logic LoadSigned;
logic MemRW;
logic [1:0] WBSel;
logic [31:0] i_io_sw;
logic [31:0] o_ld_data;
logic [31:0] o_io_ledr;
logic [31:0] o_io_ledg;
logic [31:0] o_io_lcd;
logic [31:0] o_io_hex03;
logic [31:0] o_io_hex47;
logic [31:0] o_pc_debug;
logic [31:0] instr;
logic BrLT;
logic BrEQ;
logic [31:0] Data_Writeback; // Đã sửa kích thước
logic [31:0] PC_OUT; // Biến kết nối với pc_out mới
logic LUI_Sel;

datapath DUT (
.i_clk(i_clk),
.i_reset(i_reset),
.PCSel(PCSel),
.ImmSel(ImmSel),
.RegWen(RegWen),
.instr(instr),
.ASel(ASel),
.BSel(BSel),
.BrUn(BrUn),
.ALU_op(ALU_op),
.LoadType(LoadType),
.LoadSigned(LoadSigned),
.MemRW(MemRW),
.i_io_sw(i_io_sw),
.o_ld_data(o_ld_data),
.o_io_ledr(o_io_ledr),
.o_io_ledg(o_io_ledg),
.o_io_lcd(o_io_lcd),
.o_io_hex03(o_io_hex03),
.o_io_hex47(o_io_hex47),
.o_pc_debug(o_pc_debug),
.WBSel(WBSel),
.BrLT(BrLT),
.BrEQ(BrEQ),
.LUI_Sel(LUI_Sel),
.data_writeback(Data_Writeback) // Cổng output mới
);


initial begin
i_clk = 0;
forever begin 
    #5 i_clk = ~i_clk;
end
end


initial begin
    // Cài đặt mặc định
    i_io_sw = 32'h0;
    MemRW = 1'b0;
    LoadSigned = 1'b0;
    LoadType = 4'b0;
    BrUn = 1'b0; 
    PCSel = 1'b0;
    LUI_Sel = 1'b0;
    // 1. Kích hoạt và thoát Reset (PC -> 0x00000000)
    i_reset = 1'b1;
    @(posedge i_clk); 
    i_reset = 1'b0; 
    #5
    // PC_OUT lúc này là 0x0. instr là lệnh đầu tiên (0x00A00093).
    $display("--- Start Simulation ---");


//------------------------------LỆNH 1: ADDI x1, x0, 10 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; // I_Format
    RegWen = 1'b1;
    ASel = 1'b0; // ALU A = RS1 (x0)
    BSel = 1'b1; // ALU B = Immediate (10)
    ALU_op = 2'b01; // ADD
    WBSel = 2'b01; // WB = ALU Out

    @(posedge i_clk); // Ghi x1 = 10. PC_OUT -> 0x0.
    $display("ADDI x1, x0, 10");
    $display("Cycle 1 | PC: %h | Instruction %h | WB Value: %d (Expected: 10)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");

//------------------------------LỆNH 2: ADDI x2, x0, 20 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; 
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x2 = 20. PC_OUT -> 0x4
    $display("ADDI x2, x0, 20");
    $display("Cycle 2 | PC: %h | Instruction %h | WB Value: %d (Expected: 20)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");

    
//------------------------------LỆNH 3: ADD x3, x1, x2 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2 (R-Type)
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x3 = 30. PC_OUT -> 0x8
    $display("ADD x3, x1, x2");
    $display("Cycle 3 | PC: %h | Instruction %h | WB Value: %d (Expected: 30)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 4: ADD x4, x3, x3 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2 (R-Type)
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x4 = 60. PC_OUT -> 0xC.
    $display("ADD x4, x3, x3");
    $display("Cycle 4 | PC: %h | Instruction %h | WB Value: %d (Expected: 60)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 5: SUB x5, x3, x1 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2 (R-Type)
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x5 = 50. PC_OUT -> 0x10.
    $display("SUB x5, x3, x1");
    $display("Cycle 5 | PC: %h | Instruction %h | WB Value: %d (Expected: 50)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 6: ADDI x7, x0, 0xA ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm (I-Type)
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x7 = 0x0A. PC_OUT -> 0x14.
    $display("ADDI x7, x0, 0xA");
    $display("Cycle 6 | PC: %h | Instruction %h | WB Value: %d (Expected: 10)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 7: ADDI x1, x0, 0x5 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm (I-Type)
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x1 = 0x05. PC_OUT -> 0x18.
    $display("ADDI x1, x0, 0x5");
    $display("Cycle 7 | PC: %h | Instruction %h | WB Value: %d (Expected: 5)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 8: AND x8, x7, x1 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x8 = 0x00. PC_OUT -> 0x1C.
    $display("AND x8, x7, x1");
    $display("Cycle 8 | PC: %h | Instruction %h | WB Value: %d (Expected: 0)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 9: OR x9, x7, x1 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x9 = 0x0F. PC_OUT -> 0x20.
    $display("OR x9, x7, x1");
    $display("Cycle 9 | PC: %h | Instruction %h | WB Value: %d (Expected: 15)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");

//------------------------------LỆNH 10: XOR x10, x4, x2 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x10 = 0x28. PC_OUT -> 0x24.
    $display("XOR x10, x4, x2");
    $display("Cycle 10 | PC: %h | Instruction %h | WB Value: %d (Expected: 40)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");



//------------------------------LỆNH 11: SRLI x10, x10, 5 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x10 = 0x01. PC_OUT -> 0x28
    $display("SRLI x10, x10, 5");
    $display("Cycle 11 | PC: %h | Instruction %h | WB Value: %d (Expected: 1)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");

//------------------------------LỆNH 12: SLLI x10, x10, 10 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x10 = 1024. PC_OUT -> 0x2C
    $display("SLLI x10, x10, 10");
    $display("Cycle 12 | PC: %h | Instruction %h | WB Value: %d (Expected: 1024)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");

//------------------------------LỆNH 13: SRAI x10, x10, 4 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x10 = 64. PC_OUT -> 0x30
    $display("SRAI x10, x10, 4");
    $display("Cycle 13 | PC: %h | Instruction %h | WB Value: %d (Expected: 64)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 14: SRA x10, x5, x1 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2
    ALU_op = 2'b01; 
    WBSel = 2'b01; 

    @(posedge i_clk); // Ghi x10 = 1. PC_OUT -> 0x34
    $display("SRA x10, x5, x1");
    $display("Cycle 14 | PC: %h | Instruction %h | WB Value: %d (Expected: 1)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


//------------------------------LỆNH 15: LUI x12, 0x1000 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b1000;       //U-Type
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b10; 
    WBSel = 2'b01; 
    LUI_Sel = 1'b1;
    @(posedge i_clk); // Ghi x12 = 0x1000_0000. PC_OUT -> 0x38
    $display("LUI x12, 0x1000");
    $display("Cycle 15 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x1000_0000)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");


 
//------------------------------LỆNH 16: ADDI x1, x0, 0x0020 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    LUI_Sel = 1'b0;
    @(posedge i_clk); // Ghi x1 = 0x0000_0020. PC_OUT -> 0x3C
    $display("ADDI x1, x0, 0x0020");
    $display("Cycle 16 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x0020)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");   


//------------------------------LỆNH 17: ADD x12, x12, x1 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = RS2
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x12 = 0x1000_0020. PC_OUT -> 0x40
    $display("ADD x12, x12, x1");
    $display("Cycle 17 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x1000_0020)", o_pc_debug, instr, Data_Writeback); 
    $display("-----------------------------");  


//------------------------------LỆNH 18: ADDI x14, x0, 0x00FA ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x14 = 0x0000_00FA. PC_OUT -> 0x44
    $display("ADDI x14, x0, 0x01FA");
    $display("Cycle 18 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x0000_01FA)", o_pc_debug, instr, Data_Writeback);
    $display("-----------------------------");  


//------------------------------LỆNH 19: SH x14, 0(x12) ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0001;   //S-Type
    RegWen = 1'b0;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b00; 
    WBSel = 2'b01; 
    MemRW = 1'b1;
    LoadSigned = 1'b1;
    LoadType = 4'b0011;
    @(posedge i_clk); // Ghi 0x00FA vào địa chỉ 0x1000_0020. PC_OUT -> 0x48
    $display("SH x14, 0(x12)");
    $display("Cycle 19 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x1000_0020)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");

//------------------------------LỆNH 20: LH x15, 0(x12) ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b00; 
    WBSel = 2'b00;
    MemRW = 1'b0;
    LoadSigned = 1'b1;
    LoadType = 4'b0011;
    @(posedge i_clk); // Ghi x15 = 0x0000_0000. PC_OUT -> 0x4C
    $display("LH x15, 4(x12)");
    $display("Cycle 20 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x0000_0000)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");


//------------------------------LỆNH 21: SLTI x16, x5, 0x145 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01;
    @(posedge i_clk); // Ghi x16 = 1 PC_OUT -> 0x50
    $display("SLTI x16, x5, 0x145");
    $display("Cycle 21 | PC: %h | Instruction %h | WB Value: %d (Expected: 1)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");

//------------------------------LỆNH 22: SLTI x16, x5, 0x005 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01;
    MemRW = 1'b0;
    LoadSigned = 1'b1;
    LoadType = 4'b0011;
    @(posedge i_clk); // Ghi x16 = 0 PC_OUT -> 0x54
    $display("SLTI x16, x5, 0x005");
    $display("Cycle 22 | PC: %h | Instruction %h | WB Value: %d (Expected: 0)", o_pc_debug, instr, Data_Writeback); 
    $display("-----------------------------"); 


//------------------------------LỆNH 23: ADDI x6, x0, 50 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x6 = 50. PC_OUT -> 0x58
    $display("ADDI x6, x0, 50");
    $display("Cycle 23 | PC: %h | Instruction %h | WB Value: %d (Expected: 50)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");



//------------------------------LỆNH 24: SLT x16, x6, x5 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b0; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01;
    @(posedge i_clk); // Ghi x16 = 0 PC_OUT -> 0x5C
    $display("SLT x16, x6, x5");
    $display("Cycle 24 | PC: %h | Instruction %h | WB Value: %h (Expected: 0)", o_pc_debug, instr, Data_Writeback); 
    $display("-----------------------------"); 


//------------------------------LỆNH 25: BLT x6, x5, branch ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    ImmSel = 4'b0010;       //B-Type 
    RegWen = 1'b0;
    ASel = 1'b1; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b10; 
    WBSel = 2'b01;
    PCSel = BrLT;
    @(posedge i_clk); // Nhảy tới PC + 4  | PC = 0x60
    $display("BNE x6, x5, branch");
    $display("Cycle 25 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x6c)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");


//------------------------------LỆNH 26: ADDI x2, x2, 10 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x2 = x2 + 10. PC_OUT -> 0x64
    $display("ADDI x2, x2, 10");
    $display("Cycle 26 | PC: %h | Instruction %h | WB Value: %d (Expected: 30)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");


//------------------------------LỆNH 27: ADDI x0, x0, 0 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x0 = 0. PC_OUT -> 0x68
    $display("ADDI x0, x0, 0");
    $display("Cycle 27 | PC: %h | Instruction %h | WB Value: %d (Expected: 0)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");

//------------------------------LỆNH 28: ADDI x2, x2, 5 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x2 = x2 + 5. PC_OUT -> 0x6C
    $display("ADDI x2, x2, 5");
    $display("Cycle 28 | PC: %h | Instruction %h | WB Value: %d (Expected: 35)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");


//---------------------------Lệnh 29: AUIPC x5, 0x0A------------------------------------------//
   // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b1000;   //U-Type 
    RegWen = 1'b1;
    ASel = 1'b1; // PC_Out
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b10; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x5 = 0x70 + 0x0A. PC_OUT -> 0xA070
    $display("AUIPC x5, 0x0A");
    $display("Cycle 29 | PC: %h | Instruction %h | WB Value: %h (Expected: 0xA070)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");


//------------------------------LỆNH 30: ADDI x1, x0, 0 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b0;
    ImmSel = 4'b0000; 
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b01; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x1 = 0. PC_OUT -> 0x74
    $display("ADDI x1, x0, 0");
    $display("Cycle 30 | PC: %h | Instruction %h | WB Value: %d (Expected: 0)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");

/*
//------------------------------LỆNH 31: JAL ra, branch ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b1;
    ImmSel = 4'b0100; 
    RegWen = 1'b1;
    ASel = 1'b1; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b10; 
    WBSel = 2'b10; 
    @(posedge i_clk); // Ghi x1 = 0. PC_OUT -> 0x6C
    $display("JAL ra, branch");
    $display("Cycle 31 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x6C)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");
*/

//------------------------------LỆNH 31: JALR ra, x3, 0x04 ------------------------------------//
    // Lệnh này được FETCH/DECODE/EXECUTE trong chu kỳ này
    PCSel = 1'b1;
    ImmSel = 4'b0000; //I-Type
    RegWen = 1'b1;
    ASel = 1'b0; 
    BSel = 1'b1; // ALU B = Imm
    ALU_op = 2'b10; 
    WBSel = 2'b01; 
    @(posedge i_clk); // Ghi x1 = 0. PC_OUT -> 0x6C
    $display("JALR ra,x3, 0x04");
    $display("Cycle 31 | PC: %h | Instruction %h | WB Value: %h (Expected: 0x022)", o_pc_debug, instr, Data_Writeback);  
    $display("-----------------------------");

    $finish;
end
endmodule
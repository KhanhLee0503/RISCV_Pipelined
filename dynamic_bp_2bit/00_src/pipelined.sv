module pipelined(
						input logic i_clk,
						input logic i_reset,
						input logic [31:0] i_io_sw,
						
						output logic [31:0] o_io_ledr,
						output logic [31:0] o_io_ledg,
						output logic [31:0] o_io_lcd,
						output logic [6:0] o_io_hex0, 
						output logic [6:0] o_io_hex1, 
						output logic [6:0] o_io_hex2,
						output logic [6:0] o_io_hex3, 
						output logic [6:0] o_io_hex4, 
						output logic [6:0] o_io_hex5, 
						output logic [6:0] o_io_hex6, 
						output logic [6:0] o_io_hex7,  
						output logic [31:0] o_pc_debug,
						output logic o_insn_vld,
						output logic o_ctrl,
						output logic o_mispred
						);
//logic i_clk;						
logic i_low_reset;
assign i_low_reset = ~i_reset;		
logic pre_o_insn_vld;	
logic [31:0] instr;						
logic  BrLT;
logic  BrEQ;
logic PCSel;
logic [3:0] ImmSel;
logic RegWen;
logic BrUn;
logic ASel;
logic BSel;
logic [1:0] ALU_op;
logic MemRW;
logic LoadSigned;
logic [3:0] LoadType;
logic [1:0] WBSel;
logic LUI_Sel;

logic [31:0] o_io_hex03;
logic [31:0] o_io_hex47;

/*
Clock_div clock_div(
				.clk(clk), 
				.i_clk(i_clk)
				);
*/
control_unit Control_Unit(
						.instr(instr),
						.BrLT(BrLT),
						.BrEQ(BrEQ),

						.PCSel(PCSel),
						.ImmSel(ImmSel),
						.RegWen(RegWen),
						.BrUn(BrUn),
						.ASel(ASel),
						.BSel(BSel),
						.ALU_op(ALU_op),
						.MemRW(MemRW),
						.LoadType(LoadType),
						.LoadSigned(LoadSigned),
						.WBSel(WBSel),
						.LUI_Sel(LUI_Sel),
						.o_insn_vld(pre_o_insn_vld)
						 );
								 
datapath Datapath(
						.i_clk(i_clk),
						.i_reset(i_low_reset),
						.PCSel(PCSel),
				
						.ImmSel(ImmSel),				//ImmSel = 00_00 : I_Format
														//ImmSel = 00_01 : S_Format
														//ImmSel = 00_10 : B_Format
														//ImmSel = 01_xx : J_Format
														//ImmSel = 10_xx : U_Format
						.RegWen(RegWen),
						.BrUn(BrUn),
					
						
						.BSel(BSel),					//If 0 select RS2, else select BRC
						.ASel(ASel),					//If 0 select RS1, else select BRC
						.ALU_op(ALU_op),	
						
						.LoadType(LoadType),   			// 0001: load byte | 0011: load halfword | 1111: load word
						.LoadSigned(LoadSigned),		//if 0 is unsigned, 1 is signed	
						
						.MemRW(MemRW),					//1 is Writing, 0 is Reading
						
						.WBSel(WBSel),					//0 is Load Data, 1 is ALU Out, 2 is PC + 4
						.LUI_Sel(LUI_Sel),
						
						.i_insn_vld(pre_o_insn_vld),
						.i_io_sw(i_io_sw),
						.o_io_ledr(o_io_ledr),
						.o_io_ledg(o_io_ledg),
						.o_io_lcd(o_io_lcd),
						.o_io_hex03(o_io_hex03),
						.o_io_hex47(o_io_hex47),
						.o_ctrl(o_ctrl),
						.o_insn_vld(o_insn_vld),
						.o_mispred(o_mispred),
						.o_pc_debug(o_pc_debug),
						.instr(instr),
						.BrLT(BrLT),
						.BrEQ(BrEQ)
						);

assign o_io_hex0 = o_io_hex03[6:0];
assign o_io_hex1 = o_io_hex03[14:8];
assign o_io_hex2 = o_io_hex03[22:16];
assign o_io_hex3 = o_io_hex03[30:24];
assign o_io_hex4 = o_io_hex47[6:0];
assign o_io_hex5 = o_io_hex47[14:8];
assign o_io_hex6 = o_io_hex47[22:16];
assign o_io_hex7 = o_io_hex47[30:24];


endmodule 

module datapath(
					input logic i_clk,
					input logic i_reset,
					input logic PCSel,
					input logic i_insn_vld,

					input logic [3:0] ImmSel,	//ImmSel = 00_00 : I_Format
														//ImmSel = 00_01 : S_Format
														//ImmSel = 00_10 : B_Format
														//ImmSel = 01_xx : J_Format
														//ImmSel = 10_xx : U_Format
					input logic RegWen,
					
					input logic BrUn,
					
					
					input logic BSel,			//If 0 select RS2, else select BRC
					input logic ASel,			//If 0 select RS1, else select BRC
					input logic [1:0] ALU_op,
					
					input logic [3:0] LoadType,   // 0001: load byte | 0011: load halfword | 1111: load word
					input logic LoadSigned,			//if 0 is unsigned, 1 is signed		
					input logic MemRW,				//1 is Writing, 0 is Reading
					
					input logic [1:0] WBSel,				//0 is Load Data, 1 is ALU Out, 2 is PC + 4
					input logic LUI_Sel,
					
					input logic [31:0] i_io_sw,
					output logic [31:0] o_io_ledr,
					output logic [31:0] o_io_ledg,
					output logic [31:0] o_io_lcd,
					output logic [31:0] o_io_hex03,
					output logic [31:0] o_io_hex47,
					output logic o_insn_vld,
					output logic [31:0] o_pc_debug,
					output logic o_ctrl,
					output logic o_mispred,
					output logic [31:0] instr,
					output logic BrLT,
					output logic BrEQ
					);

		
parameter JAL       = 7'b110_1111;
parameter JALR      = 7'b110_0111;
parameter B_TYPE    = 7'b110_0011;
		
logic [31:0] PCSel_out;		

logic [31:0] PC_out;

logic [31:0] PC_plus4;

logic [31:0] Instruction;
logic [31:0] Immediate;

logic [31:0] RS1_Out;
logic [31:0] RS2_Out;

logic [31:0] A_Out;
logic [31:0] A_Out_Sub;
logic [31:0] B_Out;

logic [3:0] ALU_Opcode;
logic [31:0] ALU_Out;

logic [31:0] o_ld_data;
logic [31:0] Data_Writeback;
//assign data_writeback = Data_Writeback;


logic dummy1;
logic dummy2;
assign dummy2 = 1'b0;
logic dummy3; 

logic flush;
logic stall;
logic ID_EX_Bubble;
logic stall_j;
logic stall_L;

logic HD_BrLT;
logic HD_BrEQ;

assign BrLT = HD_BrLT;
assign BrEQ = HD_BrEQ;

logic branch_taken;
logic insn_vld_EX_Out;
logic insn_vld_MEM_Out;
logic insn_vld_WB_Out;
assign o_insn_vld = insn_vld_MEM_Out;
//################***Pipeline register declaration***########################
//-------------------IF_Stage-----------------------
logic [31:0] Instr_ID_Out;
logic [31:0] PC_ID_Out;
assign instr = Instr_ID_Out;


//------------------ID_Stage------------------------
logic [31:0] RS1_EX_Out;
logic [31:0] RS2_EX_Out;
logic [31:0] Imm_EX_Out;
logic [31:0] PC_EX_Out;
logic [31:0] Instr_EX_Out;

logic [5:0] EX_Ctrl_Out; 
logic [5:0] MEM_EX_Ctrl_Out;
logic [2:0] WB_EX_Ctrl_Out;

//-----------------EX_Stage-------------------------
logic [31:0] PC_MEM_Out;
logic [31:0] ALU_MEM_Out;
logic [31:0] RS2_MEM_Out;
logic [31:0] Instr_MEM_Out;

logic [5:0] MEM_MEM_Ctrl_Out;
logic [2:0] WB_MEM_Ctrl_Out;

//----------------MEM_Stage-------------------------
logic [31:0] PC_plus4_WB_Out;
logic [31:0] ALU_WB_Out;
logic [31:0] Mem_WB_Out;
logic [31:0] PC_plus4_MEM;
logic [31:0] Instr_WB_Out;

//----------------WB_Stage------------------------
logic [2:0] WB_WB_Ctrl_Out;
assign o_pc_debug = PC_MEM_Out;

//-------------Forwarding_Unit_Signals------------------------
logic [1:0] ForwardingA_sel;
logic [1:0] ForwardingB_sel;
logic [1:0] ForwardingC_sel;
logic 		ForwardingD_sel;
logic [1:0] ForwardingE_sel;

logic [31:0] forwardingA_Out;
logic [31:0] forwardingB_Out;
logic [31:0] forwardingC_Out;
logic [31:0] forwardingD_Out;
logic [31:0] forwardingE_Out;


//Branch_Target_Buffer Signals
logic [31:0] 	lookup_pc;
logic 			btb_hit;
logic [31:0] 	predicted_target;
logic 			update_en;
logic [31:0] 	update_pc;
logic [31:0] 	update_target;

//----------------------------
logic BTB_HIT_ID;
logic BTB_HIT_EX;
logic [1:0] PC_Sel_BP;
logic PC_Mispredicted;
logic [31:0] Predicted_PC_ID;
logic [31:0] Predicted_PC_EX;
logic [31:0] Mispredicted_PC_ID;
logic [31:0] Mispredicted_PC_EX;
logic BHT_taken;
logic predict_taken;
logic predict_taken_ID;
logic predict_taken_EX;
logic PC_Mispredicted_MEM_out;
logic PC_Mispredicted_WB_out;

logic [12:0] ghbr_lookup_index;
logic [12:0] ghbr_update_index;
logic [12:0] ghbr_snapshot_out;
logic [12:0] ghbr_snapshot_out_ID;
logic [12:0] ghbr_snapshot_out_EX;

assign predict_taken = btb_hit & BHT_taken;
//----------------------------Branch_Target_Buffer------------------------
Branch_Target_Buffer BTB(
						.clk(i_clk),
    					.reset(i_reset),
						.actual_taken(branch_taken),
    					.lookup_pc(PC_out),
						.lookup_index(ghbr_lookup_index),
    			        .btb_hit(btb_hit),
    					.predicted_target(predicted_target),

						.update_index(ghbr_update_index),
    					.update_en(update_en),
    					.update_pc(update_pc),
    					.update_target(update_target)
						);

Branch_History_Table BHT
(
    .clk(i_clk),
    .reset(i_reset),

    .lookup_pc(PC_out),
	.lookup_index(ghbr_lookup_index),

    .predict_taken(BHT_taken),

	.update_index(ghbr_update_index),
    .update_en(update_en),
    .update_pc(update_pc),
    .actual_taken(branch_taken)
);

Global_Branch_History_Registers GHBR(
    .clk(i_clk),
    .reset(i_reset),
    .update_en(update_en),
    .current_taken(branch_taken),
    .lookup_pc(PC_out),
   	.update_pc(update_pc),

    // GHR snapshot for update
    .ghr_snapshot_in(ghbr_snapshot_out_EX),
    .ghr_snapshot_out(ghbr_snapshot_out),

    // Outputs
    .lookup_index(ghbr_lookup_index),
    .update_index(ghbr_update_index)
);

//-----------------Selecting_PC_Combination-----------------------
always_comb begin
	if(PC_Mispredicted)
		if(branch_taken)
			PC_Sel_BP = 2'b01;
		else
			PC_Sel_BP = 2'b11;
	else if((predict_taken) && (branch_taken))
		PC_Sel_BP = 2'b10;
	else
		PC_Sel_BP = 2'b00; 
end


//####################***Datapath_Pipelined***#############################

//------------------------Instruction_Fetch-------------------------
mux4to1_32bit PC_Select(
			.In1(PC_plus4),
			.In2(ALU_Out),
			.In3(predicted_target),
			.In4(Mispredicted_PC_EX),
			.sel(PC_Sel_BP),
			.out(PCSel_out)
			);	

register32bit_bubble Program_Counter(
				.clk(i_clk),
				.rst(i_reset),
				.stall_j(stall_j),
				.Bubble(dummy2),
				.stall(stall),
				.flush(dummy2),
				.in(PCSel_out),
				.out(PC_out)		
				);	

					
adder_32bit ADDER_PC1(
			.A(PC_out),
			.B(32'h0000_0004),
			.sel(1'b0),
			.OUT(PC_plus4),
			.CarryOut(dummy1)
			);
					
					
InstrMem Instruction_Memory( 
			   .i_addr(PC_out[12:0]),
			   .o_rdata(Instruction)
			   );					


register32bit PC_ID(
				.clk(i_clk),
				.rst(i_reset),
				.stall(stall),
				.flush(flush),
				.in(PC_out),
				.out(PC_ID_Out)		
				);	


register32bit Instr_ID(
						.clk(i_clk),
						.rst(i_reset),
						.stall(stall),
						.flush(flush),
						.in(Instruction),
						.out(Instr_ID_Out)
						);

register32bit PredictedPC_ID(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(predicted_target),
							.out(Predicted_PC_ID)
							);

register32bit MispredictedPC_ID(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(PC_plus4),
							.out(Mispredicted_PC_ID)
							);

register1bit ID_BTB_Hit(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(predict_taken),
							.out(predict_taken_ID)
							);


register13bit GHBR_SNAPSHOT_ID(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(ghbr_snapshot_out),
							.out(ghbr_snapshot_out_ID)
							);
//---------------------------Instruction_Decode----------------------------
ImmGen ImmediateGeneration(
			  .Instruction(Instr_ID_Out[31:7]),
			  .ImmSel(ImmSel),			 
			  .OutImm(Immediate)
			  );	
									

regfile_pl RegisterFile(
			.i_clk(i_clk),
			.i_reset(i_reset),
			.i_rs1_addr(Instr_ID_Out[19:15]),
			.i_rs2_addr(Instr_ID_Out[24:20]),
			.i_rd_addr(Instr_WB_Out[11:7]),
			.i_rd_data(Data_Writeback),
			.i_rd_wren(WB_WB_Ctrl_Out[2]),

			.o_rs1_data(RS1_Out),
			.o_rs2_data(RS2_Out)
			);
							


register32bit_bubble RS1_ID(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush),
					.in(RS1_Out),
					.out(RS1_EX_Out)		
					);	


register32bit_bubble RS2_ID(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush),
					.in(RS2_Out),
					.out(RS2_EX_Out)		
					);	

register32bit_bubble ImmGen_ID(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush),
					.in(Immediate),
					.out(Imm_EX_Out)		
					);	

register32bit_bubble PC_EX(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush),
					.in(PC_ID_Out),
					.out(PC_EX_Out)		
					);	

register32bit_bubble Instr_EX(
						.clk(i_clk),
						.rst(i_reset),
						.stall_j(dummy2),
						.Bubble(ID_EX_Bubble),
						.stall(stall),
						.flush(flush),
						.in(Instr_ID_Out),
						.out(Instr_EX_Out)
						);

register6bit_bubble EX_Ctrl(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush), 
					.in({ALU_op, BrUn, LUI_Sel, ASel, BSel}), 
					.out(EX_Ctrl_Out)
					);


register6bit_bubble MEM_EX_Ctrl(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush),
					.in({MemRW, LoadSigned, LoadType}), 
					.out(MEM_EX_Ctrl_Out)
					);

register3bit_bubble WB_EX_Ctrl(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush), 
					.in({RegWen,WBSel}), 
					.out(WB_EX_Ctrl_Out)
					);


register1bit_bubble Insn_Vld_EX(
					.clk(i_clk),
					.rst(i_reset),
					.stall_j(dummy2),
					.Bubble(ID_EX_Bubble),
					.stall(stall),
					.flush(flush), 
					.in(i_insn_vld), 
					.out(insn_vld_EX_Out)
					);


register32bit PredictedPC_EX(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(Predicted_PC_ID),
							.out(Predicted_PC_EX)
							);


register32bit MispredictedPC_EX(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(Mispredicted_PC_ID),
							.out(Mispredicted_PC_EX)
							);
							
register1bit EX_BTB_Hit(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(predict_taken_ID),
							.out(predict_taken_EX)
							);


register13bit GHBR_SNAPSHOT_EX(
							.clk(i_clk),
							.rst(i_reset),
							.stall(dummy2),
							.flush(dummy2),
							.in(ghbr_snapshot_out_ID),
							.out(ghbr_snapshot_out_EX)
							);							
//------------------------------Execution-----------------------------
mux4to1_32bit Forwarding_C(
						.In1(RS1_EX_Out),
						.In2(ALU_MEM_Out),
						.In3(ALU_WB_Out),
						.In4(32'b0),
						.sel(ForwardingC_sel),
						.out(forwardingC_Out)
						);

mux4to1_32bit Forwarding_E(
						.In1(RS2_EX_Out),
						.In2(ALU_MEM_Out),
						.In3(ALU_WB_Out),
						.In4(32'b0),
						.sel(ForwardingE_sel),
						.out(forwardingE_Out)
						);


BRC BranchComparision(
			.i_rs1_data(forwardingC_Out),
			.i_rs2_data(forwardingE_Out), 
			.i_br_un(EX_Ctrl_Out[3]), 
			.o_br_less(HD_BrLT), 
			.o_br_equal(HD_BrEQ)
			);
					

mux4to1_32bit Forwarding_A(
							.In1(RS1_EX_Out),
							.In2(ALU_MEM_Out),
							.In3(ALU_WB_Out),
							.In4(Mem_WB_Out),
							.sel(ForwardingA_sel),
							.out(forwardingA_Out)
						  );
		
							
mux2to1_32bit A_Select(
			.In1(forwardingA_Out),
			.In2(PC_EX_Out),
			.sel(EX_Ctrl_Out[1]),
			.out(A_Out)
			);

mux2to1_32bit LUI_Select(
			.In1(A_Out),
			.In2(32'h0),
			.sel(EX_Ctrl_Out[2]),
			.out(A_Out_Sub)
			);

mux4to1_32bit Forwarding_B(
							.In1(RS2_EX_Out),
							.In2(ALU_MEM_Out),
							.In3(ALU_WB_Out),
							.In4(Mem_WB_Out),
							.sel(ForwardingB_sel),
							.out(forwardingB_Out)
						  );	

mux2to1_32bit B_Select(
			.In1(forwardingB_Out),
			.In2(Imm_EX_Out),
			.sel(EX_Ctrl_Out[0]),
			.out(B_Out)
			);		
	

alu_control ALU_Control(
			.funct3(Instr_EX_Out[14:12]),
			.funct7(Instr_EX_Out[30]),			//Bit number 5 of funct7
			.ALU_op(EX_Ctrl_Out[5:4]),
			.opcode_bit5(Instr_EX_Out[5]),
			.Opcode(ALU_Opcode)
			);
		
					
ALU ALU(
	 .i_op_a(A_Out_Sub),
	 .i_op_b(B_Out),
	 .i_alu_op(ALU_Opcode),
	 .o_alu_data(ALU_Out)
	);

//------------------Compare Current Jump PC and Predicted PC------------
always_comb begin
    PC_Mispredicted = 1'b0;
    update_en       = 1'b0;
    update_pc       = 32'b0;
    update_target   = 32'b0;

    // -------------------- JAL / JALR --------------------
    if ((Instr_EX_Out[6:0] == JALR) || (Instr_EX_Out[6:0] == JAL)) begin
        update_en     = 1'b1;
        update_pc     = PC_EX_Out;
        update_target = ALU_Out;

        if (Predicted_PC_EX != ALU_Out)
            PC_Mispredicted = 1'b1;
    end

    // -------------------- B-type ------------------------
    else if (Instr_EX_Out[6:0] == B_TYPE) begin
        update_en     = 1'b1;
        update_pc     = PC_EX_Out;
        update_target = (branch_taken) ? ALU_Out : 32'b0;   // thường update khi taken

        // 1. Mispredict hướng
        if (predict_taken_EX != branch_taken)
            PC_Mispredicted = 1'b1;

        // 2. Đúng hướng nhưng sai target
        else if ((predict_taken_EX) && (branch_taken) && (Predicted_PC_EX != ALU_Out))
            PC_Mispredicted = 1'b1;
    end
end

register32bit_mem PC_MEM( 
					.clk(i_clk),
					.rst(i_reset),
					.stall_L(stall_L),
					.stall_j(stall_j),
					.stall(dummy2),
					.flush(flush),
					.in(PC_EX_Out),
					.out(PC_MEM_Out)		
					);	


register32bit_mem ALU_MEM(
					.clk(i_clk),
					.rst(i_reset),
					.stall_L(stall_L),
					.stall_j(stall_j),
					.stall(dummy2),
					.flush(flush),
					.in(ALU_Out),
					.out(ALU_MEM_Out)		
					);	


mux2to1_32bit Forwarding_D(
			.In1(RS2_EX_Out),
			.In2(ALU_MEM_Out),
			.sel(ForwardingD_sel),
			.out(forwardingD_Out)
			);

register32bit_mem RS2_MEM(
					.clk(i_clk),
					.rst(i_reset),
					.stall_L(stall_L),
					.stall_j(stall_j),
					.stall(dummy2),
					.flush(flush),
					.in(forwardingD_Out),
					.out(RS2_MEM_Out)		
					);	


register32bit_mem Instr_MEM(
						.clk(i_clk),
						.rst(i_reset),
						.stall_L(stall_L),
						.stall_j(stall_j),
						.stall(dummy2),
						.flush(flush),
						.in(Instr_EX_Out),
						.out(Instr_MEM_Out)
						);

register6bit_mem MEM_MEM_Ctrl(
					.clk(i_clk),
					.rst(i_reset),
					.stall_L(stall_L),
					.stall_j(stall_j), 
					.stall(dummy2),
					.flush(flush),
					.in(MEM_EX_Ctrl_Out), 
					.out(MEM_MEM_Ctrl_Out)
					);

register3bit_mem WB_MEM_Ctrl(
					.clk(i_clk),
					.rst(i_reset),
					.stall_L(stall_L),
					.stall_j(stall_j),
					.stall(dummy2),
					.flush(flush), 
					.in(WB_EX_Ctrl_Out), 
					.out(WB_MEM_Ctrl_Out)
					);

register1bit_mem Insn_Vld_MEM(
					.clk(i_clk),
					.rst(i_reset),
					.stall_L(stall_L),
					.stall_j(stall_j),
					.stall(dummy2),
					.flush(flush), 
					.in(insn_vld_EX_Out), 
					.out(insn_vld_MEM_Out)
					);

register1bit_mem PC_Mispredicted_MEM(
					.clk(i_clk),
					.rst(i_reset),
					.stall_L(stall_L),
					.stall_j(stall_j),
					.stall(dummy2),
					.flush(flush), 
					.in(PC_Mispredicted), 
					.out(PC_Mispredicted_MEM_out)
					);


Forwarding_Unit Forwarding_Unit(
						.clk(i_clk),
						.reset(i_reset),
						.IF_ID_rs1(Instr_ID_Out[19:15]),	//(Instr_ID_Out[19:15]),
                        .IF_ID_rs2(Instr_ID_Out[24:20]),
						.IF_ID_Opcode(Instr_ID_Out[6:0]),
						.IF_ID_RegWen(RegWen),
						.IF_ID_MemRW(MemRW),

						.ID_EX_rs1(Instr_EX_Out[19:15]),
                        .ID_EX_rs2(Instr_EX_Out[24:20]),
						.ID_EX_rd(Instr_EX_Out[11:7]),
						.ID_EX_Opcode(Instr_EX_Out[6:0]),
						.ID_EX_Bubble(ID_EX_Bubble),
						.ID_EX_RegWen(WB_EX_Ctrl_Out[2]),
						.ID_EX_MemRW(MEM_EX_Ctrl_Out[5]),
						.ID_EX_funct3(Instr_EX_Out[14:12]),

                        .EX_MEM_rd(Instr_MEM_Out[11:7]),
						.EX_MEM_rs1(Instr_MEM_Out[19:15]),
						.EX_MEM_rs2(Instr_MEM_Out[24:20]),
						.EX_MEM_Opcode(Instr_MEM_Out[6:0]),
						.EX_MEM_MemRW(MEM_MEM_Ctrl_Out[5]),
						.EX_MEM_RegWen(WB_MEM_Ctrl_Out[2]),

						.MEM_WB_Opcode(Instr_WB_Out[6:0]),
						.MEM_WB_rd(Instr_WB_Out[11:7]),
						.MEM_WB_RegWen(WB_WB_Ctrl_Out[2]),
						.BrLT(HD_BrLT),
					    .BrEQ(HD_BrEQ),
						.Mispredicted_PC(PC_Mispredicted),
         
						.stall_L(stall_L),
						.stall_j(stall_j),
						.branch_taken(branch_taken),
						.flush(flush),
						.stall(stall),

                        .ForwardingA_sel(ForwardingA_sel),
                        .ForwardingB_sel(ForwardingB_sel),
						.ForwardingC_sel(ForwardingC_sel),
						.ForwardingD_sel(ForwardingD_sel),
						.ForwardingE_sel(ForwardingE_sel)
                      );

//-------------------------------Memory_Stage------------------------------			
lsu LoadStore_Unit(
		.i_clk(i_clk),
		.i_reset(i_reset),
		.i_load_type(MEM_MEM_Ctrl_Out[3:0]),		
		.i_load_signed(MEM_MEM_Ctrl_Out[4]),			
		
		.i_lsu_addr(ALU_MEM_Out),
		.i_st_data(RS2_MEM_Out),
		.i_lsu_wren(MEM_MEM_Ctrl_Out[5]),				
		.i_io_sw(i_io_sw),
		
		.o_ld_data(o_ld_data),
		.o_io_ledr(o_io_ledr),
		.o_io_ledg(o_io_ledg),
		.o_io_lcd(o_io_lcd),
		
		.o_io_hex03(o_io_hex03),
		.o_io_hex47(o_io_hex47)
		);									
						
adder_32bit ADDER_PC2(
			.A(PC_MEM_Out),
			.B(32'h0000_0004),
			.sel(1'b0),
			.OUT(PC_plus4_MEM),
			.CarryOut(dummy3)
			);


register32bit PC_PLUS4_WB(
					.clk(i_clk),
					.rst(i_reset),
					.stall(dummy2),
					.flush(dummy2),
					.in(PC_plus4_MEM),
					.out(PC_plus4_WB_Out)		
					);	


register32bit ALU_WB(
					.clk(i_clk),
					.rst(i_reset),
					.flush(dummy2),
					.stall(dummy2),
					.in(ALU_MEM_Out),
					.out(ALU_WB_Out)		
					);	


register32bit MEM_WB(
					.clk(i_clk),
					.rst(i_reset),
					.stall(dummy2),
					.flush(dummy2),
					.in(o_ld_data),
					.out(Mem_WB_Out)		
					);	


register32bit Instr_WB(
						.clk(i_clk),
						.rst(i_reset),
						.stall(dummy2),
						.flush(dummy2),
						.in(Instr_MEM_Out),
						.out(Instr_WB_Out)
						);

register3bit WB_WB_Ctrl(
					.clk(i_clk),
					.rst(i_reset),
					.stall(dummy2),
					.flush(dummy2), 
					.in(WB_MEM_Ctrl_Out), 
					.out(WB_WB_Ctrl_Out)
					);


register1bit Insn_Vld_WB(
					.clk(i_clk),
					.rst(i_reset),
					.stall(dummy2),
					.flush(dummy2), 
					.in(insn_vld_MEM_Out), 
					.out(insn_vld_WB_Out)
					);	

register1bit PC_Mispredicted_WB(
					.clk(i_clk),
					.rst(i_reset),
					.stall(dummy2),
					.flush(dummy2), 
					.in(PC_Mispredicted_MEM_out), 
					.out(PC_Mispredicted_WB_out)
					);			
//---------------------------Writeback_Stage-------------------------------
mux4to1_32bit WriteBack(
			.In1(Mem_WB_Out),
			.In2(ALU_WB_Out),
			.In3(PC_plus4_WB_Out),
			.In4(32'b0), 
			.sel(WB_WB_Ctrl_Out[1:0]),
			.out(Data_Writeback)
			);	

always_comb begin
	if((Instr_WB_Out[6:0] == B_TYPE) || (Instr_WB_Out[6:0] == JAL) || (Instr_WB_Out[6:0] == JALR)) 
		o_ctrl = 1'b1;
	else 
		o_ctrl = 1'b0;
end

assign o_mispred = PC_Mispredicted_WB_out;


endmodule 



//------------------------Pipeline Registers--------------------------------

module register32bit(
						input logic clk,
						input logic rst,
						input logic stall,
						input logic flush,
						input logic [31:0] in,
						output logic [31:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 32'b0;
	else if (flush) out <= 32'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule


module register6bit(
						input logic clk,
						input logic rst,
						input logic stall,
						input logic flush,
						input logic [5:0] in,
						output logic [5:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 6'b0;
	else if (flush) out <= 6'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule


module register3bit(
						input logic clk,
						input logic rst,
						input logic stall,
						input logic flush,
						input logic [2:0] in,
						output logic [2:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 3'b0;
	else if (flush) out <= 3'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule

module register1bit(
						input logic clk,
						input logic rst,
						input logic stall,
						input logic flush,
						input logic in,
						output logic out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 1'b0;
	else if (flush) out <= 1'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule

module register13bit(
						input logic clk,
						input logic rst,
						input logic stall,
						input logic flush,
						input logic [12:0] in,
						output logic [12:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 13'b0;
	else if (flush) out <= 13'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule
//---------------------------Pipeline ID_EX special register (With Internal Bubble Signal)-------------------------

module register32bit_bubble(
						input logic clk,
						input logic rst,
						input logic stall_j,
						input logic Bubble,
						input logic stall,
						input logic flush,
						input logic [31:0] in,
						output logic [31:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 32'b0;
	else if (stall_j) out <= in;
	else if(Bubble)	out <= 32'b0;
	else if (flush) out <= 32'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule


module register6bit_bubble(
						input logic clk,
						input logic rst,
						input logic stall_j,
						input logic Bubble,
						input logic stall,
						input logic flush,
						input logic [5:0] in,
						output logic [5:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 6'b0;
	else if (stall_j) out <= in;
	else if(Bubble)	out <= 6'b0;
	else if (flush) out <= 6'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule


module register3bit_bubble(
						input logic clk,
						input logic rst,
						input logic stall_j,
						input logic Bubble,
						input logic stall,
						input logic flush,
						input logic [2:0] in,
						output logic [2:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 3'b0;
	else if(stall_j) out <= in;
	else if(Bubble)	out <= 3'b0;
	else if (flush) out <= 3'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule

module register1bit_bubble(
						input logic clk,
						input logic rst,
						input logic stall_j,
						input logic Bubble,
						input logic stall,
						input logic flush,
						input logic in,
						output logic out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 1'b0;
	else if (stall_j) out <= in;
	else if(Bubble)	out <= 1'b0;
	else if (flush) out <= 1'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule

module register32bit_mem(
						input logic clk,
						input logic rst,
						input logic stall_L,
						input logic stall_j,
						input logic stall,
						input logic flush,
						input logic [31:0] in,
						output logic [31:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 32'b0;
	else if (stall_L) out <= out;
	else if (stall_j) out <= in;
	else if (flush) out <= 32'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule


module register6bit_mem(
						input logic clk,
						input logic rst,
						input logic stall_L,
						input logic stall_j,
						input logic stall,
						input logic flush,
						input logic [5:0] in,
						output logic [5:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 6'b0;
	else if (stall_L) out <= out;
	else if (stall_j) out <= in;
	else if (flush) out <= 6'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule


module register3bit_mem(
						input logic clk,
						input logic rst,
						input logic stall_L,
						input logic stall_j,
						input logic stall,
						input logic flush,
						input logic [2:0] in,
						output logic [2:0] out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 3'b0;
	else if (stall_L) out <= out;
	else if(stall_j) out <= in;
	else if (flush) out <= 3'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule


module register1bit_mem(
						input logic clk,
						input logic rst,
						input logic stall_L,
						input logic stall_j,
						input logic stall,
						input logic flush,
						input logic in,
						output logic out
					);
		
always_ff@(posedge clk or posedge rst) begin
	if(rst) out <= 1'b0;
	else if (stall_L) out <= out;
	else if(stall_j) out <= in;
	else if (flush) out <= 1'b0;
	else if (stall == 1'b0) out <= in;
end
endmodule
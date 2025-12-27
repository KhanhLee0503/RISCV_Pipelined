////////////////////////
//Immediate Generator //
////////////////////////
module ImmGen(
				input logic [24:0] Instruction,
				input logic [3:0] ImmSel,					//ImmSel = 00_00 : I_Format
															//ImmSel = 00_01 : S_Format
															//ImmSel = 00_10 : B_Format
															//ImmSel = 01_xx : J_Format
															//ImmSel = 10_xx : U_Format 
				output logic [31:0] OutImm
				 );
wire [31:0] ISB;
wire [31:0] J;
wire [31:0] U;
ISB_Format ISB_Format(
							.Instr31_25(Instruction[24:18]),
							.Instr24_20(Instruction[17:13]),
							.Instr11_7(Instruction[4:0]),
							.ImmSel(ImmSel[1:0]),
							.OutISB(ISB)
							);
							
J_Format J_Format(
						.Instr31_25(Instruction[24:18]),
						.Instr24_20(Instruction[17:13]),
						.Instr19_12(Instruction[12:5]),
						.OutJ(J)						
						);
						
U_Format U_Format(
						.Instr31_12(Instruction[24:5]),
						.OutU(U)
						);
						
mux4to1_32bit mux4to1(
							 .In1(ISB),
							 .In2(J),
							 .In3(U),
							 .In4(32'b0),
							 .sel(ImmSel[3:2]),
							 .out(OutImm)
							 );

endmodule 

//----------------------------Sub_Modules-----------------------------------


////////////////////////
//ISB Format Generator//
////////////////////////
module ISB_Format(
				input logic [6:0] Instr31_25,
				input logic [4:0] Instr24_20,
				input logic [4:0] Instr11_7,
				input logic [1:0] ImmSel,				// ImmSel = 00 => I_Format
														// ImmSel = 01 => S_Format
														// ImmSel = 10 => B_Format
				output logic [31:0] OutISB
				);

wire bit11;
wire [4:0] bit4_0;
				
mux2to1 mux2to1(
					.In1(Instr31_25[6]),
					.In2(Instr11_7[0]),
					.sel(ImmSel[1]),
					.out(bit11)
					);

					
					
mux4to1_5bit mux4to1(
							.In1(Instr24_20),
							.In2(Instr11_7),
							.In3({Instr11_7[4:1],1'b0}),
							.In4(5'b0),
							.sel(ImmSel),
							.out(bit4_0)
							);

assign OutISB[31:12] = {20{Instr31_25[6]}};
assign OutISB[11] = bit11;
assign OutISB[10:5] = Instr31_25[5:0];
assign OutISB[4:0] = bit4_0;
endmodule 



////////////////////////
//J Format Generator//
////////////////////////
module J_Format(
					input logic [6:0] Instr31_25,
					input logic [4:0] Instr24_20,
					input logic [7:0] Instr19_12,
					output [31:0] OutJ
					); 
assign OutJ[31:20] = {12{Instr31_25[6]}};
assign OutJ[19:12] = Instr19_12;
assign OutJ[11] = Instr24_20[0];
assign OutJ[10:5] = Instr31_25[5:0];
assign OutJ[4:0] = {Instr24_20[4:1],1'b0};
endmodule 



////////////////////////
//U Format Generator//
////////////////////////
module U_Format(
					input logic [19:0] Instr31_12,
					output logic [31:0] OutU
					);
assign OutU[31:12] = Instr31_12;
assign OutU[11:0] = 12'b0;
endmodule


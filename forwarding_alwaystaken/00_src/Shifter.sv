module Shifter(
					input logic [31:0] In,
					input logic [4:0] ShAm,
					input logic [1:0] Shift_sel,	//00: Shift Right Logic,
															//01: Shift Left Logic,
															//10: Shift Right Arithmetic
					output logic [31:0] OUT
					);
wire [31:0] shiftright_arith;
wire [31:0] shiftright_logic;
wire [31:0] shiftleft_logic;

ShiftRight_Arithmetic Shiftright_arith(
							.In(In),
							.ShAm(ShAm),
							.OUT(shiftright_arith)
							);					
					

ShiftRight_Logic Shiftright_logic(
							.In(In),
							.ShAm(ShAm),
							.OUT(shiftright_logic)
							);					

ShiftLeft_Logic Shiftleft_logic(
							.In(In),
							.ShAm(ShAm),
							.OUT(shiftleft_logic)
							);					
							
mux4to1_32bit mux4to1(
							.In1(shiftright_logic),
							.In2(shiftleft_logic),
							.In3(shiftright_arith),
							.In4(32'b0),
							.sel(Shift_sel),
							.out(OUT)
							);

endmodule

//////////////////////////
//Shift Right Arithmetic//
//////////////////////////
module ShiftRight_Arithmetic(
									input logic [31:0] In,
									input logic [4:0] ShAm,
									output logic [31:0] OUT
									 );
wire [31:0] stage_0;
wire [31:0] stage_1;
wire [31:0] stage_2;
wire [31:0] stage_3;

mux2to1_32bit mux5(
						.In1(In),
						.In2({{16{In[31]}}, In[31:16]}), 
						.sel(ShAm[4]),
						.out(stage_3)
						);

mux2to1_32bit mux4(
						.In1(stage_3),
						.In2({{8{stage_3[31]}},stage_3[31:8]}),
						.sel(ShAm[3]),
						.out(stage_2)
						);

mux2to1_32bit mux3(
						.In1(stage_2),
						.In2({{4{stage_2[31]}},stage_2[31:4]}),
						.sel(ShAm[2]),
						.out(stage_1)
						);
mux2to1_32bit mux2(
						.In1(stage_1),
						.In2({{2{stage_1[31]}},stage_1[31:2]}),
						.sel(ShAm[1]),
						.out(stage_0)
						);
mux2to1_32bit mux1(
						.In1(stage_0),
						.In2({stage_0[31],stage_0[31:1]}),
						.sel(ShAm[0]),
						.out(OUT)
						);
									 
endmodule




/////////////////////
//Shift Right Logic//
/////////////////////
module ShiftRight_Logic(
							input logic [31:0] In,
							input logic [4:0] ShAm,
							output logic [31:0] OUT
							);
wire [31:0] stage_0;
wire [31:0] stage_1;
wire [31:0] stage_2;
wire [31:0] stage_3;

mux2to1_32bit mux5(
						.In1(In),
						.In2({16'b0,In[31:16]}),
						.sel(ShAm[4]),
						.out(stage_3)
						);

mux2to1_32bit mux4(
						.In1(stage_3),
						.In2({8'b0,stage_3[31:8]}),
						.sel(ShAm[3]),
						.out(stage_2)
						);

mux2to1_32bit mux3(
						.In1(stage_2),
						.In2({4'b0,stage_2[31:4]}),
						.sel(ShAm[2]),
						.out(stage_1)
						);
mux2to1_32bit mux2(
						.In1(stage_1),
						.In2({2'b0,stage_1[31:2]}),
						.sel(ShAm[1]),
						.out(stage_0)
						);
mux2to1_32bit mux1(
						.In1(stage_0),
						.In2({1'b0,stage_0[31:1]}),
						.sel(ShAm[0]),
						.out(OUT)
						);
endmodule




////////////////////
//Shift Left Logic//
////////////////////
module ShiftLeft_Logic(
							input logic [31:0] In,
							input logic [4:0] ShAm,
							output logic [31:0] OUT
							);
wire [31:0] stage_0;
wire [31:0] stage_1;
wire [31:0] stage_2;
wire [31:0] stage_3;

mux2to1_32bit mux5(
						.In1(In),
						.In2({In[15:0],16'b0}),
						.sel(ShAm[4]),
						.out(stage_3)
						);

mux2to1_32bit mux4(
						.In1(stage_3),
						.In2({stage_3[23:0],8'b0}),
						.sel(ShAm[3]),
						.out(stage_2)
						);

mux2to1_32bit mux3(
						.In1(stage_2),
						.In2({stage_2[27:0],4'b0}),
						.sel(ShAm[2]),
						.out(stage_1)
						);
mux2to1_32bit mux2(
						.In1(stage_1),
						.In2({stage_1[29:0],2'b0}),
						.sel(ShAm[1]),
						.out(stage_0)
						);
mux2to1_32bit mux1(
						.In1(stage_0),
						.In2({stage_0[30:0],1'b0}),
						.sel(ShAm[0]),
						.out(OUT)
						);
endmodule



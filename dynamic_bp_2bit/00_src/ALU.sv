///////////////////
//ALU Full Module//
///////////////////
/*
This ALU can operates 10 differents instructions as below

Input: i_op_a - 32bit
Input: i_op_b - 32bit
Output: o_alu_data - 32bit
Input: i_alu_op - 4bit
*/

module ALU(i_op_a, i_op_b, i_alu_op, o_alu_data);
parameter N = 32;
input logic [N-1:0] i_op_a;    		//First operand for ALU operations - 32bit
input logic [N-1:0] i_op_b;    		//Second operand for ALU operations - 32bit
input logic [3:0] i_alu_op;    		//The opcode of the operation - 4bit
output logic [N-1:0] o_alu_data;	//Result of the ALU operation - 32bit

//Operation Opcodes
parameter ADD  = 4'b0000;
parameter SUB  = 4'b0001;

parameter SLT  = 4'b0010;
parameter SLTU = 4'b0011;

parameter SRL  = 4'b0100;
parameter SLL  = 4'b0101;
parameter SRA  = 4'b0110;

parameter XOR  = 4'b1000;
parameter OR   = 4'b1001;
parameter AND  = 4'b1010;
	
wire [N-1:0] AU_out;
wire [N-1:0] LU_out;
	
AU AU(
		.In1_AU(i_op_a),
		.In2_AU(i_op_b),
		.AU_opcode(i_alu_op[2:0]),
		.OUT_AU(AU_out)
		);
LU LU(
		.In1_LU(i_op_a),
		.In2_LU(i_op_b),
		.LU_opcode(i_alu_op[1:0]),
		.OUT_LU(LU_out)
		);

mux2to1_32bit mux2to1(
						.In1(AU_out),
						.In2(LU_out),
						.sel(i_alu_op[3]),
						.out(o_alu_data)
					);

endmodule

//----------------------------------Sub_Modules----------------------------------

///////////////////
//Arithmetic Unit//
//////////////////
/*
It contains 7 different arithmetic operations
*/
module AU(
			input logic [31:0] In1_AU,
			input logic [31:0] In2_AU,
			input logic [2:0] AU_opcode,
			output logic [31:0] OUT_AU
			);
parameter N = 32;


wire carry_o;
wire [N-1:0] Add_Sub;
wire SetLessThan;
wire [N-1:0] Shift;

wire addsub_sel;
mux2to1 mux_adder(.In1(1'b0), .In2(1'b1), .sel(AU_opcode[0]), .out(addsub_sel));

adder_32bit adder_subtractor(
						.A(In1_AU),
						.B(In2_AU),
						.sel(addsub_sel),
						.OUT(Add_Sub),
						.CarryOut(carry_o)
						);

wire cmp_sel;
mux2to1 mux_compare(.In1(1'b0), .In2(1'b1), .sel(AU_opcode[0]), .out(cmp_sel));						
comparator_lt set_lt_signed(
									.A(In1_AU),
									.B(In2_AU),
									.sel_signed(cmp_sel),
									.AltB_o(SetLessThan)
									);
									
Shifter shifter(
							.In(In1_AU),
							.ShAm(In2_AU[4:0]),
							.Shift_sel(AU_opcode[1:0]),
							.OUT(Shift)
							);
														
mux4to1_32bit mux4to1(
						.In1(Add_Sub),
						.In2({{31'b0},SetLessThan}),
						.In3(Shift),
						.In4(Shift),
						.sel(AU_opcode[2:1]),
						.out(OUT_AU)
						);
endmodule


//////////////
//Logic Unit//
/////////////
/*
It contains 3 different logic operations
*/
module LU(
			input logic [31:0] In1_LU,
			input logic [31:0] In2_LU,
			input logic [1:0] LU_opcode,
			output logic [31:0] OUT_LU
			);
parameter N = 32;
wire [N-1:0] XOR_gates;
wire [N-1:0] OR_gates;
wire [N-1:0] AND_gates;

Logic_Unit XOR_alu(
						.A(In1_LU),
						.B(In2_LU),
						.sel_func(2'b00),
						.OUT(XOR_gates)
						);

Logic_Unit OR_alu(
						.A(In1_LU), 
						.B(In2_LU),
						.sel_func(2'b01),
						.OUT(OR_gates)
						);

Logic_Unit AND_alu(
						.A(In1_LU),
						.B(In2_LU),
						.sel_func(2'b10),
						.OUT(AND_gates)
						);
						
mux4to1_32bit mux4to1(
					.In1(XOR_gates),
					.In2(OR_gates),
					.In3(AND_gates),
					.In4(32'b0), 
					.sel(LU_opcode),
					.out(OUT_LU)
					);						
endmodule
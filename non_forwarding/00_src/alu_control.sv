module alu_control(
						input logic [2:0] funct3,
						input logic funct7,			//Bit number 5 of funct7
						input logic [1:0] ALU_op,
						input logic opcode_bit5,
						output logic [3:0] Opcode
						);
logic [3:0] addsub_no_imm;
logic [3:0] IRType_out;
logic [3:0] addsub;
logic [3:0] out_SRA_SRL;

mux2to1_4bit mux_addsub(
						.In1(4'b0000),
						.In2(4'b0001),
						.sel(funct7),
						.out(addsub_no_imm)
						);					

mux2to1_4bit mux_IR_ADDSUB(
						.In1(4'b0000),
						.In2(addsub_no_imm),
						.sel(opcode_bit5),
						.out(addsub)
						  );
				
mux2to1_4bit mux_SRA_SRL(
						.In1(4'b0100),
						.In2(4'b0110),
						.sel(funct7),
						.out(out_SRA_SRL)
						);					
						
mux8to1_4bit mux_IRType(
						.In1(addsub),
						.In2(4'b0101),
						.In3(4'b0010),
						.In4(4'b0011),
						.In5(4'b1000),
						.In6(out_SRA_SRL),
						.In7(4'b1001),
						.In8(4'b1010),
						.sel(funct3),
						.out(IRType_out)
						);
					
						
mux4to1_4bit mux_output(
						.In1(4'b0),
						.In2(IRType_out),
						.In3(4'b0),
						.In4(4'b0),
						.sel(ALU_op),
						.out(Opcode)
						);
endmodule 

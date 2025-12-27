////////////////////
//MUX 2 to 1 32bit//
////////////////////
module mux2to1_32bit(
							input logic [31:0]In1,
							input logic [31:0]In2,
							input logic sel,
							output logic [31:0] out
							);			
genvar i;
generate
	for(i=0; i<32; i=i+1) begin: mux2to1_gen
		mux2to1 mux2to1(
							 .In1(In1[i]),
							 .In2(In2[i]),
							 .sel(sel),
							 .out(out[i]));
	end
endgenerate
endmodule

//----------------------------Sub_Modules-----------------------------//

////////////////
// MUX 4 to 1 //
///////////////
module mux4to1(
    input  logic In1,
    input  logic In2,
    input  logic In3,
    input  logic In4,
    input  logic [1:0] sel,
    output logic out
);
    wire stage1_1, stage1_2;

    mux2to1 m1(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage1_1));
    mux2to1 m2(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage1_2));
    mux2to1 m3(.In1(stage1_1), .In2(stage1_2), .sel(sel[1]), .out(out));
endmodule


////////////////
// MUX 2 to 1 //
////////////////
module mux2to1(
    input  logic In1,
    input  logic In2,
    input  logic sel,
    output logic out
);
    assign out = sel ? In2 : In1;
endmodule

/////////////////////
// MUX 2 to 1  5bit//
/////////////////////
module mux2to1_5bit(
    input  logic [4:0] In1,
    input  logic [4:0] In2,
    input  logic sel,
    output logic [4:0] out
);
    assign out = sel ? In2 : In1;
endmodule


////////////////////
//MUX 4 to 1 32bit//
////////////////////
module mux4to1_32bit(
					input logic [31:0]In1,
					input logic [31:0]In2,
					input logic [31:0]In3,
					input logic [31:0]In4, 
					input logic [1:0] sel,
					output logic [31:0]out
					);
wire [31:0]stage1_1;
wire [31:0]stage1_2;

//stage_0
mux2to1_32bit mux1(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage1_1));
mux2to1_32bit mux2(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage1_2));

//stage_1
mux2to1_32bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[1]), .out(out));
endmodule

////////////////////
//MUX 8 to 1 32bit//
////////////////////
module mux8to1_32bit(
					input logic [31:0]In1,
					input logic [31:0]In2,
					input logic [31:0]In3,
					input logic [31:0]In4,
					input logic [31:0]In5,
					input logic [31:0]In6,
					input logic [31:0]In7,
					input logic [31:0]In8,
					input logic [2:0] sel,
					output logic [31:0]out
					);
wire [31:0]stage1_1;
wire [31:0]stage1_2;
wire [31:0]stage2_1;
wire [31:0]stage2_2;
wire [31:0]stage2_3;
wire [31:0]stage2_4;

//stage_0
mux2to1_32bit mux4(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage2_1));
mux2to1_32bit mux5(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage2_2));
mux2to1_32bit mux6(.In1(In5), .In2(In6), .sel(sel[0]), .out(stage2_3));
mux2to1_32bit mux7(.In1(In7), .In2(In8), .sel(sel[0]), .out(stage2_4));

//stage_1
mux2to1_32bit mux1(.In1(stage2_1), .In2(stage2_2), .sel(sel[1]), .out(stage1_1));
mux2to1_32bit mux2(.In1(stage2_3), .In2(stage2_4), .sel(sel[1]), .out(stage1_2));

//stage_2
mux2to1_32bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[2]), .out(out));
endmodule


/////////////////////
//MUX 16 to 1 32bit//
/////////////////////
module mux16to1_32bit(
							input logic [31:0]In1,
							input logic [31:0]In2,
							input logic [31:0]In3,
							input logic [31:0]In4,
							input logic [31:0]In5,
							input logic [31:0]In6,
							input logic [31:0]In7,
							input logic [31:0]In8,
							input logic [31:0]In9,
							input logic [31:0]In10,
							input logic [31:0]In11,
							input logic [31:0]In12,
							input logic [31:0]In13,
							input logic [31:0]In14,
							input logic [31:0]In15,
							input logic [31:0]In16,
							input logic [3:0] sel,
							output logic [31:0]out
							);
wire [31:0] stage1_1;
wire [31:0] stage1_2;							
					
//Stage_1					
mux8to1_32bit mux1(
					.In1(In1),
					.In2(In2),
					.In3(In3),
					.In4(In4),
					.In5(In5),
					.In6(In6),
					.In7(In7),
					.In8(In8),
					.sel(sel[2:0]),
					.out(stage1_1)
					);
					

mux8to1_32bit mux2(
					.In1(In9),
					.In2(In10),
					.In3(In11),
					.In4(In12),
					.In5(In13),
					.In6(In14),
					.In7(In15),
					.In8(In16),
					.sel(sel[2:0]),
					.out(stage1_2)
					);
					
//Stage_2
mux2to1_32bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[3]), .out(out));
endmodule





///////////////////////
//MUX 32 to 1 - 32bit//
///////////////////////
module mux32to1(
					input logic [31:0]In1,
					input logic [31:0]In2,
					input logic [31:0]In3,
					input logic [31:0]In4,
					input logic [31:0]In5,
					input logic [31:0]In6,
					input logic [31:0]In7,
					input logic [31:0]In8,
					input logic [31:0]In9,
					input logic [31:0]In10,
					input logic [31:0]In11,
					input logic [31:0]In12,
					input logic [31:0]In13,
					input logic [31:0]In14,
					input logic [31:0]In15,
					input logic [31:0]In16,
					
					input logic [31:0]In17,
					input logic [31:0]In18,
					input logic [31:0]In19,
					input logic [31:0]In20,
					input logic [31:0]In21,
					input logic [31:0]In22,
					input logic [31:0]In23,
					input logic [31:0]In24,
					input logic [31:0]In25,
					input logic [31:0]In26,
					input logic [31:0]In27,
					input logic [31:0]In28,
					input logic [31:0]In29,
					input logic [31:0]In30,
					input logic [31:0]In31,
					input logic [31:0]In32,
					input logic [4:0] sel,
					output logic [31:0]out
					);
					
wire [31:0] stage1_1;
wire [31:0] stage1_2;							
					
//Stage_1					
mux16to1_32bit mux1(
							.In1(In1),
							.In2(In2),
							.In3(In3),
							.In4(In4),
							.In5(In5),
							.In6(In6),
							.In7(In7),
							.In8(In8),
							
							.In9(In9),
							.In10(In10),
							.In11(In11),
							.In12(In12),
							.In13(In13),
							.In14(In14),
							.In15(In15),
							.In16(In16),
							.sel(sel[3:0]),
							.out(stage1_1)
							);
					

mux16to1_32bit mux2(
							.In1(In17),
							.In2(In18),
							.In3(In19),
							.In4(In20),
							.In5(In21),
							.In6(In22),
							.In7(In23),
							.In8(In24),
							
							.In9(In25),
							.In10(In26),
							.In11(In27),
							.In12(In28),
							.In13(In29),
							.In14(In30),
							.In15(In31),
							.In16(In32),
							.sel(sel[3:0]),
							.out(stage1_2)
							);
								
//Stage_2
mux2to1_32bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[4]), .out(out));			
endmodule

////////////////
//Demux 1 to 2//
////////////////
module demux1to2(
					 input logic in,
					 input logic sel,
					 output logic out0,
					 output logic out1
					 );
assign out0 = in&~sel;
assign out1 = in&sel; 
endmodule


////////////////////
//MUX 2 to 1 24bit//
////////////////////
module mux2to1_24bit(
							input logic [23:0]In1,
							input logic [23:0]In2,
							input logic sel,
							output logic [23:0] out
							);			
genvar i;
generate
	for(i=0; i<24; i=i+1) begin: mux2to1_gen
		mux2to1 mux2to1(
							 .In1(In1[i]),
							 .In2(In2[i]),
							 .sel(sel),
							 .out(out[i]));
	end
endgenerate
endmodule


////////////////////
//MUX 2 to 1 16bit//
////////////////////
module mux2to1_16bit(
							input logic [15:0]In1,
							input logic [15:0]In2,
							input logic sel,
							output logic [15:0] out
							);			
genvar i;
generate
	for(i=0; i<16; i=i+1) begin: mux2to1_gen
		mux2to1 mux2to1(
							 .In1(In1[i]),
							 .In2(In2[i]),
							 .sel(sel),
							 .out(out[i]));
	end
endgenerate
endmodule


////////////////////
//MUX 2 to 1 8bit//
////////////////////
module mux2to1_8bit(
							input logic [7:0]In1,
							input logic [7:0]In2,
							input logic sel,
							output logic [7:0] out
							);			
genvar i;
generate
	for(i=0; i<8; i=i+1) begin: mux2to1_gen
		mux2to1 mux2to1(
							 .In1(In1[i]),
							 .In2(In2[i]),
							 .sel(sel),
							 .out(out[i]));
	end
endgenerate
endmodule



////////////////////
//MUX 2 to 1 4bit//
////////////////////
module mux2to1_4bit(
							input logic [3:0]In1,
							input logic [3:0]In2,
							input logic sel,
							output logic [3:0] out
							);			
genvar i;
generate
	for(i=0; i<4; i=i+1) begin: mux2to1_gen
		mux2to1 mux2to1(
							 .In1(In1[i]),
							 .In2(In2[i]),
							 .sel(sel),
							 .out(out[i]));
	end
endgenerate
endmodule


////////////////////
//MUX 8 to 1 4bit//
////////////////////
module mux8to1_4bit(
					input logic [3:0]In1,
					input logic [3:0]In2,
					input logic [3:0]In3,
					input logic [3:0]In4,
					input logic [3:0]In5,
					input logic [3:0]In6,
					input logic [3:0]In7,
					input logic [3:0]In8,
					input logic [2:0] sel,
					output logic [3:0]out
					);
wire [3:0]stage1_1;
wire [3:0]stage1_2;
wire [3:0]stage2_1;
wire [3:0]stage2_2;
wire [3:0]stage2_3;
wire [3:0]stage2_4;

//stage_0
mux2to1_4bit mux4(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage2_1));
mux2to1_4bit mux5(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage2_2));
mux2to1_4bit mux6(.In1(In5), .In2(In6), .sel(sel[0]), .out(stage2_3));
mux2to1_4bit mux7(.In1(In7), .In2(In8), .sel(sel[0]), .out(stage2_4));

//stage_1
mux2to1_4bit mux1(.In1(stage2_1), .In2(stage2_2), .sel(sel[1]), .out(stage1_1));
mux2to1_4bit mux2(.In1(stage2_3), .In2(stage2_4), .sel(sel[1]), .out(stage1_2));

//stage_2
mux2to1_4bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[2]), .out(out));
endmodule



////////////////////
//MUX 4 to 1 4bit//
////////////////////
module mux4to1_4bit(
					input logic [3:0]In1,
					input logic [3:0]In2,
					input logic [3:0]In3,
					input logic [3:0]In4, 
					input logic [1:0] sel,
					output logic [3:0]out
					);
wire [3:0]stage1_1;
wire [3:0]stage1_2;

//stage_0
mux2to1_4bit mux1(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage1_1));
mux2to1_4bit mux2(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage1_2));

//stage_1
mux2to1_4bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[1]), .out(out));
endmodule


////////////////////
//MUX 4 to 1 5bit//
////////////////////
module mux4to1_5bit(
					input logic [4:0]In1,
					input logic [4:0]In2,
					input logic [4:0]In3,
					input logic [4:0]In4, 
					input logic [1:0] sel,
					output logic [4:0]out
					);
wire [4:0]stage1_1;
wire [4:0]stage1_2;

//stage_0
mux2to1_5bit mux1(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage1_1));
mux2to1_5bit mux2(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage1_2));

//stage_1
mux2to1_5bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[1]), .out(out));
endmodule




////////////////////
//MUX 4 to 1 8bit//
////////////////////
module mux4to1_8bit(
					input logic [7:0] In1,
					input logic [7:0] In2,
					input logic [7:0] In3,
					input logic [7:0] In4, 
					input logic [1:0] sel,
					output logic [7:0] out
					);
wire [7:0]stage1_1;
wire [7:0]stage1_2;

//stage_0
mux2to1_8bit mux1(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage1_1));
mux2to1_8bit mux2(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage1_2));

//stage_1
mux2to1_8bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[1]), .out(out));
endmodule


module regfile(
					input logic 		 i_clk,
					input logic 		 i_reset,
					input logic [4:0]  i_rs1_addr,
					input logic [4:0]  i_rs2_addr,
					input logic [4:0]  i_rd_addr,
					input logic [31:0] i_rd_data,
					input logic 		 i_rd_wren,
					
					output logic [31:0] o_rs1_data,
					output logic [31:0] o_rs2_data
					);
logic [31:0] rd_WE;

logic [31:0] register_out [31:0];

decoder5to32 decoder(
							.in(i_rd_addr),
							.WE(i_rd_wren),
							.out(rd_WE)
							);	

register_32bit register_x0(
							.data_in(32'b0),
							.load(1'b0),
							.clear(i_reset),
							.clk(i_clk),
							.OUT(register_out[0])
							);
	
							
genvar i;
generate
	for(i=1; i<32; i=i+1) begin : register
		register_32bit register(
							.data_in(i_rd_data),
							.load(rd_WE[i]),
							.clear(i_reset),
							.clk(i_clk),
							.OUT(register_out[i])
							);
	end
endgenerate							
							

mux32to1 mux1(
					.In1(register_out[0]),
					.In2(register_out[1]),
					.In3(register_out[2]),
					.In4(register_out[3]),
					.In5(register_out[4]),
					.In6(register_out[5]),
					.In7(register_out[6]),
					.In8(register_out[7]),
					.In9(register_out[8]),
					.In10(register_out[9]),
					.In11(register_out[10]),
					.In12(register_out[11]),
					.In13(register_out[12]),
					.In14(register_out[13]),
					.In15(register_out[14]),
					.In16(register_out[15]),
					
					.In17(register_out[16]),
					.In18(register_out[17]),
					.In19(register_out[18]),
					.In20(register_out[19]),
					.In21(register_out[20]),
					.In22(register_out[21]),
					.In23(register_out[22]),
					.In24(register_out[23]),
					.In25(register_out[24]),
					.In26(register_out[25]),
					.In27(register_out[26]),
					.In28(register_out[27]),
					.In29(register_out[28]),
					.In30(register_out[29]),
					.In31(register_out[30]),
					.In32(register_out[31]),
					.sel(i_rs1_addr),
					.out(o_rs1_data)
					);							

mux32to1 mux2(
					.In1(register_out[0]),
					.In2(register_out[1]),
					.In3(register_out[2]),
					.In4(register_out[3]),
					.In5(register_out[4]),
					.In6(register_out[5]),
					.In7(register_out[6]),
					.In8(register_out[7]),
					.In9(register_out[8]),
					.In10(register_out[9]),
					.In11(register_out[10]),
					.In12(register_out[11]),
					.In13(register_out[12]),
					.In14(register_out[13]),
					.In15(register_out[14]),
					.In16(register_out[15]),
					
					.In17(register_out[16]),
					.In18(register_out[17]),
					.In19(register_out[18]),
					.In20(register_out[19]),
					.In21(register_out[20]),
					.In22(register_out[21]),
					.In23(register_out[22]),
					.In24(register_out[23]),
					.In25(register_out[24]),
					.In26(register_out[25]),
					.In27(register_out[26]),
					.In28(register_out[27]),
					.In29(register_out[28]),
					.In30(register_out[29]),
					.In31(register_out[30]),
					.In32(register_out[31]),
					.sel(i_rs2_addr),
					.out(o_rs2_data)
					);
endmodule

//-------------------------------Sub_Modules---------------------------------//

////////////////////
//DECODER 5 to 32 //
////////////////////
module decoder5to32(in, WE, out);
input logic [4:0] in;
input logic WE;
output logic [31:0] out;

always_comb begin
	out = 32'b0;
	if(WE) out[in] = 1'b1;
end
endmodule


////////////////////
//REGISTER - 32bit//
////////////////////
module register_32bit(
							input logic [31:0] data_in,
							input logic load,
							input logic clear,
							input logic clk,
							output reg [31:0] OUT
							);
genvar i;
generate
	for(i=0; i<32; i=i+1) begin : FlipFlop
			D_FF_Load D_FlipFlop(
										.Data(data_in[i]),
										.clk(clk),
										.RST(clear),
										.Load(load),
										.Q(OUT[i])
										);							
	end
endgenerate
endmodule



/////////////////////////////////
//D - Flipflop with Load Enable//
/////////////////////////////////
module D_FF_Load(
						input logic Data,
						input logic clk,
						input logic RST,
						input logic Load,
						output reg Q
					  );
wire mux_out;
D_FF D_FlipFlop(
					.D(mux_out),
					.RST(RST),
					.clk(clk),
					.Q(Q)
					);					  
mux2to1 mux2to1(
					.In1(Q),
					.In2(Data),
					.sel(Load),
					.out(mux_out)
					);
endmodule  



///////////////////////////
//D - Flipflop with Reset//
///////////////////////////
module D_FF(
				input logic D,
				input logic RST,
				input logic clk,
				output reg Q
				);		
always_ff@(posedge clk or posedge RST) begin
	if(RST) Q <= 1'b0;
	else Q <= D;
end
endmodule 


///////////////////////////
//REGISTER for LSU- 32bit//
///////////////////////////
module register_LSU_32bit(
							input logic [31:0] data_in,
							input logic load,
							input logic word,
							input logic half,
							input logic clear,
							input logic clk,
							output reg [31:0] OUT
							);

logic load_byte1;
assign load_byte1 = (word&load)|(half&load);

register_8bit byte3(
					.data_in(data_in[31:24]),
					.load(word&load),
					.clear(clear),
					.clk(clk),
					.OUT(OUT[31:24])
					);


register_8bit byte2(
					.data_in(data_in[23:16]),
					.load(word&load),
					.clear(clear),
					.clk(clk),
					.OUT(OUT[23:16])
					);


register_8bit byte1(
					.data_in(data_in[15:8]),
					.load(load_byte1),
					.clear(clear),
					.clk(clk),
					.OUT(OUT[15:8])
					);

register_8bit byte0(
					.data_in(data_in[7:0]),
					.load(load),
					.clear(clear),
					.clk(clk),
					.OUT(OUT[7:0])
					);						
endmodule



////////////////////
//REGISTER - 8bit///
////////////////////
module register_8bit(
							input logic [7:0] data_in,
							input logic load,
							input logic clear,
							input logic clk,
							output reg [7:0] OUT
							);
genvar i;
generate
	for(i=0; i<8; i=i+1) begin : FlipFlop
			D_FF_Load D_FlipFlop(
										.Data(data_in[i]),
										.clk(clk),
										.RST(clear),
										.Load(load),
										.Q(OUT[i])
										);							
	end
endgenerate
endmodule



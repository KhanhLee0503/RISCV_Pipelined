/*------comparator_lt - so sanh so co dau va khong dau-------
*Input-32bit: A,B
*Input-1bit: sel_signed (Neu = 0 thi so sanh so co dau, nguoc lai thi so sanh so khong dau)
*Output-32bit: AltB_o (Neu A<B thi AltB_o = 1)
*/

module comparator_lt(
							A,
							B,
							sel_signed,
							AltB_o);
parameter N = 32;
parameter AltB_i = 1'b1;
parameter AgtB_i = 1'b0;
input logic [N-1:0] A;
input logic [N-1:0] B;
input logic sel_signed;
output logic AltB_o;

wire unused_gt;
wire unused_eq;
wire outbar;
wire out_signed;

   comparator_32bit com1(.in_1(A), .in_2(B), .AltB(outbar), .AgtB(unused_gt), .AeqB(unused_eq));
	mux4to1 mux4to1(.In1(outbar), .In2(AgtB_i), .In3(AltB_i), .In4(outbar), .sel({A[N-1],B[N-1]}), .out(out_signed));
	mux2to1 mux2to1(.In1(out_signed), .In2(outbar), .sel(sel_signed), .out(AltB_o));
endmodule

//-------------------------------Sub_Modules---------------------------------//

///////////////////////////
//Module Comparator 32 Bit//
///////////////////////////
module comparator_32bit(
								in_1,
								in_2,
								AgtB,
								AltB,
								AeqB
								);
parameter N = 32;

input logic [N-1:0] in_1;
input logic [N-1:0] in_2;
output logic AgtB;
output logic AltB;
output logic AeqB;

wire [8:0] AltB_ex;
wire [8:0] AeqB_ex;
wire [8:0] AgtB_ex;

assign AeqB_ex[0] = 1;
assign AltB_ex[0] = 0;
assign AgtB_ex[0] = 0;

genvar i;
genvar j;
generate
	for(j=0; j<8; j=j+1) begin : cmp_block
		localparam i=j*4;
		comparator_4bit c(.A(in_1[i+3:i]),
								.B(in_2[i+3:i]),
								.AgtB_i(AgtB_ex[j]),
								.AltB_i(AltB_ex[j]),
								.AeqB_i(AeqB_ex[j]),
								.AgtB_o(AgtB_ex[j+1]),
								.AeqB_o(AeqB_ex[j+1]),
								.AltB_o(AltB_ex[j+1]));
	end
endgenerate

assign AgtB = AgtB_ex[8];
assign AeqB = AeqB_ex[8];
assign AltB = AltB_ex[8];

endmodule




///////////////////////////
//Module Comparator 4 Bit//
///////////////////////////
module comparator_4bit( 
						 input logic [3:0]A, B,
						 input logic AgtB_i,
						 input logic AeqB_i,
						 input logic AltB_i,
                   output logic AgtB_o,
                   output logic AltB_o,
                   output logic AeqB_o
                      );				 
//Compare bit_0
wire AeqB_0;
wire AltB_0;
wire AgtB_0;

//Compare bit_1
wire AeqB_1;
wire AltB_1;
wire AgtB_1;

//Compare bit_2
wire AeqB_2;
wire AltB_2;
wire AgtB_2;

//Compare bit_3
wire AeqB_3;
wire AltB_3;
wire AgtB_3;
					 

comparator_1bit c3(.A(A[3]), .B(B[3]), .AgtB(AgtB_3), .AltB(AltB_3), .AeqB(AeqB_3));
comparator_1bit c2(.A(A[2]), .B(B[2]), .AgtB(AgtB_2), .AltB(AltB_2), .AeqB(AeqB_2));
comparator_1bit c1(.A(A[1]), .B(B[1]), .AgtB(AgtB_1), .AltB(AltB_1), .AeqB(AeqB_1));
comparator_1bit c0(.A(A[0]), .B(B[0]), .AgtB(AgtB_0), .AltB(AltB_0), .AeqB(AeqB_0));

assign AeqB_o = AeqB_3&AeqB_2&AeqB_1&AeqB_0&AeqB_i;
assign AgtB_o = AgtB_3 | (AeqB_3 & AgtB_2) | (AeqB_3 & AeqB_2 & AgtB_1) | (AeqB_3 & AeqB_2 & AeqB_1 & AgtB_0) | (AeqB_3 & AeqB_2 & AeqB_1 & AeqB_0 & AgtB_i);
assign AltB_o = AltB_3 | (AeqB_3 & AltB_2) | (AeqB_3 & AeqB_2 & AltB_1) | (AeqB_3 & AeqB_2 & AeqB_1 & AltB_0) | (AeqB_3 & AeqB_2 & AeqB_1 & AeqB_0 & AltB_i);
endmodule



///////////////////////////
//Module Comparator 1 Bit//
///////////////////////////
module comparator_1bit(
							  input logic A,B,
							  output logic AgtB, 		//Output when A>B
							  output logic AltB,			//Output when A<B
							  output logic AeqB			//Output when A=B
							  );
assign AeqB = A~^B;
assign AgtB = A&~B;
assign AltB = ~A&B;
endmodule		



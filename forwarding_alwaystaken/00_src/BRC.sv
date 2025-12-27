///////////////////////
//Branch Comparision//
//////////////////////
/*
	INPUT:	i_rs1_data (Data from the first register)
	INPUT:	i_rs2_data (Data from the second register)
	INPUT:	i_br_un (Comparision Mode) - (1 is signed, 0 is unsigned)
	OUTPUT: 	o_br_equal (output is 1 if rs1 = rs2)
	OUTPUT: 	o_br_less (output is 1 if rs1 < rs2)
*/
module BRC(i_rs1_data, i_rs2_data, i_br_un, o_br_less, o_br_equal);
parameter N = 32;
input [N-1:0] i_rs1_data;
input [N-1:0] i_rs2_data;
input i_br_un;
output o_br_less;
output o_br_equal;

wire sel_signed;
assign sel_signed = ~i_br_un;
comparator_lt_equal brc1(.A(i_rs1_data), .B(i_rs2_data), .sel_signed(sel_signed), .AltB_o(o_br_less), .AeqB_o(o_br_equal));
endmodule


//--------------------------Sub_Modules---------------------------------//
/////////////////////////////////
//Comparator Equal or Less Than//
/////////////////////////////////
module comparator_lt_equal(A, B, sel_signed, AltB_o, AeqB_o);

parameter N = 32;
parameter AltB_i = 1'b1;
parameter AgtB_i = 1'b0;

input [N-1:0] A;
input [N-1:0] B;
input sel_signed;
output AltB_o;
output AeqB_o;

wire dummy;
wire outbar;
wire out_signed;

	comparator_32bit com1(.in_1(A), .in_2(B), .AltB(outbar), .AeqB(AeqB_o), .AgtB(dummy));

	mux4to1 mux1(.In1(outbar), .In2(AgtB_i), .In3(AltB_i), .In4(outbar), .sel({A[N-1],B[N-1]}), .out(out_signed));
	mux2to1 mux2(.In1(out_signed), .In2(outbar), .sel(sel_signed), .out(AltB_o));

endmodule

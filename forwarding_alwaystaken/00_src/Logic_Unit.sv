module Logic_Unit(
						input logic [1:0]sel_func,
						input logic [31:0] A,B,
						output logic [31:0] OUT
						);
/*
	sel_func = 00 => Use XOR function
	sel_func = 01 => Use OR function
	sel_func = 10 => Use AND function
*/	
wire [31:0] XOR_wire;
wire [31:0] OR_wire;
wire [31:0] AND_wire;				
wire [31:0] dummy = 32'b0;

XOR_32bit xor_32bit(.a(A), .b(B), .s(XOR_wire));
OR_32bit or_32bit(.a(A), .b(B), .s(OR_wire));
AND_32bit and_32bit(.a(A), .b(B), .s(AND_wire));		
mux4to1_32bit mux4to1_32bit(.In1(XOR_wire), .In2(OR_wire), .In3(AND_wire), .In4(dummy), .sel(sel_func), .out(OUT));
						
endmodule


//---------------------Sub_Modules-----------------------//



////////////////
// XOR 32 bit //
////////////////
module XOR_32bit(a,b,s);
			parameter n= 32;
			input logic[n-1:0] a,b;
			output logic[n-1:0] s;
			
			genvar i;
			generate
				for(i=0;i<n;i=i+1) begin : XOR_32bit
				assign s[i]=a[i]^b[i];
				end
			endgenerate
endmodule

////////////////
// AND 32 bit //
////////////////
module AND_32bit(a,b,s);
			parameter n= 32;
			input logic[n-1:0] a,b;
			output logic[n-1:0] s;
			
			genvar i;
			generate
				for(i=0;i<n;i=i+1) begin : AND_32bit
				assign s[i]=a[i]&b[i];
				end
			endgenerate
endmodule			

////////////////
// OR 32 bit //
////////////////
module OR_32bit(a,b,s);
			parameter n= 32;
			input logic[n-1:0] a,b;
			output logic[n-1:0] s;
			
			genvar i;
			generate
				for(i=0;i<n;i=i+1) begin : OR_32bit
				assign s[i]=a[i]|b[i];
				end
			endgenerate
endmodule	


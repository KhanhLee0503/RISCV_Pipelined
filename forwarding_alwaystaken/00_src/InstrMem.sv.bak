module InstrMem(
					input logic [12:0] i_addr,
					output logic [31:0] o_rdata
					);
					
logic [31:0] mem_word [0:2047];

initial begin
	//$readmemh("C:/SystemVerilog/Milestone3/forwarding/02_test/dump/isa_4b.hex", mem_word);
	$readmemh("C:/SystemVerilog/Milestone3/non_forward/02_test/dump/phepnhan.hex", mem_word);
	//$readmemh("C:/SystemVerilog/Milestone3/non_forward/02_test/dump/test_jump3.hex", mem_word);
end

always_comb begin
	o_rdata = mem_word[i_addr[12:2]];
end
endmodule

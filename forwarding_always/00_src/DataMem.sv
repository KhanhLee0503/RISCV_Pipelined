module DataMem(
    input  logic        i_clk, 
    input  logic [15:0] i_addr,
    input  logic [31:0] i_wdata,
    input  logic [3:0]  i_bmask,
    input  logic        i_wren,
    output logic [31:0] o_rdata
);

logic [13:0] word_addr;
assign word_addr = i_addr[15:2];

reg [31:0] mem_word [0:16383];

initial begin
	//$readmemh("/home/yellow/ktmt_l01_l02_6/workspace/singlecyle_test/02_test/dump/reset.hex", mem_word);
    $readmemh("C:/SystemVerilog/Milestone3/non_forward/02_test/dump/reset.hex", mem_word);
end

  // --- Write Logic (Sequential) ---
always_ff @(posedge i_clk) begin
        if (i_wren) begin
            // Byte 0: i_wdata[7:0]
            if (i_bmask[0])  mem_word[word_addr][7:0] <= i_wdata[7:0];

            // Byte 1: i_wdata[15:8]
            if (i_bmask[1]) mem_word[word_addr][15:8] <= i_wdata[15:8];
            
            // Byte 2: i_wdata[23:16]
            if (i_bmask[2]) mem_word[word_addr][23:16] <= i_wdata[23:16];

            // Byte 3: i_wdata[31:24]
            if (i_bmask[3]) mem_word[word_addr][31:24] <= i_wdata[31:24];
        end
    end

/*
// --- Read Logic (Combinational) ---
always_comb begin
    if(!i_wren) begin
        o_rdata = mem_word[word_addr];
    end
    else begin
        o_rdata = 32'b0;
    end
end
*/


  // --- Read Logic (Combinational) ---
always_ff @(posedge i_clk) begin
    if(!i_wren) begin
        o_rdata = mem_word[word_addr];
    end
    else begin
        o_rdata = 32'b0;
    end
end

endmodule
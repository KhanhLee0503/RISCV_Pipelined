module Branch_Target_Buffer #(
    parameter ENTRY_NUM = 8192,
    parameter INDEX_BITS = $clog2(ENTRY_NUM), //Nếu ENTRY_NUM = 64 thì INDEX_BITS = 6
    parameter LOOKUP_INDEX_SIZE = INDEX_BITS-1,
    parameter LOOKUP_TAG_SIZE   = 31 - (INDEX_BITS+1)
)
(
    input logic clk,
    input logic reset,
    input logic actual_taken,
    input logic [31:0]  lookup_pc,
    input logic [INDEX_BITS-1:0] lookup_index,
    output logic        btb_hit,
    output logic [31:0] predicted_target,

    input logic         update_en,
    input logic [INDEX_BITS-1:0] update_index,
    input logic [31:0]  update_pc,
    input logic [31:0]  update_target
);

integer i;

//Nén các bit dưới đây lại thành 1 vector
typedef struct packed{
    logic valid;
    logic [LOOKUP_TAG_SIZE:0] tag;
    logic [31:0] target;
    //Optional (1bit predictor)
}btb_entry;


//------BTB Table-----
btb_entry btb_table [ENTRY_NUM];

//Tính toán tag
logic [LOOKUP_TAG_SIZE : 0]      lookup_tag;  
assign lookup_tag   = lookup_pc[31: INDEX_BITS+2];  //Lấy từ bit 8 tới bit 31


//------------------BTB_Lookup-------------------
always_comb begin
    if ((btb_table[lookup_index].valid) && (btb_table[lookup_index].tag == lookup_tag)) begin
        btb_hit = 1'b1;
        predicted_target = btb_table[lookup_index].target;
    end

    else begin
        btb_hit = 1'b0;
        predicted_target = 0;
    end
end


//--------------------BTB_Update---------------------
always_ff @(posedge clk or posedge reset) begin
      if (reset) begin
            for (i=0 ; i<ENTRY_NUM; i=i+1) begin
                btb_table[i].valid  <= 0;
                btb_table[i].tag    <= 0;
                btb_table[i].target <= 0;
            end
        end else if (update_en) begin
            btb_table[update_index].valid  <= 1;
            btb_table[update_index].tag    <= update_pc[31: INDEX_BITS+2];
            btb_table[update_index].target <= update_target;
        end
end

endmodule
module Branch_History_Table #(
    parameter ENTRY_NUM = 8192,
    parameter INDEX_BITS = $clog2(ENTRY_NUM),
    parameter TAG_BITS   = 32 - (INDEX_BITS + 2)   // PC[31 : INDEX_BITS+2]
)(
    input  logic        clk,
    input  logic        reset,

    // Lookup
    input  logic [31:0] lookup_pc,
    output logic        predict_taken,

    // Update
    input  logic        update_en,
    input  logic [31:0] update_pc,
    input  logic        actual_taken
);

    // BHT Entry
    typedef struct packed {
        logic          valid;
    //    logic [TAG_BITS-1:0] tag;
        logic [1:0]    counter;   // 2-bit predictor
    } bht_entry_t;

    bht_entry_t bht_table[ENTRY_NUM];

    integer i;

    // ----------- Index & Tag Extract -------------
    logic [INDEX_BITS-1:0] lookup_index;
    assign lookup_index = lookup_pc[INDEX_BITS+1 : 2];

  //  logic [TAG_BITS-1:0] lookup_tag;
  //  assign lookup_tag = lookup_pc[31 : INDEX_BITS+2];


    logic [INDEX_BITS-1:0] update_index;
    assign update_index = update_pc[INDEX_BITS+1 : 2];

   // logic [TAG_BITS-1:0] update_tag;
   // assign update_tag = update_pc[31 : INDEX_BITS+2];


    // ------------- Combinational Prediction ----------------
    always_comb begin
        if (bht_table[lookup_index].valid) //&&
           // bht_table[lookup_index].tag == lookup_tag)
        begin
            predict_taken = bht_table[lookup_index].counter[1];
        end
        else begin
            predict_taken = 1'b0; // default not taken
        end
    end


    // ----------------- Update Predictor -------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < ENTRY_NUM; i++) begin
                bht_table[i].valid    <= 1'b0;
               // bht_table[i].tag      <= '0;
                bht_table[i].counter  <= 2'b01;  // weak not taken
            end
        end
        else if (update_en) begin
            // If new entry (tag mismatch), reset counter
            if (!bht_table[update_index].valid)// ||
             //   (bht_table[update_index].tag != update_tag))
            begin
                bht_table[update_index].valid    <= 1'b1;
               // bht_table[update_index].tag      <= update_tag;
                bht_table[update_index].counter  <= actual_taken ? 2'b10 : 2'b01;
            end
            else begin
                // normal 2-bit update
                case (bht_table[update_index].counter)
                    2'b00: bht_table[update_index].counter <= actual_taken ? 2'b01 : 2'b00;
                    2'b01: bht_table[update_index].counter <= actual_taken ? 2'b10 : 2'b00;
                    2'b10: bht_table[update_index].counter <= actual_taken ? 2'b11 : 2'b01;
                    2'b11: bht_table[update_index].counter <= actual_taken ? 2'b11 : 2'b10;
                endcase
            end
        end
    end

endmodule

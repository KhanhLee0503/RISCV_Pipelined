module Global_Branch_History_Registers
#(
    parameter ENTRY_NUM = 8192,
    parameter GHR_WIDTH = $clog2(ENTRY_NUM),
    parameter INDEX_BITS = GHR_WIDTH
)
(
    input  logic clk,
    input  logic reset,

    // Update
    input  logic update_en,
    input  logic current_taken,

    // Lookup PC + Update PC
    input  logic [31:0] lookup_pc,
    input  logic [31:0] update_pc,

    // Snapshot
    input  logic [GHR_WIDTH-1:0] ghr_snapshot_in,
    output logic [GHR_WIDTH-1:0] ghr_snapshot_out,

    // Index outputs
    output logic [INDEX_BITS-1 : 0] lookup_index,
    output logic [INDEX_BITS-1 : 0] update_index
);

logic [GHR_WIDTH-1:0] ghr;

// Update GHR
always_ff @(posedge clk or posedge reset) begin
    if (reset)
        ghr <= '0;
    else if (update_en)
        ghr <= {ghr[GHR_WIDTH-2:0], current_taken};
end

// Snapshot out
assign ghr_snapshot_out = ghr;

// Lookup uses current GHR
assign lookup_index = ghr ^ lookup_pc[INDEX_BITS+1:2];

// Update uses old GHR snapshot
assign update_index = ghr_snapshot_in ^ update_pc[INDEX_BITS+1:2];

endmodule

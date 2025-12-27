`timescale 1ns / 1ns
module regfile_tb();

    // ----------------------------------------------------
    // 1. Signal and Golden Model Declaration
    // ----------------------------------------------------
    reg clk;
    reg reset;
    reg [4:0] rs1_addr;
    reg [4:0] rs2_addr;
    reg [4:0] rd_addr;
    reg [31:0] rd_data; 
    reg rd_wren;

    wire [31:0] rs1_output;
    wire [31:0] rs2_output;
    
    // REFERENCE MODEL: Stores the ideal values of the registers
    reg [31:0] golden_regfile [0:31]; 

    // Instance DUT (Device Under Test)
    regfile dut(.i_clk(clk),
                .i_reset(reset),
                .i_rs1_addr(rs1_addr),
                .i_rs2_addr(rs2_addr),
                .i_rd_addr(rd_addr),
                .i_rd_data(rd_data),
                .i_rd_wren(rd_wren),
                .o_rs1_data(rs1_output),
                .o_rs2_data(rs2_output)
               );

    // ----------------------------------------------------
    // 2. Clock Generation
    // ----------------------------------------------------
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; // Clock period 10ns
        end
    end

    // ----------------------------------------------------
    // 3. Supporting Verification Tasks
    // ----------------------------------------------------

    // Task: Writes data to the register and updates the Golden Model
    task automatic write_reg(input [4:0] addr, input [31:0] data);
        rd_wren = 1'b1;
        rd_addr = addr;
        rd_data = data;
        
        // Golden Model update (only when the register is not x0)
        if (addr != 0) begin
            golden_regfile[addr] = data;
        end // Syntax fix: closing the 'if' block here
        
        @(posedge clk);
        rd_wren = 1'b0;
    endtask

    // Read and check the result
    task automatic check_read(input [4:0] addr1, input [4:0] addr2);
        rs1_addr = addr1;
        rs2_addr = addr2;
        
        // Wait for read time (1ns) make sure the output is stable
        #1; 
        
        // Checking output 1 (rs1)
        assert (rs1_output == golden_regfile[addr1]) else 
            $error("READING ERROR rs1 (x%0d): Expected: %h, Result: %h",
                   addr1, golden_regfile[addr1], rs1_output);
                   
        // Checking output 2 (rs2)
        assert (rs2_output == golden_regfile[addr2]) else
            $error("READING ERROR rs2 (x%0d): Expected: %h, Result: %h",
                   addr2, golden_regfile[addr2], rs2_output);
                   
    endtask

    // ----------------------------------------------------
    // 4. Main Test Sequence
    // ----------------------------------------------------
    initial begin
        // --- Declarations MUST precede any executable statements ---
        // Variables used in PHASE 3 are declared here
        logic [4:0] hazard_addr;
        logic [31:0] old_data;
        logic [31:0] new_data;
        // ----------------------------------------------------------
    
        // 1. Initialize signals
        rd_wren = 1'b0;
        rs1_addr = 5'b0;
        rs2_addr = 5'b0;
        rd_addr = 5'b0;
        rd_data = 32'b0;
        golden_regfile = '{default: 0}; // Initialize Golden Model
        
        // Reset
        @(posedge clk);
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        $display("--- Starting Register File Verification ---");

        // --- PHASE 1: Sequential and Random Read-Write Check ---
        $display("\n[PHASE 1] Writing random data to x1..x31");
        for(int i=1; i<32; i=i+1) begin
            // Declared 'test_data' as automatic (local to the loop block)
            automatic logic [31:0] test_data = $urandom; 
            write_reg(i, test_data);
        end

        // Read and verify all registers
        $display("[PHASE 1] Reading and verifying x1..x31");
        for(int i=1; i<32; i=i+1) begin
            check_read(i, (i==31) ? 5'd1 : 5'd0); // Read i via rs1 and x1 (or x0) via rs2
        end
        $display("[PHASE 1] Sequential Read-Write Check FINISHED.");


        // --- PHASE 2: Checking X0 (Zero Register) ---
        $display("\n[PHASE 2] Checking x0 constraint (Zero Register)");
        
        // 1. Attempt to Write to x0 (x0 should not be writable)
        $display("   -> Attempting to write 32'hDEADBEEF to x0...");
        write_reg(0, 32'hDEADBEEF); 
        
        // 2. Reading x0
        check_read(0, 0); // Both ports should read 0
            
        $display("x0 check successful: Confirmed x0 is always 0.");
        
        
        // --- PHASE 3: Checking Write-After-Read Hazard (WAR) ---
        // DUT must return the OLD VALUE when reading in the same write cycle
        $display("\n[PHASE 3] Checking Write-After-Read Hazard (WAR)");
        
        // Variables were moved to the top of the initial block, now they are assigned
        hazard_addr = 5'd10;
        // Read old value from Golden Model before writing
        old_data = golden_regfile[hazard_addr]; 
        new_data = 32'hFEEDF00D;
        
        // 1. Setup reading old value
        rs1_addr = hazard_addr;
        rs2_addr = hazard_addr;
        
        #1; // Ensure combinatorial output is stable
        
        // 2. Activate writing new value (before posedge clk)
        rd_wren = 1'b1;
        rd_addr = hazard_addr;
        rd_data = new_data;
        
        // 3. Reread in the same cycle (before posedge clk).
        // DUT must return OLD_DATA (combinatorial output)
        #1;
        $display("   -> Writing %h to x%0d. Checking rs1/rs2 output...", new_data, hazard_addr);

        // Read port 1: Old value
        assert (rs1_output == old_data) else 
            $error("WAR ERROR: rs1 read x%0d in the write period and NOT return the old value: (%h). Result: %h",
                   hazard_addr, old_data, rs1_output);
        
        // Read port 2: Old value
        assert (rs2_output == old_data) else 
            $error("WAR ERROR: rs2 read x%0d in the write period and NOT return the old value: (%h). Result: %h",
                   hazard_addr, old_data, rs2_output);
                   
        // 4. End of cycle (write occurs)
        @(posedge clk);
        
        // 5. Check if the new value was written successfully (after posedge clk)
        rd_wren = 1'b0;
        golden_regfile[hazard_addr] = new_data; // Update Golden Model
        
        check_read(hazard_addr, hazard_addr); // Read back
        
        $display("Checking WAR Hazard Done.");
        

        // --- End of Simulation ---
        $display("\n--- Register File Verification Successful ---");
        $finish;
    end
endmodule
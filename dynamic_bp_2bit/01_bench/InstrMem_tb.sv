`timescale 1ns/1ns
module InstrMem_tb();
    logic [10:0] i_addr;
    logic [31:0] o_rdata;

    // Instantiate DUT
    InstrMem DUT(
        .i_addr(i_addr),
        .o_rdata(o_rdata)
    );

    // Reference memory
    logic [31:0] ref_mem [0:511];

    // Load expected content
    initial begin
        $readmemh("C:/SystemVerilog/InstrMem/program.hex", ref_mem);
    end

    // Test loop
    initial begin
        i_addr = 0;
        #5;

        for (int i = 0; i < 512; i++) begin
            i_addr = i << 2;  
            #2;               

            if (o_rdata === ref_mem[i])
                $display("At %03d: PASS. Data read: %h", i, o_rdata);
            else
                $display("At %03d: FAIL. Expected: %h, Read: %h",
                         i, ref_mem[i], o_rdata);
        end

        $display("=== Test Finished ===");
        $finish;
    end
endmodule

`timescale  1ns/1ns
module DataMem_tb;

    logic i_clk;
    logic i_reset;
    
    logic [10:0] i_addr;
    logic [31:0] i_wdata;
    logic [3:0] i_bmask;
    logic i_wren;
    logic [31:0] o_rdata;

    DataMem DUT (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_addr(i_addr),
        .i_wdata(i_wdata),
        .i_bmask(i_bmask),
        .i_wren(i_wren),
        .o_rdata(o_rdata)
    );


    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end


    initial begin
        $display("------------------- Starting Testbench DataMem -------------------");
        
        // Khởi tạo tất cả inputs
        i_reset     = 1;
        i_wren      = 0;
        i_addr      = 0;
        i_wdata     = 0;
        i_bmask     = 0;

        // --- Bắt đầu Reset ---
        @(posedge i_clk);
        i_reset = 0;
        $display("Time %0t: END Reset.", $time);
        
        // --- 1. Kiểm tra Ghi/Đọc Toàn Word (Word Write/Read) ---
        i_wren   = 1;
        i_bmask  = 4'b1111; // Toàn Word
        i_addr   = 11'h00C;  // Địa chỉ 0xC (Word Index 3)
        i_wdata  = 32'hDEADBEEF;
        @(posedge i_clk);
        
        i_wren = 0;
        @(negedge i_clk);
        if (o_rdata == 32'hDEADBEEF)
            $display("Time %0t:  Word Write/Read Correct!!. Data Read: %h", $time, o_rdata);
        else
            $fatal(1, "Time %0t:  Word Write/Read FAIL!!. Data Read: %h, expected: DEADBEEF", $time, o_rdata);

        // --- 2. Kiểm tra Ghi Byte (Byte Write) ---
        // Ghi Byte 1 (Byte 8-15) vào cùng Word Index 3
        i_wren = 1;
        i_bmask = 4'b0001;
        i_addr = 11'h0D;  // Địa chỉ 0xD (Word Index 3, Byte Offset 01)
        i_wdata = 32'h12345678; // Chỉ dùng 78
        @(posedge i_clk);
        
        // Đọc lại để kiểm tra
        i_wren = 0;
        @(negedge i_clk);
        // Byte 1 (78) thay thế Byte 1 (BE) cũ. Word mới: DEAD78EF
        if (o_rdata == 32'h00DEAD78) 
            $display("Time %0t: Byte Write Correct!!. Data Read: %h", $time, o_rdata);
        else
            $fatal(1, "Time %0t: Byte Write FAIL!!. Data Read: %h, expected: DEAD78EF", $time, o_rdata);
            
        // --- 3. Kiểm tra Ghi Half-Word (16-bit Write) ---
        // Ghi Half-Word dưới (Bytes 0, 1) vào Word Index 4.
        i_wren = 1;
        i_bmask = 4'b0011;
        i_addr = 11'h012;  // Địa chỉ 0x12 (Word Index 4, Byte Offset 10)
        i_wdata = 32'h0000_ABCD; // Chỉ dùng ABCD
        @(posedge i_clk);
        
        // Đọc lại để kiểm tra
        i_wren = 0;
        @(negedge i_clk);
        // Word mới: 0000ABCD
        if (o_rdata == 32'h0000ABCD) 
            $display("Time %0t: Half-Word Write OK. Data Read: %h", $time, o_rdata);
        else
            $fatal(1, "Time %0t: Half-Word Write FAIL. Data Read: %h, expected: 0000ABCD", $time, o_rdata);
            
        // --- 4. Kiểm tra Lỗi Căn chỉnh (Alignment Error Check) ---
        // Cố gắng ghi Half-Word vào địa chỉ lẻ (i_addr[0] = 1)
        i_wren = 1;
        i_bmask = 4'b0011;
        i_addr = 11'h011;  // Địa chỉ lẻ 0x11 (Word Index 4, Byte Offset 01)
        i_wdata = 32'hFFFFFFFF; 
        @(posedge i_clk);
        
        // Đọc lại để kiểm tra (dữ liệu phải KHÔNG thay đổi)
        i_wren = 0;
        @(negedge i_clk);
        // Word phải giữ nguyên 0000ABCD vì lỗi căn chỉnh.
        if (o_rdata == 32'hABCD0000) 
            $display("Time %0t: Alignment Check OK (Write Disable). Data Read: %h", $time, o_rdata);
        else
            $fatal(1, "Time %0t: Alignment Check FAIL. Data Read: %h, expected: 0000ABCD", $time, o_rdata);
            
        // -------------------------------------------------------------
        // --- 5. Kiểm tra Hazard Đọc-Sau-Ghi (Read-After-Write Hazard) ---
        // Word Index 5 (Địa chỉ 0x14)
        i_wren = 0;
        i_addr = 11'h014;
        i_wdata = 0;
        
        // Ghi Word mới (Word Index 5)
        @(posedge i_clk);
        i_wren = 1;
        i_bmask = 4'b1111;
        i_wdata = 32'hCAFEF00D;
        i_addr = 11'h014; // Địa chỉ ghi
        
        // Đọc ngay trong cùng chu kỳ xung nhịp (Asynchronous Read)
        // Vì i_wren=1, o_rdata phải là 0, KHÔNG phải là dữ liệu mới (CAFEF00D)
        @(negedge i_clk);
        if (o_rdata == 32'h00000000)
            $display("Time %0t: RAW Hazard Check OK (o_rdata = 0 when i_wren=1).", $time);
        else
            $fatal(1, "Time %0t: RAW Hazard Check FAIL. Data Read: %h, expected: 00000000", $time, o_rdata);
            
        // Đọc Word đã ghi ở chu kỳ xung nhịp tiếp theo
        @(posedge i_clk); // Ghi hoàn tất
        i_wren = 0;       // Tắt ghi để cho phép đọc
        
        @(negedge i_clk); // Đọc tổ hợp (combinational)
        if (o_rdata == 32'hCAFEF00D)
            $display("Time %0t: Read after Write OK. Data Read: %h", $time, o_rdata);
        else
            $fatal(1, "Time %0t: Read after Write FAIL. Data Read: %h, expected: CAFEF00D", $time, o_rdata);

        // --- 6. Kết thúc ---
        @(posedge i_clk);
        $display("------------------- Finish Testbench Successfully -------------------");
        $stop;
    end
    
endmodule
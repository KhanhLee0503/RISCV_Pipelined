module regfile_pl (
    // Inputs
    input  logic        i_clk,       // Global clock
    input  logic        i_reset,     // Global active reset
    input  logic [4:0]  i_rs1_addr,  // Address of the first source register (Read 1)
    input  logic [4:0]  i_rs2_addr,  // Address of the second source register (Read 2)
    input  logic [4:0]  i_rd_addr,   // Address of the destination register (Write)
    input  logic [31:0] i_rd_data,   // Data to write to the destination register
    input  logic        i_rd_wren,   // Write enable for the destination register

    // Outputs
    output logic [31:0] o_rs1_data,  // Data from the first source register
    output logic [31:0] o_rs2_data   // Data from the second source register
);

    // Khai báo mảng thanh ghi
    // 32 thanh ghi, mỗi thanh ghi 32 bit. reg[0] đến reg[31]
    logic [31:0] register_array [0:31];

    // --- LOGIC GHI (WRITE LOGIC) ---
    // Khối tổ hợp (sequential logic) thực hiện việc ghi dữ liệu vào thanh ghi
    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            // Reset: Đặt tất cả thanh ghi (tùy chọn) hoặc chỉ thanh ghi x0 = 0
            // Thường chỉ cần đảm bảo x0=0 và các thanh ghi khác ở trạng thái không xác định hoặc 0
            for (int i = 0; i < 32; i++) begin
                register_array[i] <= 32'h0;
            end
        end else if (i_rd_wren) begin
            // Ghi: Chỉ ghi nếu Write Enable (i_rd_wren) được kích hoạt
            // và địa chỉ đích KHÔNG PHẢI là x0 (thanh ghi số 0)
            if (i_rd_addr != 5'b0) begin
                register_array[i_rd_addr] <= i_rd_data;
            end
        end
        // Đảm bảo x0 luôn bằng 0 (trong trường hợp thiết kế phức tạp hơn)
        register_array[0] <= 32'h0;
    end

    // --- LOGIC ĐỌC (READ LOGIC) VỚI BYPASS/FORWARDING (Ghi trước, đọc sau) ---
    // Khối logic tổ hợp (combinational logic) để đọc dữ liệu
    always_comb begin
        // Mặc định: Đọc từ mảng thanh ghi
        o_rs1_data = register_array[i_rs1_addr];
        o_rs2_data = register_array[i_rs2_addr];

        // 1. Xử lý thanh ghi x0
        // Đảm bảo rằng việc đọc địa chỉ 0 luôn trả về 0, ngay cả khi mảng thanh ghi chưa được cập nhật.
        if (i_rs1_addr == 5'b0) begin
            o_rs1_data = 32'h0;
        end
        if (i_rs2_addr == 5'b0) begin
            o_rs2_data = 32'h0;
        end

        // 2. Xử lý Bỏ qua (Bypass/Forwarding) - Ghi trước, đọc sau (Write-after-Read)
        // Điều kiện:
        // - Lệnh Ghi được kích hoạt (i_rd_wren)
        // - Thanh ghi đích Ghi (i_rd_addr) KHÔNG PHẢI là x0
        // - Địa chỉ Đọc (i_rs1_addr hoặc i_rs2_addr) TRÙNG với địa chỉ Ghi (i_rd_addr)

        // Bỏ qua cho Cổng Đọc 1 (rs1)
        if (i_rd_wren && (i_rd_addr != 5'b0) && (i_rd_addr == i_rs1_addr)) begin
            // Trả về dữ liệu đang được ghi (i_rd_data) thay vì dữ liệu cũ từ mảng
            o_rs1_data = i_rd_data;
        end

        // Bỏ qua cho Cổng Đọc 2 (rs2)
        if (i_rd_wren && (i_rd_addr != 5'b0) && (i_rd_addr == i_rs2_addr)) begin
            // Trả về dữ liệu đang được ghi (i_rd_data) thay vì dữ liệu cũ từ mảng
            o_rs2_data = i_rd_data;
        end
    end

endmodule
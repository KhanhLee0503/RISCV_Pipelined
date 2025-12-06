module Clock_div(
    input  logic clk,      // Clock đầu vào 50 MHz
    output logic i_clk     // Clock đầu ra 12.5 MHz
);
    integer count = 0;

    always_ff @(posedge clk) begin
        count <= count + 1;
        if (count >= 1) begin       // Đảo sau mỗi 2 chu kỳ clock (count = 0,1)
            count <= 0;
            i_clk <= ~i_clk;        // Toggle đầu ra
        end
    end
endmodule
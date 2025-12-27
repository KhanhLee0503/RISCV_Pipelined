module BRC_tb();
reg signed[31:0] In1;
reg signed[31:0] In2;
reg sel_signed;
wire output_equal;
wire output_lessthan;

BRC dut(
        .i_rs1_data(In1),
        .i_rs2_data(In2),
        .i_br_un(sel_signed),
        .o_br_less(output_lessthan),
        .o_br_equal(output_equal)
        );

initial begin
    In1 = -32'd1220;
    In2 = 32'd103990;
    sel_signed = 1'b0;

    #10
    In1 = -32'd1220;
    In2 = 32'd103990;
    sel_signed = 1'b1;

    #10
    In1 = 32'd300029;
    In2 = 32'd300029;
    sel_signed = 1'b0;
    
    #10
    In1 = 32'd29;
    In2 = 32'd29;
    sel_signed = 1'b1;
    
    #10
    In1 = 32'd45029;
    In2 = 32'd300029;
    sel_signed = 1'b0;

    #10
    In1 = 32'd45029;
    In2 = 32'd300029;
    sel_signed = 1'b1;

    #10
    In1 = -32'd45029;
    In2 = -32'd300029;
    sel_signed = 1'b0;

    #10
    In1 = -32'd45029;
    In2 = -32'd300029;
    sel_signed = 1'b1;

end

always@ (*) begin
    #1
    case(sel_signed)
        1'b0: begin
            if (In1 != In2) begin
                //r_ = unsigned (a < b);
                if (output_lessthan == ($unsigned(In1) < $unsigned(In2))) $display ("[%t][Information] Operation is Compare Less Than Unsigned. a is %d, b is %d, result is %d, correct!", $time,In1,In2,output_lessthan);
                else $display ("[%t][Information] Operation is Compare Less Than Unsigned. a is %d, b is %d, result is %d, NOT correct!", $time,In1,In2,output_lessthan);
            end
                //r_ = unsigned (a = b);
            else if (In1 == In2) begin
                if (output_equal == ($unsigned(In1) == $unsigned(In2))) $display ("[%t][Information] Operation is Compare Equal. a is %d, b is %d, result is %d, correct!", $time,In1,In2,output_equal);
                else $display ("[%t][Information] Operation is Compare Equal. a is %d, b is %d, result is %d, NOT correct!", $time,In1,In2,output_equal); 
            end
        end
        1'b1: begin
            if (In1 != In2) begin
                //r_ = signed (a < b);
                if (output_lessthan == ($signed(In1) < $signed(In2))) $display ("[%t][Information] Operation is Compare Less Than signed. a is %d, b is %d, result is %d, correct!", $time,In1,In2,output_lessthan);
                else $display ("[%t][Information] Operation is Compare Less Than signed. a is %d, b is %d, result is %d, NOT correct!", $time,In1,In2,output_lessthan);
            end
                //r_ = signed (a = b);
            else if (In1 == In2) begin
                if (output_equal == ($signed(In1) == $signed(In2))) $display ("[%t][Information] Operation is Compare Equal. a is %d, b is %d, result is %d, correct!", $time,In1,In2,output_equal);
                else $display ("[%t][Information] Operation is Compare Equal. a is %d, b is %d, result is %d, NOT correct!", $time,In1,In2,output_equal); 
            end
        end

        default: $display ("[%t][Warning] Operator is invalid!", $time);
    endcase
end
endmodule
module lsu_tb();
logic clk, reset;
logic load_signed;
logic wren;
logic [3:0] load_type;

logic [31:0] addr;
logic [31:0] data_in;

logic [31:0] in_sw;
logic [31:0] out_data;
logic [31:0] out_ledr;
logic [31:0] out_ledg;
logic [31:0] out_lcd;
logic [31:0] out_hex03;
logic [31:0] out_hex47;

parameter MEM_DATA        = 32'h1234_5678;
parameter MEM_DATA_OUT    = 32'h0000_0056;

parameter LEDR_DATA       = 32'h1111_1111;
parameter LEDR_DATA_OUT   = 32'h0000_1111;

parameter LEDG_DATA       = 32'hBBBB_BBBB;
parameter LEDG_DATA_OUT   = 32'hFFFF_BBBB;

parameter LCD_DATA        = 32'h3333_3333;
parameter LCD_DATA_OUT    = 32'h3333_3333;

parameter HEX03_DATA      = 32'hAAAA_AAAA;
parameter HEX03_DATA_OUT  = 32'hFFFF_FFAA;

parameter HEX47_DATA      = 32'h5555_5555;
parameter HEX47_DATA_OUT  = 32'h0000_0055;

parameter SWITCH_DATA     = 32'h8888_8888;
parameter SWITCH_DATA_OUT = 32'hFFFF_8888; 

lsu DUT (
        .i_clk(clk),
        .i_reset(reset),
        .i_load_type(load_type),	
        .i_load_signed(load_signed),
        
        .i_lsu_addr(addr),
        .i_st_data(data_in),
        .i_lsu_wren(wren),
        .i_io_sw(in_sw),
        
        .o_ld_data(out_data),
        .o_io_ledr(out_ledr),
        .o_io_ledg(out_ledg),
        .o_io_lcd(out_lcd),
        
        .o_io_hex03(out_hex03),
        .o_io_hex47(out_hex47)   
        );

initial begin
    clk = 1'b0;
    forever begin
        #2 clk = ~clk;
    end
end

initial begin
    // Reset
    reset = 1'b1;
    wren = 1'b0;
    addr = 0;
    data_in = 0;
    load_type = 4'b0;
    load_signed = 1'b0;
    #2
    reset = 1'b0;
    #2
    //--------------------Write Phase--------------------
    // Write LCD
    addr = 32'h1000_40FF;
    data_in = LCD_DATA;
    load_type = 4'hF;
    wren = 1'b1;
    @(posedge clk);
    #1 

    // Write LEDR
    addr = 32'h1000_0053;
    data_in = LEDR_DATA;
    load_type = 4'hF;
    wren = 1'b1;
    @(posedge clk);
    #1 

    // Write LEDG
    addr = 32'h1000_1103;
    data_in = LEDG_DATA;
    load_type = 4'h3;
    load_signed = 1'b1;
    wren = 1'b1;
    @(posedge clk);
    #1 

    // Write Data Memory
    addr = 32'h0000_0022;
    data_in = MEM_DATA;
    wren = 1'b1;
    load_type = 4'h3;
    @(posedge clk);
    #1 

    // Write HEX03 
    addr = 32'h1000_2000;
    data_in = HEX03_DATA;
    load_type = 4'hF;
    wren = 1'b1;
    @(posedge clk);
    #1 

    // Write HEX47
    addr = 32'h1000_3000;
    data_in = HEX47_DATA;
    load_type = 4'hF;
    wren = 1'b1;
    @(posedge clk);
    #1 

    // Write SWITCH
    addr = 32'h1001_00FF;
    in_sw = SWITCH_DATA;
    load_type = 4'hF;
    wren = 1'b1;
    @(posedge clk);
    #1 

    //--------------------Read Phase--------------------
    @(posedge clk);
    wren = 0;
    #1;

    // LEDG
    addr = 32'h1000_1103;
    load_type = 4'h3;
    load_signed = 1'b1;
    #1;
    if (out_ledg == LEDG_DATA_OUT)
        $display("LEDG PASS: %h", out_ledg);
    else
        $display("LEDG FAIL: %h", out_ledg);

    // LCD
    addr = 32'h1000_40FF;
    load_type = 4'hF;
    load_signed = 1'b1;
    #1;
    if (out_lcd == LCD_DATA_OUT)
        $display("LCD PASS: %h", out_lcd);
    else
        $display("LCD FAIL: %h", out_lcd);

    // LEDR
    addr = 32'h1000_0053;
    load_type = 4'h3;
    load_signed = 1'b0;
    #1;
    if (out_ledr == LEDR_DATA_OUT)
        $display("LEDR PASS: %h", out_ledr);
    else
        $display("LEDR FAIL: %h", out_ledr);

    // HEX03
    addr = 32'h1000_2000;
    load_type = 4'h1;
    load_signed = 1'b1;
    #1;
    if (out_hex03 == HEX03_DATA_OUT)
        $display("HEX03 PASS: %h", out_hex03);
    else
        $display("HEX03 FAIL: %h", out_hex03);

    // HEX47
    addr = 32'h1000_3000;
    load_type = 4'h1;
    load_signed = 1'b1;
    #1;
    if (out_hex47 == HEX47_DATA_OUT)
        $display("HEX47 PASS: %h", out_hex47);
    else
        $display("HEX47 FAIL: %h", out_hex47);

    // SWITCH
    addr = 32'h1001_00FF;
    load_type = 4'h3;
    load_signed = 1'b1;
    #1;
    if (out_data == SWITCH_DATA_OUT)
        $display("SWITCH PASS: %h", out_data);
    else
        $display("SWITCH FAIL: %h", out_data);

        // Data Memory
    addr = 32'h0000_0023;
    load_type = 4'h1;
    load_signed = 1'b1;
    #1;
    if (out_data == MEM_DATA_OUT)
        $display("DataMem PASS: %h", out_data);
    else
        $display("DataMem FAIL: %h", out_data);

     #10 $finish;
end

endmodule

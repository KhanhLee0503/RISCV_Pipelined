module Forwarding_Unit(
                        input clk,
                        input reset,
                        input logic [4:0] IF_ID_rs1,
                        input logic [4:0] IF_ID_rs2, 
                        input logic IF_ID_RegWen,
						input logic IF_ID_MemRW,
                        input logic [6:0] IF_ID_Opcode,
                        
                        input logic [4:0] ID_EX_rd,
                        input logic [4:0] ID_EX_rs1,
                        input logic [4:0] ID_EX_rs2,
                        input logic [6:0] ID_EX_Opcode,
                        input logic ID_EX_RegWen,
                        input logic ID_EX_MemRW,
                        input logic [2:0] ID_EX_funct3,

                        input logic [4:0] EX_MEM_rs1,
                        input logic [4:0] EX_MEM_rs2,
                        input logic [4:0] EX_MEM_rd,
                        input logic [6:0] EX_MEM_Opcode,
                        input logic EX_MEM_RegWen,
                        input logic EX_MEM_MemRW,

                        input logic [6:0] MEM_WB_Opcode,
                        input logic [4:0] MEM_WB_rd,
                        input logic  MEM_WB_RegWen,
                        input logic BrLT,
					    input logic BrEQ,

                        output logic stall_L,
                        output logic stall_j,
                        output logic branch_taken,
                        output logic flush,
                        output logic stall,
                        output logic ID_EX_Bubble,

                        output logic [1:0] ForwardingA_sel,
                        output logic [1:0] ForwardingB_sel,
                        output logic [1:0] ForwardingC_sel,
                        output logic ForwardingD_sel,
                        output logic [1:0] ForwardingE_sel                    
                      );

parameter NONE              = 0;
parameter DATA_HAZARD1      = 1;
parameter DATA_HAZARD2      = 2;
parameter LOAD_HAZARD3      = 3;

parameter JAL       = 7'b110_1111;
parameter JALR      = 7'b110_0111;
parameter B_TYPE    = 7'b110_0011;

parameter LOAD_INSTRUCTION  = 7'b000_0011;
parameter STORE_INSTRUCTION = 7'b010_0011;
parameter I_INSTRUCTION     = 7'b001_0011;
parameter R_INSTRUCTION     = 7'b011_0011;
parameter LUI_INSTRUCTION   = 7'b011_0111;
parameter AUI_INSTRUCTION   = 7'b001_0111;

parameter BEQ  = 3'b000;
parameter BNE  = 3'b001;
parameter BLT  = 3'b100;
parameter BGE  = 3'b101;
parameter BLTU = 3'b110;
parameter BGEU = 3'b111; 


logic [3:0] Stall_Counter;
logic [3:0] Hazard_Type;


logic IsBranch_EX;
logic Jump_ID;
logic Jump_EX;

//--------------------------------Branch_Control-----------------------------------------
always_comb begin
    if (ID_EX_Opcode == B_TYPE) begin
        IsBranch_EX = 1'b1;
        stall_j     = 1'b0;
        Jump_ID     = 1'b0;
        Jump_EX     = 1'b0;
    end

    else if ((ID_EX_Opcode == JALR) || (ID_EX_Opcode == JAL)) begin
        IsBranch_EX = 1'b0;
        stall_j     = 1'b1;
        Jump_ID     = 1'b0;
        Jump_EX     = 1'b1;
    end
    
    else begin
        Jump_EX     = 1'b0;
        Jump_ID     = 1'b0;
        IsBranch_EX = 1'b0;
        stall_j     = 1'b0;
    end
end

always_comb begin
    if(Jump_EX) begin
        flush = 1'b1;
        branch_taken = 1'b1;
    end
    else if ((ID_EX_funct3 == BEQ) && (IsBranch_EX) && (BrEQ)) begin 
        flush = 1'b1;
        branch_taken = 1'b1;
    end
    else if ((ID_EX_funct3 == BNE) && (IsBranch_EX) && (~BrEQ)) begin
        flush = 1'b1;
        branch_taken = 1'b1;
    end
    else if ((ID_EX_funct3 == BLT) && (IsBranch_EX) && (BrLT)) begin
        flush = 1'b1;
        branch_taken = 1'b1;
    end
    else if ((ID_EX_funct3 == BGE) && (IsBranch_EX) && (~BrLT)) begin
        flush = 1'b1;
        branch_taken = 1'b1;
    end
    else if ((ID_EX_funct3 == BLTU) && (IsBranch_EX) && (BrLT)) begin
        flush = 1'b1;
        branch_taken = 1'b1;
    end
    else if ((ID_EX_funct3 == BGEU) && (IsBranch_EX) && (~BrLT)) begin   
        flush = 1'b1;
        branch_taken = 1'b1;
    end
    else begin
        flush = 1'b0;
        branch_taken = 1'b0;
    end
end



//------------------------------Data_Control--------------------------------------
always_ff @(posedge clk or posedge reset) begin
    if(reset) Stall_Counter <= 4'b0;
    else begin
        //1. During Stall Cycles
        if(Stall_Counter > 0) Stall_Counter <= Stall_Counter - 1;
        //2. Stall ends and there is new hazard 
        else if (Hazard_Type > NONE) Stall_Counter <= Hazard_Type;
        //3. No hazard
        else Stall_Counter <= 4'b0;
    end
end


always_comb begin
    //---------------------------------Dont have to Stall !!-----------------------------------
    //**1st Situation
   if ((IF_ID_Opcode == JAL)||(IF_ID_Opcode == LUI_INSTRUCTION) || (IF_ID_Opcode == AUI_INSTRUCTION)) begin
        Hazard_Type = NONE; 
        ID_EX_Bubble = 1'b0;
    end

    else if (ID_EX_Opcode == LOAD_INSTRUCTION) begin
        Hazard_Type = LOAD_HAZARD3;
        ID_EX_Bubble = 1'b1;
    end

    else if (EX_MEM_Opcode == LOAD_INSTRUCTION) begin
        Hazard_Type = DATA_HAZARD2;
        ID_EX_Bubble = 1'b0;
    end

    /*
    //--------------------Data Hazard from Immediate Instructions----------------------------
    //1st Situation
    else if (((IF_ID_Opcode == I_INSTRUCTION)|| (IF_ID_Opcode == JALR) || (IF_ID_Opcode == LOAD_INSTRUCTION)) && (ID_EX_RegWen) && (ID_EX_rd != 0) && (ID_EX_rd == IF_ID_rs1)) begin
        Hazard_Type = DATA_HAZARD2; 
        ID_EX_Bubble = 1'b1;
    end
    
    //2nd Situation
    else if (((IF_ID_Opcode == I_INSTRUCTION)|| (IF_ID_Opcode == JALR) || (IF_ID_Opcode == LOAD_INSTRUCTION)) && (EX_MEM_RegWen) && (EX_MEM_rd != 0) && (EX_MEM_rd == IF_ID_rs1)) begin
        Hazard_Type = DATA_HAZARD1;
        ID_EX_Bubble = 1'b0; 
    end
    */
/*
    //-----------------------------Data Hazard Registers------------------------
    //1st Situation
    else if ((ID_EX_RegWen) && (ID_EX_Opcode != LOAD_INSTRUCTION) && (ID_EX_rd != 0) && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2))) begin
        Hazard_Type = DATA_HAZARD2;
        ID_EX_Bubble = 1'b1; 
    end
    
    //2nd Situation
    else if ((EX_MEM_RegWen) && (EX_MEM_Opcode != LOAD_INSTRUCTION) && (EX_MEM_rd != 0) && ((EX_MEM_rd == IF_ID_rs1) || (EX_MEM_rd == IF_ID_rs2))) begin
        Hazard_Type = DATA_HAZARD1;
        ID_EX_Bubble = 1'b0; 
    end
*/

    //-------------------------------No Hazards---------------------------
    else begin
        Hazard_Type = NONE;
        ID_EX_Bubble = 1'b0;
    end
end

always_ff@(posedge clk) begin
    if(ID_EX_Opcode == LOAD_INSTRUCTION)  stall_L <= 1;
    else stall_L <= 1'b0;
end



always_comb begin
    if((IsBranch_EX) && (EX_MEM_rd == ID_EX_rs1) && (EX_MEM_rd !=0) && (EX_MEM_RegWen))
        ForwardingC_sel = 2'b01;
    else if ((IsBranch_EX) && (MEM_WB_rd == ID_EX_rs1) && (MEM_WB_rd !=0) && (MEM_WB_RegWen))
        ForwardingC_sel = 2'b10;
    else 
        ForwardingC_sel = 2'b0;
end


always_comb begin
    if((IsBranch_EX) && (EX_MEM_rd == ID_EX_rs2) && (EX_MEM_rd !=0) && (EX_MEM_RegWen))
        ForwardingE_sel = 2'b01;

    else if((IsBranch_EX) && (MEM_WB_rd == ID_EX_rs2) && (MEM_WB_rd !=0) && (MEM_WB_RegWen))
        ForwardingE_sel = 2'b10;
    else 
        ForwardingE_sel = 2'b0;
end



//-----------------------------------------------Forwarding Unit--------------------------------------------
always_comb begin
    if ((EX_MEM_RegWen) && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1) 
    && (ID_EX_Opcode != JAL) && (ID_EX_Opcode != LUI_INSTRUCTION) && (ID_EX_Opcode != AUI_INSTRUCTION)) 
        ForwardingA_sel = 2'b01;
    else if ((MEM_WB_RegWen) && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1) 
    && (ID_EX_Opcode != JAL) && (ID_EX_Opcode != LUI_INSTRUCTION) && (ID_EX_Opcode != AUI_INSTRUCTION)) 
        ForwardingA_sel = 2'b10;
    else 
        ForwardingA_sel = 2'b00;
end

always_comb begin
    if ((EX_MEM_RegWen) && (EX_MEM_rd != 0) && (ID_EX_Opcode != I_INSTRUCTION) && (ID_EX_Opcode != JALR) && (ID_EX_Opcode != LOAD_INSTRUCTION) && (EX_MEM_rd == ID_EX_rs2) 
    && (ID_EX_Opcode != JAL) && (ID_EX_Opcode != LUI_INSTRUCTION) && (ID_EX_Opcode != AUI_INSTRUCTION)) 
        ForwardingB_sel = 2'b01;

    else if ((MEM_WB_RegWen) && (MEM_WB_rd != 0) && (ID_EX_Opcode != I_INSTRUCTION) && (ID_EX_Opcode != JALR) && (ID_EX_Opcode != LOAD_INSTRUCTION) && (MEM_WB_rd == ID_EX_rs2) 
    && (ID_EX_Opcode != JAL) && (ID_EX_Opcode != LUI_INSTRUCTION) && (ID_EX_Opcode != AUI_INSTRUCTION)) 
        ForwardingB_sel = 2'b10;

    else 
        ForwardingB_sel = 2'b00;
end


//--------------------------------------------------------Store_Instruction--------------------------------------------------

always_comb begin
    if ((EX_MEM_RegWen) && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2) && (ID_EX_MemRW)) 
        ForwardingD_sel = 1'b1;
    else 
        ForwardingD_sel = 1'b0;
end

assign stall = (Stall_Counter > 0) || ((Hazard_Type > 0) && (Stall_Counter == 0));

endmodule


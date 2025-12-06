module control_unit(
                    
                    input logic [31:0]  instr,
                    input logic BrLT,
                    input logic BrEQ,

                    output logic PCSel,
                    output logic [3:0] ImmSel,
                    output logic RegWen,
                    output logic BrUn,  
                    output logic ASel,
                    output logic BSel,
                    output logic [1:0] ALU_op,
                    output logic MemRW,
                    output logic [3:0] LoadType,
                    output logic LoadSigned,
                    output logic [1:0] WBSel,
                    output logic LUI_Sel,
                    output logic o_insn_vld
                   );

always_comb begin
	o_insn_vld = 1'b1;
	MemRW = 1'b0;
	LoadSigned = 1'b0;
	LoadType = 4'b1111;
	PCSel = 1'b0;
	LUI_Sel = 1'b0;
	ALU_op = 2'b00;
	ASel = 1'b0;
	BSel = 1'b0;
	BrUn = 1'b0;
	RegWen = 1'b0;
	ImmSel = 4'b0;
	WBSel = 2'b0;

case(instr[6:0])
    //-------------------R-Type--------------------------
    7'b0110011: begin 
                    PCSel = 1'b0;
                    ImmSel = 4'b0;     //I-Type
                    RegWen = 1'b1;          
                    ASel = 1'b0; // ALU A = RS1 (R-Type)
                    BSel = 1'b0; // ALU B = RS2 (R-Type)
                    ALU_op = 2'b01;     
                    WBSel = 2'b01;   
                end

    //------------------I-Type-----------------------------
    7'b0010011: begin
                    PCSel = 1'b0;
                    ImmSel = 4'b0;    //I-Type 
                    RegWen = 1'b1;
                    ASel = 1'b0; 
                    BSel = 1'b1;     // ALU B = Imm (I-Type)
                    ALU_op = 2'b01; 
                    WBSel = 2'b01; 
                end

    //-------------------U-Type------------------------------
    //LUI
    7'b0110111: begin
                    PCSel = 1'b0;
                    ImmSel = 4'b1000;       //U-Type
                    RegWen = 1'b1;
                    ASel = 1'b0; // ALU A = RS1
                    BSel = 1'b1; // ALU B = Imm
                    ALU_op = 2'b10; 
                    WBSel = 2'b01; 
                    LUI_Sel = 1'b1;
                end
    
    //AUIPC
    7'b0010111: begin
                    PCSel = 1'b0;
                    ImmSel = 4'b1000;   //U-Type 
                    RegWen = 1'b1;
                    ASel = 1'b1; // ALU A = PC_Out
                    BSel = 1'b1; // ALU B = Imm
                    ALU_op = 2'b10; 
                    WBSel = 2'b01; 
                end
    
    //------------------B-Type----------------------------
    7'b1100011: begin
        case(instr[14:12])
            //BEQ
            3'b000 : begin
                        BrUn = 1'b1;
                        ImmSel = 4'b0010;       //B-Type 
                        RegWen = 1'b0;
                        ASel = 1'b1; 
                        BSel = 1'b1; // ALU B = Imm
                        ALU_op = 2'b10; 
                        WBSel = 2'b01;
                        PCSel = BrEQ;
                     end

            //BNE
            3'b001 : begin
                        BrUn = 1'b1;
                        ImmSel = 4'b0010;       //B-Type 
                        RegWen = 1'b0;
                        ASel = 1'b1; 
                        BSel = 1'b1; // ALU B = Imm
                        ALU_op = 2'b10; 
                        WBSel = 2'b01;
                        PCSel = ~BrEQ;
                     end

            //BLT
            3'b100 : begin
                        BrUn = 1'b1;
                        ImmSel = 4'b0010;       //B-Type 
                        RegWen = 1'b0;
                        ASel = 1'b1; 
                        BSel = 1'b1; // ALU B = Imm
                        ALU_op = 2'b10; 
                        WBSel = 2'b01;
                        PCSel = BrLT;
                     end

            //BGE
            3'b101 : begin
                        BrUn = 1'b1;
                        ImmSel = 4'b0010;       //B-Type 
                        RegWen = 1'b0;
                        ASel = 1'b1; 
                        BSel = 1'b1; // ALU B = Imm
                        ALU_op = 2'b10; 
                        WBSel = 2'b01;
                        PCSel = ~BrLT;
                     end

            //BLTU
            3'b110 : begin
                        ImmSel = 4'b0010;       //B-Type 
                        RegWen = 1'b0;
                        ASel = 1'b1; 
                        BSel = 1'b1; // ALU B = Imm
                        ALU_op = 2'b10; 
                        WBSel = 2'b01;
                        PCSel = BrLT;
                     end

            //BGEU
            3'b111 : begin
                        ImmSel = 4'b0010;       //B-Type 
                        RegWen = 1'b0;
                        ASel = 1'b1; 
                        BSel = 1'b1; // ALU B = Imm
                        ALU_op = 2'b10; 
                        WBSel = 2'b01;
                        PCSel = ~BrLT;
                     end 
				default:begin
							o_insn_vld = 1'b1;
							MemRW = 1'b0;
							LoadSigned = 1'b0;
							LoadType = 4'b1111;
							BrUn = 1'b0; 
							PCSel = 1'b0;
							LUI_Sel = 1'b0;
							ALU_op = 2'b00;
							ASel = 1'b0;
							BSel = 1'b0;
							BrUn = 1'b0;
							RegWen = 1'b0;
							ImmSel = 4'b0;
							PCSel = 1'b0;
							WBSel = 2'b0;
				end	
        endcase
    end

    //----------------------------J-Type--------------------------
    //JAL
    7'b1101111 : begin
                    PCSel = 1'b1;
                    ImmSel = 4'b0100;      //J-Type
                    RegWen = 1'b1;
                    ASel = 1'b1; 
                    BSel = 1'b1; // ALU B = Imm
                    ALU_op = 2'b10; 
                    WBSel = 2'b10;  //PC + 4
                 end
    
    //JALR
    7'b1100111: begin
                    PCSel = 1'b1;
                    ImmSel = 4'b0000; //I-Type
                    RegWen = 1'b1;
                    ASel = 1'b0; // ALU A = RS1
                    BSel = 1'b1; // ALU B = Imm
                    ALU_op = 2'b10; 
                    WBSel = 2'b10;  //PC + 4
                  end
    
    //-----------------------------S-Type------------------------
    7'b0100011: begin
        case(instr[14:12])
           //SB
           3'b000: begin
                    PCSel = 1'b0;
                    ImmSel = 4'b0001;   //S-Type
                    RegWen = 1'b0;
                    ASel = 1'b0;        // ALU A = RS1
                    BSel = 1'b1;        // ALU B = Imm
                    ALU_op = 2'b00; 
                    WBSel = 2'b01; 
                    MemRW = 1'b1;
                    LoadType = 4'b0001;
                   end
            
           //SH
           3'b001: begin
                    PCSel = 1'b0;
                    ImmSel = 4'b0001;   //S-Type
                    RegWen = 1'b0;
                    ASel = 1'b0;        //ALU A = RS1
                    BSel = 1'b1;        // ALU B = Imm
                    ALU_op = 2'b00; 
                    WBSel = 2'b01; 
                    MemRW = 1'b1;
                    LoadType = 4'b0011;
                    end

            //SW
            3'b010: begin
                        PCSel = 1'b0;
                        ImmSel = 4'b0001;   //S-Type
                        RegWen = 1'b0;
                        ASel = 1'b0;        //ALU A = RS1
                        BSel = 1'b1;        // ALU B = Imm
                        ALU_op = 2'b00; 
                        WBSel = 2'b01; 
                        MemRW = 1'b1;
                        LoadType = 4'b1111;
                    end

				default:begin
						o_insn_vld = 1'b1;
						MemRW = 1'b0;
						LoadSigned = 1'b0;
						LoadType = 4'b1111;
						BrUn = 1'b0; 
						PCSel = 1'b0;
						LUI_Sel = 1'b0;
						ALU_op = 2'b00;
						ASel = 1'b0;
						BSel = 1'b0;
						BrUn = 1'b0;
						RegWen = 1'b0;
						ImmSel = 4'b0;
						PCSel = 1'b0;
						WBSel = 2'b0;
				end	
        endcase
    end

    //----------------------I-Type(Load)-------------------------
    7'b0000011: begin
        case(instr[14:12])
                //LB
                3'b000: begin
                            PCSel = 1'b0;
                            ImmSel = 4'b0000; 
                            RegWen = 1'b1;
                            ASel = 1'b0;        // ALU A = RS1
                            BSel = 1'b1;        // ALU B = Imm
                            ALU_op = 2'b00; 
                            WBSel = 2'b00;      //DataMem
                            MemRW = 1'b0;
                            LoadSigned = 1'b1;      //Signed
                            LoadType = 4'b0001;
                        end

                //LH
                3'b001: begin
                            PCSel = 1'b0;
                            ImmSel = 4'b0000; 
                            RegWen = 1'b1;
                            ASel = 1'b0;        // ALU A = RS1
                            BSel = 1'b1;        // ALU B = Imm
                            ALU_op = 2'b00; 
                            WBSel = 2'b00;
                            MemRW = 1'b0;
                            LoadSigned = 1'b1;      //Signed
                            LoadType = 4'b0011;
                        end

                //LW
                3'b010: begin
                            PCSel = 1'b0;
                            ImmSel = 4'b0000; 
                            RegWen = 1'b1;
                            ASel = 1'b0;        // ALU A = RS1
                            BSel = 1'b1;        // ALU B = Imm
                            ALU_op = 2'b00; 
                            WBSel = 2'b00;
                            MemRW = 1'b0;
                            LoadSigned = 1'b0;      
                            LoadType = 4'b1111;
                        end

                 //LBU
                 3'b100: begin
                            PCSel = 1'b0;
                            ImmSel = 4'b0000; 
                            RegWen = 1'b1;
                            ASel = 1'b0;        // ALU A = RS1
                            BSel = 1'b1;        // ALU B = Imm
                            ALU_op = 2'b00; 
                            WBSel = 2'b00;
                            MemRW = 1'b0;
                            LoadSigned = 1'b0;      //Unsigned
                            LoadType = 4'b0001;
                         end

                 //LHU
                 3'b101: begin
                            PCSel = 1'b0;
                            ImmSel = 4'b0000; 
                            RegWen = 1'b1;
                            ASel = 1'b0;        // ALU A = RS1
                            BSel = 1'b1;        // ALU B = Imm
                            ALU_op = 2'b00; 
                            WBSel = 2'b00;
                            MemRW = 1'b0;
                            LoadSigned = 1'b0;      //Unsigned
                            LoadType = 4'b0011;
                         end
	 			default:begin
						o_insn_vld = 1'b1;
						MemRW = 1'b0;
						LoadSigned = 1'b0;
						LoadType = 4'b1111;
						BrUn = 1'b0; 
						PCSel = 1'b0;
						LUI_Sel = 1'b0;
						ALU_op = 2'b00;
						ASel = 1'b0;
						BSel = 1'b0;
						BrUn = 1'b0;
						RegWen = 1'b0;
						ImmSel = 4'b0;
						PCSel = 1'b0;
						WBSel = 2'b0;
				end	
            endcase
    end
    default: begin
               o_insn_vld = 1'b0;
               ALU_op = 2'b00;
					MemRW = 1'b0;
					LoadSigned = 1'b0;
					LoadType = 4'b1111;
					BrUn = 1'b0; 
					PCSel = 1'b0;
					LUI_Sel = 1'b0;
					ASel = 1'b0;
					BSel = 1'b0;
					BrUn = 1'b0;
					RegWen = 1'b0;
					ImmSel = 4'b0;
					PCSel = 1'b0;
					WBSel = 2'b0;
					end
endcase    
end
endmodule
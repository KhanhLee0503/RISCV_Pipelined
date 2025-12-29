# RISCV_Pipelined

## Overview
In this significant milestone, students are assigned the responsibility of designing multiple models of the RV32I processor employing pipelined techniques, as outlined in the lectures. The primary objective of this milestone is to compare at least two techniques to comprehend the functionality of pipelining a processor and address its limitations to attain enhanced performance. Given that the base processor has been successfully implemented in Milestone 2, students are permitted to reuse its components, thereby enabling a feasible timeframe of four weeks for implementing these strategies. However, it is noteworthy that individuals seeking to enhance the frequency and capacity of their processor must employ BRAMs. While not mandatory, their utilization is highly recommended and may result in additional credit. Furthermore, students who demonstrate a thorough understanding of the concept of branch prediction are eligible to incorporate branch predictors into their processors, which will be awarded bonus credits. It is important to note that all the prerequisites for communication between your custom processor (soft-core) and external peripherals remain unchanged. For undergraduate students, an additional penalty week is allocated to ensure the fulfillment of the milestone requirements.

<img width="1215" height="742" alt="image" src="https://github.com/user-attachments/assets/dc1b471b-5078-4107-9e37-1801002bdaca" />

## Specification
### Top Level Module: pipelined.sv
### I/O Ports:
<img width="962" height="514" alt="image" src="https://github.com/user-attachments/assets/12364588-d152-4629-8aad-1ddc7f1ca0d4" />

## Pipelining
- Enable and Reset signals of each stage are critical for a proper pipelined processor. Any issues at first arise from their improper control.
- **insn_vld** is now playing an important role, since flushing an instruction invalidates it, preventing it from being counted as an instruction in the code flow during the final stage (WB). This ensures accurate computation.
- **o_ctrl** signal is added to record control transfer instructions. If a branch or jump instruction is in the WB stage, this signal is asserted with a value of 1.
- **o_mispred** signal is added to record mispredictions, when the Hazard Detection asserts a flush due to a control transfer instruction being mispredicted. This signal is propagated to the WB stage as well.
- Placing a single instruction in the pipeline to verify its correct flow through each stage. Subsequently, introduce more instructions without any hazards and compare the number of active **o_insn_vld** signals (high) with the expected number of instructions.

## Datapath
### ALU
- ALU (Arithmetic Logic Unit) là lõi tính toán của bộ xử lý, thực hiện các phép toán số học và logic trong tập lệnh RV32I: ADD, SUB, SLT/SLTU, AND, OR, XOR, SLL, SRL, SRA, . . . ALU nhận hai toán hạng operand_a, operand_b và mã điều khiển alu_op từ Control Unit, trả về giá trị alu_data cho datapath.
- Trong thiết kế này, ALU được chia thành các module con:
- Bộ cộng CLA 32-bit.
- Bộ dịch Barrel Shifter 32-bit.
- Comparator 32-bit (số không dấu và số có dấu).
- Khối BRC phục vụ lệnh nhánh.

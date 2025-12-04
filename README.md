# Pipelined-SIMD-Multimedia-Unit
Designed a four-stage pipelined SIMD (Single Instruction, Multiple Data) multimedia unit using VHDL implementing a reduced multimedia instruction set inspired by Sony Cell SPU and Intel SSE architectures.

# Part 1 
The first part of the project focused on building and verifying the multimedia ALU (MALU). This is for the Execute stage of the pipeline.
Key features:
- Supports three instruction formats: LI, R3, and R4.
- Implements saturated arithmetic, logical operations, and SIMD multiply-add/subtract instructions.
- Uses 128-bit registers for multimedia operations.
- Fully tested using VHDL testbenches and waveform verification

# Part 2
The second part of the project focused on building the remaining stages of the pipeline: Instruction Fetch, Instruction Decode, and Write Back as well as getting data forwarding to work.
Key features:
- Register File with 3 read ports and 1 write port.
- Instruction decoding for all formats (LI, R3, R4).
- Correct handling of immediate loads using load index.
- Data forwarding to avoid stalls on read-after-write hazards.
- Pipeline registers (IF/ID, ID/EX, EX/WB) carrying control and operand data.
- Custom assembler and VHDL testbench were used for loading programs and verifying execution.
<img width="864" height="366" alt="image" src="https://github.com/user-attachments/assets/4e267401-bd45-4da1-8527-1c01b769b0a3" />

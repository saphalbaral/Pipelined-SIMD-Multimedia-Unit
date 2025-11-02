# Pipelined-SIMD-Multimedia-Unit
IN PROGRESS: Designing a four-stage pipelined SIMD (Single Instruction, Multiple Data) multimedia unit using VHDL implementing a reduced multimedia instruction set inspired by Sony Cell SPU and Intel SSE architectures.

This is an ongoing project. Part 1 covers the execute stage (Stage 3) of a four-stage pipelined multimedia unit. The design implements and verifies all multimedia ALU functions after forwarding. The execute stage performs arithmetic and logical computations defined by the instruction set using 128-bit registers.
- Implemented the Multimedia ALU in VHDL as a behavioral model supporting a load immediate instruction, saturated arithmetic in the R4 instruction format (Multiply-Add and Multiply-Subtract), and R3 instruction format (AND, OR, etc.).
<img width="864" height="366" alt="image" src="https://github.com/user-attachments/assets/4e267401-bd45-4da1-8527-1c01b769b0a3" />

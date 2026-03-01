`timescale 1ns / 1ps
// Define Opcodes
`define RTYPEOPCODE 6'b000000
`define LWOPCODE 6'b100011
`define SWOPCODE 6'b101011
`define BEQOPCODE 6'b000100
`define JOPCODE 6'b000010
`define ORIOPCODE 6'b001101
`define ADDIOPCODE 6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE 6'b001100
`define LUIOPCODE 6'b001111
`define SLTIOPCODE 6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE 6'b001110
`define JALOPCODE 6'b000011
// Define Function codes (used for R-type instructions)
`define SLLFunc 6'b000000
`define SRLFunc 6'b000010
`define SRAFunc 6'b000011
`define ADDFunc 6'b100000
`define ADDUFunc 6'b100001
`define SUBFunc 6'b100010
`define SUBUFunc 6'b100011
`define ANDFunc 6'b100100
`define ORFunc 6'b100101
`define XORFunc 6'b100110
`define NORFunc 6'b100111
`define SLTFunc 6'b101010
`define SLTUFunc 6'b101011
`define JRFunc 6'b001000
// Define ALU operation codes
`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SLL 4'b0011
`define SRL 4'b0100
`define SUB 4'b0110
`define SLT 4'b0111
`define ADDU 4'b1000
`define SUBU 4'b1001
`define XOR 4'b1010
`define SLTU 4'b1011
`define NOR 4'b1100
`define SRA 4'b1101
`define LUI 4'b1110
module PipelinedControl(Jump, Branch, RegDst, UseImmed, UseShamt, Jal,
RegSrc,
RegWrite, MemRead, MemWrite, SignExtend, ALUOp, JumpSel, OpCode, FuncCode);
// Define inputs and outputs
input [5:0] OpCode;
input [5:0] FuncCode;
output reg UseShamt, UseImmed;
output reg [3:0] ALUOp;
output reg RegDst, RegSrc, RegWrite, MemRead, MemWrite, Branch,
Jump, JumpSel, Jal, SignExtend;
always @(*) begin
case(OpCode)
`RTYPEOPCODE: begin
// If R-Type instruction
ALUOp = 4'b1111;
case(FuncCode)
// Shift Instruction
`SLLFunc: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite,
MemRead, MemWrite, Branch, Jump, SignExtend} = 10'b110010000x;
{JumpSel, Jal} = 2'b00;
end
// Shift Instruction
`SRLFunc: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite,
MemRead, MemWrite, Branch, Jump, SignExtend} = 10'b110010000x;
{JumpSel, Jal} = 2'b00;
end
// Shift Instruction
`SRAFunc: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite,
MemRead, MemWrite, Branch, Jump, SignExtend} = 10'b110010000x;
{JumpSel, Jal} = 2'b00;
end
`JRFunc: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite,
MemRead, MemWrite, Branch, Jump, SignExtend} = 10'b0001000010;
{JumpSel, Jal} = 2'b10;
end
//R type instruction that are not shift
default: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b100010000x;
{JumpSel, Jal} = 2'b00;
end
endcase
end
// Load opcode
`LWOPCODE: begin
ALUOp = `ADD;
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0011110001;
{JumpSel, Jal} = 2'b00;
end
// Store opcode
`SWOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'bx01x001001;
ALUOp = `ADD;
{JumpSel, Jal} = 2'b00;
end
// Branch if equal opcode
`BEQOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'bx00x000101;
ALUOp = `SUB;
{JumpSel, Jal} = 2'b00;
end
// Jump opcode
`JOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'bx00x00001x;
ALUOp = 4'bxxxx;
{JumpSel, Jal} = 2'b00;
end
// Or immediate opcode
`ORIOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100000;
ALUOp = `OR;
{JumpSel, Jal} = 2'b00;
end
// Add immediate opcode
`ADDIOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100001;
ALUOp = `ADD;
{JumpSel, Jal} = 2'b00;
end
// Add immediate unsigned opcode
`ADDIUOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100000;
ALUOp = `ADDU;
{JumpSel, Jal} = 2'b00;
end
// AND bitwise with immediate opcode
`ANDIOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100000;
ALUOp = `AND;
{JumpSel, Jal} = 2'b00;
end
// Load Upper Immediate opcode
`LUIOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100000;
ALUOp = `LUI;
{JumpSel, Jal} = 2'b00;
end
// Set less than Immediate opcode
`SLTIOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100001;
ALUOp = `SLT;
{JumpSel, Jal} = 2'b00;
end
// Set less than Immediate unsigned opcode
`SLTIUOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100000;
ALUOp = `SLTU;
{JumpSel, Jal} = 2'b00;
end
// XOR bitwise Immediate opcode
`XORIOPCODE: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0010100000;
ALUOp = `XOR;
{JumpSel, Jal} = 2'b00;
end
// Jump and Link
`JALOPCODE:begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0000100010;
ALUOp = 4'bxxxx;
{JumpSel, Jal} = 2'b01;
end
default: begin
{RegDst, UseShamt,UseImmed, RegSrc, RegWrite, MemRead,
MemWrite, Branch, Jump, SignExtend} = 10'b0000000000;
ALUOp = 4'b0000;
{JumpSel, Jal} = 2'b00;
end
endcase
end
endmodule
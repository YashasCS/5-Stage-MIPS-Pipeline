`timescale 1ns / 1ps
module PipelinedProc(CLK, Reset_L, startPC, dMemOut);
// Define the inputs and outputs
input CLK, Reset_L;
input [31:0] startPC;
output [31:0] dMemOut;
reg [31:0] PC;
// Define the wires for PC calculations
reg [31:0] PCnext;
wire [31:0] IF_Instruction;
// Define the wires for control signals
wire SignExtend;
// Define wires for ALU usage
reg [31:0] ALUInputA;
reg [31:0] ALUInputB;
wire [3:0] ALUCtrl;
wire [31:0] BusW;
wire [31:0] ID_SignExtendOut;
wire [31:0] IF_PCnew;
wire IF_write, PC_write, bubble;
wire [31:0] EX_BusB_BusW;
wire [31:0] DataMem_DataIn;
wire [1:0] addrSel;
// Pipeline Registers: IF_ID
// Input Instruction memory DataOut
reg [31:0] IF_ID_PCnew;
reg [31:0] IF_ID_Instruction;
wire [31:0] ID_Instruction = IF_ID_Instruction;
wire [31:0] ID_PCnew = IF_ID_PCnew;
// Pipeline Registers: ID_EX
// Control Signals
reg ID_EX_RegDst, ID_EX_RegWrite, ID_EX_MemRead,
ID_EX_MemWrite, ID_EX_MemToReg, ID_EX_Jal;
reg [3:0] ID_EX_ALUOp;
wire ID_RegDst, ID_RegWrite, ID_MemRead, ID_MemWrite,
ID_Branch, ID_Jump, ID_MemToReg, ID_Jr, ID_Jal;
wire [3:0] ID_ALUOp;
wire EX_RegDst, EX_RegWrite, EX_MemRead, EX_MemWrite,
EX_MemToReg, EX_Jal;
wire [3:0] EX_ALUOp;
assign {EX_MemToReg, EX_RegDst, EX_RegWrite, EX_MemRead, EX_MemWrite,
EX_ALUOp, EX_Jal} = {ID_EX_MemToReg, ID_EX_RegDst, ID_EX_RegWrite,
ID_EX_MemRead, ID_EX_MemWrite, ID_EX_ALUOp, ID_EX_Jal};
//Forwarding Unit Signals
reg [1:0] ID_EX_ALUOpCtrlA, ID_EX_ALUOpCtrlB ;
reg ID_EX_DataMemForwardCtrl_EX , ID_EX_DataMemForwardCtrl_MEM ;
wire [1:0] ID_ALUOpCtrlA, ID_ALUOpCtrlB ;
wire ID_DataMemForwardCtrl_EX , ID_DataMemForwardCtrl_MEM ;
wire [1:0] EX_ALUOpCtrlA, EX_ALUOpCtrlB ;
wire EX_DataMemForwardCtrl_EX , EX_DataMemForwardCtrl_MEM ;
assign {EX_ALUOpCtrlA, EX_ALUOpCtrlB, EX_DataMemForwardCtrl_EX ,
EX_DataMemForwardCtrl_MEM} = {ID_EX_ALUOpCtrlA, ID_EX_ALUOpCtrlB,
ID_EX_DataMemForwardCtrl_EX , ID_EX_DataMemForwardCtrl_MEM};
// Data
reg [20:0] ID_EX_Instruction;
(* keep = "true"*)reg [31:0] ID_EX_SignExtendOut; 
reg [31:0] ID_EX_BusB, ID_EX_BusA, ID_EX_PCnew;
wire [31:0] ID_BusA, ID_BusB;
wire [20:0] EX_Instruction;
wire [31:0] EX_SignExtendOut, EX_BusB, EX_BusA, EX_PCnew;
assign {EX_Instruction, EX_SignExtendOut, EX_BusB, EX_BusA, EX_PCnew} =
{ID_EX_Instruction, ID_EX_SignExtendOut, ID_EX_BusB, ID_EX_BusA, ID_EX_PCnew}
;
// Pipeline Registers: EX_MEM
// Control unit Signals
reg EX_MEM_MemToReg, EX_MEM_RegWrite, EX_MEM_MemRead,
EX_MEM_MemWrite;
wire MEM_MemToReg, MEM_RegWrite, MEM_MemRead, MEM_MemWrite;
assign {MEM_MemToReg, MEM_RegWrite, MEM_MemRead, MEM_MemWrite} =
{EX_MEM_MemToReg, EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite};
// Forwarding Signals
reg EX_MEM_DataMemForwardCtrl_MEM;
wire MEM_DataMemForwardCtrl_MEM;
assign MEM_DataMemForwardCtrl_MEM = EX_MEM_DataMemForwardCtrl_MEM;
// Data
reg [31:0] EX_MEM_ALUOut;
wire [31:0] EX_ALUOut, ALUOut;
assign EX_ALUOut = (EX_Jal == 1)? EX_PCnew:ALUOut;
wire [31:0] MEM_ALUOut = EX_MEM_ALUOut;
reg [31:0] EX_MEM_BusB_BusW;
wire [31:0] MEM_BusB_BusW = EX_MEM_BusB_BusW;
reg [4:0] EX_MEM_Rw;
wire [4:0] MEM_Rw = EX_MEM_Rw;
wire [4:0] EX_Rw;
// Pipeline Registers: MEM_WB
// Control unit Signals
reg MEM_WB_MemToReg, MEM_WB_RegWrite;
wire WB_MemToReg, WB_RegWrite;
assign {WB_MemToReg, WB_RegWrite} = {MEM_WB_MemToReg, MEM_WB_RegWrite};
// Data
wire [31:0] MEM_DataMem_DataOut;
reg [31:0] MEM_WB_DataMem_DataOut;
wire [31:0] WB_DataMem_DataOut = MEM_WB_DataMem_DataOut;
reg [31:0] MEM_WB_ALUOut;
wire [31:0] WB_ALUOut = MEM_WB_ALUOut;
reg [4:0] MEM_WB_Rw;
wire [4:0] WB_Rw = MEM_WB_Rw;
//Module Instantiation
// Intruction Memory
InstructionMemory InstructionMemory(
.Data(IF_Instruction),
.Address(PC)
);
// PipelinedControl Unit
PipelinedControl dhiraj_plc(
.RegSrc(ID_MemToReg),
.RegDst(ID_RegDst),
.UseShamt(ID_UseShamt),
.UseImmed(ID_UseImmed),
.RegWrite(ID_RegWrite),
.MemRead(ID_MemRead),
.MemWrite(ID_MemWrite),
.Branch(ID_Branch),
.Jump(ID_Jump),
.JumpSel(ID_Jr),
.Jal(ID_Jal),
.SignExtend(SignExtend),
.ALUOp(ID_ALUOp),
.OpCode(ID_Instruction[31:26]),
.FuncCode(ID_Instruction[5:0])
);
// Hazard Unit
wire Zero;
HazardUnit dhiraj_hu(
.IF_write(IF_write),
.PC_write(PC_write),
.bubble(bubble),
.addrSel(addrSel),
.Jump(ID_Jump),
.Branch(ID_Branch),
.ALUZero(Zero),
.memReadEX(EX_MemRead),
.ID_Rs(ID_Instruction[25:21]),
.ID_Rt(ID_Instruction[20:16]),
.UseShamt(ID_UseShamt),
.UseImmed(ID_UseImmed) ,
.Clk(CLK) ,
.Jr(ID_Jr),
.EX_RegWrite(EX_RegWrite),
.MEM_RegWrite(MEM_RegWrite),
.EX_Rw(EX_Rw),
.MEM_Rw(MEM_Rw),
.Rst(Reset_L)
);
// Register File
RegisterFile dhiraj_rf(
.BusA(ID_BusA) ,
.BusB(ID_BusB) ,
.BusW(BusW) ,
.RA(ID_Instruction[25:21]),
.RB(ID_Instruction[20:16]),
.RW(WB_Rw),
.RegWr(WB_RegWrite),
.Clk(CLK)
);
// Sign Extend
SignExtender SE(
.imm16(ID_Instruction[15:0]),
.signExtImm(ID_SignExtendOut),
.signExtend(SignExtend)
);
// Forwarding Unit
ForwardingUnit dhiraj_fu(
.UseShamt(ID_UseShamt) ,
.UseImmed (ID_UseImmed),
.ID_Rs(ID_Instruction[25:21])
,
.ID_Rt(ID_Instruction[20:16])
,
.EX_Rw (EX_Rw),
.MEM_Rw (MEM_Rw),
.EX_RegWrite (EX_RegWrite) ,
.MEM_RegWrite (MEM_RegWrite)
,
.ALUOpCtrlA(ID_ALUOpCtrlA) ,
.ALUOpCtrlB(ID_ALUOpCtrlB) ,
.DataMemForwardCtrl_EX(ID_DataMemForwardCtrl_EX) ,
.DataMemForwardCtrl_MEM(ID_DataMemForwardCtrl_MEM)
);
// ALU control
ALUControl ALUControl(
.ALUCtrl(ALUCtrl),
.ALUop(EX_ALUOp),
.FuncCode(EX_Instruction[5:0])
);
// ALU
ALU ALU(
.BusW(ALUOut),
.Zero(Zero),
.BusA(ALUInputA),
.BusB(ALUInputB),
.ALUCtrl(ALUCtrl)
);
// Data Memory
DataMemory DataMemory(
.ReadData(MEM_DataMem_DataOut),
.Address(MEM_ALUOut[5:0]),
.WriteData(DataMem_DataIn),
.MemoryRead(MEM_MemRead),
.MemoryWrite(MEM_MemWrite),
.Clock(CLK)
);
always @(*) begin
// PC Operations
case(addrSel)
2'b00: PCnext <= IF_PCnew;
2'b01: PCnext <= (ID_Jr==1)?ID_BusA:{ID_PCnew[31:28],ID_Instruction[25:0],2'b00};
2'b10: PCnext <= (EX_SignExtendOut<<2) + EX_PCnew;
default: PCnext <= IF_PCnew;
endcase
// 4:1 MUX for ALU Input A
case(EX_ALUOpCtrlA)
2'b00: ALUInputA <= EX_Instruction[10:6];
2'b01: ALUInputA <= BusW;
2'b10: ALUInputA <= MEM_ALUOut;
2'b11: ALUInputA <= EX_BusA;
default: ALUInputA <= 32'b0;
endcase
// 4:1 MUX for ALU Input B
case(EX_ALUOpCtrlB)
2'b00: ALUInputB <= EX_SignExtendOut;
2'b01: ALUInputB <= BusW;
2'b10: ALUInputB <= MEM_ALUOut;
2'b11: ALUInputB <= EX_BusB;
default: ALUInputB <= 32'b0;
endcase
end
// DEFINING MUX in top module
assign EX_Rw = (EX_Jal==0)?((EX_RegDst == 0)?
EX_Instruction[20:16] : EX_Instruction[15:11]):5'b11111;
assign EX_BusB_BusW = (EX_DataMemForwardCtrl_EX== 0) ? EX_BusB : BusW;
assign DataMem_DataIn = (MEM_DataMemForwardCtrl_MEM == 0) ? MEM_BusB_BusW :
BusW;
assign BusW = (WB_MemToReg == 1) ? WB_DataMem_DataOut :
WB_ALUOut;
// Assign the outputs
assign dMemOut = MEM_DataMem_DataOut;
// Assign the wires value according to the block diagram
assign IF_PCnew = PC + 4;
// At every negedge of clock or reset, assign the PC
always @(negedge CLK) begin
// Update The PC
if(Reset_L == 0)
PC <= startPC;
else if(PC_write == 1)
PC <= PCnext;
else
PC <= PC;
// Update the IF/ID Register
if (IF_write == 1) begin
IF_ID_PCnew <= IF_PCnew;
IF_ID_Instruction[31:0] <= IF_Instruction[31:0];
end
else begin
IF_ID_PCnew <= IF_ID_PCnew;
IF_ID_Instruction[31:0] <= IF_ID_Instruction[31:0];
end
// Update the ID_EX Register only if bubble is 0
if (bubble == 1)
{ID_EX_RegDst, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite,
ID_EX_Jal, ID_EX_MemToReg, ID_EX_ALUOp} <= 12'b000000000000;
else
{ID_EX_RegDst, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite,
ID_EX_MemToReg, ID_EX_Jal, ID_EX_ALUOp} <= {ID_RegDst, ID_RegWrite,
ID_MemRead, ID_MemWrite, ID_MemToReg, ID_Jal, ID_ALUOp};
{ID_EX_ALUOpCtrlA, ID_EX_ALUOpCtrlB, ID_EX_DataMemForwardCtrl_EX ,
ID_EX_DataMemForwardCtrl_MEM} <= {ID_ALUOpCtrlA, ID_ALUOpCtrlB,
ID_DataMemForwardCtrl_EX , ID_DataMemForwardCtrl_MEM};
{ID_EX_Instruction, ID_EX_SignExtendOut, ID_EX_BusB, ID_EX_BusA,
ID_EX_PCnew}<= {ID_Instruction[20:0], ID_SignExtendOut, ID_BusB, ID_BusA,
ID_PCnew};
// Update the EX_MEM Register
{EX_MEM_MemToReg, EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite} <=
{EX_MemToReg, EX_RegWrite, EX_MemRead, EX_MemWrite};
EX_MEM_DataMemForwardCtrl_MEM <= EX_DataMemForwardCtrl_MEM;
EX_MEM_ALUOut <= EX_ALUOut;
EX_MEM_BusB_BusW <= EX_BusB_BusW;
EX_MEM_Rw <= EX_Rw;
// Update the MEM_WB Register
{MEM_WB_MemToReg, MEM_WB_RegWrite} <= {MEM_MemToReg, MEM_RegWrite} ;
MEM_WB_DataMem_DataOut <= MEM_DataMem_DataOut;
MEM_WB_ALUOut <= MEM_ALUOut;
MEM_WB_Rw <= MEM_Rw;
end
endmodule
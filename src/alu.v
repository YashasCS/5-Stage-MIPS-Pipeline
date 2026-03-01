`timescale 1ns / 1ps
// define the ALU operations (ALUop)
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
module ALU(BusW, Zero, BusA, BusB, ALUCtrl);
// Define Inputs and Outputs
input signed [31:0] BusA;
input signed [31:0] BusB;
input [3:0] ALUCtrl;
output reg [31:0] BusW;
output reg Zero;
always @(*) begin
case(ALUCtrl)
// Define ALU operations based on the ALUCtrl
`AND : BusW <= BusA & BusB;
`OR : BusW <= BusA | BusB;
`ADD : BusW <= BusA + BusB;
`SLL : BusW <= BusB << BusA;
`SRL : BusW <= BusB >> BusA;
`SUB : BusW <= BusA - BusB;
`SLT : BusW <= (BusA < BusB)? 1 : 0;
`ADDU : BusW <= BusA + BusB;
`SUBU : BusW <= BusA - BusB;
`XOR : BusW <= BusA ^ BusB;
`NOR : BusW <= ~(BusA | BusB);
`SRA : BusW <= BusB >>> BusA[4:0];
`LUI : BusW <= {BusB[15:0],16'b0};
`SLTU : begin
if(BusA[31] == 0 && BusB[31] == 0)
BusW <= (BusA < BusB)? 1 : 0;
else if(BusA[31] == 1 && BusB[31] == 1)
BusW <= ((~BusA) + 1 < (~BusB) + 1)? 1 : 0;
else if(BusA[31] == 1 && BusB[31] == 0)
BusW <= ((~BusA) + 1 < BusB)? 1 : 0;
else if (BusA[31] == 0 && BusB[31] == 1)
BusW <= (BusA < (~BusB) + 1)? 1 : 0;
else
BusW <= 0;
end
default: BusW <= 0;
endcase
// Output bit zero if BusW is 0
Zero <= (BusA == BusB) ? 1'b1 : 1'b0;
end
endmodule
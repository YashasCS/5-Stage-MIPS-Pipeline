`timescale 1ns / 1ps
module HazardUnit(IF_write, PC_write, bubble, addrSel, Jump, Jr, Branch,
ALUZero,
memReadEX, ID_Rs, ID_Rt, EX_Rw, MEM_Rw, EX_RegWrite, MEM_RegWrite, UseShamt,
UseImmed, Clk, Rst);
// Input and output ports
output reg IF_write, PC_write, bubble;
output reg [1:0] addrSel;
input Jump , Branch , ALUZero , memReadEX , Clk , Rst, Jr,
EX_RegWrite, MEM_RegWrite ;
input [4:0] EX_Rw, MEM_Rw;
input UseShamt , UseImmed ;
input [4:0] ID_Rs, ID_Rt;
wire LdHazard, JrHazard;
reg [1:0] state, Next_State;
// Load hazard, For R-type => if any register equal to load register
// For shift or I-type => if the register equal to the load inf
// Logic for detecting load hazard previous state
/*assign LdHazard =
(memReadEX == 1) & (prevRt != 0) & (((ID_Rs == prevRt || ID_Rt == prevRt) &
UseShamt == 0 & UseImmed == 0) ||
(UseShamt == 1 & ID_Rs == prevRt) ||(UseImmed == 1 & ID_Rs == prevRt ))?1:0 ;
*/
assign LdHazard = (((ID_Rs == EX_Rw && UseShamt != 1) || (ID_Rt == EX_Rw &&
UseImmed != 1)) && EX_Rw != 0 && memReadEX == 1) ? 1 : 0;
// Jr hazard
assign JrHazard = ((Jr == 1) && ((EX_Rw == ID_Rs && EX_RegWrite ==
1)||(MEM_Rw == ID_Rs && MEM_RegWrite == 1))) ? 1 : 0;
always @(*) begin
// Check for hazard => Load, Branch, and Jump
case(state)
2'b00: begin
if ((LdHazard == 1) || (JrHazard == 1)) begin
Next_State <= 2'b00;
{IF_write, PC_write, bubble} <= 3'b001;
addrSel <= 2'b00;
end
else if (Branch == 1) begin
Next_State <= 2'b01;
{IF_write, PC_write, bubble} <= 3'b000;
addrSel <= 2'b00;
end
else if (Jump == 1) begin
Next_State <= 2'b11;
{IF_write, PC_write, bubble} <= 3'b010;
addrSel <= 2'b01;
end
// NO Hazard
else begin
Next_State <= 2'b00;
{IF_write, PC_write, bubble} <= 3'b110;
addrSel <= 2'b00;
end
end
// Branch 0
2'b01: begin
if (ALUZero == 1) begin
// If branch is taken
Next_State <= 2'b10;
{IF_write, PC_write, bubble} <= 3'b011;
addrSel <= 2'b10;
end
else begin
// If branch NOT taken
Next_State <= 2'b00;
{IF_write, PC_write, bubble} <= 3'b111;
addrSel <= 2'b00;
end
end
// Branch 1
2'b10: begin
Next_State <= 2'b00;
{IF_write, PC_write, bubble} <= 3'b111;
addrSel <= 2'b00;
end
// Jump
2'b11: begin
Next_State <= 2'b00;
{IF_write, PC_write, bubble} <= 3'b111;
addrSel <= 2'b00;
end
default: begin
Next_State <= 2'b00;
{IF_write, PC_write, bubble} <= 3'b110;
addrSel <= 2'b00;
end
endcase
end
// State is changed in negedge of the clock
always @(negedge Clk) begin
// If reset
if(Rst == 0)
state <= 2'b00;
else
state <= Next_State;
end
endmodule
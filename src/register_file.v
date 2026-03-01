`timescale 1ns / 1ps
module RegisterFile(BusA , BusB , BusW , RA, RB, RW, RegWr , Clk);
// Define Inputs, Outputs and 32*32 RegisterMemory
input [4:0] RA;
input [4:0] RB;
input [4:0] RW;
input [31:0] BusW;
input RegWr, Clk;
output [31:0] BusA;
output [31:0] BusB;
reg [31:0] RegisterMemory[31:0];
// Read continuously from the register memory
assign BusB = (RB==0) ? 0 : RegisterMemory[RB];
assign BusA = (RA==0) ? 0 : RegisterMemory[RA];
// Write in the memory at the posedge of clock
always @(posedge Clk) begin
if (RegWr == 1 && RW!=0) begin
RegisterMemory[RW] <= BusW;
end
end
endmodule
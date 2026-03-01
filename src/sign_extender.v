`timescale 1ns / 1ps
module SignExtender(signExtImm, signExtend, imm16);
output [31:0] signExtImm;
input [15:0] imm16;
input signExtend;
assign signExtImm = signExtend? ({{16{imm16[15]}}, imm16[15:0]}):
{16'b0,imm16[15:0]};
endmodule
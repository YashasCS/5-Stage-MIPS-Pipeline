`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2024 08:09:18 PM
// Design Name: 
// Module Name: ForwardingUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ForwardingUnit (UseShamt , UseImmed , ID_Rs, ID_Rt, EX_Rw, MEM_Rw,
EX_RegWrite, MEM_RegWrite, AluOpCtrlA, AluOpCtrlB, DataMemForwardCtrl_EX ,
DataMemForwardCtrl_MEM ) ;

input UseShamt , UseImmed ;
input [4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
input EX_RegWrite, MEM_RegWrite ;
output reg [1:0] AluOpCtrlA, AluOpCtrlB ;
output DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM ;

always @(*) begin
    if (UseShamt == 1)
        AluOpCtrlA <= 2'b00;
    
    else if((MEM_RegWrite == 1) && ID_Rs == MEM_Rw && MEM_Rw != 0) begin        /// checking if you are actually writing to the register file and dest is true 
        if((EX_RegWrite ==1) && (MEM_Rw == EX_Rw)) begin                         
            if (ID_Rs == EX_Rw && EX_Rw !=0 && EX_RegWrite ==1)
                AluOpCtrlA <= 2'b10; end
        else 
        begin
            AluOpCtrlA <= 2'b01;
        end 
    end else
        AluOpCtrlA <= 2'b11; 
end 
    
always @(*) begin 
    if(UseImmed == 1) begin 
        AluOpCtrlB <= 2'b00; 
    end
    
    else if(EX_RegWrite && ID_Rt == EX_Rw && EX_Rw !=0) begin 
        AluOpCtrlB<=2'b01; 
    end 
     
    else if(MEM_RegWrite && ID_Rt == MEM_Rw && MEM_Rw != 0) begin
        AluOpCtrlB <= 2'b10; 
    end 
    
    else begin
        AluOpCtrlB <= 2'b11;
    end
end 

assign DataMemForwardCtrl_EX =  (MEM_Rw == ID_Rt) && MEM_RegWrite && (MEM_Rw != 0);   
assign DataMemForwardCtrl_MEM = (EX_Rw == ID_Rs) && EX_RegWrite && (EX_Rw !=0);

endmodule

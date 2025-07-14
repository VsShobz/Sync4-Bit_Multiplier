`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 16:50:10
// Design Name: 
// Module Name: sync4bitMul
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


module sync4bitMul(input clk, input [3:0] a,b , output reg [7:0] mul);
    always@(posedge clk)begin
        mul <= a * b ;
    end
endmodule

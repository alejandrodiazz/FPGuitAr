`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2019 11:20:27 PM
// Design Name: 
// Module Name: note_positions
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


module note_positions(input clk_in, input [3:0] index, output reg [10:0] x_pos);
  always_ff @(posedge clk_in)begin
    case(index)
      4'd1:  x_pos<= 100;
      4'd2:  x_pos<= 167;
      4'd3:  x_pos<= 233;
      4'd4:  x_pos<= 300;
      4'd5:  x_pos<= 367;
      4'd6:  x_pos<= 433;
      4'd7:  x_pos<= 500;
      4'd8:  x_pos<= 567;
      4'd9:  x_pos<= 633;
      4'd10: x_pos<= 700;
      4'd11: x_pos<= 767;
      4'd12: x_pos<= 833;
      4'd13: x_pos<= 900;
    endcase
  end
endmodule

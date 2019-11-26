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


module note_positions(input clk_in, input [5:0] index, output reg [10:0] x_pos);
  always_ff @(posedge clk_in)begin
    case(index)
        6'd1:  x_pos <= 200;    // A1
        6'd2:  x_pos <= 250;
        6'd3:  x_pos <= 300;
        6'd4:  x_pos <= 350;
        6'd5:  x_pos <= 400;
        6'd6:  x_pos <= 450;
        6'd7:  x_pos <= 500;
        6'd8:  x_pos <= 550;
        6'd9:  x_pos <= 600;
        6'd10:  x_pos <= 650;
        6'd11:  x_pos <= 700;
        6'd12:  x_pos <= 750;
        6'd13:  x_pos <= 210;   // A2
        6'd14:  x_pos <= 260;
        6'd15:  x_pos <= 310;
        6'd16:  x_pos <= 360;
        6'd17:  x_pos <= 410;
        6'd18:  x_pos <= 460;
        6'd19:  x_pos <= 510;
        6'd20:  x_pos <= 560;
        6'd21:  x_pos <= 610;
        6'd22:  x_pos <= 660;
        6'd23:  x_pos <= 710;
        6'd24:  x_pos <= 760;
        6'd25:  x_pos <= 220;   // A3
        6'd26:  x_pos <= 270;
        6'd27:  x_pos <= 320;
        6'd28:  x_pos <= 370;
        6'd29:  x_pos <= 420;
        6'd30:  x_pos <= 470;
        6'd31:  x_pos <= 520;
        6'd32:  x_pos <= 570;
        6'd33:  x_pos <= 620;
        6'd34:  x_pos <= 670;
        6'd35:  x_pos <= 720;
        6'd36:  x_pos <= 770;
        6'd37:  x_pos <= 230;   // A4
        6'd38:  x_pos <= 280;
        6'd39:  x_pos <= 330;
        6'd40:  x_pos <= 380;
        6'd41:  x_pos <= 430;
        6'd42:  x_pos <= 480;
        6'd43:  x_pos <= 530;
        6'd44:  x_pos <= 580;
        6'd45:  x_pos <= 630;
        6'd46:  x_pos <= 680;
        6'd47:  x_pos <= 730;
        6'd48:  x_pos <= 780;
        6'd49:  x_pos <= 240;   // A5
        6'd50:  x_pos <= 290;
        6'd51:  x_pos <= 340;
        6'd52:  x_pos <= 390;
        6'd53:  x_pos <= 440;
        6'd54:  x_pos <= 490;
        6'd55:  x_pos <= 540;
        6'd56:  x_pos <= 590;
        6'd57:  x_pos <= 640;
        6'd58:  x_pos <= 690;
        6'd59:  x_pos <= 740;
        6'd60:  x_pos <= 790;
        6'd61:  x_pos <= 800;   // A6
    endcase
  end
endmodule

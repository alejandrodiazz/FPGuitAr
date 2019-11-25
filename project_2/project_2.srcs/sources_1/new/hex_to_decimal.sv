`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2019 03:50:55 PM
// Design Name: 
// Module Name: hex_to_decimal
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


module hex_to_decimal(
    input reset,
    input [10:0] hcount_in,
    input [9:0]  vcount_in,
    input [16:0] score,
    input clk_in,
    output [11:0] digit_pixels
    );
    
    logic [3:0] digit1000, digit100, digit10, digit1;
    logic [16:0] number;
    logic [3:0] state;
    
    logic [3:0] di1000, di100, di10, di1;
    
    //IMAGE
    wire [11:0] dig1, dig10, dig100, dig1000;  // output for digit pixel from module
    picture_blob_digit  d1(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(clk_in), .x_in(900),.y_in(100),
        .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(dig1), .offset(0), .digit(digit1)); 
    picture_blob_digit  d10(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(clk_in), .x_in(830),.y_in(100),
        .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(dig10), .offset(0), .digit(digit10)); 
    picture_blob_digit  d100(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(clk_in), .x_in(760),.y_in(100),
        .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(dig100), .offset(0), .digit(digit100)); 
    picture_blob_digit  d1000(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(clk_in), .x_in(690),.y_in(100),
        .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(dig1000), .offset(0), .digit(digit1000)); 

    assign digit_pixels = dig1 | dig10 | dig100 | dig1000;
    always_ff @(posedge clk_in) begin
        if (reset) begin
            state <= 0;
        end else if(state == 0) begin
            state <= 1;
            digit1000 <= 0; digit100 <= 0; digit10 <= 0; digit1 <= 0;
            number <= score;
        end else if(state == 1) begin
            if(number >= 1000) begin
                number  <= number - 1000;
                digit1000 <= digit1000 + 1;
            end else if(number >= 100) begin
                number  <= number - 100;
                digit100 <= digit100 + 1;
            end else if(number >= 10) begin
                number  <= number - 10;
                digit10 <= digit10 + 1;
            end else if(number >= 1) begin
                number  <= number - 1;
                digit1 <= digit1 + 1;
            end else begin
                state <= 0;
                di1 <= digit1;
                di10 <= digit10;
                di100 <= digit100;
                di1000 <= digit1000;
            end
        end
    end
    
endmodule

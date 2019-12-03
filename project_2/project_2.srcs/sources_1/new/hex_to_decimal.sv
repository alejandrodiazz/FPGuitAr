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
    input [16:0] score,
    input clk_in,
    output reg [3:0] di1,
    output reg [3:0] di10,
    output reg [3:0] di100,
    output reg [3:0] di1000
    );
    
    logic [3:0] digit1000, digit100, digit10, digit1;
    logic [16:0] number;
    logic [3:0] state;
    
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

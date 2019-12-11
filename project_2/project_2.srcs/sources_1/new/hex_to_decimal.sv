`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 6.111 Final Project Fall 2019
// Engineer: Alejandro Diaz 
// 
// Create Date: 11/24/2019 03:50:55 PM
// Module Name: hex_to_decimal
// Project Name: FPGuitarHero
// Description: Converts hexadecimal to decimal through subtraction over ~10-50 
// clock cycles, latency is not an issue because the human eye does not 
// care about this speed. 
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
        end else if(state == 0) begin           // reset values
            state <= 1;
            digit1000 <= 0; digit100 <= 0; digit10 <= 0; digit1 <= 0;
            number <= score;
        end else if(state == 1) begin
            if(number >= 1000) begin            // find the number of 1000's
                number  <= number - 1000;
                digit1000 <= digit1000 + 1;
            end else if(number >= 100) begin    // find the number of 100's
                number  <= number - 100;
                digit100 <= digit100 + 1;
            end else if(number >= 10) begin     // find the number of 10's
                number  <= number - 10;
                digit10 <= digit10 + 1;
            end else if(number >= 1) begin      // find the number of 1's
                number  <= number - 1;
                digit1 <= digit1 + 1;
            end else begin                      
                state <= 0;                     // restart the process
                di1 <= digit1;                  // update decimal output values
                di10 <= digit10;
                di100 <= digit100;
                di1000 <= digit1000;
            end
        end
    end
    
endmodule

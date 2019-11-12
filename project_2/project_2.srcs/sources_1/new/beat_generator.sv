`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2019 10:18:07 PM
// Design Name: 
// Module Name: beat_generator
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


module beat_generator(
    input reset,
    input clk_in,
    input [26:0] bpm,
    output reg [5:0] beat
    );
    
    logic [26:0]counter;
    
    always_ff @ (posedge clk_in) begin
        if( reset ) begin                   // reset values
            counter <= 0; 
            beat <= 0;  
        end else begin
            if(counter == bpm) begin        // if bpm is reached then increment beat
                beat <= beat + 1;
                counter <= 0;               // reset counter
            end else begin
                counter <= counter + 1;     // increment counter
            end
        end
    end
    
endmodule

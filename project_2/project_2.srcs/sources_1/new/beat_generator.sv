`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 6.111 Final Project Fall 2019
// Engineer: Alejandro Diaz 
//
// Create Date: 11/11/2019 10:18:07 PM
// Module Name: beat_generator
// Project Name: FPGuitarHero
// Description: Creates the beat for songs that determines which notes should be
// generated
//////////////////////////////////////////////////////////////////////////////////


module beat_generator(
    input reset,
    input clk_in,
    input [26:0] bpm,
    output reg [8:0] beat
    );
    
    logic [26:0] counter;
    
    always_ff @ (posedge clk_in) begin
        if( reset ) begin                   // reset values
            counter <= 0; 
            beat <= 511;  
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

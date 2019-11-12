`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2019 11:12:04 PM
// Design Name: 
// Module Name: note_generator
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


module note_generator(
    input reset,
    input clk_in,
    input [5:0] beat,
    input [23:0] music_out,
    output [12:0] pixel
    );
    
    logic [5:0] old_beat;
    logic [1:0] note_state;
    logic outputting;
    logic [3:0] note_buffer;
    logic [3:0] note_num;
    logic [1:0] wait_; 
    logic [10:0] x_pos;
    
    note_positions notepos(.clk_in(clk_in), .index(note_num), .x_pos(x_pos));
    
    // Notes
   logic [10:0] x0;     // x coordinate
   logic [9:0] y0;        // y coordinate which changes
   wire [11:0] note_pixel1;    // output from blob module for paddle
   parameter note_width = 16;        // fixed note width
   logic[8:0] note_length1;
   blob note1(.width(note_width), .height(note_length1), .color(12'hFFF), .pixel_clk_in(vclock_in),.x_in(note_x1),.y_in(note_y1),
                .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(note_pixel1));
   
   logic [10:0] note_x2;     // x coordinate
   logic [9:0] note_y2;        // y coordinate which changes
   wire [11:0] note_pixel2;    // output from blob module for paddle
   logic[8:0] note_length2;             
   blob note2(.width(note_width), .height(note_length2), .color(12'hFFF), .pixel_clk_in(vclock_in),.x_in(note_x2),.y_in(note_y2),
                .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(note_pixel2));
    
    always_ff @ (posedge clk_in) begin
        old_beat <= beat;
        if( reset ) begin                   // reset values
            note_state <= 0;
            wait_ <= 0;
            note_buffer <= 0;
        end else begin
            if( (beat != old_beat) || outputting) begin
                wait_ <= wait_ + 1;
                if(wait_ == 0) begin
                    note_state <= note_state + 1;`          // creates small time buffer for note creation
                    case(note_state) 
                        2'd0:  begin
                            outputting <= 1;
                            if(music_out[23:20] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[23:20];
                            end
                        end
                        2'd1:  begin
                            if(music_out[17:14] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[17:14];
                            end
                        end
                        2'd2:  begin
                            if(music_out[11:8] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[11:8];
                            end
                        end
                        2'd3:  begin
                            if(music_out[5:2] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[5:2];
                            end
                        end
                    endcase
                end
            end
            
            case(note_buffer) 
                4'd0:  x0 <= x_pos;
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
                4'd14: x_pos<= 900;
                4'd15: x_pos<= 900;
            endcase
        end
    end
    
endmodule

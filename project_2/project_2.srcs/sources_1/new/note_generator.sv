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
    input [10:0] hcount_in, // horizontal index of current pixel (0..1023)
    input [9:0]  vcount_in, // vertical index of current pixel (0..767)
    input [5:0] beat,
    input [26:0] bpm,
    input [23:0] music_out,
    output reg [11:0] pixel,
    output [23:0] testing
    );
    
    logic [5:0] old_beat;
    logic [1:0] note_state;
    logic outputting;
    logic [3:0] note_buffer;
    logic [3:0] note_num;
    logic [1:0] wait_; 
    logic [10:0] x_pos;
    
    note_positions notepos(.clk_in(clk_in), .index(note_num), .x_pos(x_pos));
    
    // NOTE BLOBS
    logic [10:0] x0;     // x coordinate
    logic [9:0] y0;        // y coordinate which changes
    wire [11:0] npixel0;    // output from blob module for paddle
    parameter note_width = 16;        // fixed note width
    logic[8:0] nlen0;
    blob note0(.width(note_width), .height(nlen0), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x0),.y_in(y0),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel0));
    
    logic [10:0] x1;     // x coordinate
    logic [9:0] y1;        // y coordinate which changes
    wire [11:0] npixel1;    // output from blob module for paddle
    logic[8:0] nlen1;             
    blob note1(.width(note_width), .height(nlen1), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x1),.y_in(y1),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel1));
            
    logic [10:0] x2;     // x coordinate
    logic [9:0] y2;        // y coordinate which changes
    wire [11:0] npixel2;    // output from blob module for paddle
    logic[8:0] nlen2;             
    blob note2(.width(note_width), .height(nlen2), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x2),.y_in(y2),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel2));
            
    logic [10:0] x3;     // x coordinate
    logic [9:0] y3;        // y coordinate which changes
    wire [11:0] npixel3;    // output from blob module for paddle
    logic[8:0] nlen3;             
    blob note3(.width(note_width), .height(nlen3), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x3),.y_in(y3),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel3));
    
    logic [10:0] x4;     // x coordinate
    logic [9:0] y4;        // y coordinate which changes
    wire [11:0] npixel4;    // output from blob module for paddle
    logic[8:0] nlen4;             
    blob note4(.width(note_width), .height(nlen4), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x4),.y_in(y4),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel4));
    
    logic [10:0] x5;     // x coordinate
    logic [9:0] y5;        // y coordinate which changes
    wire [11:0] npixel5;    // output from blob module for paddle
    logic[8:0] nlen5;             
    blob note5(.width(note_width), .height(nlen5), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x5),.y_in(y5),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel5));
    
    
    
    logic [1:0] curr_note_length;
    logic [8:0] note_length;
    logic [26:0] speed;
    assign speed = bpm / 60;
    logic [26:0] speed_counter;
    logic activate_note;
    logic activate_wait;
    
    assign testing = { 8'b0, note_buffer, note_num, 2'b0, music_out[23:18]};
    
    always_ff @ (posedge clk_in) begin
        old_beat <= beat;                   // feed in new beat
        pixel <= (npixel0 | npixel1 | npixel2 | npixel3 | npixel4 | npixel5);       // displays the note pixels on the screen
        if( reset ) begin                   // reset values
            note_state <= 0;
            wait_ <= 0;
            note_buffer <= 15;
            speed_counter <= 0;
            outputting <= 0;
            old_beat <= 0;
        end else begin
            if (beat != old_beat) begin
                outputting <= 1;
            end
            if(outputting) begin
                wait_ <= wait_ + 1;
                if(wait_ == 0) begin                    // creates small time buffer for note creation
                    note_state <= note_state + 1;          
                    case(note_state) 
                        2'd0:  begin
                            if(music_out[23:20] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[23:20];
                                curr_note_length <= music_out[19:18];
                                activate_note <= 1;
                            end
                        end
                        2'd1:  begin
                            if(music_out[17:14] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[17:14];
                                curr_note_length <= music_out[13:12];
                                activate_note <= 1;
                            end
                        end
                        2'd2:  begin
                            if(music_out[11:8] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[11:8];
                                curr_note_length <= music_out[7:6];
                                activate_note <= 1;
                            end
                        end
                        2'd3:  begin
                            outputting <= 0;                        // done generating notes
                            if(music_out[5:2] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[5:2];
                                curr_note_length <= music_out[1:0];
                                activate_note <= 1;
                            end
                        end
                    endcase
                end 
            end else begin
                wait_ <= 0;
                activate_note <= 0;
            end
            
            // display appropriate notes with x position and length
            if( activate_note ) begin
                
                if(activate_wait) begin
                    activate_note <= 0;
                    activate_wait <= 0;
                end else begin
                    activate_wait <= 1;
                end
                
                case(note_buffer) 
                    4'd0:  begin
                        x0 <= x_pos; y0 <= 0; nlen0 <= note_length;
                        end
                    4'd1:  begin
                        x1 <= x_pos; y1 <= 0; nlen1 <= note_length;
                        end
                    4'd2:  begin
                        x2 <= x_pos; y2 <= 0; nlen2 <= note_length;
                        end
                    4'd3: begin
                        x3 <= x_pos; y3 <= 0; nlen3 <= note_length;
                        end
                    4'd4: begin
                        x4 <= x_pos; y4 <= 0; nlen4 <= note_length;
                        end
                    4'd5: begin
                        x5 <= x_pos; y5 <= 0; nlen5 <= note_length;
                        end 
//                    4'd6:  x_pos<= 433;
//                    4'd7:  x_pos<= 500;
//                    4'd8:  x_pos<= 567;
//                    4'd9:  x_pos<= 633;
//                    4'd10: x_pos<= 700;
//                    4'd11: x_pos<= 767;
//                    4'd12: x_pos<= 833;
//                    4'd13: x_pos<= 900;
//                    4'd14: x_pos<= 900;
//                    4'd15: x_pos<= 900;
                endcase
            end
            
            // move notes
            if(speed_counter >= speed) begin
                y0 <= y0 + 1; y1 <= y1 + 1; y2 <= y2 + 1; y3 <= y3 + 1; y4 <= y4 + 1; y5 <= y5 + 1;
                speed_counter <= 0;
            end else begin
                speed_counter <= speed_counter + 1;
            end
            
            // determine length of notes
            case(curr_note_length) 
                2'd0: note_length <= 9'b000100000;
                2'd1: note_length <= 9'b001000000;
                2'd2: note_length <= 9'b010000000;
                2'd3: note_length <= 9'b100000000;
            endcase
        end
    end
    
endmodule

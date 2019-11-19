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
    output [23:0] testing,
    output reg pixel_step
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
            
    logic [10:0] x6;     // x coordinate
    logic [9:0] y6;        // y coordinate which changes
    wire [11:0] npixel6;    // output from blob module for paddle
    logic[8:0] nlen6;             
    blob note6(.width(note_width), .height(nlen6), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x6),.y_in(y6),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel6));
    
    logic [10:0] x7;     // x coordinate
    logic [9:0] y7;        // y coordinate which changes
    wire [11:0] npixel7;    // output from blob module for paddle
    logic[8:0] nlen7;             
    blob note7(.width(note_width), .height(nlen7), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x7),.y_in(y7),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel7));
    
    logic [10:0] x8;     // x coordinate
    logic [9:0] y8;        // y coordinate which changes
    wire [11:0] npixel8;    // output from blob module for paddle
    logic[8:0] nlen8;             
    blob note8(.width(note_width), .height(nlen8), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x8),.y_in(y8),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel8));
            
    logic [10:0] x9;     // x coordinate
    logic [9:0] y9;        // y coordinate which changes
    wire [11:0] npixel9;    // output from blob module for paddle
    logic[8:0] nlen9;             
    blob note9(.width(note_width), .height(nlen9), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x9),.y_in(y9),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel9));
    
    logic [10:0] x10;     // x coordinate
    logic [9:0] y10;        // y coordinate which changes
    wire [11:0] npixel10;    // output from blob module for paddle
    logic[8:0] nlen10;             
    blob note10(.width(note_width), .height(nlen10), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x10),.y_in(y10),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel10));
    
    logic [10:0] x11;     // x coordinate
    logic [9:0] y11;        // y coordinate which changes
    wire [11:0] npixel11;    // output from blob module for paddle
    logic[8:0] nlen11;             
    blob note11(.width(note_width), .height(nlen11), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x11),.y_in(y11),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel11));
    
    logic [10:0] x12;     // x coordinate
    logic [9:0] y12;        // y coordinate which changes
    wire [11:0] npixel12;    // output from blob module for paddle
    logic[8:0] nlen12;             
    blob note12(.width(note_width), .height(nlen12), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x12),.y_in(y12),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel12));
    
      
    logic [10:0] x13;     // x coordinate
    logic [9:0] y13;        // y coordinate which changes
    wire [11:0] npixel13;    // output from blob module for paddle
    logic[8:0] nlen13;             
    blob note13(.width(note_width), .height(nlen13), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x13),.y_in(y13),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel13));
            
    logic [10:0] x14;     // x coordinate
    logic [9:0] y14;        // y coordinate which changes
    wire [11:0] npixel14;    // output from blob module for paddle
    logic[8:0] nlen14;             
    blob note14(.width(note_width), .height(nlen14), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x14),.y_in(y14),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel14));
    
    logic [10:0] x15;     // x coordinate
    logic [9:0] y15;        // y coordinate which changes
    wire [11:0] npixel15;    // output from blob module for paddle
    logic[8:0] nlen15;             
    blob note15(.width(note_width), .height(nlen15), .color(12'hFFF), .pixel_clk_in(clk_in),.x_in(x15),.y_in(y15),
            .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel15));
    
    
    logic [1:0] curr_note_length;
    logic [8:0] note_length;
    logic [26:0] speed;
    assign speed = bpm / 50;
    logic [26:0] speed_counter;
    logic activate_note;
    logic activate_wait;
    
    assign testing = { 8'b0, note_buffer, note_num, 2'b0, music_out[23:18]};
    
    always_ff @ (posedge clk_in) begin
        old_beat <= beat;                   // feed in new beat
        pixel <= (npixel0 | npixel1 | npixel2 | npixel3 | npixel4 | npixel5 | npixel6 | 
                    npixel7 | npixel8 | npixel9 | npixel10 | npixel11 | npixel12 | npixel13 |
                    npixel14 | npixel15);       // displays the note pixels on the screen
        if( reset ) begin                   // reset values
            note_state <= 0;
            wait_ <= 0;
            note_buffer <= 15;
            speed_counter <= 0;
            outputting <= 0;
            old_beat <= 0;
            activate_wait <= 1;
            pixel_step <= 0;
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
                    activate_wait <= 0;
                end else begin
                    activate_wait <= 1;
                    case(note_buffer) 
                    4'd0:  begin x0 <= x_pos;  y0 <= 0;  nlen0 <= note_length;  end
                    4'd1:  begin x1 <= x_pos;  y1 <= 0;  nlen1 <= note_length;  end
                    4'd2:  begin x2 <= x_pos;  y2 <= 0;  nlen2 <= note_length;  end
                    4'd3:  begin x3 <= x_pos;  y3 <= 0;  nlen3 <= note_length;  end
                    4'd4:  begin x4 <= x_pos;  y4 <= 0;  nlen4 <= note_length;  end
                    4'd5:  begin x5 <= x_pos;  y5 <= 0;  nlen5 <= note_length;  end 
                    4'd6:  begin x6 <= x_pos;  y6 <= 0;  nlen6 <= note_length;  end
                    4'd7:  begin x7 <= x_pos;  y7 <= 0;  nlen7 <= note_length;  end
                    4'd8:  begin x8 <= x_pos;  y8 <= 0;  nlen8 <= note_length;  end
                    4'd9:  begin x9 <= x_pos;  y9 <= 0;  nlen9 <= note_length;  end
                    4'd10: begin x10 <= x_pos; y10 <= 0; nlen10 <= note_length; end
                    4'd11: begin x11 <= x_pos; y11 <= 0; nlen11 <= note_length; end
                    4'd12: begin x12 <= x_pos; y12 <= 0; nlen12 <= note_length; end
                    4'd13: begin x13 <= x_pos; y13 <= 0; nlen13 <= note_length; end
                    4'd14: begin x14 <= x_pos; y14 <= 0; nlen14 <= note_length; end
                    4'd15: begin x15 <= x_pos; y15 <= 0; nlen15 <= note_length; end
                endcase
                end
            end
            
            // move notes
            if(speed_counter >= speed) begin
                y0 <=  y0 < 770?  y0 + 1:  780;
                y1 <=  y1 < 770?  y1 + 1:  780;
                y2 <=  y2 < 770?  y2 + 1:  780;
                y3 <=  y3 < 770?  y3 + 1:  780;
                y4 <=  y4 < 770?  y4 + 1:  780;
                y5 <=  y5 < 770?  y5 + 1:  780;
                y6 <=  y6 < 770?  y6 + 1:  780;
                y7 <=  y7 < 770?  y7 + 1:  780;
                y8 <=  y8 < 770?  y8 + 1:  780;
                y9 <=  y9 < 770?  y9 + 1:  780;
                y10 <= y10 < 770? y10 + 1: 780;
                y11 <= y11 < 770? y11 + 1: 780;
                y12 <= y12 < 770? y12 + 1: 780;
                y13 <= y13 < 770? y13 + 1: 780;
                y14 <= y14 < 770? y14 + 1: 780;
                y15 <= y15 < 770? y15 + 1: 780;
                speed_counter <= 0;
                pixel_step <= 1;
            end else begin
                pixel_step <= 0;
                speed_counter <= speed_counter + 1;
            end
            
            // determine length of notes
            case(curr_note_length) 
                2'd0: note_length <= 9'b000110000;
                2'd1: note_length <= 9'b001100000;
                2'd2: note_length <= 9'b011000000;
                2'd3: note_length <= 9'b110000000;
            endcase
        end
    end
    
endmodule

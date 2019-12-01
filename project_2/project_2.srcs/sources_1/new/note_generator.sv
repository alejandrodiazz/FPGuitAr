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
    input [6:0] beat,
    input [26:0] bpm,
    input [35:0] music_out,
    output reg [11:0] pixel,
    output [23:0] testing,
    output reg pixel_step
    );
    
    
    // NOTE BLOBS
    logic [10:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15,
                x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31;  // x coordinate
    logic [9:0]  y0, y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, 
                y16, y17, y18, y19, y20, y21, y22, y23, y24, y25, y26, y27, y28, y29, y30, y31; // y coord which changes
    wire [11:0] npixel0, npixel1, npixel2, npixel3, npixel4, npixel5, npixel6, npixel7, 
        npixel8, npixel9, npixel10, npixel11, npixel12, npixel13, npixel14, npixel15, 
        npixel16, npixel17, npixel18, npixel19, npixel20, npixel21, npixel22, npixel23, 
        npixel24, npixel25, npixel26, npixel27, npixel28, npixel29, npixel30, npixel31;    // output from blob module for paddle
    logic[8:0] nlen0, nlen1, nlen2, nlen3, nlen4, nlen5, nlen6, nlen7, nlen8, nlen9, 
        nlen10, nlen11, nlen12, nlen13, nlen14, nlen15, nlen16, nlen17, nlen18, nlen19, 
        nlen20, nlen21, nlen22, nlen23, nlen24, nlen25, nlen26, nlen27, nlen28, nlen29, 
        nlen30, nlen31;
    logic[11:0] ncolor0, ncolor1, ncolor2, ncolor3, ncolor4, ncolor5, ncolor6, ncolor7, ncolor8, ncolor9, 
        ncolor10, ncolor11, ncolor12, ncolor13, ncolor14, ncolor15, ncolor16, ncolor17, ncolor18, ncolor19, 
        ncolor20, ncolor21, ncolor22, ncolor23, ncolor24, ncolor25, ncolor26, ncolor27, ncolor28, ncolor29, 
        ncolor30, ncolor31;
    parameter note_width = 10;        // fixed note width
    
    blob note0(.width(note_width), .height(nlen0), .color(ncolor0), .pixel_clk_in(clk_in),.x_in(x0),.y_in(y0),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel0));
    blob note1(.width(note_width), .height(nlen1), .color(ncolor1), .pixel_clk_in(clk_in),.x_in(x1),.y_in(y1),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel1));
    blob note2(.width(note_width), .height(nlen2), .color(ncolor2), .pixel_clk_in(clk_in),.x_in(x2),.y_in(y2),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel2));
    blob note3(.width(note_width), .height(nlen3), .color(ncolor3), .pixel_clk_in(clk_in),.x_in(x3),.y_in(y3),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel3));
    blob note4(.width(note_width), .height(nlen4), .color(ncolor4), .pixel_clk_in(clk_in),.x_in(x4),.y_in(y4),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel4));
    blob note5(.width(note_width), .height(nlen5), .color(ncolor5), .pixel_clk_in(clk_in),.x_in(x5),.y_in(y5),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel5));
    blob note6(.width(note_width), .height(nlen6), .color(ncolor6), .pixel_clk_in(clk_in),.x_in(x6),.y_in(y6),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel6));
    blob note7(.width(note_width), .height(nlen7), .color(ncolor7), .pixel_clk_in(clk_in),.x_in(x7),.y_in(y7),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel7));
    blob note8(.width(note_width), .height(nlen8), .color(ncolor8), .pixel_clk_in(clk_in),.x_in(x8),.y_in(y8),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel8));
    blob note9(.width(note_width), .height(nlen9), .color(ncolor9), .pixel_clk_in(clk_in),.x_in(x9),.y_in(y9),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel9));
    blob note10(.width(note_width), .height(nlen10), .color(ncolor10), .pixel_clk_in(clk_in),.x_in(x10),.y_in(y10),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel10));
    blob note11(.width(note_width), .height(nlen11), .color(ncolor11), .pixel_clk_in(clk_in),.x_in(x11),.y_in(y11),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel11));
    blob note12(.width(note_width), .height(nlen12), .color(ncolor12), .pixel_clk_in(clk_in),.x_in(x12),.y_in(y12),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel12));
    blob note13(.width(note_width), .height(nlen13), .color(ncolor13), .pixel_clk_in(clk_in),.x_in(x13),.y_in(y13),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel13));
    blob note14(.width(note_width), .height(nlen14), .color(ncolor14), .pixel_clk_in(clk_in),.x_in(x14),.y_in(y14),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel14));
    blob note15(.width(note_width), .height(nlen15), .color(ncolor15), .pixel_clk_in(clk_in),.x_in(x15),.y_in(y15),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel15));
    blob note16(.width(note_width), .height(nlen16), .color(ncolor16), .pixel_clk_in(clk_in),.x_in(x16),.y_in(y16),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel16));
    blob note17(.width(note_width), .height(nlen17), .color(ncolor17), .pixel_clk_in(clk_in),.x_in(x17),.y_in(y17),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel17));
    blob note18(.width(note_width), .height(nlen18), .color(ncolor18), .pixel_clk_in(clk_in),.x_in(x18),.y_in(y18),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel18));
    blob note19(.width(note_width), .height(nlen19), .color(ncolor19), .pixel_clk_in(clk_in),.x_in(x19),.y_in(y19),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel19));
    blob note20(.width(note_width), .height(nlen20), .color(ncolor20), .pixel_clk_in(clk_in),.x_in(x20),.y_in(y20),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel20));
    blob note21(.width(note_width), .height(nlen21), .color(ncolor21), .pixel_clk_in(clk_in),.x_in(x21),.y_in(y21),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel21));
    blob note22(.width(note_width), .height(nlen22), .color(ncolor22), .pixel_clk_in(clk_in),.x_in(x22),.y_in(y22),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel22));
    blob note23(.width(note_width), .height(nlen23), .color(ncolor23), .pixel_clk_in(clk_in),.x_in(x23),.y_in(y23),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel23));
    blob note24(.width(note_width), .height(nlen24), .color(ncolor24), .pixel_clk_in(clk_in),.x_in(x24),.y_in(y24),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel24));
    blob note25(.width(note_width), .height(nlen25), .color(ncolor25), .pixel_clk_in(clk_in),.x_in(x25),.y_in(y25),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel25));
    blob note26(.width(note_width), .height(nlen26), .color(ncolor26), .pixel_clk_in(clk_in),.x_in(x26),.y_in(y26),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel26));
    blob note27(.width(note_width), .height(nlen27), .color(ncolor27), .pixel_clk_in(clk_in),.x_in(x27),.y_in(y27),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel27));
    blob note28(.width(note_width), .height(nlen28), .color(ncolor28), .pixel_clk_in(clk_in),.x_in(x28),.y_in(y28),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel28));
    blob note29(.width(note_width), .height(nlen29), .color(ncolor29), .pixel_clk_in(clk_in),.x_in(x29),.y_in(y29),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel29));
    blob note30(.width(note_width), .height(nlen30), .color(ncolor30), .pixel_clk_in(clk_in),.x_in(x30),.y_in(y30),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel30));
    blob note31(.width(note_width), .height(nlen31), .color(ncolor31), .pixel_clk_in(clk_in),.x_in(x31),.y_in(y31),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel31));

    
    logic [6:0] old_beat;
    logic [1:0] note_state;
    logic outputting;
    logic [4:0] note_buffer;
    logic [5:0] note_num;
    logic [1:0] wait_; 
    logic [10:0] x_pos;
    
    logic [2:0] curr_note_length;
    logic [8:0] note_length;
    logic [11:0] note_color;
    logic [26:0] speed;
    assign speed = bpm / 30;    // controls rate of falling and distance between notes
    logic [26:0] speed_counter;
    logic activate_note;
    logic activate_wait;
    
    note_positions notepos(.clk_in(clk_in), .index(note_num), .x_pos(x_pos));
    
    assign testing = { 3'b0, note_buffer, 2'b0, note_num, 2'b0, music_out[35:30]}; // 24 bits goes into top part of hex display
    
    always_ff @ (posedge clk_in) begin
        old_beat <= beat;                   // feed in new beat
        pixel <= (npixel0 | npixel1 | npixel2 | npixel3 | npixel4 | npixel5 | npixel6 | 
            npixel7 | npixel8 | npixel9 | npixel10 | npixel11 | npixel12 | npixel13 | 
            npixel14 | npixel15 | npixel16 | npixel17 | npixel18 | npixel19 | npixel20 | 
            npixel21 | npixel22 | npixel23 | npixel24 | npixel25 | npixel26 | npixel27 | 
            npixel28 | npixel29 | npixel30 | npixel31);       // displays the note pixels on the screen
        if( reset ) begin                   // reset values
            note_state <= 0;
            wait_ <= 0;
            note_buffer <= 31;
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
                            if(music_out[35:30] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[35:30];
                                curr_note_length <= music_out[29:27];
                                activate_note <= 1;
                            end
                        end
                        2'd1:  begin
                            if(music_out[26:21] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[26:21];
                                curr_note_length <= music_out[20:18];
                                activate_note <= 1;
                            end
                        end
                        2'd2:  begin
                            if(music_out[17:12] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[17:12];
                                curr_note_length <= music_out[11:9];
                                activate_note <= 1;
                            end
                        end
                        2'd3:  begin
                            outputting <= 0;                        // done generating notes
                            if(music_out[8:3] != 0) begin
                                note_buffer <= note_buffer + 1;
                                note_num <= music_out[8:3];
                                curr_note_length <= music_out[2:0];
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
                        5'd0: begin x0 <=  x_pos; y0 <= 0; nlen0 <= note_length; ncolor0 <= note_color; end
                        5'd1: begin x1 <=  x_pos; y1 <= 0; nlen1 <= note_length; ncolor1 <= note_color; end
                        5'd2: begin x2 <=  x_pos; y2 <= 0; nlen2 <= note_length; ncolor2 <= note_color; end
                        5'd3: begin x3 <=  x_pos; y3 <= 0; nlen3 <= note_length; ncolor3 <= note_color; end
                        5'd4: begin x4 <=  x_pos; y4 <= 0; nlen4 <= note_length; ncolor4 <= note_color; end
                        5'd5: begin x5 <=  x_pos; y5 <= 0; nlen5 <= note_length; ncolor5 <= note_color; end
                        5'd6: begin x6 <=  x_pos; y6 <= 0; nlen6 <= note_length; ncolor6 <= note_color; end
                        5'd7: begin x7 <=  x_pos; y7 <= 0; nlen7 <= note_length; ncolor7 <= note_color; end
                        5'd8: begin x8 <=  x_pos; y8 <= 0; nlen8 <= note_length; ncolor8 <= note_color; end
                        5'd9: begin x9 <=  x_pos; y9 <= 0; nlen9 <= note_length; ncolor9 <= note_color; end
                        5'd10: begin x10 <=  x_pos; y10 <= 0; nlen10 <= note_length; ncolor10 <= note_color; end
                        5'd11: begin x11 <=  x_pos; y11 <= 0; nlen11 <= note_length; ncolor11 <= note_color; end
                        5'd12: begin x12 <=  x_pos; y12 <= 0; nlen12 <= note_length; ncolor12 <= note_color; end
                        5'd13: begin x13 <=  x_pos; y13 <= 0; nlen13 <= note_length; ncolor13 <= note_color; end
                        5'd14: begin x14 <=  x_pos; y14 <= 0; nlen14 <= note_length; ncolor14 <= note_color; end
                        5'd15: begin x15 <=  x_pos; y15 <= 0; nlen15 <= note_length; ncolor15 <= note_color; end
                        5'd16: begin x16 <=  x_pos; y16 <= 0; nlen16 <= note_length; ncolor16 <= note_color; end
                        5'd17: begin x17 <=  x_pos; y17 <= 0; nlen17 <= note_length; ncolor17 <= note_color; end
                        5'd18: begin x18 <=  x_pos; y18 <= 0; nlen18 <= note_length; ncolor18 <= note_color; end
                        5'd19: begin x19 <=  x_pos; y19 <= 0; nlen19 <= note_length; ncolor19 <= note_color; end
                        5'd20: begin x20 <=  x_pos; y20 <= 0; nlen20 <= note_length; ncolor20 <= note_color; end
                        5'd21: begin x21 <=  x_pos; y21 <= 0; nlen21 <= note_length; ncolor21 <= note_color; end
                        5'd22: begin x22 <=  x_pos; y22 <= 0; nlen22 <= note_length; ncolor22 <= note_color; end
                        5'd23: begin x23 <=  x_pos; y23 <= 0; nlen23 <= note_length; ncolor23 <= note_color; end
                        5'd24: begin x24 <=  x_pos; y24 <= 0; nlen24 <= note_length; ncolor24 <= note_color; end
                        5'd25: begin x25 <=  x_pos; y25 <= 0; nlen25 <= note_length; ncolor25 <= note_color; end
                        5'd26: begin x26 <=  x_pos; y26 <= 0; nlen26 <= note_length; ncolor26 <= note_color; end
                        5'd27: begin x27 <=  x_pos; y27 <= 0; nlen27 <= note_length; ncolor27 <= note_color; end
                        5'd28: begin x28 <=  x_pos; y28 <= 0; nlen28 <= note_length; ncolor28 <= note_color; end
                        5'd29: begin x29 <=  x_pos; y29 <= 0; nlen29 <= note_length; ncolor29 <= note_color; end
                        5'd30: begin x30 <=  x_pos; y30 <= 0; nlen30 <= note_length; ncolor30 <= note_color; end
                        5'd31: begin x31 <=  x_pos; y31 <= 0; nlen31 <= note_length; ncolor31 <= note_color; end
                    endcase
                end
            end
            
            // move notes
            // check if blob has been moved out of screen
            // if so then hold it out of screen
            if(speed_counter >= speed) begin
                y0 <= y0 < 770? y0 + 1: 780;
                y1 <= y1 < 770? y1 + 1: 780;
                y2 <= y2 < 770? y2 + 1: 780;
                y3 <= y3 < 770? y3 + 1: 780;
                y4 <= y4 < 770? y4 + 1: 780;
                y5 <= y5 < 770? y5 + 1: 780;
                y6 <= y6 < 770? y6 + 1: 780;
                y7 <= y7 < 770? y7 + 1: 780;
                y8 <= y8 < 770? y8 + 1: 780;
                y9 <= y9 < 770? y9 + 1: 780;
                y10 <= y10 < 770? y10 + 1: 780;
                y11 <= y11 < 770? y11 + 1: 780;
                y12 <= y12 < 770? y12 + 1: 780;
                y13 <= y13 < 770? y13 + 1: 780;
                y14 <= y14 < 770? y14 + 1: 780;
                y15 <= y15 < 770? y15 + 1: 780;
                y16 <= y16 < 770? y16 + 1: 780;
                y17 <= y17 < 770? y17 + 1: 780;
                y18 <= y18 < 770? y18 + 1: 780;
                y19 <= y19 < 770? y19 + 1: 780;
                y20 <= y20 < 770? y20 + 1: 780;
                y21 <= y21 < 770? y21 + 1: 780;
                y22 <= y22 < 770? y22 + 1: 780;
                y23 <= y23 < 770? y23 + 1: 780;
                y24 <= y24 < 770? y24 + 1: 780;
                y25 <= y25 < 770? y25 + 1: 780;
                y26 <= y26 < 770? y26 + 1: 780;
                y27 <= y27 < 770? y27 + 1: 780;
                y28 <= y28 < 770? y28 + 1: 780;
                y29 <= y29 < 770? y29 + 1: 780;
                y30 <= y30 < 770? y30 + 1: 780;
                y31 <= y31 < 770? y31 + 1: 780;

                speed_counter <= 0;
                pixel_step <= 1;
            end else begin
                pixel_step <= 0;
                speed_counter <= speed_counter + 1;
            end
            
            // determine length of notes
            case(curr_note_length) 
                3'd0: note_length <= 9'b000011000;  //16th note
                3'd1: note_length <= 9'b000110000;  // 8th note
                3'd2: note_length <= 9'b001100000;  // 1/4th note
                3'd3: note_length <= 9'b011000000;  // 1/2 note
                3'd4: note_length <= 9'b110000000;  // whole note
            endcase
            
            // determine note color based on octave
            // The rgb rotate through black 000, blue 00F, green 0F0, cyan 0FF, red F00, magenta F0F, 
            // yellow FF0, and white FFF
            case(note_num) inside
                [6'd1 :6'd12]:  note_color <= 12'hFFF; // white
                [6'd13 :6'd24]: note_color <= 12'hF00; // red
                [6'd25 :6'd36]: note_color <= 12'h0F0; // green
                [6'd37 :6'd48]: note_color <= 12'h00F; // blue
                [6'd49 :6'd60]: note_color <= 12'h0FF; // cyan
                6'd61:          note_color <= 12'hFF0; // yellow
            endcase
        end
    end
    
endmodule

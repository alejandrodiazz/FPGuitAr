`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 03:23:43 PM
// Design Name: 
// Module Name: FPGuitAr_Hero
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


////////////////////////////////////////////////////////////////////////////////
//
// Final_Project: the game itself!
//
////////////////////////////////////////////////////////////////////////////////

module FPGuitAr_Hero (
    input vclock_in,        // 65MHz clock
    input clk_100,
    input reset_in,         // 1 to initialize module
    input btnu, btnd, btnr, btnl,          // when hands should move
    input [3:0] pspeed_in,  // puck speed in pixels/tick 
    input [10:0] hcount_in, // horizontal index of current pixel (0..1023)
    input [9:0]  vcount_in, // vertical index of current pixel (0..767)
    input hsync_in,         // XVGA horizontal sync signal (active low)
    input vsync_in,         // XVGA vertical sync signal (active low)
    input blank_in,         // XVGA blanking (1 means output black pixel)
        
    output phsync_out,       // pong game's horizontal sync
    output pvsync_out,       // pong game's vertical sync
    output pblank_out,       // pong game's blanking
    output [11:0] pixel_out,  // pong game's pixel  // r=11:8, g=7:4, b=3:0
    input [15:0] sw,
    output logic aud_pwm,
    output logic aud_sd,
    output reg [15:0] led,
    output [31:0] hex_disp
    );
        
   assign phsync_out = hsync_in;
   assign pvsync_out = vsync_in;
   assign pblank_out = blank_in;
   
   logic [12:0] notes;
   
   audio_gen audio1( .clk_100mhz(clk_100), .reset(reset_in), .sw(sw), .notes(notes),
                .aud_pwm(aud_pwm), .aud_sd(aud_sd)); // CHANGE running on 65MHz clock

   // Hands
   logic [10:0] hand1_x;     // location of hand on screen 
   logic [9:0] hand1_y;
   logic [10:0] h_x = 200;      // hand dimensions
   logic [9:0] h_y = 10;
   wire [11:0] hand1_pixel;  // output for puck pixel from module
   blob hand1(.width(h_x), .height(h_y), .color(12'hFFF), .pixel_clk_in(vclock_in), .x_in(hand1_x),
            .y_in(hand1_y),.hcount_in(hcount_in), .vcount_in(vcount_in), .pixel_out(hand1_pixel)); 
   
   logic [10:0] hand2_x;     // location of hand on screen 
   logic [9:0] hand2_y;
   wire [11:0] hand2_pixel;  // output for puck pixel from module
   blob hand2(.width(h_x), .height(h_y), .color(12'hFFF), .pixel_clk_in(vclock_in), .x_in(hand2_x),
            .y_in(hand2_y),.hcount_in(hcount_in), .vcount_in(vcount_in), .pixel_out(hand2_pixel)); 
     
   // lines           
//   wire [11:0] line_pixel;  // output for puck pixel from module
//   parameter line_width = 8;
//   blob #(.WIDTH(h1_x),.HEIGHT(h1_y),.COLOR(12'hFFF))   // white!  
//   hand1(.pixel_clk_in(vclock_in), .x_in(hand1_x),.y_in(hand1_y),.hcount_in(hcount_in),
//                .vcount_in(vcount_in), .pixel_out(line_pixel)); 
             
         
   // RED PLANET
   wire [11:0] planet_pixel;
   blob planet1(.width(128), .height(128), .color(12'hF00), .pixel_clk_in(vclock_in),.x_in(450),.y_in(330),
                .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(planet_pixel));
   
   parameter m = 1;             // alpha parameters
   parameter n = 2;             // power of two
   logic [11:0] alpha_pixel;    // holds shifted values after alpha blending 
   
   //assign pixel_out = paddle_pixel | alpha_pixel; // add together all pixels for the screen 
   assign pixel_out = alpha_pixel; // add together all pixels for the screen 
   logic[3:0] a;                // different segments of the alpha blending
   logic[3:0] b;
   logic[3:0] c;
   
   logic [5:0] beat;
   logic [26:0] bpm;
   logic [23:0] music_out;
   logic [11:0] note_pixels;
   logic [23:0] testing;
   logic pixel_step;
   logic add_to_score;
   music_lookup muse(.beat(beat), .clk_in(vclock_in), .music_out(music_out));
   beat_generator meter1(.reset(reset_in), .clk_in(vclock_in), .bpm(bpm), .beat(beat));
   note_generator notegen(.reset(reset_in), .clk_in(vclock_in), .hcount_in(hcount_in),.vcount_in(vcount_in),
        .beat(beat), .bpm(bpm), .music_out(music_out), .pixel(note_pixels), .testing(testing), .pixel_step(pixel_step));
        
   //assign hex_disp = {testing,2'b0, beat};     // to hex out for debugging
   assign hex_disp = score;
   
   logic [20:0] hand1_counter;
   logic [20:0] hand2_counter;
   logic [12:0] n_array;
   logic [31:0] score;
   always @ (posedge vclock_in) begin 
        // PIXEL OUT          
//        if ((hand_pixel & planet_pixel) == 0)begin      // if puck and planet do not overlap
//            alpha_pixel <= hand_pixel | planet_pixel;   // regular adding of pixels
//        end else begin                                  // alpha blending
//            a <= ((hand_pixel[11:8] * m) >> n)| (planet_pixel[11:8] - ((planet_pixel[11:8] * m) >> n));
//            b <= ((hand_pixel[7:4] * m) >> n) | (planet_pixel[7:4] - ((planet_pixel[7:4] * m) >> n));
//            c <= ((hand_pixel[3:0] * m) >> n) | (planet_pixel[3:0] - ((planet_pixel[3:0] * m) >> n));
//            alpha_pixel <= {a,b,c};
//        end
        alpha_pixel <= note_pixels | hand1_pixel | hand2_pixel | planet_pixel;
        
        // MOVING HANDS
        if(reset_in) begin                      // reset values on a reset
            hand1_x <= 200; hand1_y <= 600;                    // reset hands
            hand2_x <= 720; hand2_y <= 600;
            bpm <= 21666000;                          // CHANGE later should be set in another manner
            notes <= 0;
            score <= 0;
        end else begin
            // AUDIO
            if((vcount_in == 1) && (hcount_in == 1)) begin      // EVERY FRAME check flags
                n_array <= 0;                                   // reset all flags
                notes <= n_array;                               // shift flags into notes being played
                if(add_to_score) begin                            // add to score based on note intersections
                    score <= score + n_array[0] + n_array[1] + n_array[2] + n_array[3] + n_array[4] + n_array[5] +
                        n_array[6] + n_array[7] + n_array[8] + n_array[9] + n_array[10] + n_array[11] + n_array[12];
                    add_to_score <= 0;    
                end
            end else begin
                if (pixel_step) begin
                    add_to_score <= 1;
                end
                if( (hand1_pixel != 0) || (hand2_pixel != 0) ) begin        // if hand pixels are being drawn
                    if ( note_pixels != 0 )begin    // if any note is being drawn
                        if( (hcount_in >=100) && (hcount_in <=116) )        // if A4  0
                            n_array[12] <= 1;
                        else if ((hcount_in >= 167) && (hcount_in <=200))   // if Bb4 1
                            n_array[11] <= 1;
                        else if ((hcount_in >= 233) && (hcount_in <=250))   // if B4  2
                            n_array[10] <= 1;
                        else if ((hcount_in >= 300) && (hcount_in <=320))   // if C5  3
                            n_array[9] <= 1;
                        else if ((hcount_in >= 367) && (hcount_in <=387))   // if C#5 4
                            n_array[8] <= 1;
                        else if ((hcount_in >= 433) && (hcount_in <=453))   // if D5  5
                            n_array[7] <= 1;
                        else if ((hcount_in >= 500) && (hcount_in <=520))   // if Eb5 6
                            n_array[6] <= 1;
                        else if ((hcount_in >= 567) && (hcount_in <=587))   // if E5  7
                            n_array[5] <= 1;
                        else if ((hcount_in >= 633) && (hcount_in <=653))   // if F5  8
                            n_array[4] <= 1;
                        else if ((hcount_in >= 700) && (hcount_in <=720))   // if F#5 9
                            n_array[3] <= 1;
                        else if ((hcount_in >= 767) && (hcount_in <=787))   // if G5  10
                            n_array[2] <= 1;
                        else if ((hcount_in >= 833) && (hcount_in <=853))   // if Ab5 11
                            n_array[1] <= 1;    
                        else if ((hcount_in >= 900) && (hcount_in <=920))   // if A5  12
                            n_array[0] <= 1;
                           
                    end
                end 
            end
            
            // HAND1 Movement
            if (btnu) begin
                if(hand1_counter == 200000) begin
                    hand1_x <= hand1_x + 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnl) begin
                if(hand1_counter == 200000) begin
                    hand1_x <= hand1_x - 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else begin
                hand1_counter <= 0;
            end
            
            // HAND2 Movement
            if (btnr) begin
                if(hand2_counter == 200000) begin
                    hand2_x <= hand2_x + 1;
                    hand2_counter <= 0;
                end else begin
                    hand2_counter <= hand2_counter + 1;
                end
            end else if(btnd) begin
                if(hand2_counter == 200000) begin
                    hand2_x <= hand2_x - 1;
                    hand2_counter <= 0;
                end else begin
                    hand2_counter <= hand2_counter + 1;
                end
            end else begin
                hand2_counter <= 0;
            end
            
        end
    end
endmodule
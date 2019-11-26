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
   
   logic [60:0] notes;
   logic [16:0] score;
   
   audio_gen audio1( .clk_100mhz(clk_100), .reset(reset_in), .sw(sw), .notes(notes),
                .aud_pwm(aud_pwm), .aud_sd(aud_sd)); // CHANGE running on 65MHz clock
   
   wire [11:0] digit_pixels;             
   hex_to_decimal hd(.reset(reset_in), .vcount_in(vcount_in), .hcount_in(hcount_in), .score(score),
            .clk_in(vclock_in), .digit_pixels(digit_pixels) );

   // Hands
   logic [10:0] hand1_x;     // location of hand on screen 
   logic [9:0] hand1_y;
   logic [10:0] h_x = 150;      // hand dimensions
   logic [9:0] h_y = 5;
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
   logic [3:0] song;
   logic [2:0] speed;
   assign song = sw[5:2];
   assign speed = sw[8:6];
   music_lookup muse(.beat(beat),.song(song), .clk_in(vclock_in), .music_out(music_out));
   beat_generator meter1(.reset(reset_in), .clk_in(vclock_in), .bpm(bpm), .beat(beat));
   note_generator notegen(.reset(reset_in), .clk_in(vclock_in), .hcount_in(hcount_in),.vcount_in(vcount_in),
        .beat(beat), .bpm(bpm), .music_out(music_out), .pixel(note_pixels), .testing(testing), .pixel_step(pixel_step));
        
   //assign hex_disp = {testing,2'b0, beat};     // to hex out for debugging
   assign hex_disp = score;
   
   logic [20:0] hand1_counter;
   logic [20:0] hand2_counter;
   logic [60:0] n_array;
   logic reset_score;
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
        alpha_pixel <= note_pixels | hand1_pixel | hand2_pixel | planet_pixel | digit_pixels;
        
        // MOVING HANDS
        if(reset_in) begin                      // reset values on a reset
            hand1_x <= 200; hand1_y <= 600;                    // reset hands
            hand2_x <= 720; hand2_y <= 600;
            notes <= 0;
            score <= 0;
            reset_score <= 0;
        end else begin
            // SPEED
            case(speed)
                3'd0: bpm <= 65000000;
                3'd1: bpm <= 48750000;
                3'd2: bpm <= 32500000;
                3'd3: bpm <= 16250000;
                3'd4: bpm <= 8125000;
            endcase
            // SCORE
            if( (beat == 0) && reset_score) begin
                score<= 0; reset_score <= 0;
            end else if (beat != 0) begin
                reset_score <= 1;
            end
            // AUDIO
            if((vcount_in == 1) && (hcount_in == 1)) begin      // EVERY FRAME check flags
                n_array <= 0;                                   // reset all flags
                notes <= n_array;                               // shift flags into notes being played
                if(add_to_score) begin                            // add to score based on note intersections
                    score <= score + n_array[0] + n_array[1] + n_array[2] + n_array[3] + n_array[4] 
                        + n_array[5] + n_array[6] + n_array[7] + n_array[8] + n_array[9] + n_array[10] 
                        + n_array[11] + n_array[12] + n_array[13] + n_array[14] + n_array[15] + n_array[16] 
                        + n_array[17] + n_array[18] + n_array[19] + n_array[20] + n_array[21] + n_array[22] 
                        + n_array[23] + n_array[24] + n_array[25] + n_array[26] + n_array[27] + n_array[28] 
                        + n_array[29] + n_array[30] + n_array[31] + n_array[32] + n_array[33] + n_array[34] 
                        + n_array[35] + n_array[36] + n_array[37] + n_array[38] + n_array[39] + n_array[40] 
                        + n_array[41] + n_array[42] + n_array[43] + n_array[44] + n_array[45] + n_array[46] 
                        + n_array[47] + n_array[48] + n_array[49] + n_array[50] + n_array[51] + n_array[52] 
                        + n_array[53] + n_array[54] + n_array[55] + n_array[56] + n_array[57] + n_array[58] 
                        + n_array[59] + n_array[60];
                    add_to_score <= 0;    
                end
            end else begin
                if (pixel_step) begin
                    add_to_score <= 1;
                end
                if( (hand1_pixel != 0) || (hand2_pixel != 0) ) begin        // if hand pixels are being drawn
                    if(note_pixels != 0) begin                              // if note pixels are being drawn
                        if ((hcount_in >= 200) && (hcount_in <=209)) n_array[60] <= 1;
                        else if ((hcount_in >= 250) && (hcount_in <=259)) n_array[59] <= 1;
                        else if ((hcount_in >= 300) && (hcount_in <=309)) n_array[58] <= 1;
                        else if ((hcount_in >= 350) && (hcount_in <=359)) n_array[57] <= 1;
                        else if ((hcount_in >= 400) && (hcount_in <=409)) n_array[56] <= 1;
                        else if ((hcount_in >= 450) && (hcount_in <=459)) n_array[55] <= 1;
                        else if ((hcount_in >= 500) && (hcount_in <=509)) n_array[54] <= 1;
                        else if ((hcount_in >= 550) && (hcount_in <=559)) n_array[53] <= 1;
                        else if ((hcount_in >= 600) && (hcount_in <=609)) n_array[52] <= 1;
                        else if ((hcount_in >= 650) && (hcount_in <=659)) n_array[51] <= 1;
                        else if ((hcount_in >= 700) && (hcount_in <=709)) n_array[50] <= 1;
                        else if ((hcount_in >= 750) && (hcount_in <=759)) n_array[49] <= 1;
                        else if ((hcount_in >= 210) && (hcount_in <=219)) n_array[48] <= 1;
                        else if ((hcount_in >= 260) && (hcount_in <=269)) n_array[47] <= 1;
                        else if ((hcount_in >= 310) && (hcount_in <=319)) n_array[46] <= 1;
                        else if ((hcount_in >= 360) && (hcount_in <=369)) n_array[45] <= 1;
                        else if ((hcount_in >= 410) && (hcount_in <=419)) n_array[44] <= 1;
                        else if ((hcount_in >= 460) && (hcount_in <=469)) n_array[43] <= 1;
                        else if ((hcount_in >= 510) && (hcount_in <=519)) n_array[42] <= 1;
                        else if ((hcount_in >= 560) && (hcount_in <=569)) n_array[41] <= 1;
                        else if ((hcount_in >= 610) && (hcount_in <=619)) n_array[40] <= 1;
                        else if ((hcount_in >= 660) && (hcount_in <=669)) n_array[39] <= 1;
                        else if ((hcount_in >= 710) && (hcount_in <=719)) n_array[38] <= 1;
                        else if ((hcount_in >= 760) && (hcount_in <=769)) n_array[37] <= 1;
                        else if ((hcount_in >= 220) && (hcount_in <=229)) n_array[36] <= 1;
                        else if ((hcount_in >= 270) && (hcount_in <=279)) n_array[35] <= 1;
                        else if ((hcount_in >= 320) && (hcount_in <=329)) n_array[34] <= 1;
                        else if ((hcount_in >= 370) && (hcount_in <=379)) n_array[33] <= 1;
                        else if ((hcount_in >= 420) && (hcount_in <=429)) n_array[32] <= 1;
                        else if ((hcount_in >= 470) && (hcount_in <=479)) n_array[31] <= 1;
                        else if ((hcount_in >= 520) && (hcount_in <=529)) n_array[30] <= 1;
                        else if ((hcount_in >= 570) && (hcount_in <=579)) n_array[29] <= 1;
                        else if ((hcount_in >= 620) && (hcount_in <=629)) n_array[28] <= 1;
                        else if ((hcount_in >= 670) && (hcount_in <=679)) n_array[27] <= 1;
                        else if ((hcount_in >= 720) && (hcount_in <=729)) n_array[26] <= 1;
                        else if ((hcount_in >= 770) && (hcount_in <=779)) n_array[25] <= 1;
                        else if ((hcount_in >= 230) && (hcount_in <=239)) n_array[24] <= 1;
                        else if ((hcount_in >= 280) && (hcount_in <=289)) n_array[23] <= 1;
                        else if ((hcount_in >= 330) && (hcount_in <=339)) n_array[22] <= 1;
                        else if ((hcount_in >= 380) && (hcount_in <=389)) n_array[21] <= 1;
                        else if ((hcount_in >= 430) && (hcount_in <=439)) n_array[20] <= 1;
                        else if ((hcount_in >= 480) && (hcount_in <=489)) n_array[19] <= 1;
                        else if ((hcount_in >= 530) && (hcount_in <=539)) n_array[18] <= 1;
                        else if ((hcount_in >= 580) && (hcount_in <=589)) n_array[17] <= 1;
                        else if ((hcount_in >= 630) && (hcount_in <=639)) n_array[16] <= 1;
                        else if ((hcount_in >= 680) && (hcount_in <=689)) n_array[15] <= 1;
                        else if ((hcount_in >= 730) && (hcount_in <=739)) n_array[14] <= 1;
                        else if ((hcount_in >= 780) && (hcount_in <=789)) n_array[13] <= 1;
                        else if ((hcount_in >= 240) && (hcount_in <=249)) n_array[12] <= 1;
                        else if ((hcount_in >= 290) && (hcount_in <=299)) n_array[11] <= 1;
                        else if ((hcount_in >= 340) && (hcount_in <=349)) n_array[10] <= 1;
                        else if ((hcount_in >= 390) && (hcount_in <=399)) n_array[9] <= 1;
                        else if ((hcount_in >= 440) && (hcount_in <=449)) n_array[8] <= 1;
                        else if ((hcount_in >= 490) && (hcount_in <=499)) n_array[7] <= 1;
                        else if ((hcount_in >= 540) && (hcount_in <=549)) n_array[6] <= 1;
                        else if ((hcount_in >= 590) && (hcount_in <=599)) n_array[5] <= 1;
                        else if ((hcount_in >= 640) && (hcount_in <=649)) n_array[4] <= 1;
                        else if ((hcount_in >= 690) && (hcount_in <=699)) n_array[3] <= 1;
                        else if ((hcount_in >= 740) && (hcount_in <=749)) n_array[2] <= 1;
                        else if ((hcount_in >= 790) && (hcount_in <=799)) n_array[1] <= 1;
                        else if ((hcount_in >= 800) && (hcount_in <=809)) n_array[0] <= 1;
                    end
                end 
            end
            
            // HAND1 Movement
            if (btnu) begin
                if(hand1_counter == 150000) begin
                    hand1_x <= hand1_x + 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnl) begin
                if(hand1_counter == 150000) begin
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
                if(hand2_counter == 150000) begin
                    hand2_x <= hand2_x + 1;
                    hand2_counter <= 0;
                end else begin
                    hand2_counter <= hand2_counter + 1;
                end
            end else if(btnd) begin
                if(hand2_counter == 150000) begin
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
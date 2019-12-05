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
   
   audio_gen audio1( .clk_100mhz(clk_100), .reset(reset_in), .volume(sw[15:14]), .notes(notes),
                .aud_pwm(aud_pwm), .aud_sd(aud_sd)); // CHANGE running on 65MHz clock
                
   // VOLUME BAR PIXELS
   logic [9:0] volume_height = 512-sw[15:7] + 100;
   wire [11:0] volume_bar_pixel;  // output for puck pixel from module
   blob volume(.width(30), .height(sw[15:7]), .color(12'hF00), .pixel_clk_in(vclock_in), .x_in(20),
            .y_in(volume_height),.hcount_in(hcount_in), .vcount_in(vcount_in), .pixel_out(volume_bar_pixel));
   
   // SCORE PIXELS
   logic [3:0] di1, di10, di100, di1000;          
   hex_to_decimal hd(.reset(reset_in), .score(score),.clk_in(vclock_in), 
        .di1(di1), .di10(di10), .di100(di100), .di1000(di1000) );
            
   //SCORE IMAGE
    logic [9:0] dig1x, dig10x, dig100x, dig1000x;
    logic [8:0] dig1y, dig10y, dig100y, dig1000y;
    logic [3:0] num1, num10, num100, num1000; 
    wire [11:0] dig1, dig10, dig100, dig1000;  // output for digit pixel from module
    picture_blob_digit  d1(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(vclock_in), .x_in(dig1x),.y_in(dig1y),
        .hcount_in(hcount_in),.vcount_in(vcount_in),.pixel_out(dig1),.offset(0), .digit(num1)); 
    picture_blob_digit  d10(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(vclock_in), .x_in(dig10x),.y_in(dig10y),
        .hcount_in(hcount_in),.vcount_in(vcount_in),.pixel_out(dig10),.offset(0), .digit(num10)); 
    picture_blob_digit  d100(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(vclock_in), .x_in(dig100x),.y_in(dig100y),
        .hcount_in(hcount_in),.vcount_in(vcount_in),.pixel_out(dig100),.offset(0), .digit(num100)); 
    picture_blob_digit  d1000(.WIDTH(72),.HEIGHT(77),.pixel_clk_in(vclock_in), .x_in(dig1000x),.y_in(dig1000y),
        .hcount_in(hcount_in),.vcount_in(vcount_in),.pixel_out(dig1000),.offset(0), .digit(num1000)); 
       

   // Hands
   logic [10:0] hand1_x, hand2_x;     // location of hand on screen 
   logic [9:0] hand1_y, hand2_y;
   logic [10:0] h_x = 80;      // hand dimensions
   logic [9:0] h_y = 5;
   wire [11:0] hand1_pixel, hand2_pixel;  // output for puck pixel from module
   blob hand1(.width(h_x), .height(h_y), .color(12'h00F), .pixel_clk_in(vclock_in), .x_in(hand1_x),
            .y_in(hand1_y),.hcount_in(hcount_in), .vcount_in(vcount_in), .pixel_out(hand1_pixel)); 
   
   blob hand2(.width(h_x), .height(h_y), .color(12'h0F0), .pixel_clk_in(vclock_in), .x_in(hand2_x),
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
   
   logic [6:0] beat; // up to 127 beats
   logic [6:0] old_beat; // up to 127 beats
   logic reset_beat;
   logic [26:0] bpm;
   logic [35:0] music_out;
   logic [11:0] note_pixels;
   logic [23:0] testing;
   logic pixel_step;
   logic add_to_score;
   logic [3:0] song;
   logic [2:0] speed;
   beat_generator meter1(.reset(reset_beat), .clk_in(vclock_in), .bpm(bpm), .beat(beat));
   music_lookup music(.beat(beat),.song(song), .clk_in(vclock_in), .music_out(music_out));
   note_generator notegen(.reset(reset_in), .clk_in(vclock_in), .hcount_in(hcount_in),.vcount_in(vcount_in),
        .beat(beat), .bpm(bpm), .music_out(music_out), .pixel(note_pixels), .testing(testing), .pixel_step(pixel_step));
          
   assign hex_disp = {testing,1'b0, beat};  // to hex out for debugging
   
   logic [20:0] hand1_counter;
   logic [20:0] hand2_counter;
   logic [60:0] n_array;
   logic [3:0]  game_state;
   logic [9:0] button_click_counter;
   logic [9:0] menu_array;
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
        
        // MOVING HANDS
        if( (game_state == 0) || reset_in) begin                // reset values on a reset
            hand1_x <= 400; hand1_y <= 600;                     // reset hands
            hand2_x <= 720; hand2_y <= 600;
            notes <= 0;
            score <= 0;
            game_state <= 1;
            button_click_counter <= 0;
        end else if (game_state == 1) begin
            dig1x <= 700; dig10x <= 700; dig100x <= 700; dig1000x <= 700;
            dig1y <= 50; dig10y <= 150; dig100y <= 250; dig1000y <= 350;
            num1 <= 0; num10<= 1; num100 <= 2; num1000<= 3; 
            alpha_pixel <= hand1_pixel | dig1 | dig10 | dig100 | dig1000;     // | dpixel2; //| dpixel3; //| dpixel4 | dpixel5 | dpixel6;
            reset_beat <= 1;
            
            if(button_click_counter == 120)begin
                game_state <= game_state + 1;    // goes to next menu if button is selected
                score <= 0;
                button_click_counter <= 0;
            end
            
            if(vcount_in == 1 && hcount_in == 1) begin          // counts hand button intersect time
                menu_array <= 0;
                if(menu_array[0] == 1)begin button_click_counter <= button_click_counter + 1;      song <= 0; end
                else if(menu_array[1] == 1)begin button_click_counter <= button_click_counter + 1; song <= 1; end
                else if(menu_array[2] == 1)begin button_click_counter <= button_click_counter + 1; song <= 2; end
                else if(menu_array[3] == 1)begin button_click_counter <= button_click_counter + 1; song <= 3; end
//                else if(menu_array[4] == 1)begin button_click_counter <= button_click_counter + 1; song <= 4; end
//                else if(menu_array[5] == 1)begin button_click_counter <= button_click_counter + 1; song <= 5; end
//                else if(menu_array[6] == 1)begin button_click_counter <= button_click_counter + 1; song <= 6; end
                else button_click_counter <= 0;
            end
            
            if(hand1_pixel != 0) begin          // checks for hand button intersect
                if(dig1 != 0)  menu_array[0] <= 1;
                if(dig10 != 0)  menu_array[1] <= 1;
                if(dig100 != 0)  menu_array[2] <= 1;
                if(dig1000 != 0)  menu_array[3] <= 1;
//                menu_array[3] <= (dpixel3 != 0)? 1:0;
//                menu_array[4] <= (dpixel4 != 0)? 1:0;
//                menu_array[5] <= (dpixel5 != 0)? 1:0;
//                menu_array[6] <= (dpixel6 != 0)? 1:0;
            end
            
            // HAND1 Movement
            if (btnl) begin
                if(hand1_counter == 150000) begin
                    hand1_x <= hand1_x - 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnr) begin
                if(hand1_counter == 150000) begin
                    hand1_x <= hand1_x + 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnu) begin
                if(hand1_counter == 150000) begin
                    hand1_y <= hand1_y - 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnd) begin
                if(hand1_counter == 150000) begin
                    hand1_y <= hand1_y + 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else begin
                hand1_counter <= 0;
            end
        end else if(game_state == 2) begin
            dig1x <= 850; dig10x <= 850; dig100x <= 850; dig1000x <= 850;
            dig1y <= 50; dig10y <= 150; dig100y <= 250; dig1000y <= 350;
            num1 <= 0; num10<= 1; num100 <= 2; num1000<= 3; 
            alpha_pixel <= hand1_pixel | dig1 | dig10 | dig100 | dig1000;     // | dpixel2; //| dpixel3; //| dpixel4 | dpixel5 | dpixel6;
            reset_beat <= 1;
            
            if(button_click_counter == 120)begin
                game_state <= game_state + 1;    // goes to next menu if button is selected
                hand1_x <= 200; hand1_y <= 600;  // reset hands (probably won't overlap with hand movement)
                score <= 0;
                button_click_counter <= 0;
            end
            
            if(vcount_in == 1 && hcount_in == 1) begin          // counts hand button intersect time
                menu_array <= 0;
                if(menu_array[0] == 1)begin button_click_counter <= button_click_counter + 1;      speed <= 0; end
                else if(menu_array[1] == 1)begin button_click_counter <= button_click_counter + 1; speed <= 1; end
                else if(menu_array[2] == 1)begin button_click_counter <= button_click_counter + 1; speed <= 2; end
                else if(menu_array[3] == 1)begin button_click_counter <= button_click_counter + 1; speed <= 3; end
                else button_click_counter <= 0;
            end
            
            if(hand1_pixel != 0) begin          // checks for hand button intersect
                if(dig1 != 0)  menu_array[0] <= 1;
                if(dig10 != 0)  menu_array[1] <= 1;
                if(dig100 != 0)  menu_array[2] <= 1;
                if(dig1000 != 0)  menu_array[3] <= 1;
            end
            
            // HAND1 Movement
            if (btnl) begin
                if(hand1_counter == 150000) begin
                    hand1_x <= hand1_x - 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnr) begin
                if(hand1_counter == 150000) begin
                    hand1_x <= hand1_x + 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnu) begin
                if(hand1_counter == 150000) begin
                    hand1_y <= hand1_y - 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else if(btnd) begin
                if(hand1_counter == 150000) begin
                    hand1_y <= hand1_y + 1;
                    hand1_counter <= 0;
                end else begin
                    hand1_counter <= hand1_counter + 1;
                end
            end else begin
                hand1_counter <= 0;
            end
            
        end else if(game_state == 3) begin      // SONG PLAYING
            reset_beat <= 0;    // end reset beat pulse
            // digit pixels
            dig1x <= 900; dig10x <= 830; dig100x <= 760; dig1000x <= 690;
            dig1y <= 50; dig10y <= 50; dig100y <= 50; dig1000y <= 50;
            num1 <= di1; num10<= di10; num100 <= di100; num1000<= di1000; 
            // PIXELS
            alpha_pixel <= note_pixels | hand1_pixel | hand2_pixel | volume_bar_pixel | dig1 | dig10 | dig100 | dig1000;
            // SPEED
            case(speed)
                3'd0: bpm <= 65000000;
                3'd1: bpm <= 40000000;
                3'd2: bpm <= 20000000;
                3'd3: bpm <= 10000000;
            endcase
            
            old_beat<=beat;
            if( (beat == 127) && (old_beat == 126) ) begin // GO BACK to START
                game_state <= game_state + 1;
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
        end else if (game_state == 4) begin             // GAME OVER SCREEN
            dig1x <= 570; dig10x <= 500; dig100x <= 430; dig1000x <= 360;
            dig1y <= 320; dig10y <= 320; dig100y <= 320; dig1000y <= 320;
            num1 <= di1; num10<= di10; num100 <= di100; num1000<= di1000;   // display final score
            alpha_pixel <= dig1 | dig10 | dig100 | dig1000;   // | dpixel2; //| dpixel3; //| dpixel4 | dpixel5 | dpixel6;
            reset_beat <= 1;
            
            if(button_click_counter == 300)begin
                game_state <= 0;    // goes to next menu if button is selected
                score <= 0;
            end
            
            if(vcount_in == 1 && hcount_in == 1) begin          // counts hand button intersect time
                button_click_counter <= button_click_counter + 1;
            end
        end
    end
    
endmodule
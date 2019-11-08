
`timescale 1ns / 1ps
default_nettype none;
//////////////////////////////////////////////////////////////////////////////////
//
// Updated 8/10/2019 Lab 3
// Updated 8/12/2018 V2.lab5c
// Create Date: 10/1/2019 V1.0
// Design Name: Lab 3, all significant changes in picture_blob and pong_game ########
// Module Name: labkit
//
//////////////////////////////////////////////////////////////////////////////////

module labkit(
   input clk_100mhz,
   input[15:0] sw,
   input btnc, btnu, btnl, btnr, btnd,
   output[3:0] vga_r,
   output[3:0] vga_b,
   output[3:0] vga_g,
   output vga_hs,
   output vga_vs,
   output led16_b, led16_g, led16_r,
   output led17_b, led17_g, led17_r,
   output[15:0] led,
   output ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
   output[7:0] an,    // Display location 0-7
   output logic aud_pwm,
   output logic aud_sd
   );

    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    clk_wiz_65 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));

    wire [31:0] data;      //  instantiate 7-segment display; display (8) 4-bit hex
    wire [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    display_8hex display(.clk_in(clk_65mhz),.data_in(data), .seg_out(segments), .strobe_out(an));
    //assign seg[6:0] = segments;
    assign  dp = 1'b1;  // turn off the period

//    assign led = sw;                        // turn leds on
    assign data = {28'h0123456, sw[3:0]};   // display 0123456 + sw[3:0]
    assign led16_r = btnl;                  // left button -> red led
    assign led16_g = btnc;                  // center button -> green led
    assign led16_b = btnr;                  // right button -> blue led
    assign led17_r = btnl;
    assign led17_g = btnc;
    assign led17_b = btnr;

    wire [10:0] hcount;    // pixel on current line
    wire [9:0] vcount;     // line number
    wire hsync, vsync;
    wire [11:0] pixel;
    reg [11:0] rgb;    
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));

    // btnc button is user reset
    wire reset;
    debounce db1(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnc),.clean_out(reset));
   
    // UP and DOWN buttons for pong paddle
    wire up,down;
    debounce db2(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnu),.clean_out(up));
    debounce db3(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnd),.clean_out(down));

    wire phsync,pvsync,pblank;
    pong_game pg(.vclock_in(clk_65mhz),.reset_in(reset), .btnu(btnu),.btnd(btnd),.btnr(btnr), .btnl(btnl), 
                .pspeed_in(sw[15:12]), .hcount_in(hcount),.vcount_in(vcount), .hsync_in(hsync),.vsync_in(vsync),
                .blank_in(blank),.phsync_out(phsync),.pvsync_out(pvsync),.pblank_out(pblank),.pixel_out(pixel), 
                .sw(sw), .aud_pwm(aud_pwm), .aud_sd(aud_sd), .led(led));

    wire border = (hcount==0 | hcount==1023 | vcount==0 | vcount==767 |
                   hcount == 512 | vcount == 384);

    reg b,hs,vs;
    always_ff @(posedge clk_65mhz) begin
      if (sw[1:0] == 2'b01) begin
         // 1 pixel outline of visible area (white)
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= {12{border}};
      end else if (sw[1:0] == 2'b10) begin
         // color bars
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= {{4{hcount[8]}}, {4{hcount[7]}}, {4{hcount[6]}}} ;
      end else begin
         // default: pong
         hs <= phsync;
         vs <= pvsync;
         b <= pblank;
         rgb <= pixel;
      end
    end

//    assign rgb = sw[0] ? {12{border}} : pixel ; //{{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}};

    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;
//    ila_0  myila(.clk(clk_65mhz),.probe0(hsync),.probe1(hcount),.probe2(pixel)); // instantiate ila

endmodule

////////////////////////////////////////////////////////////////////////////////
//
// Final_Project: the game itself!
//
////////////////////////////////////////////////////////////////////////////////

module pong_game (
    input vclock_in,        // 65MHz clock
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
    output reg [15:0] led
    );
        
   assign phsync_out = hsync_in;
   assign pvsync_out = vsync_in;
   assign pblank_out = blank_in;
   
   logic [12:0] notes;
   
   audio_gen audio1( .clk_100mhz(vclock_in), .reset(reset_in), .sw(sw), .notes(notes),
                .aud_pwm(aud_pwm), .aud_sd(aud_sd)); // CHANGE running on 65MHz clock

   // Hands
   logic [10:0] hand1_x;     // location of hand on screen 
   logic [9:0] hand1_y;
   logic [10:0] h_x = 70;      // hand dimensions
   logic [9:0] h_y = 30;
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
             
   // Notes
   logic [10:0] note_x1;     // x coordinate
   logic [9:0] note_y1;        // y coordinate which changes
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
             
   // RED PLANET
   wire [11:0] planet_pixel;
   blob planet1(.width(128), .height(128), .color(12'hF00), .pixel_clk_in(vclock_in),.x_in(450),.y_in(330),
                .hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(planet_pixel));
   
   parameter m = 1;             // alpha parameters
   parameter n = 1;             // power of two
   logic [11:0] alpha_pixel;    // holds shifted values after alpha blending 
   
   //assign pixel_out = paddle_pixel | alpha_pixel; // add together all pixels for the screen 
   assign pixel_out = alpha_pixel; // add together all pixels for the screen 
   logic[3:0] a;                // different segments of the alpha blending
   logic[3:0] b;
   logic[3:0] c;
   
   logic [5:0] beat;
   logic [7:0] bpm;
   logic [23:0] music_out;
   music_lookup muse(.beat(beat), .clk_in(vclock_in), .music_out(music_out));
   
   logic [25:0] counter;
   logic [20:0] hand1_counter;
   logic [20:0] hand2_counter;
   logic n1;
   logic n2;
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
        alpha_pixel <= note_pixel1 | note_pixel2 | hand1_pixel | hand2_pixel | planet_pixel;
        
        // MOVING HANDS
        if(reset_in) begin                      // reset values on a reset
            hand1_x <= 200; hand1_y <= 600;                    // reset hands
            hand2_x <= 680; hand2_y <= 600;
            note_x1 <= 300; note_y1 <= 0; note_length1 <= 150; // CHANGE could be changed later as a function of bpm and length of note
            note_x2 <= 770; note_y2 <= 0; note_length2 <= 150; // CHANGE could be changed later as a function of bpm and length of note
            bpm <= 60;                          // CHANGE later should be set in another manner
            counter <= 0;                       // initialize counter
            notes <= 0;
        end else begin
            // AUDIO
            if((vcount_in == 1) && (hcount_in == 1)) begin    // every frame check flags
                n1 <= 0;
                n2 <= 0;
                notes[12] <= n1? 1:0;
                notes[11] <= n2? 1:0;
            end else begin
                if( (hand1_pixel != 0) || (hand2_pixel != 0) ) begin        // if hand pixels are being drawn
                    if ( (note_pixel1 != 0) || (note_pixel2 != 0) )begin    // if any note is being drawn
                        if( (hcount_in >=100) && (hcount_in <=116) )        // if C  1
                            n1 <= 1;
                        else if ((hcount_in >= 167) && (hcount_in <=200))   // if C# 2
                            n2 <= 1;
                        
                    end
                end 
            end
            
            
            // move NOTES
            if (counter == 500000) begin
                counter <= 0;
                if (note_y1 >= 700) begin
                    note_y1 <= 0;
                    note_y2 <= 0;
                end else begin
                    note_y1 <= note_y1 + 1;
                    note_y2 <= note_y2 + 1;
                end
            end else begin
                counter <= counter + 1;
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


//6bit music lookup, 24bit depth
module music_lookup(input[5:0] beat, input clk_in, output logic[24:0] music_out);
  always_ff @(posedge clk_in)begin
    case(beat)
      6'd0:  music_out<=24'b000100_000000_000000_000000;
      6'd1:  music_out<=24'b001000_000000_000000_000000;
      6'd2:  music_out<=24'b001100_000000_000000_000000;
      6'd3:  music_out<=24'b010000_000000_000000_000000;
      6'd4:  music_out<=24'b010100_000000_000000_000000;
      6'd5:  music_out<=24'b011000_000000_000000_000000;
      6'd6:  music_out<=24'b011100_000000_000000_000000;
      6'd7:  music_out<=24'b100000_000000_000000_000000;
      6'd8:  music_out<=24'b100100_000000_000000_000000;
      6'd9:  music_out<=24'b101000_000000_000000_000000;
      6'd10: music_out<=24'b101100_000000_000000_000000;
      6'd11: music_out<=24'b110000_000000_000000_000000;
      6'd12: music_out<=24'b110100_000000_000000_000000;
      6'd13: music_out<=24'b000000_000000_000000_000000;
      6'd14: music_out<=24'b000000_000000_000000_000000;
      6'd15: music_out<=24'b000000_000000_000000_000000;
      6'd16: music_out<=24'b000000_000000_000000_000000;
      6'd17: music_out<=24'b000000_000000_000000_000000;
      6'd18: music_out<=24'b000000_000000_000000_000000;
      6'd19: music_out<=24'b000000_000000_000000_000000;
      6'd20: music_out<=24'b000000_000000_000000_000000;
      6'd21: music_out<=24'b000000_000000_000000_000000;
      6'd22: music_out<=24'b000000_000000_000000_000000;
      6'd23: music_out<=24'b000000_000000_000000_000000;
      6'd24: music_out<=24'b000000_000000_000000_000000;
      6'd25: music_out<=24'b000000_000000_000000_000000;
      6'd26: music_out<=24'b000000_000000_000000_000000;
      6'd27: music_out<=24'b000000_000000_000000_000000;
      6'd28: music_out<=24'b000000_000000_000000_000000;
      6'd29: music_out<=24'b000000_000000_000000_000000;
      6'd30: music_out<=24'b000000_000000_000000_000000;
      6'd31: music_out<=24'b000000_000000_000000_000000;
      6'd32: music_out<=24'b000000_000000_000000_000000;
      6'd33: music_out<=24'b000000_000000_000000_000000;
      6'd34: music_out<=24'b000000_000000_000000_000000;
      6'd35: music_out<=24'b000000_000000_000000_000000;
      6'd36: music_out<=24'b000000_000000_000000_000000;
      6'd37: music_out<=24'b000000_000000_000000_000000;
      6'd38: music_out<=24'b000000_000000_000000_000000;
      6'd39: music_out<=24'b000000_000000_000000_000000;
      6'd40: music_out<=24'b000000_000000_000000_000000;
      6'd41: music_out<=24'b000000_000000_000000_000000;
      6'd42: music_out<=24'b000000_000000_000000_000000;
      6'd43: music_out<=24'b000000_000000_000000_000000;
      6'd44: music_out<=24'b000000_000000_000000_000000;
      6'd45: music_out<=24'b000000_000000_000000_000000;
      6'd46: music_out<=24'b000000_000000_000000_000000;
      6'd47: music_out<=24'b000000_000000_000000_000000;
      6'd48: music_out<=24'b000000_000000_000000_000000;
      6'd49: music_out<=24'b000000_000000_000000_000000;
      6'd50: music_out<=24'b000000_000000_000000_000000;
      6'd51: music_out<=24'b000000_000000_000000_000000;
      6'd52: music_out<=24'b000000_000000_000000_000000;
      6'd53: music_out<=24'b000000_000000_000000_000000;
      6'd54: music_out<=24'b000000_000000_000000_000000;
      6'd55: music_out<=24'b000000_000000_000000_000000;
      6'd56: music_out<=24'b000000_000000_000000_000000;
      6'd57: music_out<=24'b000000_000000_000000_000000;
      6'd58: music_out<=24'b000000_000000_000000_000000;
      6'd59: music_out<=24'b000000_000000_000000_000000;
      6'd60: music_out<=24'b000000_000000_000000_000000;
      6'd61: music_out<=24'b000000_000000_000000_000000;
      6'd62: music_out<=24'b000000_000000_000000_000000;
      6'd63: music_out<=24'b000000_000000_000000_000000;
    endcase
  end
endmodule


//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module blob
   (input [10:0] width,
    input [9:0] height,
    input[11:0] color, 
    input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);

   always_comb begin
      if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
	 (vcount_in >= y_in && vcount_in < (y_in+height)))
	  pixel_out = color;
      else pixel_out = 0;
   end
endmodule

////////////////////////////////////////////////////
//
// picture_blob: display a picture
//
//////////////////////////////////////////////////
module picture_blob
   (input [8:0] WIDTH,        // CHANGED width and height to inputs ########
    input [8:0] HEIGHT,
    input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input [7:0] offset,       // ADDED in an offset to change PUCK size
    output logic [11:0] pixel_out);
   
   logic[9:0] w;              // static parameters of dimensions
   logic[9:0] h;
   assign w = 256;
   assign h = 240;
   logic [15:0] image_addr;   // num of bits for 256*240 ROM
   logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

   // calculate rom address and read the location
   //   assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
    
   image_rom  rom1(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   // use color map to create 4 bits R, 4 bits G, 4 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   image_rom_map rcm (.clka(pixel_clk_in), .addra({8'b00000000, image_bits}), .douta(red_mapped));
   //green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
   //blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     
     if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))) begin
          image_addr <= ((hcount_in-x_in) << offset) + ((vcount_in-y_in)<<offset) * w; // INTRODUCED left shifting ########
          // use MSB 4 bits
          pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
          //    pixel_out <= {red_mapped[7:4], 8'h0}; // only red hues
        end else begin pixel_out <= 0;
        end
   end
endmodule

//module red_coe(
//    input clka,
//    input [7:0] addra, 
//    output logic [7:0] douta);
    
//    assign douta = addra;
    
//endmodule



module synchronize #(parameter NSYNC = 3)  // number of sync flops.  must be >= 2
                   (input clk,in,
                    output reg out);

  reg [NSYNC-2:0] sync;

  always_ff @ (posedge clk)
  begin
    {out,sync} <= {sync[NSYNC-2:0],in};
  end
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Pushbutton Debounce Module (video version - 24 bits)  
//
///////////////////////////////////////////////////////////////////////////////

module debounce (input reset_in, clock_in, noisy_in,
                 output reg clean_out);

   reg [19:0] count;
   reg new_input;

   always_ff @(posedge clock_in)
     if (reset_in) begin 
        new_input <= noisy_in; 
        clean_out <= noisy_in; 
        count <= 0; end
     else if (noisy_in != new_input) begin new_input<=noisy_in; count <= 0; end
     else if (count == 1000000) clean_out <= new_input;
     else count <= count+1;


endmodule

//////////////////////////////////////////////////////////////////////////////////
// Engineer:   g.p.hom
// 
// Create Date:    18:18:59 04/21/2013 
// Module Name:    display_8hex 
// Description:  Display 8 hex numbers on 7 segment display
//
//////////////////////////////////////////////////////////////////////////////////

module display_8hex(
    input clk_in,                 // system clock
    input [31:0] data_in,         // 8 hex numbers, msb first
    output reg [6:0] seg_out,     // seven segment display output
    output reg [7:0] strobe_out   // digit strobe
    );

    localparam bits = 13;
     
    reg [bits:0] counter = 0;  // clear on power up
     
    wire [6:0] segments[15:0]; // 16 7 bit memorys
    assign segments[0]  = 7'b100_0000;  // inverted logic
    assign segments[1]  = 7'b111_1001;  // gfedcba
    assign segments[2]  = 7'b010_0100;
    assign segments[3]  = 7'b011_0000;
    assign segments[4]  = 7'b001_1001;
    assign segments[5]  = 7'b001_0010;
    assign segments[6]  = 7'b000_0010;
    assign segments[7]  = 7'b111_1000;
    assign segments[8]  = 7'b000_0000;
    assign segments[9]  = 7'b001_1000;
    assign segments[10] = 7'b000_1000;
    assign segments[11] = 7'b000_0011;
    assign segments[12] = 7'b010_0111;
    assign segments[13] = 7'b010_0001;
    assign segments[14] = 7'b000_0110;
    assign segments[15] = 7'b000_1110;
     
    always_ff @(posedge clk_in) begin
      // Here I am using a counter and select 3 bits which provides
      // a reasonable refresh rate starting the left most digit
      // and moving left.
      counter <= counter + 1;
      case (counter[bits:bits-2])
          3'b000: begin  // use the MSB 4 bits
                  seg_out <= segments[data_in[31:28]];
                  strobe_out <= 8'b0111_1111 ;
                 end

          3'b001: begin
                  seg_out <= segments[data_in[27:24]];
                  strobe_out <= 8'b1011_1111 ;
                 end

          3'b010: begin
                   seg_out <= segments[data_in[23:20]];
                   strobe_out <= 8'b1101_1111 ;
                  end
          3'b011: begin
                  seg_out <= segments[data_in[19:16]];
                  strobe_out <= 8'b1110_1111;        
                 end
          3'b100: begin
                  seg_out <= segments[data_in[15:12]];
                  strobe_out <= 8'b1111_0111;
                 end

          3'b101: begin
                  seg_out <= segments[data_in[11:8]];
                  strobe_out <= 8'b1111_1011;
                 end

          3'b110: begin
                   seg_out <= segments[data_in[7:4]];
                   strobe_out <= 8'b1111_1101;
                  end
          3'b111: begin
                  seg_out <= segments[data_in[3:0]];
                  strobe_out <= 8'b1111_1110;
                 end

       endcase
      end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Update: 8/8/2019 GH 
// Create Date: 10/02/2015 02:05:19 AM
// Module Name: xvga
//
// xvga: Generate VGA display signals (1024 x 768 @ 60Hz)
//
//                              ---- HORIZONTAL -----     ------VERTICAL -----
//                              Active                    Active
//                    Freq      Video   FP  Sync   BP      Video   FP  Sync  BP
//   640x480, 60Hz    25.175    640     16    96   48       480    11   2    31
//   800x600, 60Hz    40.000    800     40   128   88       600     1   4    23
//   1024x768, 60Hz   65.000    1024    24   136  160       768     3   6    29
//   1280x1024, 60Hz  108.00    1280    48   112  248       768     1   3    38
//   1280x720p 60Hz   75.25     1280    72    80  216       720     3   5    30
//   1920x1080 60Hz   148.5     1920    88    44  148      1080     4   5    36
//
// change the clock frequency, front porches, sync's, and back porches to create 
// other screen resolutions
////////////////////////////////////////////////////////////////////////////////

module xvga(input vclock_in,
            output reg [10:0] hcount_out,    // pixel number on current line
            output reg [9:0] vcount_out,     // line number
            output reg vsync_out, hsync_out,
            output reg blank_out);

   parameter DISPLAY_WIDTH  = 1024;      // display width
   parameter DISPLAY_HEIGHT = 768;       // number of lines

   parameter  H_FP = 24;                 // horizontal front porch
   parameter  H_SYNC_PULSE = 136;        // horizontal sync
   parameter  H_BP = 160;                // horizontal back porch

   parameter  V_FP = 3;                  // vertical front porch
   parameter  V_SYNC_PULSE = 6;          // vertical sync 
   parameter  V_BP = 29;                 // vertical back porch

   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   reg hblank,vblank;
   wire hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount_out == (DISPLAY_WIDTH -1));    
   assign hsyncon = (hcount_out == (DISPLAY_WIDTH + H_FP - 1));  //1047
   assign hsyncoff = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE - 1));  // 1183
   assign hreset = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE + H_BP - 1));  //1343

   // vertical: 806 lines total
   // display 768 lines
   wire vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount_out == (DISPLAY_HEIGHT - 1));   // 767 
   assign vsyncon = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP - 1));  // 771
   assign vsyncoff = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE - 1));  // 777
   assign vreset = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE + V_BP - 1)); // 805

   // sync and blanking
   wire next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always_ff @(posedge vclock_in) begin
      hcount_out <= hreset ? 0 : hcount_out + 1;
      hblank <= next_hblank;
      hsync_out <= hsyncon ? 0 : hsyncoff ? 1 : hsync_out;  // active low

      vcount_out <= hreset ? (vreset ? 0 : vcount_out + 1) : vcount_out;
      vblank <= next_vblank;
      vsync_out <= vsyncon ? 0 : vsyncoff ? 1 : vsync_out;  // active low

      blank_out <= next_vblank | (next_hblank & ~hreset);
   end
   
endmodule



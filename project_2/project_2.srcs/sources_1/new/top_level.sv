`timescale 1ns / 1ps
default_nettype none;

//////////////////////////////////////////////////////////////////////////////////
//
// FPGuitAr Hero
// 6.111 Final Project Fall 2019
// Sarah Spector and Alejandro Diaz
//
//////////////////////////////////////////////////////////////////////////////////

module labkit(
    input clk_100mhz,
    input [7:0] ja,
    input [2:0] jb,
    input [15:0] sw,
    input btnc, btnu, btnl, btnr, btnd,
   
    output jbclk,
    output [3:0] vga_r,
    output [3:0] vga_b,
    output [3:0] vga_g,
    output vga_hs,
    output vga_vs,
    output ca, cb, cc, cd, ce, cf, cg, dp,   // segments a-g, dp
    output [7:0] an,                         // Display location 0-7
    output logic aud_pwm,
    output logic aud_sd
    );

    //Create 65mhz system clock
    logic clk_65mhz;
    clk_wiz_65 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    //btnc button is user reset
    logic reset;
    debounce db1(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnc),.clean_out(reset));
    
    //Instantiate 7-segment display; display (8) 4-bit hex
    logic [31:0] data;      
    logic [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    display_8hex display(.clk_in(clk_65mhz),.data_in(data), .seg_out(segments), .strobe_out(an));
    assign  dp = 1'b1;  // turn off the period
    
    //VGA display setup
    logic [10:0] hcount;    // pixel on current line
    logic [9:0] vcount;     // line number
    logic hsync, vsync, blank;
    logic [11:0] pixel;
    logic [11:0] rgb;    
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    
    //IMAGE PROCESSING SARAH
        
    //Synchronize inputs
    logic [7:0] cam_pixel;
    logic cam_pclk, cam_vsync, cam_href;
    sync_8bit pix_sync(.clk(clk_65mhz),.in(ja),.out(cam_pixel));
    sync_1bit pclk_sync(.clk(clk_65mhz),.in(jb[0]),.out(cam_pclk));
    sync_1bit vsync_sync(.clk(clk_65mhz),.in(jb[1]),.out(cam_vsync));
    sync_1bit href_sync(.clk(clk_65mhz),.in(jb[2]),.out(cam_href));

    //Camera interface and image processing
    logic [9:0] x_A, y_A; //x, y coordinates of detected object; x up to 320, y up to 240
    logic [9:0] x_B, y_B;
    logic [9:0] x_C, y_C;
    logic [9:0] x_D, y_D;
    logic is_A, is_B, is_C, is_D; //binary values representing whether an object is present in the scene or not
    image_processing my_img(    .clk(clk_65mhz),.rst(reset),.pixel(cam_pixel),.pclk(cam_pclk),.vsync(cam_vsync),.href(cam_href),.xclk(jbclk),
                                .x_A_filtered(x_A),.y_A_filtered(y_A),.x_B_filtered(x_B),.y_B_filtered(y_B),
                                .x_C_filtered(x_C),.y_C_filtered(y_C),.x_D_filtered(x_D),.y_D_filtered(y_D),
                                .is_A(is_A),.is_B(is_B),.is_C(is_C),.is_D(is_D));
    
    //GAME LOGIC, GUI, AUDIO
    FPGuitAr_Hero pg(   .x_A(x_A), .y_A(y_A), .x_B(x_B), .y_B(y_B), .x_C(x_C), .y_C(y_C), .x_D(x_D), .y_D(y_D),
                        .is_A(is_A),.is_B(is_B),.is_C(is_C),.is_D(is_D),
                        .vclock_in(clk_65mhz),.reset_in(reset), .btnu(btnu),.btnd(btnd),.btnr(btnr), .btnl(btnl), 
                        .hcount_in(hcount),.vcount_in(vcount), .hsync_in(hsync),.vsync_in(vsync),
                        .blank_in(blank),.pixel_out(pixel), .hex_disp(data), 
                        .sw(sw), .aud_pwm(aud_pwm), .aud_sd(aud_sd));

    //Setup VGA Display
    reg b,hs,vs;
    always_ff @(posedge clk_65mhz) begin
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= pixel;
    end
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;
    assign vga_hs = ~hs;
    assign vga_vs = ~vs;

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
    input off,
    output logic [11:0] pixel_out);

   always_comb begin
      if (off) begin        // allows toggling of display for blobs
        pixel_out = 0;
      end else if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
	 (vcount_in >= y_in && vcount_in < (y_in+height)))
	  pixel_out = color;
      else pixel_out = 0;
   end
endmodule


//////////////////////////////////////////////////////////////////////
//
// note blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module note_blob
   (input [10:0] width,
    input [2:0] height,
    input[11:0] color, 
    input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);
            
    always_comb begin
        case(height)     // takes height for the note    
            3'd0: begin  //16th note
                if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
                (vcount_in >= y_in && vcount_in < (y_in+ 9'b000011000)))
                pixel_out = color;
                else pixel_out = 0;
            end 
            3'd1: begin // 8th note
                if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
                (vcount_in >= y_in && vcount_in < (y_in+ 9'b000110000)))
                pixel_out = color;
                else pixel_out = 0;
            end  
            3'd2: begin // 1/4th note
                if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
                (vcount_in >= y_in && vcount_in < (y_in+ 9'b001100000)))
                pixel_out = color;
                else pixel_out = 0;
            end 
            3'd3: begin // 1/2 note
                if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
                (vcount_in >= y_in && vcount_in < (y_in+9'b011000000)))
                pixel_out = color;
                else pixel_out = 0;
            end 
            3'd4: begin // whole note
                if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
                (vcount_in >= y_in && vcount_in < (y_in+9'b110000000)))
                pixel_out = color;
                else pixel_out = 0;
            end 
            3'd5: begin // dotted 8th
                if ((hcount_in >= x_in && hcount_in < (x_in+width)) &&
                (vcount_in >= y_in && vcount_in < (y_in+9'b001001000)))
                pixel_out = color;
                else pixel_out = 0;
            end 
        endcase      
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



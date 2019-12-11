`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 6.111 Final Project Fall 2019
// Engineer: Alejandro Diaz 
// 
// Create Date: 11/24/2019 03:28:38 PM
// Module Name: picture_blob
// Project Name: FPGuitarHero
// Description: Creates images on screen with coe files and also provides scaling
// to the images if specified with the offset variables
//////////////////////////////////////////////////////////////////////////////////


// DISPLAY DIGITS
module picture_blob_digit
   (input [9:0] WIDTH,        // CHANGED width and height to inputs ########
    input [8:0] HEIGHT,
    input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input [7:0] offset,       // ADDED in an offset to change PUCK size
    input [3:0] digit,
    output logic [11:0] pixel_out);
   
   logic[10:0] digit_selector;
   logic[9:0] w;              // static parameters of dimensions
   logic[9:0] h;
   assign w = 100;
   assign h = 11;
   logic [15:0] image_addr;   // num of bits for 256*240 ROM
   logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

   image_rom  rom1(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   // use color map to create 4 bits R, 4 bits G, 4 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   image_rom_map rcm (.clka(pixel_clk_in), .addra({8'b00000000, image_bits}), .douta(red_mapped));
   
   always @ (posedge pixel_clk_in) begin
     if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))) begin
          digit_selector <= digit * 10;                                     // indexes into COE
          image_addr <= (digit_selector+( (hcount_in-x_in + 2) >> offset ) ) + ((vcount_in-y_in)>>offset) * w; // INTRODUCED right shifting for scaling
          // use MSB 4 bits
          pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
        end else begin pixel_out <= 0;
        end
   end
endmodule

// DISPLAY LETTERS
module picture_blob_alph
   (input [9:0] WIDTH,        // CHANGED width and height to inputs ########
    input [8:0] HEIGHT,
    input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input [7:0] offset,       // ADDED in an offset to change PUCK size
    input [5:0] letter,
    output logic [11:0] pixel_out);
   
   logic[10:0] digit_selector;
   logic[9:0] w;              // static parameters of dimensions
   logic[9:0] h;
   assign w = 312;
   assign h = 14;
   logic [15:0] image_addr;   // num of bits for 256*240 ROM
   logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;
    
   alph_image_rom  rom1(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   // use color map to create 4 bits R, 4 bits G, 4 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   alph_map_red_rom rcm (.clka(pixel_clk_in), .addra({8'b00000000, image_bits}), .douta(red_mapped));
   
   always @ (posedge pixel_clk_in) begin
     
     if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))) begin
          digit_selector <= letter * 12;                                    // indexes into COE                                  
          image_addr <= (digit_selector+((hcount_in-x_in + 2) >> offset )) + ((vcount_in-y_in)>>offset) * w; // INTRODUCED right shifting for scaling
          // use MSB 4 bits
          pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
        end else begin pixel_out <= 0;
        end
   end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2019 03:28:38 PM
// Design Name: 
// Module Name: picture_blob
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


////////////////////////////////////////////////////
//
// picture_blob: display a picture
//
//////////////////////////////////////////////////
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
          digit_selector <= digit * 10;
          image_addr <= (digit_selector+( (hcount_in-x_in + 2) >> offset ) ) + ((vcount_in-y_in)>>offset) * w; // INTRODUCED left shifting ########
          // use MSB 4 bits
          pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
          //    pixel_out <= {red_mapped[7:4], 8'h0}; // only red hues
        end else begin pixel_out <= 0;
        end
   end
endmodule

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

   // calculate rom address and read the location
   //   assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
    
   alph_image_rom  rom1(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   // use color map to create 4 bits R, 4 bits G, 4 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   alph_map_red_rom rcm (.clka(pixel_clk_in), .addra({8'b00000000, image_bits}), .douta(red_mapped));
   //green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
   //blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     
     if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))) begin
          digit_selector <= letter * 12;
          image_addr <= (digit_selector+((hcount_in-x_in + 2) >> offset )) + ((vcount_in-y_in)>>offset) * w; // INTRODUCED left shifting ########
          // use MSB 4 bits
          pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
          //    pixel_out <= {red_mapped[7:4], 8'h0}; // only red hues
        end else begin pixel_out <= 0;
        end
   end
endmodule


module picture_blob
   (input [9:0] WIDTH,        // CHANGED width and height to inputs ########
    input [8:0] HEIGHT,
    input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input [7:0] offset,       // ADDED in an offset to change PUCK size
    output logic [11:0] pixel_out);
   
   logic[9:0] w;              // static parameters of dimensions
   logic[9:0] h;
   assign w = 724;
   assign h = 77;
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
//////////////////////////////////////////////////////////////////////////////////
//
// Camera interface and image processing module
//
// IP required:
// -blk_mem_gen_1 is a simple dual port BRAM, port A is 16 bit wide and 76800 bits deep
// -div_gen_0 is a divider, radix 2, unsigned, 16/16
// -div_gen_1 is a divider, radix 2, unsigned, 24/17
//
//////////////////////////////////////////////////////////////////////////////////

module image_processing(
    input clk, //65MHz clock
    input rst,
    input [7:0] pixel,
    input pclk,
    input vsync,
    input href,

    output xclk,
    output logic [9:0] x_A_filtered, y_A_filtered,
    output logic [9:0] x_B_filtered, y_B_filtered,
    output logic [9:0] x_C_filtered, y_C_filtered,
    output logic [9:0] x_D_filtered, y_D_filtered,
    output logic is_A, is_B, is_C, is_D
    );

    //PARAMETERS
    
    //A = blue
    parameter hue_lower_boundA = 160; //lower bound on hue values
    parameter hue_upper_boundA = 170; //upper bound on hue values
    parameter pix_thresh_A = 190; //num pixels (post-processing) to be considered valid object
    parameter decay_A = 4'd8; //for IIR filter: number between 0 (less filtering) and 16 (more filtering)
    
    //B = green
    parameter hue_lower_boundB = 70;
    parameter hue_upper_boundB = 80;
    parameter pix_thresh_B = 20;
    parameter decay_B = 4'd11;
    
    //C = red
    parameter hue_lower_boundC = 6;      
    parameter hue_upper_boundC = 12;
    parameter pix_thresh_C = 110;
    parameter decay_C = 4'd11;
    
    //D = purple
    parameter hue_lower_boundD = 185;
    parameter hue_upper_boundD = 200;
    parameter pix_thresh_D = 80;
    parameter decay_D = 4'd11;


    //CAMERA INTERFACE
    
    //send xclk to camera; 65MHz 50% duty cycle square wave
    logic [1:0] xclk_count;  
    assign xclk = (xclk_count > 2'b01);
    always_ff @(posedge clk) begin
        xclk_count <= xclk_count + 2'b01;
    end 

    //camera_read outputs
    logic [15:0] output_pixels;     
    logic valid_pixel;
    logic frame_done_out; 
    
    //read from camera                   
    camera_read  my_camera(.p_clock_in(pclk), //camera output PCLK
                          .vsync_in(vsync), //camera output VSYNC
                          .href_in(href), //camera output HREF
                          .p_data_in(pixel), //8 bit camera pixel output D[7:0]
                          .pixel_data_out(output_pixels), //interpreted pixels from camera (16 bits)
                          .pixel_valid_out(valid_pixel), //acts as BRAM write signal
                          .frame_done_out(frame_done_out)); //causes BRAM wraparound
    

    //FRAME BUFFER
    
    //Control BRAM inputs
    logic [16:0] pixel_addr_in;
    logic [11:0] frame_buff_in;
    logic valid_pixel_delay;
    always_ff @(posedge pclk) begin //pclk clock domain
        if (frame_done_out) pixel_addr_in <= 17'b0;
        else if (valid_pixel) pixel_addr_in <= pixel_addr_in + 1;
        frame_buff_in <= {output_pixels[15:12],output_pixels[10:7],output_pixels[4:1]};
        valid_pixel_delay <= valid_pixel;
    end

    logic [16:0] pixel_addr_out;
    always_ff @(posedge clk) begin //system clock domain
        if (pixel_addr_out == 76799) pixel_addr_out <= 0;
        else pixel_addr_out <= pixel_addr_out + 1;
    end
    
    //Frame buffer BRAM, latency = 2 cycles to read
    logic [11:0] frame_buff_out;
    blk_mem_gen_0 pixel_bram(   .addra(pixel_addr_in),
                                .clka(pclk),
                                .dina(frame_buff_in),
                                .wea(valid_pixel_delay),
                                .addrb(pixel_addr_out),
                                .clkb(clk),
                                .doutb(frame_buff_out));
    
    
    //RGB -> HSV CONVERSION, latency = 22
    logic [7:0] h, s, v;
    rgb2hsv my_hsv(.clock(clk),.reset(rst),.r({frame_buff_out[11:8],4'b0}),.g({frame_buff_out[7:4],4'b0}),.b({frame_buff_out[3:0],4'b0}),.h(h),.s(s),.v(v));
    
    
    //THRESHOLDING, latency = 1
    logic thresholded_A;
    logic thresholded_B;
    logic thresholded_C;
    logic thresholded_D;
    threshold thresh_A(.clk(clk),.upper_bound(hue_upper_boundA),.lower_bound(hue_lower_boundA),.thresh_in(h),.thresh_out(thresholded_A));
    threshold thresh_B(.clk(clk),.upper_bound(hue_upper_boundB),.lower_bound(hue_lower_boundB),.thresh_in(h),.thresh_out(thresholded_B));
    threshold thresh_C(.clk(clk),.upper_bound(hue_upper_boundC),.lower_bound(hue_lower_boundC),.thresh_in(h),.thresh_out(thresholded_C));
    threshold thresh_D(.clk(clk),.upper_bound(hue_upper_boundD),.lower_bound(hue_lower_boundD),.thresh_in(h),.thresh_out(thresholded_D));
    

    //EROSION, latency = 2
    logic eroded_A;
    logic eroded_B;
    logic eroded_C;
    logic eroded_D;
    erode erode_A(.clk(clk),.thresholded(thresholded_A),.eroded(eroded_A));
    erode erode_B(.clk(clk),.thresholded(thresholded_B),.eroded(eroded_B));
    erode erode_C(.clk(clk),.thresholded(thresholded_C),.eroded(eroded_C));
    erode erode_D(.clk(clk),.thresholded(thresholded_D),.eroded(eroded_D));

    
    
    //TRACK X, Y COORDS, latency = 28
    
    //Control eroded_addr; it's pixel_addr_out delayed by 27 cycles
    logic [16:0] eroded_addr;
    assign eroded_addr = (pixel_addr_out > 26) ? pixel_addr_out - 27 : pixel_addr_out - 27 + 76800;
    
    logic [8:0] x_avg_A, x_avg_B, x_avg_C, x_avg_D;
    logic [7:0] y_avg_A, y_avg_B, y_avg_C, y_avg_D;
    track #(.PIX_THRESH(pix_thresh_A)) track_A(.clk(clk),.eroded_in(eroded_A),.eroded_addr(eroded_addr),.x_avg(x_avg_A),.y_avg(y_avg_A),.is_object(is_A));
    track #(.PIX_THRESH(pix_thresh_B)) track_B(.clk(clk),.eroded_in(eroded_B),.eroded_addr(eroded_addr),.x_avg(x_avg_B),.y_avg(y_avg_B),.is_object(is_B));
    track #(.PIX_THRESH(pix_thresh_C)) track_C(.clk(clk),.eroded_in(eroded_C),.eroded_addr(eroded_addr),.x_avg(x_avg_C),.y_avg(y_avg_C),.is_object(is_C));
    track #(.PIX_THRESH(pix_thresh_D)) track_D(.clk(clk),.eroded_in(eroded_D),.eroded_addr(eroded_addr),.x_avg(x_avg_D),.y_avg(y_avg_D),.is_object(is_D));
    
    //Flip x vals over center of screen to mirror user
    logic [8:0] x_avg_A_flipped, x_avg_B_flipped, x_avg_C_flipped, x_avg_D_flipped;
    assign x_avg_A_flipped = 32'd320 - x_avg_A;
    assign x_avg_B_flipped = 32'd320 - x_avg_B;
    assign x_avg_C_flipped = 32'd320 - x_avg_C;
    assign x_avg_D_flipped = 32'd320 - x_avg_D;

    //Multiply all coords by 3 to fill screen
    logic [9:0] x_A_mult, x_B_mult, x_C_mult, x_D_mult;
    logic [9:0] y_A_mult, y_B_mult, y_C_mult, y_D_mult;
    assign x_A_mult = x_avg_A_flipped * 3;
    assign x_B_mult = x_avg_B_flipped * 3;
    assign x_C_mult = x_avg_C_flipped * 3;
    assign x_D_mult = x_avg_D_flipped * 3;
    assign y_A_mult = y_avg_A * 3;
    assign y_B_mult = y_avg_B * 3;
    assign y_C_mult = y_avg_C * 3;
    assign y_D_mult = y_avg_D * 3;
    
    //IIR FILTER, latency = 3
    iir #(.DECAY_FACTOR(decay_A)) iir_x_A(.clk(clk),.rst(rst),.in(x_A_mult),.out(x_A_filtered));
    iir #(.DECAY_FACTOR(decay_B)) iir_x_B(.clk(clk),.rst(rst),.in(x_B_mult),.out(x_B_filtered));
    iir #(.DECAY_FACTOR(decay_C)) iir_x_C(.clk(clk),.rst(rst),.in(x_C_mult),.out(x_C_filtered));
    iir #(.DECAY_FACTOR(decay_D)) iir_x_D(.clk(clk),.rst(rst),.in(x_D_mult),.out(x_D_filtered));
    iir #(.DECAY_FACTOR(decay_A)) iir_y_A(.clk(clk),.rst(rst),.in(y_A_mult),.out(y_A_filtered));
    iir #(.DECAY_FACTOR(decay_B)) iir_y_B(.clk(clk),.rst(rst),.in(y_B_mult),.out(y_B_filtered));
    iir #(.DECAY_FACTOR(decay_C)) iir_y_C(.clk(clk),.rst(rst),.in(y_C_mult),.out(y_C_filtered));
    iir #(.DECAY_FACTOR(decay_D)) iir_y_D(.clk(clk),.rst(rst),.in(y_D_mult),.out(y_D_filtered));

endmodule

//////////////////////////////////////////////////////////////////////////////////
// 
// IIR FILTER
// State machine filtering x, y coordinates with adjustable decay factor
// Latency = 3
//
//////////////////////////////////////////////////////////////////////////////////

module iir
    #(parameter DECAY_FACTOR = 4'd8)  //number between 0 (less filtering) and 16 (more filtering)
    (input clk,
    input rst,
    input [9:0] in,

    output logic [9:0] out
    );

    logic [3:0] inverse_factor = 16 - DECAY_FACTOR;
    logic [5:0] in_shifted, out_shifted;
    logic [9:0] out_reg, in_mult, out_mult;

    assign out = out_reg;

    always_ff @(posedge clk) begin
        if (rst) out_reg <= 0;
        else begin
            in_shifted <= in >> 4;
            out_shifted <= out >> 4;
            in_mult <= in_shifted * inverse_factor;
            out_mult <= out_shifted * DECAY_FACTOR;
            out_reg <= in_mult + out_mult;
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// 
// CENTROID TRACKER
// State machine outputting avg coords of eroded pixels on each frame
// Latency = 28
//
//////////////////////////////////////////////////////////////////////////////////

module track
    #(parameter PIX_THRESH = 100) //minimum number of pixels to constitute an object
    (input clk,
    input eroded_in,
    input [16:0] eroded_addr,

    output logic [8:0] x_avg,
    output logic [7:0] y_avg,
    output logic is_object
    );

    logic eroded_delay;
    logic [8:0] x_in;
    logic [7:0] y_in;
    logic [23:0] total_x;
    logic [23:0] total_y;
    logic [16:0] num_pix;
    logic [47:0] x_divider_out;
    logic [47:0] y_divider_out;
    logic [8:0] x_avg_reg;
    logic [7:0] y_avg_reg;
    logic is_object_reg;

    assign x_avg = x_avg_reg;
    assign y_avg = y_avg_reg;
    assign is_object = is_object_reg;

    //24' by 17' dividers, latency 26, output width 48 (quotient is [47:24])
    div_gen_1 x_div(
        .aclk(clk),
        .s_axis_dividend_tdata(total_x),
        .s_axis_dividend_tvalid(1'b1),
        .s_axis_divisor_tdata(num_pix),
        .s_axis_divisor_tvalid(1'b1),
        .m_axis_dout_tdata(x_divider_out)         
    );   

    div_gen_1 y_div(
        .aclk(clk),
        .s_axis_dividend_tdata(total_y),
        .s_axis_dividend_tvalid(1'b1),
        .s_axis_divisor_tdata(num_pix),
        .s_axis_divisor_tvalid(1'b1),
        .m_axis_dout_tdata(y_divider_out)         
    );

    always_ff @(posedge clk) begin
        
        eroded_delay <= eroded_in;
        
        if (eroded_addr == 0) begin //reset all vars and output new averages (will ignore last 26 pixels, whatever)
            x_in <= 0;
            y_in <= 0;
            num_pix <= 0;
            total_x <= 0;
            total_y <= 0;
            x_avg_reg <= x_divider_out[32:24]; //bottom 9 bits of quotient
            y_avg_reg <= y_divider_out[31:24]; //bottom 8 bits of quotient
            is_object_reg <= (num_pix > PIX_THRESH);
        end else begin
            
            //Cycle 1: determine x_in and y_in
            if (x_in < 319) begin
                x_in <= x_in + 1;
            end else begin
                x_in <= 0;
                y_in <= y_in + 1; //y_in will reset to 0 automatically when eroded_addr == 0
            end
            
            //Cycle 2: count current pixel in running totals
            if (eroded_delay) begin
                num_pix <= num_pix + 1;
                total_x <= total_x + x_in;
                total_y <= total_y + y_in;
            end
            
            //Cycles 3-28: compute averages (divider modules w/ latency 26)
        end
    end
    
endmodule

//////////////////////////////////////////////////////////////////////////////////
// 
// ERODER
// State machine sequentially eroding pixels (linear n=3 kernel)
// Latency = 2
//
//////////////////////////////////////////////////////////////////////////////////

module erode(
    input clk,
    input thresholded,

    output logic eroded
    );

    logic [2:0] erosion_buffer;
    always_ff @(posedge clk) begin
        erosion_buffer[0] <= thresholded;
        erosion_buffer[1] <= erosion_buffer[0];
        erosion_buffer[2] <= erosion_buffer[1];
    end
    assign eroded = (erosion_buffer[0] && erosion_buffer[1] && erosion_buffer[2]);
    
endmodule

//////////////////////////////////////////////////////////////////////////////////
// 
// HUE THRESHOLDER
// Threshold a hue value, ouputting 1 or 0 dependent on if input is within given bounds
// Accounts for bounds surrounding zero on hue scale
// Latency = 1
//
//////////////////////////////////////////////////////////////////////////////////

module threshold(
    input clk,
    input [7:0] upper_bound,
    input [7:0] lower_bound,
    input [7:0] thresh_in,
    
    output logic thresh_out
    );
    
    logic thresh_out_reg;
    assign thresh_out = thresh_out_reg;
        
    always_ff @(posedge clk) begin
        if (upper_bound >= lower_bound) begin //accepted vals don't surround 0
            if ((thresh_in <= upper_bound) && (thresh_in >= lower_bound)) begin
                thresh_out_reg <= 1;
            end else begin
                thresh_out_reg <= 0;
            end
        end else begin //accepted hue values include vals on both sides of 0
            if ((thresh_in <= upper_bound) || (thresh_in >= lower_bound)) begin
                thresh_out_reg <= 1;
            end else begin
                thresh_out_reg <= 0;
            end
        end       
    end    
    
endmodule

//////////////////////////////////////////////////////////////////////////////////
// 
// RGB to HSV converter
// by Kevin Zheng 2010
//
//////////////////////////////////////////////////////////////////////////////////

module rgb2hsv(clock, reset, r, g, b, h, s, v);
		input wire clock;
		input wire reset;
		input wire [7:0] r;
		input wire [7:0] g;
		input wire [7:0] b;
		output reg [7:0] h;
		output reg [7:0] s;
		output reg [7:0] v;
		reg [7:0] my_r_delay1, my_g_delay1, my_b_delay1;
		reg [7:0] my_r_delay2, my_g_delay2, my_b_delay2;
		reg [7:0] my_r, my_g, my_b;
		reg [7:0] min, max, delta;
		reg [15:0] s_top;
		reg [15:0] s_bottom;
		reg [15:0] h_top;
		reg [15:0] h_bottom;
		wire [15:0] s_quotient;
		wire [31:0] s_quotient_plus_remainder;
		wire [15:0] h_quotient;
		wire [31:0] h_quotient_plus_remainder;
		reg [7:0] v_delay [19:0];
		reg [18:0] h_negative;
		reg [15:0] h_add [18:0];
		reg [4:0] i;
		
		// Clocks 4-22: perform all the divisions
		// Dividers each have latency 18
        div_gen_0 s_div(
		.aclk(clock),
		.s_axis_dividend_tdata(s_top),
		.s_axis_dividend_tvalid(1'b1),
		.s_axis_divisor_tdata(s_bottom),
		.s_axis_divisor_tvalid(1'b1),
		.m_axis_dout_tdata(s_quotient_plus_remainder)         
		);   
		assign s_quotient = s_quotient_plus_remainder[31:16];                   
		
		div_gen_0 h_div(
		.aclk(clock),
		.s_axis_dividend_tdata(h_top),
		.s_axis_dividend_tvalid(1'b1),
		.s_axis_divisor_tdata(h_bottom),
		.s_axis_divisor_tvalid(1'b1),
		.m_axis_dout_tdata(h_quotient_plus_remainder) 
		);
		assign h_quotient = h_quotient_plus_remainder[31:16];

		always @ (posedge clock) begin
		
			// Clock 1: latch the inputs (always positive)
			{my_r, my_g, my_b} <= {r, g, b};
			
			// Clock 2: compute min, max
			{my_r_delay1, my_g_delay1, my_b_delay1} <= {my_r, my_g, my_b};
			
			if((my_r >= my_g) && (my_r >= my_b)) //(B,S,S)
				max <= my_r;
			else if((my_g >= my_r) && (my_g >= my_b)) //(S,B,S)
				max <= my_g;
			else	max <= my_b;
			
			if((my_r <= my_g) && (my_r <= my_b)) //(S,B,B)
				min <= my_r;
			else if((my_g <= my_r) && (my_g <= my_b)) //(B,S,B)
				min <= my_g;
			else
				min <= my_b;
				
			// Clock 3: compute the delta
			{my_r_delay2, my_g_delay2, my_b_delay2} <= {my_r_delay1, my_g_delay1, my_b_delay1};
			v_delay[0] <= max;
			delta <= max - min;
			
			// Clock 4: compute the top and bottom of whatever divisions we need to do
			s_top <= 8'd255 * delta;
			s_bottom <= (v_delay[0]>0)?{8'd0, v_delay[0]}: 16'd1;
			
			
			if(my_r_delay2 == v_delay[0]) begin
				h_top <= (my_g_delay2 >= my_b_delay2)?(my_g_delay2 - my_b_delay2) * 8'd255:(my_b_delay2 - my_g_delay2) * 8'd255;
				h_negative[0] <= (my_g_delay2 >= my_b_delay2)?0:1;
				h_add[0] <= 16'd0;
			end 
			else if(my_g_delay2 == v_delay[0]) begin
				h_top <= (my_b_delay2 >= my_r_delay2)?(my_b_delay2 - my_r_delay2) * 8'd255:(my_r_delay2 - my_b_delay2) * 8'd255;
				h_negative[0] <= (my_b_delay2 >= my_r_delay2)?0:1;
				h_add[0] <= 16'd85;
			end 
			else if(my_b_delay2 == v_delay[0]) begin
				h_top <= (my_r_delay2 >= my_g_delay2)?(my_r_delay2 - my_g_delay2) * 8'd255:(my_g_delay2 - my_r_delay2) * 8'd255;
				h_negative[0] <= (my_r_delay2 >= my_g_delay2)?0:1;
				h_add[0] <= 16'd170;
			end
			
			h_bottom <= (delta > 0)?delta * 8'd6:16'd6;
		
			
			//delay the v and h_negative signals 18 times
			for(i=1; i<19; i=i+1) begin
				v_delay[i] <= v_delay[i-1];
				h_negative[i] <= h_negative[i-1];
				h_add[i] <= h_add[i-1];
			end
		
			v_delay[19] <= v_delay[18];
			
			//Clock 22: compute the final value of h
			//depending on the value of h_delay[18], we need to subtract 255 from it to make it come back around the circle
			if(h_negative[18] && (h_quotient > h_add[18])) begin
				h <= 8'd255 - h_quotient[7:0] + h_add[18];
			end 
			else if(h_negative[18]) begin
				h <= h_add[18] - h_quotient[7:0];
			end 
			else begin
				h <= h_quotient[7:0] + h_add[18];
			end
			
			//pass out s and v straight
			s <= s_quotient;
			v <= v_delay[19];
		end
endmodule


///////////////////////////////////////////////////////////////////////////////
//
// SYNC MODULES
// 1 bit and 8 bit versions
//
///////////////////////////////////////////////////////////////////////////////

module sync_1bit(
    input clk,
    input in,
    
    output logic out
    );

    logic buff1;
    logic buff2;

    always_ff @(posedge clk) begin
        buff1 <= in;
        buff2 <= buff1;
    end

    assign out = buff2;

endmodule //sync_1bit

module sync_8bit(
    input clk,
    input [7:0] in,

    output logic [7:0] out
    );

    logic [7:0] buff1;
    logic [7:0] buff2;

    always_ff @(posedge clk) begin
        buff1 <= in;
        buff2 <= buff1;
    end

    assign out = buff2;

endmodule //sync_8bit

///////////////////////////////////////////////////////////////////////////////
//
// Camera interface module by Joe Steinmeyer  
//
///////////////////////////////////////////////////////////////////////////////

module camera_read(
	input  p_clock_in,
	input  vsync_in,
	input  href_in,
	input  [7:0] p_data_in,
	output logic [15:0] pixel_data_out,
	output logic pixel_valid_out,
	output logic frame_done_out
    );
	
	logic [1:0] FSM_state = 0;
    logic pixel_half = 0;
	
	localparam WAIT_FRAME_START = 0;
	localparam ROW_CAPTURE = 1;
	
	always_ff @(posedge p_clock_in) begin 
        case(FSM_state)

            WAIT_FRAME_START: begin //wait for VSYNC
                FSM_state <= (!vsync_in) ? ROW_CAPTURE : WAIT_FRAME_START;
                frame_done_out <= 0;
                pixel_half <= 0;
            end
            
            ROW_CAPTURE: begin 
                FSM_state <= vsync_in ? WAIT_FRAME_START : ROW_CAPTURE;
                frame_done_out <= vsync_in ? 1 : 0;
                pixel_valid_out <= (href_in && pixel_half) ? 1 : 0; 
                if (href_in) begin
                    pixel_half <= ~ pixel_half;
                    if (pixel_half) pixel_data_out[7:0] <= p_data_in;
                    else pixel_data_out[15:8] <= p_data_in;
                end
            end

        endcase
	end
	
endmodule
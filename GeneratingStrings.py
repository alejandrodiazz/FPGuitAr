# generating Strings

##string = ""
##for i in range(0, 61):
##    string = string + "d" + str(i) + " + "
##
##print(string)

### Printing Note Positions
##base = 200
##offset = 0
##for i in range(1, 62):
##    print("6'd" + str(i) + ":  x_pos <= " + str(base + 10 * offset) + ";")
##    base = base + 50 
##    if base >= 800:
##        base = 200
##        offset += 1

# Printing n_array if statements in FPGuitArHero Main
##base = 200
##offset = 0
##for i in range(1, 62):
##    string = ""
##    string = string + "else if ((hcount_in >= "
##    string = string + str(base + 10 * offset) +") && (hcount_in <="
##    string = string + str(base + 10 * offset+ 9) + ")) "
##    string = string + "n_array[" + str(61-i) + "] <= 1;"
##    print(string)
##    base = base + 50 
##    if base >= 800:
##        base = 200
##        offset += 1

# Pring a bunch of n_array to add for score
##string = ""
##for i in range(0, 61):
##    string += "n_array[" + str(i) + "] + "
##
##print(string)
##          
##

# generating empty music rows
for i in range(0, 512):
    print("9'd" + str(i) + ": music_out<= {6'd0, 3'd0, 6'd0, 3'd0, 6'd0, 3'd0, 6'd0, 3'd0};")


# generating chromatic music rows
##count = 1
##for i in range(0, 128):
##    print("7'd" + str(i) + ": music_out<= {6'd" + str(count) + ", 3'd2, 6'd0, 3'd0, 6'd0, 3'd0, 6'd0, 3'd0};")
##    count += 1
##    if count == 62:
##        count = 1

### quick printing
##string = ""
##for i in range(0, 16):
##    string = string +  "ncolor" + str(i) + ", "
##
##print(string)

### generating note_strings
##string = ""
##for i in range(32):
##    string = string + "ncolor" + str(i) + ", "
##print(string)

# print all blobs
##for i in range(32):
##    print("blob note" + str(i) + "(.width(note_width), .height(nlen" +
##          str(i) + "), .color(ncolor" + str(i) +
##          "), .pixel_clk_in(clk_in),.x_in(x" +
##          str(i) + "),.y_in(y" + str(i) +
##          "),.hcount_in(hcount_in),.vcount_in(vcount_in), .pixel_out(npixel" +
##          str(i) + "));")

##for i in range(32):
##    print("5'd" + str(i) + ": begin x" + str(i) + " <=  x_pos; y" + str(i) +
##          " <= 0; nlen" + str(i) + " <= note_length; ncolor" + str(i) +
##          " <= note_color; end")

##
##for i in range(32):
##    print( "y" + str(i) + " <= y" + str(i) + " < 770? y" + str(i) +
##           " + 1: 780;")
    
    
          



    

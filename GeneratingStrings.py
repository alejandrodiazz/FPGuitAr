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

#generating empty music rows
for i in range(0, 128):
    print("7'd" + str(i) + ": music_out<= {6'd0, 3'd0, 6'd0, 3'd0, 6'd0, 3'd0, 6'd0, 3'd0};")


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



    

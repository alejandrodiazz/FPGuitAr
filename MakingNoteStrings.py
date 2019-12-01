# MakingMusicStrings

#A1 to A6
freqs = [55.0, 58.27, 61.74, 65.41, 69.3, 73.42, 77.78, 82.41,
          87.31, 92.5, 98.0, 103.83, 110.0, 116.54, 123.47,
          130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.0,
          196.0, 207.65, 220.0, 233.08, 246.94, 261.63, 277.18,
          293.66, 311.13, 329.63, 349.23, 369.99, 392.0, 415.3,
          440.0, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25,
          659.25, 698.46, 739.99, 783.99, 830.61, 880.0, 932.33,
          987.77, 1046.5, 1108.73, 1174.66, 1244.51, 1318.51,
          1396.91, 1479.98, 1567.98, 1661.22, 1760.0]


int_freqs = [int(i) for i in freqs]
t_vars = ["t" + str(i) for i in int_freqs]

# Generating Note Frequencies

# note_names = string.split("\n")
note_names = ['A1', 'A#1/Bb1', 'B1', 'C2', 'C#2/Db2', 'D2', 'D#2/Eb2', 'E2', 'F2', 'F#2/Gb2', 'G2', ' G#2/Ab2 ', 'A2', ' A#2/Bb2 ', 'B2', 'C3', ' C#3/Db3 ', 'D3', ' D#3/Eb3 ', 'E3', 'F3', ' F#3/Gb3 ', 'G3', ' G#3/Ab3 ', 'A3', ' A#3/Bb3 ', 'B3', 'C4', ' C#4/Db4 ', 'D4', ' D#4/Eb4 ', 'E4', 'F4', ' F#4/Gb4 ', 'G4', ' G#4/Ab4 ', 'A4', ' A#4/Bb4 ', 'B4', 'C5', ' C#5/Db5 ', 'D5', ' D#5/Eb5 ', 'E5', 'F5', ' F#5/Gb5 ', 'G5', ' G#5/Ab5 ', 'A5', ' A#5/Bb5 ', 'B5', 'C6', ' C#6/Db6 ', 'D6', ' D#6/Eb6 ', 'E6', 'F6', 'F#6/Gb6 ', 'G6', ' G#6/Ab6 ', 'A6']
note_frequencies = ['55.00', '58.27', '61.74', '65.41', '69.30', '73.42', '77.78', '82.41', '87.31', '92.50', '98.00', '103.83', '110.00', '116.54', '123.47', '130.81', '138.59', '146.83', '155.56', '164.81', '174.61', '185.00', '196.00', '207.65', '220.00', '233.08', '246.94', '261.63', '277.18', '293.66', '311.13', '329.63', '349.23', '369.99', '392.00', '415.30', '440.00', '466.16', '493.88', '523.25', '554.37', '587.33', '622.25', '659.25', '698.46', '739.99', '783.99', '830.61', '880.00', '932.33', '987.77', '1046.50', '1108.73', '1174.66', '1244.51', '1318.51', '1396.91', '1479.98', '1567.98', '1661.22', '1760.00']

phases = [] # contains all phases for the 5 octaves
sample_frequency = 48000
for i in range(0, len(note_frequencies)):
    f = float(note_frequencies[i])
    phase = (f*(2**32)-1)/sample_frequency
    phases.append(int(phase))
    # print(str(note_names[i]) + ": " + str(f) + " phase: " + str(phase)) # old bad way of printing
    list_ = [ str(note_names[i]), str(f), str(round(phase))]
##    print("{: >10} {: >10} {: >12}".format(*list_)) # new good way of printing

##print(phases)
##string = ""
##for i in t_vars:
##    string = string + i + ", "
##print(string)

## print note generators 
##for i in range(61):
##    print("d" + str(i) + " <= notes[" + str(60-i) + "]?   " + t_vars[i] + ":8'b0; // send tone")

# prints out sine generators with correct phase"
for i in range(61):
    print("sine_generator #(.PHASE_INCR(" + str(32) + "'" + "d" + str(phases[i]) + "))   tone"
        + t_vars[i] + "(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(" +t_vars[i] + "));")

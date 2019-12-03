import math
import numpy as np 
from matplotlib import pyplot as plt

step = (2* math.pi)/64

def guitar_attempt(num):
    pi = math.pi
    s = math.sin
    return (s(num) + s(2*num) + s(3*num) )

values = []
sum_ = -2 * math.pi
for i in range(64):
    # values.append(math.sin(sum_))
    values.append(guitar_attempt(sum_*.9))
    sum_ += (2*math.pi)/64

original_values = values.copy()
values.reverse()
graph = values + original_values
# plt.plot(graph) 
# plt.show()

graph2 = []
for i in graph:
    graph2.append(round(i *128/2.5) + 128)


# plt.title("Graph2") 
# plt.xlabel("x axis caption") 
# plt.ylabel("y axis caption") 
# plt.plot(graph2, "ro") 
# plt.show()

print(graph2)

regular_sine = []
pi = math.pi
s = math.sin
for i in range(128):
    regular_sine.append( int(s( (pi/64)*i ) * 128 +128) )
print(regular_sine)

# plt.title("Regular Sine") 
# plt.plot(regular_sine, "ro") 
# plt.show()

for i in range(128):
    print("7'd" + str(i) + ": amp_out <= 8'd" + str(regular_sine[i]) + ";" )

for i in range(128):
    print("7'd" + str(i) + ": amp_out <= 8'd" + str(graph2[i]) + ";" )
